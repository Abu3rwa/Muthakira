import { beforeEach, describe, expect, it } from 'vitest';
import { makeStore } from '../../app/store.js';
import { bootstrap, login, logout, sessionRefreshed } from './authSlice.js';
import { readSession, writeSession } from '../../lib/session.js';
import { OWNER, errorResponse, jsonResponse, signIn, stubFetch } from '../../test/helpers.jsx';

const loginResponse = (user = OWNER) => jsonResponse({ user, tokens: { access_token: 'access-1', refresh_token: 'refresh-1' } });

describe('auth slice', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('stores the session and marks the user authenticated on login', async () => {
    const fetchMock = stubFetch(() => loginResponse());
    const store = makeStore();

    await store.dispatch(login({ email: 'owner@example.com', password: 'secret' }));

    const state = store.getState().auth;
    expect(state.status).toBe('authenticated');
    expect(state.user.role).toBe('owner');
    expect(state.accessToken).toBe('access-1');
    expect(state.error).toBeNull();
    expect(readSession()).toEqual({ user: OWNER, accessToken: 'access-1', refreshToken: 'refresh-1' });
    expect(JSON.parse(fetchMock.mock.calls[0][1].body)).toEqual({ email: 'owner@example.com', password: 'secret' });
  });

  it('keeps the translated error code when credentials are wrong', async () => {
    stubFetch(() => errorResponse(401, 'INVALID_CREDENTIALS'));
    const store = makeStore();

    await store.dispatch(login({ email: 'owner@example.com', password: 'wrong' }));

    const state = store.getState().auth;
    expect(state.status).toBe('unauthenticated');
    expect(state.error.code).toBe('INVALID_CREDENTIALS');
    expect(state.user).toBeNull();
    expect(readSession()).toBeNull();
  });

  it('refuses a student login without ever storing a session', async () => {
    const student = { ...OWNER, id: '00000000000000000000000b', kind: 'student', role: null };
    stubFetch(() => loginResponse(student));
    const store = makeStore();

    await store.dispatch(login({ email: 'owner@example.com', password: 'secret' }));

    const state = store.getState().auth;
    expect(state.status).toBe('unauthenticated');
    expect(state.error.code).toBe('STUDENT_ACCOUNT');
    expect(state.user).toBeNull();
    expect(state.accessToken).toBeNull();
    expect(readSession()).toBeNull();
  });

  it('stays anonymous when there is no stored session', async () => {
    const fetchMock = stubFetch(() => jsonResponse({}));
    const store = makeStore();

    await store.dispatch(bootstrap());

    expect(store.getState().auth.status).toBe('unauthenticated');
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('revalidates a stored session against /auth/me', async () => {
    signIn();
    const fetchMock = stubFetch(() =>
      jsonResponse({ user: OWNER, profile: { class_level: 'Grade 12' }, wallet: { available: 120 } }),
    );
    const store = makeStore();

    await store.dispatch(bootstrap());

    const state = store.getState().auth;
    expect(state.status).toBe('authenticated');
    expect(state.wallet.available).toBe(120);
    expect(String(fetchMock.mock.calls[0][0])).toBe('/api/v1/auth/me');
    expect(fetchMock.mock.calls[0][1].headers.Authorization).toBe('Bearer access-1');
  });

  it('goes offline without discarding the session when the server is unreachable', async () => {
    signIn();
    stubFetch(() => {
      throw new TypeError('Failed to fetch');
    });
    const store = makeStore();

    await store.dispatch(bootstrap());

    expect(store.getState().auth.status).toBe('offline');
    expect(readSession()).not.toBeNull();
  });

  it('clears a blocked account and records the notice', async () => {
    signIn();
    stubFetch(() => errorResponse(403, 'ACCOUNT_BLOCKED'));
    const store = makeStore();

    await store.dispatch(bootstrap());

    const state = store.getState().auth;
    expect(state.status).toBe('unauthenticated');
    expect(state.notice).toBe('account_blocked');
    expect(readSession()).toBeNull();
  });

  it('adopts rotated tokens from a silent refresh', () => {
    const store = makeStore();
    store.dispatch(sessionRefreshed({ user: OWNER, accessToken: 'access-2', refreshToken: 'refresh-2' }));

    const state = store.getState().auth;
    expect(state.accessToken).toBe('access-2');
    expect(state.status).toBe('authenticated');
  });

  it('wipes state and storage on logout and keeps the reason', () => {
    writeSession({ user: OWNER, accessToken: 'a', refreshToken: 'r' });
    const store = makeStore();

    store.dispatch(logout({ reason: 'session_expired' }));

    const state = store.getState().auth;
    expect(state.user).toBeNull();
    expect(state.accessToken).toBeNull();
    expect(state.status).toBe('unauthenticated');
    expect(state.notice).toBe('session_expired');
    expect(readSession()).toBeNull();
  });
});