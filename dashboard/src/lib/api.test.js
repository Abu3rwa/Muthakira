import { beforeEach, describe, expect, it, vi } from 'vitest';
import { api, setAuthBridge } from '../lib/api.js';
import { readSession } from '../lib/session.js';
import { errorResponse, jsonResponse, refreshResponse, signIn, stubFetch, urlOf, initOf } from '../test/helpers.jsx';

describe('api client', () => {
  let onRefreshed;
  let onExpired;

  beforeEach(() => {
    localStorage.clear();
    onRefreshed = vi.fn();
    onExpired = vi.fn();
    setAuthBridge({ onRefreshed, onExpired });
  });

  it('sends the bearer token and parses a JSON body', async () => {
    signIn();
    const fetchMock = stubFetch(() => jsonResponse({ items: [], total: 0 }));

    const result = await api.get('/admin/payments', { status: 'submitted', limit: 50, skip: 0 });

    expect(result).toEqual({ items: [], total: 0 });
    expect(urlOf(fetchMock.mock.calls[0])).toBe('/api/v1/admin/payments?status=submitted&limit=50&skip=0');
    expect(initOf(fetchMock.mock.calls[0]).headers.Authorization).toBe('Bearer access-1');
  });

  it('drops empty filters so the server never sees blank enums', async () => {
    signIn();
    const fetchMock = stubFetch(() => jsonResponse({ items: [], total: 0 }));

    await api.get('/admin/exams', { status: '', language: 'ar', subject: null, exam_year: undefined });

    expect(urlOf(fetchMock.mock.calls[0])).toBe('/api/v1/admin/exams?language=ar');
  });

  it('refreshes once on 401 and retries the original request with the new token', async () => {
    signIn();
    const fetchMock = stubFetch((url, init) => {
      if (url.endsWith('/auth/refresh')) return refreshResponse('access-2', 'refresh-2');
      if (init?.headers?.Authorization === 'Bearer access-2') return jsonResponse({ id: 'p1', status: 'approved' });
      return errorResponse(401, 'INVALID_TOKEN');
    });

    const result = await api.get('/admin/payments/p1');

    expect(result).toEqual({ id: 'p1', status: 'approved' });
    expect(fetchMock).toHaveBeenCalledTimes(3);
    expect(urlOf(fetchMock.mock.calls[1])).toBe('/api/v1/auth/refresh');
    expect(JSON.parse(initOf(fetchMock.mock.calls[1]).body)).toEqual({ refreshToken: 'refresh-1' });
    expect(initOf(fetchMock.mock.calls[2]).headers.Authorization).toBe('Bearer access-2');
    expect(readSession().accessToken).toBe('access-2');
    expect(onRefreshed).toHaveBeenCalledTimes(1);
    expect(onExpired).not.toHaveBeenCalled();
  });

  it('shares a single refresh across concurrent 401s', async () => {
    signIn();
    const fetchMock = stubFetch((url, init) => {
      if (url.endsWith('/auth/refresh')) return refreshResponse('access-2', 'refresh-2');
      if (init?.headers?.Authorization === 'Bearer access-2') return jsonResponse({ ok: true });
      return errorResponse(401, 'INVALID_TOKEN');
    });

    const [a, b] = await Promise.all([api.get('/admin/payments'), api.get('/admin/users')]);

    expect(a).toEqual({ ok: true });
    expect(b).toEqual({ ok: true });
    const refreshCalls = fetchMock.mock.calls.filter((call) => urlOf(call).endsWith('/auth/refresh'));
    expect(refreshCalls).toHaveLength(1);
  });

  it('clears the session and reports expiry when the refresh fails', async () => {
    signIn();
    const fetchMock = stubFetch((url) =>
      url.endsWith('/auth/refresh') ? errorResponse(401, 'INVALID_REFRESH_TOKEN') : errorResponse(401, 'INVALID_TOKEN'),
    );

    await expect(api.get('/admin/payments')).rejects.toMatchObject({ code: 'INVALID_REFRESH_TOKEN', status: 401 });

    expect(readSession()).toBeNull();
    expect(onExpired).toHaveBeenCalledTimes(1);
    expect(onRefreshed).not.toHaveBeenCalled();
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('expires the session when the retried request is still 401', async () => {
    signIn();
    stubFetch((url) => (url.endsWith('/auth/refresh') ? refreshResponse() : errorResponse(401, 'INVALID_TOKEN')));

    await expect(api.get('/admin/payments')).rejects.toMatchObject({ code: 'INVALID_TOKEN' });
    expect(readSession()).toBeNull();
    expect(onExpired).toHaveBeenCalledTimes(1);
  });

  it('does not attempt a refresh without a refresh token', async () => {
    const fetchMock = stubFetch(() => errorResponse(401, 'UNAUTHORIZED'));

    await expect(api.get('/admin/payments')).rejects.toMatchObject({ code: 'UNAUTHORIZED' });
    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(onExpired).not.toHaveBeenCalled();
  });

  it('surfaces the server code and validation details', async () => {
    signIn();
    stubFetch(() =>
      errorResponse(422, 'VALIDATION_ERROR', [{ path: 'reason', message: 'String must contain at least 2 character(s)' }]),
    );

    await expect(api.post('/admin/payments/p1/reject', { reason: 'x' })).rejects.toMatchObject({
      status: 422,
      code: 'VALIDATION_ERROR',
      details: [{ path: 'reason', message: 'String must contain at least 2 character(s)' }],
    });
  });

  it('maps a transport failure to NETWORK_ERROR without touching the session', async () => {
    signIn();
    stubFetch(() => {
      throw new TypeError('Failed to fetch');
    });

    await expect(api.get('/admin/payments')).rejects.toMatchObject({ status: 0, code: 'NETWORK_ERROR' });
    expect(readSession()).not.toBeNull();
    expect(onExpired).not.toHaveBeenCalled();
  });

  it('returns a blob for receipt downloads', async () => {
    signIn();
    stubFetch(() => new Response('binary', { status: 200, headers: { 'Content-Type': 'image/png' } }));

    const blob = await api.blob('/admin/receipts/r1/file');

    expect(blob.type).toBe('image/png');
    expect(await blob.text()).toBe('binary');
  });
});