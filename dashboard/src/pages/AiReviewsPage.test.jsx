import { beforeEach, describe, expect, it } from 'vitest';
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import AiReviewsPage from './AiReviewsPage.jsx';
import { ToastHost } from '../components/Toasts.jsx';
import {
  authenticatedState,
  english,
  jsonResponse,
  renderWithProviders,
  stubFetch,
  urlOf,
} from '../test/helpers.jsx';

const gradingRow = (overrides = {}) => ({
  id: 'r1',
  kind: 'grading',
  ref_id: 'a1',
  reason: 'Low confidence (0.4)',
  payload: {
    question_id: 'q1',
    proposed_marks: 2,
    maximum_marks: 4,
    feedback: 'Good start, but the definition is incomplete.',
    missing_points: ['definition'],
    confidence: 0.4,
  },
  status: 'pending',
  user: { id: 's1', name: 'سارة' },
  resolution_note: null,
  resolved_at: null,
  created_at: '2026-11-11T10:00:00.000Z',
  ...overrides,
});

const generationRow = (overrides = {}) => ({
  ...gradingRow(),
  id: 'r2',
  kind: 'generation',
  ref_id: 'j1',
  reason: 'Generated questions await staff review',
  payload: {
    questions: [
      {
        type: 'mcq',
        text: 'What is 2 + 2?',
        options: ['3', '4', '5', '6'],
        key: 'B',
        explanation: 'Basic addition.',
        difficulty: 2,
        topic_keys: ['math'],
      },
    ],
  },
  ...overrides,
});

const page = (items, total = items.length) => jsonResponse({ total, limit: 50, skip: 0, items });

function renderQueue() {
  return renderWithProviders(
    <>
      <AiReviewsPage />
      <ToastHost />
    </>,
    { preloadedState: authenticatedState() },
  );
}

beforeEach(async () => {
  await english();
});

describe('AiReviewsPage', () => {
  it('renders the pending queue with one row per review', async () => {
    const fetchMock = stubFetch(() => page([gradingRow(), generationRow()]));
    renderQueue();

    expect(await screen.findByText('Low confidence (0.4)')).toBeInTheDocument();
    expect(screen.getByText('Generated questions await staff review')).toBeInTheDocument();
    expect(screen.getAllByText('سارة')).toHaveLength(2);
    expect(urlOf(fetchMock.mock.calls[0])).toBe('/api/v1/admin/ai/reviews?status=pending&limit=50&skip=0');
  });

  it('approves a grading review with a note and removes it from the pending queue', async () => {
    const fetchMock = stubFetch((url) => {
      if (url.endsWith('/resolve')) return jsonResponse({ id: 'r1', kind: 'grading', status: 'approved' });
      return page([gradingRow()]);
    });
    renderQueue();

    await userEvent.click(await screen.findByText('Low confidence (0.4)'));

    const modal = await screen.findByRole('dialog');
    expect(within(modal).getByText('Good start, but the definition is incomplete.')).toBeInTheDocument();
    expect(within(modal).getByText('2 / 4')).toBeInTheDocument();
    expect(within(modal).getByText(/Approving applies these marks/)).toBeInTheDocument();

    await userEvent.type(within(modal).getByLabelText(/Note for the record/), 'checked against the rubric');
    await userEvent.click(within(modal).getByRole('button', { name: 'Approve' }));

    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument());
    const call = fetchMock.mock.calls.find((entry) => urlOf(entry).endsWith('/resolve'));
    expect(call[1].method).toBe('POST');
    expect(JSON.parse(call[1].body)).toEqual({ status: 'approved', note: 'checked against the rubric' });
    expect(await screen.findByText('No reviews in this tab.')).toBeInTheDocument();
    expect(screen.getByText('Review resolved.')).toBeInTheDocument();
  });

  it('shows generated questions with the publish warning before approving', async () => {
    stubFetch(() => page([generationRow()]));
    renderQueue();

    await userEvent.click(await screen.findByText('Generated questions await staff review'));

    const modal = await screen.findByRole('dialog');
    expect(within(modal).getByText('What is 2 + 2?')).toBeInTheDocument();
    expect(within(modal).getByText('4')).toBeInTheDocument();
    expect(within(modal).getByText(/publishes these questions as a free practice paper/)).toBeInTheDocument();
    expect(within(modal).getByRole('button', { name: 'Approve' })).toBeInTheDocument();
    expect(within(modal).getByRole('button', { name: 'Reject' })).toBeInTheDocument();
  });

  it('rejects a review without a note when none is written', async () => {
    const fetchMock = stubFetch((url) => {
      if (url.endsWith('/resolve')) return jsonResponse({ id: 'r2', kind: 'generation', status: 'rejected' });
      return page([generationRow()]);
    });
    renderQueue();

    await userEvent.click(await screen.findByText('Generated questions await staff review'));
    const modal = await screen.findByRole('dialog');
    await userEvent.click(within(modal).getByRole('button', { name: 'Reject' }));

    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument());
    const call = fetchMock.mock.calls.find((entry) => urlOf(entry).endsWith('/resolve'));
    expect(JSON.parse(call[1].body)).toEqual({ status: 'rejected' });
  });

  it('keeps the modal open with the server error when the resolve fails', async () => {
    stubFetch((url) => {
      if (url.endsWith('/resolve')) {
        return jsonResponse(
          { error: { code: 'REVIEW_NOT_PENDING', message: 'already resolved', request_id: 't' } },
          409,
        );
      }
      return page([gradingRow()]);
    });
    renderQueue();

    await userEvent.click(await screen.findByText('Low confidence (0.4)'));
    const modal = await screen.findByRole('dialog');
    await userEvent.click(within(modal).getByRole('button', { name: 'Approve' }));

    expect(await within(modal).findByText(/already been resolved/)).toBeInTheDocument();
    expect(screen.getByRole('dialog')).toBeInTheDocument();
  });

  it('shows a resolved review read-only with its resolution note', async () => {
    stubFetch(() =>
      page([
        gradingRow({
          status: 'approved',
          resolution_note: 'marks were fair',
          resolved_at: '2026-11-11T11:00:00.000Z',
        }),
      ]),
    );
    renderQueue();

    await userEvent.click(await screen.findByRole('tab', { name: /Approved/ }));
    await userEvent.click(await screen.findByText('Low confidence (0.4)'));

    const modal = await screen.findByRole('dialog');
    expect(within(modal).getByText('marks were fair')).toBeInTheDocument();
    expect(within(modal).queryByRole('button', { name: 'Approve' })).not.toBeInTheDocument();
    expect(within(modal).getAllByRole('button', { name: 'Close' }).length).toBeGreaterThan(0);
  });
});