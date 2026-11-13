import { beforeEach, describe, expect, it } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import AiPage from './AiPage.jsx';
import {
  authenticatedState,
  english,
  errorResponse,
  jsonResponse,
  OWNER,
  renderWithProviders,
  stubFetch,
  urlOf,
} from '../test/helpers.jsx';

const SUMMARY = {
  month: '2026-11',
  enabled: true,
  configured: true,
  model: 'gpt-5.4-mini',
  budget_usd: 50,
  spend_usd: 0.012345,
  remaining_usd: 49.987655,
  calls: 3,
  failed_calls: 1,
  credits_charged: 12,
  input_tokens: 1000,
  output_tokens: 500,
  by_feature: [{ feature: 'grading', calls: 3, spend_usd: 0.012345, credits: 12 }],
};

const row = (overrides = {}) => ({
  id: 'u1',
  user: { id: 's1', name: 'سارة' },
  feature: 'grading',
  model: 'gpt-5.4-mini',
  prompt_version: 'grading-v1',
  input_tokens: 800,
  output_tokens: 200,
  cached_tokens: 0,
  cost_usd: 0.0015,
  credits_charged: 2,
  status: 'ok',
  error_code: null,
  created_at: '2026-11-11T10:00:00.000Z',
  ...overrides,
});

const usageResponse = (items = [row()]) =>
  jsonResponse({ summary: SUMMARY, items, total: items.length, limit: 50, skip: 0 });

const TEST_PASS = {
  ok: true,
  configured: true,
  enabled: true,
  model: 'gpt-5.4-mini',
  base_url: 'https://api.openai.com/v1',
  latency_ms: 120,
  code: null,
  error: null,
};

beforeEach(async () => {
  await english();
});

describe('AiPage', () => {
  it('renders the month summary and one row per AI call', async () => {
    const fetchMock = stubFetch(() => usageResponse());
    renderWithProviders(<AiPage />, { preloadedState: authenticatedState() });

    expect(await screen.findByText('سارة')).toBeInTheDocument();
    expect(screen.getAllByText('$0.012345')).toHaveLength(2);
    expect(screen.getByText('$49.987655')).toBeInTheDocument();
    expect(screen.getByText('AI on')).toBeInTheDocument();
    expect(screen.getAllByText('gpt-5.4-mini').length).toBeGreaterThan(0);
    expect(urlOf(fetchMock.mock.calls[0])).toBe('/api/v1/admin/ai/usage?limit=50&skip=0');
  });

  it('shows the self-test to the owner and reports a pass with the model', async () => {
    const fetchMock = stubFetch((url) =>
      url.endsWith('/admin/ai/test') ? jsonResponse(TEST_PASS) : usageResponse(),
    );
    renderWithProviders(<AiPage />, { preloadedState: authenticatedState() });

    await userEvent.click(await screen.findByRole('button', { name: 'Run self-test' }));

    expect(await screen.findByText('The model answered correctly.')).toBeInTheDocument();
    expect(screen.getByText('Working')).toBeInTheDocument();
    expect(screen.getByText('120 ms')).toBeInTheDocument();
    const call = fetchMock.mock.calls.find((entry) => urlOf(entry).endsWith('/admin/ai/test'));
    expect(call[1].method).toBe('POST');
  });

  it('reports a failed self-test with the cause, never a silent pass', async () => {
    stubFetch((url) =>
      url.endsWith('/admin/ai/test')
        ? jsonResponse({ ...TEST_PASS, ok: false, code: 'AI_UPSTREAM_ERROR', error: 'upstream down' })
        : usageResponse(),
    );
    renderWithProviders(<AiPage />, { preloadedState: authenticatedState() });

    await userEvent.click(await screen.findByRole('button', { name: 'Run self-test' }));

    expect(await screen.findByText('The self-test failed.')).toBeInTheDocument();
    expect(screen.getByText('AI_UPSTREAM_ERROR: upstream down')).toBeInTheDocument();
    expect(screen.getByText('Not working')).toBeInTheDocument();
  });

  it('hides the self-test from a content editor', async () => {
    stubFetch(() => usageResponse());
    renderWithProviders(<AiPage />, {
      preloadedState: authenticatedState({ ...OWNER, role: 'content_editor' }),
    });

    expect(await screen.findByText('سارة')).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Run self-test' })).not.toBeInTheDocument();
  });

  it('refetches with the chosen feature when a tab is clicked', async () => {
    const fetchMock = stubFetch(() => usageResponse([]));
    renderWithProviders(<AiPage />, { preloadedState: authenticatedState() });
    await screen.findByText('No AI calls recorded yet.');

    await userEvent.click(screen.getByRole('tab', { name: 'Generation' }));

    await waitFor(() =>
      expect(urlOf(fetchMock.mock.calls[1])).toBe('/api/v1/admin/ai/usage?feature=generation&limit=50&skip=0'),
    );
    expect(screen.getByRole('tab', { name: 'Generation' })).toHaveAttribute('aria-selected', 'true');
  });

  it('shows a failed fetch as an error with a retry, never as an empty ledger', async () => {
    let offline = true;
    const fetchMock = stubFetch(() =>
      offline ? Promise.reject(new TypeError('Failed to fetch')) : usageResponse(),
    );
    renderWithProviders(<AiPage />, { preloadedState: authenticatedState() });

    const alert = await screen.findByRole('alert');
    expect(alert).toHaveTextContent('Could not load this data');
    expect(screen.queryByText('No AI calls recorded yet.')).not.toBeInTheDocument();

    offline = false;
    await userEvent.click(screen.getByRole('button', { name: 'Try again' }));

    expect(await screen.findByText('سارة')).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });
});