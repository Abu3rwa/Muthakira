import { render } from '@testing-library/react';
import { Provider } from 'react-redux';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';
import { makeStore } from '../app/store.js';
import { writeSession } from '../lib/session.js';
import i18n from '../i18n/index.js';

export const OWNER = {
  id: '000000000000000000000001',
  name: 'Owner',
  email: 'owner@example.com',
  phone: null,
  kind: 'admin',
  role: 'owner',
  status: 'active',
};

export const session = {
  user: OWNER,
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
};

export function signIn(overrides = {}) {
  const next = { ...session, ...overrides };
  writeSession(next);
  return next;
}

export function authenticatedState(user = OWNER) {
  return {
    auth: {
      user,
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      profile: null,
      wallet: null,
      status: 'authenticated',
      pending: false,
      error: null,
      notice: null,
    },
  };
}

export async function english() {
  await i18n.changeLanguage('en');
}

export function renderWithProviders(ui, { preloadedState, route = '/' } = {}) {
  const store = makeStore(preloadedState);
  const utils = render(
    <Provider store={store}>
      <MemoryRouter initialEntries={[route]}>{ui}</MemoryRouter>
    </Provider>,
  );
  return { store, ...utils };
}

export const jsonResponse = (body, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

export const errorResponse = (status, code, details = null) =>
  jsonResponse({ error: { code, message: code, details, request_id: 'test-request' } }, status);

export const refreshResponse = (accessToken = 'access-2', refreshToken = 'refresh-2', user = OWNER) =>
  jsonResponse({ user, tokens: { access_token: accessToken, refresh_token: refreshToken } });

export function stubFetch(handler) {
  const fetchMock = vi.fn(handler);
  vi.stubGlobal('fetch', fetchMock);
  return fetchMock;
}

export const urlOf = (call) => String(call[0]);
export const initOf = (call) => call[1] ?? {};