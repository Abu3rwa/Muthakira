import { beforeEach, describe, expect, it } from 'vitest';
import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import SettingsPage from './SettingsPage.jsx';
import { ToastHost } from '../components/Toasts.jsx';
import {
  authenticatedState,
  english,
  jsonResponse,
  renderWithProviders,
  stubFetch,
  urlOf,
} from '../test/helpers.jsx';

const setting = (overrides = {}) => ({
  key: 'ai.enabled',
  value: true,
  default_value: true,
  overridden: false,
  updated_at: null,
  type: 'boolean',
  ...overrides,
});

const ITEMS = [
  setting(),
  setting({
    key: 'ai.monthly_budget_usd',
    value: 50,
    default_value: 50,
    type: 'number',
    min: 0,
    max: 100000,
  }),
  setting({
    key: 'ai.review_confidence',
    value: 0.6,
    default_value: 0.6,
    type: 'number',
    min: 0,
    max: 1,
  }),
  setting({
    key: 'credits.signup_bonus',
    value: 100,
    default_value: 100,
    type: 'integer',
    min: 0,
    max: 100000,
  }),
];

function stubSettings() {
  return stubFetch((url, init = {}) => {
    if (url.endsWith('/admin/settings/mail-status')) {
      return jsonResponse({ configured: true, ok: true, host: 'smtp.example.test', port: 587, user: 'u', from: 'f@example.test' });
    }
    if (url.endsWith('/admin/settings') && init.method === 'PUT') {
      const body = JSON.parse(init.body);
      return jsonResponse({ key: body.key, value: body.value, previous: null, updated_at: '2026-11-11T12:00:00.000Z' });
    }
    return jsonResponse({ items: ITEMS });
  });
}

function renderPage() {
  return renderWithProviders(
    <>
      <SettingsPage />
      <ToastHost />
    </>,
    { preloadedState: authenticatedState() },
  );
}

const rowOf = (control) => control.closest('.field');

beforeEach(async () => {
  await english();
});

describe('SettingsPage AI rows', () => {
  it('renders the AI group with a toggle reflecting the stored boolean', async () => {
    stubSettings();
    renderPage();

    expect(await screen.findByText('AI features')).toBeInTheDocument();
    const toggle = screen.getByLabelText('AI master switch');
    expect(toggle).toBeChecked();
    expect(within(rowOf(toggle)).getByRole('button', { name: 'Save' })).toBeDisabled();
  });

  it('saves a real boolean when the toggle is flipped', async () => {
    const fetchMock = stubSettings();
    renderPage();

    const toggle = await screen.findByLabelText('AI master switch');
    await userEvent.click(toggle);
    expect(toggle).not.toBeChecked();
    await userEvent.click(within(rowOf(toggle)).getByRole('button', { name: 'Save' }));

    expect(await screen.findByText('Setting saved.')).toBeInTheDocument();
    const call = fetchMock.mock.calls.find((entry) => (entry[1] ?? {}).method === 'PUT');
    expect(urlOf(call)).toBe('/api/v1/admin/settings');
    expect(JSON.parse(call[1].body)).toEqual({ key: 'ai.enabled', value: false });
  });

  it('saves a fractional budget as a number, not a string', async () => {
    const fetchMock = stubSettings();
    renderPage();

    const input = await screen.findByLabelText('Monthly budget (USD)');
    await userEvent.clear(input);
    await userEvent.type(input, '12.5');
    await userEvent.click(within(rowOf(input)).getByRole('button', { name: 'Save' }));

    expect(await screen.findByText('Setting saved.')).toBeInTheDocument();
    const call = fetchMock.mock.calls.find((entry) => (entry[1] ?? {}).method === 'PUT');
    expect(JSON.parse(call[1].body)).toEqual({ key: 'ai.monthly_budget_usd', value: 12.5 });
  });

  it('blocks an out-of-range confidence with a visible error', async () => {
    const fetchMock = stubSettings();
    renderPage();

    const input = await screen.findByLabelText('Human review below confidence');
    await userEvent.clear(input);
    await userEvent.type(input, '1.5');

    expect(await screen.findByText('Allowed range: 0–1')).toBeInTheDocument();
    expect(within(rowOf(input)).getByRole('button', { name: 'Save' })).toBeDisabled();
    expect(fetchMock.mock.calls.some((entry) => (entry[1] ?? {}).method === 'PUT')).toBe(false);
  });

  it('still rejects a fractional value on an integer setting', async () => {
    stubSettings();
    renderPage();

    const input = await screen.findByLabelText('Signup bonus (credits)');
    await userEvent.clear(input);
    await userEvent.type(input, '1.5');

    expect(await screen.findByText('Enter a valid number')).toBeInTheDocument();
    expect(within(rowOf(input)).getByRole('button', { name: 'Save' })).toBeDisabled();
  });
});