import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { addListCases, initialDetailState, initialListState, mergeQuery, patchItem, reject } from '../listState.js';

export const fetchUsers = createAsyncThunk('users/list', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/users', mergeQuery(getState().users, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const fetchUser = createAsyncThunk('users/detail', async (id, { rejectWithValue }) => {
  try {
    return await api.get(`/admin/users/${id}`);
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const blockUser = createAsyncThunk('users/block', async ({ id, reason }, { rejectWithValue }) => {
  try {
    return await api.post(`/admin/users/${id}/block`, { reason });
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const unblockUser = createAsyncThunk('users/unblock', async (id, { rejectWithValue }) => {
  try {
    return await api.post(`/admin/users/${id}/unblock`);
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

const usersSlice = createSlice({
  name: 'users',
  initialState: {
    ...initialListState({ q: '' }, 20),
    detail: { ...initialDetailState(), saving: false },
  },
  reducers: {
    resetUsers(state) {
      state.status = 'idle';
      state.items = [];
      state.total = 0;
      state.skip = 0;
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    addListCases(builder, fetchUsers);
    builder
      .addCase(fetchUser.pending, (state, action) => {
        state.detail.status = 'loading';
        state.detail.currentId = action.meta.arg;
        state.detail.error = null;
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.detail.status = 'ready';
        state.detail.byId[action.payload.user.id] = action.payload;
        state.detail.currentId = action.payload.user.id;
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.detail.status = 'error';
        state.detail.error = action.payload;
      });

    for (const thunk of [blockUser, unblockUser]) {
      builder
        .addCase(thunk.pending, (state) => {
          state.detail.saving = true;
        })
        .addCase(thunk.fulfilled, (state, action) => {
          state.detail.saving = false;
          patchItem(state, action.payload.user.id, action.payload.user);
          const detail = state.detail.byId[action.payload.user.id];
          if (detail) detail.user = { ...detail.user, ...action.payload.user };
        })
        .addCase(thunk.rejected, (state, action) => {
          state.detail.saving = false;
          state.detail.error = action.payload;
        });
    }
  },
});

export const { resetUsers } = usersSlice.actions;
export default usersSlice.reducer;
