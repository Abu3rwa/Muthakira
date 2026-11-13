import { buildQuery } from './query.js';
import { clearSession, readSession, writeSession } from './session.js';

export const API_BASE = import.meta.env?.VITE_API_BASE || '/api/v1';

export class ApiClientError extends Error {
  constructor({ status = 0, code = 'INTERNAL_ERROR', message = '', details = null, requestId = null }) {
    super(message || code);
    this.name = 'ApiClientError';
    this.status = status;
    this.code = code;
    this.details = details;
    this.requestId = requestId;
  }
}

export function errorPayload(error) {
  if (error instanceof ApiClientError) {
    return {
      status: error.status,
      code: error.code,
      message: error.message,
      details: error.details ?? null,
      requestId: error.requestId ?? null,
    };
  }
  return {
    status: 0,
    code: 'INTERNAL_ERROR',
    message: error?.message ?? '',
    details: null,
    requestId: null,
  };
}

let bridge = { onRefreshed: () => {}, onExpired: () => {} };

export function setAuthBridge(next) {
  bridge = { ...bridge, ...next };
}

async function toApiError(response) {
  let body = null;
  try {
    body = await response.json();
  } catch {
    body = null;
  }
  const error = body?.error ?? {};
  return new ApiClientError({
    status: response.status,
    code: error.code || 'INTERNAL_ERROR',
    message: error.message || '',
    details: error.details ?? null,
    requestId: error.request_id || response.headers.get('x-request-id'),
  });
}

function initFor(method, body, extraHeaders, signal) {
  const session = readSession();
  const headers = { Accept: 'application/json', ...extraHeaders };
  if (session?.accessToken) headers.Authorization = `Bearer ${session.accessToken}`;
  const init = { method, headers, signal };
  if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    init.body = JSON.stringify(body);
  }
  return init;
}

const send = (path, { method = 'GET', body, headers, signal } = {}) =>
  fetch(`${API_BASE}${path}`, initFor(method, body, headers, signal));

async function refreshTokens() {
  const session = readSession();
  if (!session?.refreshToken) {
    throw new ApiClientError({ status: 401, code: 'NO_SESSION', message: 'Sign in again' });
  }
  const response = await fetch(`${API_BASE}/auth/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ refreshToken: session.refreshToken }),
  });
  if (!response.ok) throw await toApiError(response);
  const data = await response.json();
  const next = {
    user: data.user ?? session.user,
    accessToken: data.tokens.access_token,
    refreshToken: data.tokens.refresh_token,
  };
  writeSession(next);
  bridge.onRefreshed(next);
  return next;
}

let refreshPromise = null;

function refreshOnce() {
  if (!refreshPromise) {
    refreshPromise = refreshTokens().finally(() => {
      refreshPromise = null;
    });
  }
  return refreshPromise;
}

function expire(error) {
  clearSession();
  bridge.onExpired(error);
  return error;
}

function transportError(error) {
  return new ApiClientError({
    status: 0,
    code: error?.name === 'AbortError' ? 'ABORTED' : 'NETWORK_ERROR',
    message: error?.message ?? '',
  });
}

export async function request(path, options = {}) {
  const { raw = false, ...rest } = options;

  let response;
  try {
    response = await send(path, rest);
  } catch (error) {
    throw transportError(error);
  }

  if (response.status === 401 && readSession()?.refreshToken) {
    try {
      await refreshOnce();
    } catch (error) {
      throw expire(error);
    }
    try {
      response = await send(path, rest);
    } catch (error) {
      throw transportError(error);
    }
    if (response.status === 401) throw expire(await toApiError(response));
  }

  if (!response.ok) throw await toApiError(response);
  if (raw) return response;
  if (response.status === 204) return null;
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}

export async function fetchBlob(path) {
  const response = await request(path, { raw: true, headers: { Accept: '*/*' } });
  return response.blob();
}

export const api = {
  get: (path, params, options) => request(`${path}${buildQuery(params)}`, { ...options, method: 'GET' }),
  post: (path, body, options) => request(path, { ...options, method: 'POST', body }),
  put: (path, body, options) => request(path, { ...options, method: 'PUT', body }),
  patch: (path, body, options) => request(path, { ...options, method: 'PATCH', body }),
  blob: fetchBlob,
};