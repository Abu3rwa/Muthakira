import { beforeEach, describe, expect, it } from 'vitest';
import { makeStore } from '../../app/store.js';
import { approvePayment, fetchPayment, fetchPayments, rejectPayment } from './paymentsSlice.js';
import { errorResponse, jsonResponse, signIn, stubFetch, urlOf } from '../../test/helpers.jsx';

const CHECKLIST = {
  amount_matches: true,
  date_recent: true,
  reference_matches: true,
  receiver_account_ours: true,
};

const row = (overrides = {}) => ({
  id: 'p1',
  status: 'submitted',
  payment_code: 'MO-000031',
  package: { id: 'pkg1', name: { ar: 'باقة', en: 'Revision' }, credits: 300, price_sdg: 14000 },
  expected_amount_sdg: 14017,
  reference: 'BK-778120',
  created_at: '2026-11-11T10:00:00.000Z',
  submitted_at: '2026-11-11T10:05:00.000Z',
  decided_at: null,
  ...overrides,
});

const detail = (overrides = {}) => ({
  ...row(),
  student: { id: 'u1', name: 'سارة', email: 'sara@example.test', phone: null },
  checklist: { amount_matches: false, date_recent: false, reference_matches: false, receiver_account_ours: false },
  receipts: [],
  ...overrides,
});

async function loadedStore() {
  const store = makeStore();
  await store.dispatch(fetchPayments({ skip: 0 }));
  await store.dispatch(fetchPayment('p1'));
  return store;
}

describe('payments slice', () => {
  beforeEach(() => {
    localStorage.clear();
    signIn();
  });

  it('loads the queue with server pagination', async () => {
    const fetchMock = stubFetch(() => jsonResponse({ items: [row()], total: 1 }));
    const store = makeStore();

    await store.dispatch(fetchPayments({ filters: { status: 'submitted' }, skip: 0 }));

    const state = store.getState().payments;
    expect(state.status).toBe('ready');
    expect(state.items).toHaveLength(1);
    expect(state.total).toBe(1);
    expect(urlOf(fetchMock.mock.calls[0])).toContain('/admin/payments?status=submitted&limit=50&skip=0');
  });

  it('marks the list and detail approved and records the granted credits', async () => {
    stubFetch((url) => {
      if (url.endsWith('/approve')) return jsonResponse({ message: 'Payment approved', request_id: 'p1', credits: 300 });
      if (url.endsWith('/admin/payments/p1')) return jsonResponse(detail());
      return jsonResponse({ items: [row()], total: 1 });
    });
    const store = await loadedStore();

    await store.dispatch(approvePayment({ id: 'p1', checklist: CHECKLIST }));

    const state = store.getState().payments;
    expect(state.items[0].status).toBe('approved');
    expect(state.items[0].decided_at).toBeTruthy();
    expect(state.detail.byId.p1.status).toBe('approved');
    expect(state.detail.byId.p1.checklist).toEqual(CHECKLIST);
    expect(state.detail.saving).toBe(false);
    expect(state.lastDecision).toEqual({ id: 'p1', status: 'approved', credits: 300 });
  });

  it('sends the checklist exactly as the reviewer ticked it', async () => {
    const fetchMock = stubFetch((url) => {
      if (url.endsWith('/approve')) return jsonResponse({ message: 'Payment approved', request_id: 'p1', credits: 300 });
      if (url.endsWith('/admin/payments/p1')) return jsonResponse(detail());
      return jsonResponse({ items: [row()], total: 1 });
    });
    const store = await loadedStore();

    await store.dispatch(approvePayment({ id: 'p1', checklist: CHECKLIST }));

    const call = fetchMock.mock.calls.find((entry) => urlOf(entry).endsWith('/approve'));
    expect(call[1].method).toBe('POST');
    expect(JSON.parse(call[1].body)).toEqual({ checklist: CHECKLIST });
  });

  it('rolls the optimistic status back when the server refuses the approval', async () => {
    stubFetch((url) => {
      if (url.endsWith('/approve')) return errorResponse(409, 'PAYMENT_NOT_REVIEWABLE');
      if (url.endsWith('/admin/payments/p1')) return jsonResponse(detail());
      return jsonResponse({ items: [row()], total: 1 });
    });
    const store = await loadedStore();

    await store.dispatch(approvePayment({ id: 'p1', checklist: CHECKLIST }));

    const state = store.getState().payments;
    expect(state.items[0].status).toBe('submitted');
    expect(state.items[0].previousStatus).toBeUndefined();
    expect(state.detail.byId.p1.status).toBe('submitted');
    expect(state.detail.saving).toBe(false);
    expect(state.detail.error.code).toBe('PAYMENT_NOT_REVIEWABLE');
    expect(state.lastDecision).toBeNull();
  });

  it('records the rejection reason on both the list row and the detail', async () => {
    const fetchMock = stubFetch((url) => {
      if (url.endsWith('/reject')) return jsonResponse({ message: 'Payment rejected', request_id: 'p1' });
      if (url.endsWith('/admin/payments/p1')) return jsonResponse(detail());
      return jsonResponse({ items: [row()], total: 1 });
    });
    const store = await loadedStore();

    await store.dispatch(rejectPayment({ id: 'p1', reason: 'المبلغ غير مطابق' }));

    const state = store.getState().payments;
    expect(state.items[0].status).toBe('rejected');
    expect(state.items[0].reject_reason).toBe('المبلغ غير مطابق');
    expect(state.detail.byId.p1.status).toBe('rejected');
    expect(state.lastDecision).toEqual({ id: 'p1', status: 'rejected', credits: null });
    const call = fetchMock.mock.calls.find((entry) => urlOf(entry).endsWith('/reject'));
    expect(JSON.parse(call[1].body)).toEqual({ reason: 'المبلغ غير مطابق' });
  });

  it('surfaces a checklist refusal from the server as a detail error', async () => {
    stubFetch((url) => {
      if (url.endsWith('/approve')) return errorResponse(422, 'CHECKLIST_INCOMPLETE');
      if (url.endsWith('/admin/payments/p1')) return jsonResponse(detail());
      return jsonResponse({ items: [row()], total: 1 });
    });
    const store = await loadedStore();

    await store.dispatch(approvePayment({ id: 'p1', checklist: { ...CHECKLIST, amount_matches: false } }));

    expect(store.getState().payments.detail.error.code).toBe('CHECKLIST_INCOMPLETE');
  });

  it('keeps a failed fetch distinguishable from an empty queue', async () => {
    stubFetch(() => errorResponse(500, 'INTERNAL_ERROR'));
    const store = makeStore();

    await store.dispatch(fetchPayments({ skip: 0 }));

    const state = store.getState().payments;
    expect(state.status).toBe('error');
    expect(state.error.code).toBe('INTERNAL_ERROR');
    expect(state.items).toEqual([]);
  });
});