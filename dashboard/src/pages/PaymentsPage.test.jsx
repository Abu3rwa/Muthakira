import { beforeEach, describe, expect, it } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Route, Routes } from 'react-router-dom';
import PaymentsPage from './PaymentsPage.jsx';
import {
  authenticatedState,
  english,
  jsonResponse,
  renderWithProviders,
  stubFetch,
  urlOf,
} from '../test/helpers.jsx';

const row = (overrides = {}) => ({
  id: '000000000000000000000031',
  payment_code: 'BK-0001',
  package: { name: { ar: 'حزمة ٣٠٠', en: '300 credits' }, credits: 300 },
  expected_amount_sdg: 1500,
  reference: 'TRX-99',
  status: 'submitted',
  created_at: '2026-11-01T08:00:00.000Z',
  submitted_at: '2026-11-01T09:00:00.000Z',
  ...overrides,
});

const page = (items, total = items.length) => jsonResponse({ total, limit: 50, skip: 0, items });

function renderQueue() {
  return renderWithProviders(<PaymentsPage />, { preloadedState: authenticatedState() });
}

beforeEach(async () => {
  await english();
});

describe('PaymentsPage', () => {
  it('renders the submitted queue with one row per request', async () => {
    const fetchMock = stubFetch(() =>
      page([row(), row({ id: '000000000000000000000032', payment_code: 'BK-0002', expected_amount_sdg: 3000, reference: null })]),
    );
    renderQueue();

    expect(await screen.findByText('BK-0001')).toBeInTheDocument();
    expect(screen.getByText('BK-0002')).toBeInTheDocument();
    expect(screen.getByText('1,500 SDG')).toBeInTheDocument();
    expect(screen.getByText('3,000 SDG')).toBeInTheDocument();
    expect(screen.getByText('TRX-99')).toBeInTheDocument();
    expect(screen.getByText('No reference yet')).toBeInTheDocument();
    expect(screen.getAllByRole('row')).toHaveLength(3);
    expect(urlOf(fetchMock.mock.calls[0])).toBe('/api/v1/admin/payments?status=submitted&limit=50&skip=0');
    expect(screen.queryByText('Nothing here yet')).not.toBeInTheDocument();
  });

  it('shows an empty state — not an error — when the queue has no requests', async () => {
    stubFetch(() => page([]));
    renderQueue();

    expect(await screen.findByText('No payment requests match this filter.')).toBeInTheDocument();
    expect(screen.getByText('Nothing here yet')).toBeInTheDocument();
    expect(screen.queryByRole('table')).not.toBeInTheDocument();
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
  });

  it('shows a failed fetch as an error with a retry, never as an empty queue', async () => {
    let offline = true;
    const fetchMock = stubFetch(() =>
      offline ? Promise.reject(new TypeError('Failed to fetch')) : page([row()]),
    );
    renderQueue();

    const alert = await screen.findByRole('alert');
    expect(alert).toHaveTextContent('Could not load this data');
    expect(alert).toHaveTextContent('NETWORK_ERROR');
    expect(screen.queryByText('No payment requests match this filter.')).not.toBeInTheDocument();
    expect(screen.queryByText('Nothing here yet')).not.toBeInTheDocument();
    expect(screen.queryByRole('table')).not.toBeInTheDocument();

    offline = false;
    await userEvent.click(screen.getByRole('button', { name: 'Try again' }));

    expect(await screen.findByText('BK-0001')).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
  });

  it('refetches with the chosen status when a filter tab is clicked', async () => {
    const fetchMock = stubFetch(() => page([]));
    renderQueue();
    await screen.findByText('No payment requests match this filter.');

    await userEvent.click(screen.getByRole('tab', { name: 'Approved' }));

    await waitFor(() =>
      expect(urlOf(fetchMock.mock.calls[1])).toBe('/api/v1/admin/payments?status=approved&limit=50&skip=0'),
    );
    expect(screen.getByRole('tab', { name: 'Approved' })).toHaveAttribute('aria-selected', 'true');
  });

  it('opens a request when its row is clicked', async () => {
    stubFetch(() => page([row()]));
    renderWithProviders(
      <Routes>
        <Route path="/payments" element={<PaymentsPage />} />
        <Route path="/payments/:id" element={<p>payment detail</p>} />
      </Routes>,
      { preloadedState: authenticatedState(), route: '/payments' },
    );

    await userEvent.click(await screen.findByText('BK-0001'));

    expect(await screen.findByText('payment detail')).toBeInTheDocument();
  });
});