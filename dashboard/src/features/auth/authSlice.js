import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api, errorPayload } from '../../lib/api.js';
import { clearSession, readSession, writeSession } from '../../lib/session.js';

const stored = readSession();

const initialState = {
  user: stored?.user ?? null,
  accessToken: stored?.accessToken ?? null,
  refreshToken: stored?.refreshToken ?? null,
  profile: null,
  wallet: null,
  status: stored?.accessToken ? 'restoring' : 'unauthenticated',
  pending: false,
  error: null,
  notice: null,
};

const sessionOf = (data) => ({
  user: data.user,
  accessToken: data.tokens.access_token,
  refreshToken: data.tokens.refresh_token,
});

export const login = createAsyncThunk('auth/login', async (credentials, { rejectWithValue }) => {
  try {
    const data = await api.post('/auth/login', credentials);
    // Reject before the session is stored: an authenticated non-admin would trip the route guards.
    if (data.user?.kind !== 'admin') {
      return rejectWithValue({ status: 403, code: 'STUDENT_ACCOUNT' });
    }
    const session = sessionOf(data);
    writeSession(session);
    return session;
  } catch (error) {
    return rejectWithValue(errorPayload(error));
  }
});

export const bootstrap = createAsyncThunk('auth/bootstrap', async () => {
  const session = readSession();
  if (!session?.accessToken) return { kind: 'anonymous' };
  try {
    const data = await api.get('/auth/me');
    return { kind: 'authenticated', user: data.user, profile: data.profile, wallet: data.wallet };
  } catch (error) {
    if (error.code === 'NETWORK_ERROR' || error.code === 'ABORTED') return { kind: 'offline' };
    clearSession();
    return { kind: error.status === 403 ? 'blocked' : 'anonymous' };
  }
});

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    logout(state, action) {
      clearSession();
      state.user = null;
      state.accessToken = null;
      state.refreshToken = null;
      state.profile = null;
      state.wallet = null;
      state.status = 'unauthenticated';
      state.error = null;
      state.notice = action.payload?.reason ?? null;
    },
    sessionRefreshed(state, action) {
      state.user = action.payload.user;
      state.accessToken = action.payload.accessToken;
      state.refreshToken = action.payload.refreshToken;
      state.status = 'authenticated';
    },
    clearNotice(state) {
      state.notice = null;
    },
    retryBootstrap(state) {
      state.status = 'restoring';
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.pending, (state) => {
        state.pending = true;
        state.error = null;
        state.notice = null;
      })
      .addCase(login.fulfilled, (state, action) => {
        state.pending = false;
        state.user = action.payload.user;
        state.accessToken = action.payload.accessToken;
        state.refreshToken = action.payload.refreshToken;
        state.status = 'authenticated';
      })
      .addCase(login.rejected, (state, action) => {
        state.pending = false;
        state.status = 'unauthenticated';
        state.error = action.payload ?? { code: 'INTERNAL_ERROR' };
      })
      .addCase(bootstrap.pending, (state) => {
        if (state.status !== 'authenticated') state.status = 'restoring';
      })
      .addCase(bootstrap.fulfilled, (state, action) => {
        const { kind } = action.payload;
        if (kind === 'authenticated') {
          state.user = action.payload.user;
          state.profile = action.payload.profile;
          state.wallet = action.payload.wallet;
          state.status = 'authenticated';
          state.error = null;
        } else if (kind === 'offline') {
          state.status = 'offline';
        } else {
          state.user = null;
          state.accessToken = null;
          state.refreshToken = null;
          state.status = 'unauthenticated';
          state.notice = kind === 'blocked' ? 'account_blocked' : state.notice;
        }
      });
  },
});

export const { logout, sessionRefreshed, clearNotice, retryBootstrap } = authSlice.actions;
export default authSlice.reducer;
