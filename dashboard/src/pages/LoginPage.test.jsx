import { beforeEach, describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Route, Routes } from 'react-router-dom';
import LoginPage from './LoginPage.jsx';
import { readSession } from '../lib/session.js';
import {
  OWNER,
  english,
  errorResponse,
  initOf,
  jsonResponse,
  renderWithProviders,
  stubFetch,
  urlOf,
} from '../test/helpers.jsx';

const PASSWORD = 'Mothakira#2026';

const loginResponse = (user = OWNER) =>
  jsonResponse({ user, tokens: { access_token: 'access-new', refresh_token: 'refresh-new' } });

function renderLogin(preloadedState) {
  return renderWithProviders(
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/payments" element={<p>payments landing</p>} />
      <Route path="/exams" element={<p>exams landing</p>} />
    </Routes>,
    { preloadedState, route: '/login' },
  );
}

const identifierField = () => screen.getByPlaceholderText('name@example.com');
const passwordField = () => screen.getByLabelText(/password/i);
const submitButton = () => screen.getByRole('button', { name: 'Sign in' });

async function signInWith(email, password = PASSWORD) {
  await userEvent.type(identifierField(), email);
  await userEvent.type(passwordField(), password);
  await userEvent.click(submitButton());
}

beforeEach(async () => {
  await english();
});

describe('LoginPage', () => {
  it('blocks an empty submit with field errors and never calls the API', async () => {
    const fetchMock = stubFetch(() => jsonResponse({}));
    renderLogin();

    await userEvent.click(submitButton());

    expect(screen.getByText('Enter your email address')).toBeInTheDocument();
    expect(screen.getByText('Enter the password')).toBeInTheDocument();
    expect(identifierField()).toHaveAttribute('aria-invalid', 'true');
    expect(passwordField()).toHaveAttribute('aria-invalid', 'true');
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('signs an owner in with their email and lands on the payments queue', async () => {
    const fetchMock = stubFetch(() => loginResponse());
    renderLogin();

    await signInWith('owner@example.com');

    expect(await screen.findByText('payments landing')).toBeInTheDocument();
    expect(urlOf(fetchMock.mock.calls[0])).toBe('/api/v1/auth/login');
    expect(initOf(fetchMock.mock.calls[0]).method).toBe('POST');
    expect(JSON.parse(initOf(fetchMock.mock.calls[0]).body)).toEqual({
      email: 'owner@example.com',
      password: PASSWORD,
    });
    expect(readSession()).toMatchObject({ accessToken: 'access-new', refreshToken: 'refresh-new' });
  });

  it('rejects a phone number before calling the API', async () => {
    const fetchMock = stubFetch(() => jsonResponse({}));
    renderLogin();

    await signInWith('0912345678');

    expect(screen.getByText('Enter a valid email address')).toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('refuses a student account, clears the session and stays on the login screen', async () => {
    const student = { ...OWNER, id: '00000000000000000000000b', kind: 'student', role: null };
    stubFetch(() => loginResponse(student));
    const { store } = renderLogin();

    await signInWith('student@example.com');

    expect(
      await screen.findByText('This is a student account. Use the mobile app to sign in.'),
    ).toBeInTheDocument();
    expect(screen.queryByText('payments landing')).not.toBeInTheDocument();
    expect(screen.queryByText('exams landing')).not.toBeInTheDocument();
    expect(readSession()).toBeNull();
    expect(store.getState().auth.status).toBe('unauthenticated');
  });

  it('shows the translated message for wrong credentials and keeps no session', async () => {
    stubFetch(() => errorResponse(401, 'INVALID_CREDENTIALS'));
    const { store } = renderLogin();

    await signInWith('owner@example.com', 'wrong-password');

    expect(await screen.findByText('Email or password is incorrect.')).toBeInTheDocument();
    expect(screen.queryByText('payments landing')).not.toBeInTheDocument();
    expect(readSession()).toBeNull();
    expect(store.getState().auth.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('explains a blocked account instead of showing an empty form', async () => {
    stubFetch(() => jsonResponse({}));
    renderLogin({
      auth: {
        user: null,
        accessToken: null,
        refreshToken: null,
        profile: null,
        wallet: null,
        status: 'unauthenticated',
        pending: false,
        error: null,
        notice: 'account_blocked',
      },
    });

    expect(await screen.findByText('This account is blocked. Contact the owner.')).toBeInTheDocument();
  });
});