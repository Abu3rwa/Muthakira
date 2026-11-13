import { beforeEach, describe, expect, it } from 'vitest';
import { makeStore } from '../../app/store.js';
import { fetchAiReviews, fetchAiUsage, resolveAiReview, runAiTest } from './aiSlice.js';
import { errorResponse, jsonResponse, signIn, stubFetch, urlOf } from '../../test/helpers.jsx';

const SUMMARY = {
  month: '2026-11',
  enabled: true,
  configured: true,
  model: 'gpt-5.4-mini',
  budget_usd: 50,
  spend_usd: 0.01,
  remaining_usd: 49.99,
  calls: 2,
  failed_calls: 0,
  credits_charged: 4,
  input_tokens: 1000,
  output_tokens: 400,
  by_feature: [{ feature: 'grading', calls: 2, spend_usd: 0.01, credits: 4 }],
};

const usageRow = (overrides = {}) => ({
  id: 'u1',
  user: { id: 's1', name: 'سارة' },
  feature: 'grading',
  model: 'gpt-5.4-mini',
  prompt_version: 'grading-v1',
  input_tokens: 800,
  output_tokens: 200,
  cached_tokens: 0,
  cost_usd: 0.005,
  credits_charged: 2,
  status: 'ok',
  error_code: null,
  created_at: '2026-11-11T10:00:00.000Z',
  ...overrides,
});

const reviewRow = (overrides = {}) => ({
  id: 'r1',
  kind: 'grading',
  ref_id: 'a1',
  reason: 'Low confidence (0.4)',
  payload: { proposed_marks: 2, maximum_marks: 4, confidence: 0.4, feedback: 'ok', missing_points: [] },
  status: 'pending',
  user: { id: 's1', name: 'سارة' },
  resolution_note: null,
  resolved_at: null,
  created_at: '2026-11-11T10:00:00.000Z',
  ...overrides,
});

describe('ai slice', () => {
  beforeEach(() => {
    localStorage.clear();
    signIn();
  });

  it('loads usage with the summary and server pagination', async () => {
    const fetchMock = stubFetch(() => jsonResponse({ summary: SUMMARY, items: [usageRow()], total: 1 }));
    const store = makeStore();

    await store.dispatch(fetchAiUsage({ skip: 0 }));

    const state = store.getState().ai.usage;
    expect(state.status).toBe('ready');
    expect(state.items).toHaveLength(1);
    expect(state.summary.model).toBe('gpt-5.4-mini');
    expect(state.summary.remaining_usd).toBe(49.99);
    expect(urlOf(fetchMock.mock.calls[0])).toContain('/admin/ai/usage?limit=50&skip=0');
  });

  it('passes the feature filter to the server', async () => {
    const fetchMock = stubFetch(() => jsonResponse({ summary: SUMMARY, items: [], total: 0 }));
    const store = makeStore();

    await store.dispatch(fetchAiUsage({ filters: { feature: 'generation' }, skip: 0 }));

    expect(urlOf(fetchMock.mock.calls[0])).toContain('/admin/ai/usage?feature=generation&limit=50&skip=0');
    expect(store.getState().ai.usage.filters.feature).toBe('generation');
  });

  it('loads the review queue filtered by status', async () => {
    const fetchMock = stubFetch(() => jsonResponse({ items: [reviewRow()], total: 1 }));
    const store = makeStore();

    await store.dispatch(fetchAiReviews({ skip: 0 }));

    const state = store.getState().ai.reviews;
    expect(state.status).toBe('ready');
    expect(state.items[0].id).toBe('r1');
    expect(urlOf(fetchMock.mock.calls[0])).toContain('/admin/ai/reviews?status=pending&limit=50&skip=0');
  });

  it('removes an approved review from the pending queue and sends the note', async () => {
    const fetchMock = stubFetch((url) => {
      if (url.endsWith('/resolve')) return jsonResponse({ id: 'r1', kind: 'grading', status: 'approved' });
      return jsonResponse({ items: [reviewRow()], total: 1 });
    });
    const store = makeStore();
    await store.dispatch(fetchAiReviews({ skip: 0 }));

    await store.dispatch(resolveAiReview({ id: 'r1', status: 'approved', note: 'checked' }));

    const state = store.getState().ai;
    expect(state.reviews.items).toHaveLength(0);
    expect(state.reviews.total).toBe(0);
    expect(state.saving).toBe(false);
    expect(state.saveError).toBeNull();
    const call = fetchMock.mock.calls.find((entry) => urlOf(entry).endsWith('/resolve'));
    expect(call[1].method).toBe('POST');
    expect(JSON.parse(call[1].body)).toEqual({ status: 'approved', note: 'checked' });
  });

  it('omits an empty note from the resolve body', async () => {
    const fetchMock = stubFetch((url) => {
      if (url.endsWith('/resolve')) return jsonResponse({ id: 'r1', kind: 'grading', status: 'rejected' });
      return jsonResponse({ items: [reviewRow()], total: 1 });
    });
    const store = makeStore();
    await store.dispatch(fetchAiReviews({ skip: 0 }));

    await store.dispatch(resolveAiReview({ id: 'r1', status: 'rejected' }));

    const call = fetchMock.mock.calls.find((entry) => urlOf(entry).endsWith('/resolve'));
    expect(JSON.parse(call[1].body)).toEqual({ status: 'rejected' });
    expect(store.getState().ai.reviews.items).toHaveLength(0);
  });

  it('keeps the review in the queue when the server refuses the resolve', async () => {
    stubFetch((url) => {
      if (url.endsWith('/resolve')) return errorResponse(409, 'REVIEW_NOT_PENDING');
      return jsonResponse({ items: [reviewRow()], total: 1 });
    });
    const store = makeStore();
    await store.dispatch(fetchAiReviews({ skip: 0 }));

    await store.dispatch(resolveAiReview({ id: 'r1', status: 'approved' }));

    const state = store.getState().ai;
    expect(state.reviews.items).toHaveLength(1);
    expect(state.reviews.total).toBe(1);
    expect(state.saving).toBe(false);
    expect(state.saveError.code).toBe('REVIEW_NOT_PENDING');
  });

  it('stores the self-test result', async () => {
    const result = { ok: true, configured: true, enabled: true, model: 'gpt-5.4-mini', base_url: 'https://api.openai.com/v1', latency_ms: 120, code: null, error: null };
    const fetchMock = stubFetch(() => jsonResponse(result));
    const store = makeStore();

    await store.dispatch(runAiTest());

    expect(store.getState().ai.test.result).toEqual(result);
    expect(store.getState().ai.test.running).toBe(false);
    const call = fetchMock.mock.calls[0];
    expect(urlOf(call)).toContain('/admin/ai/test');
    expect(call[1].method).toBe('POST');
  });

  it('keeps a failed usage fetch distinguishable from an empty ledger', async () => {
    stubFetch(() => errorResponse(500, 'INTERNAL_ERROR'));
    const store = makeStore();

    await store.dispatch(fetchAiUsage({ skip: 0 }));

    const state = store.getState().ai.usage;
    expect(state.status).toBe('error');
    expect(state.error.code).toBe('INTERNAL_ERROR');
    expect(state.items).toEqual([]);
    expect(state.summary).toBeNull();
  });
});