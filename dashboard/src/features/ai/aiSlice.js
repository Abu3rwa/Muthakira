import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { initialListState, mergeQuery, patchItem, reject } from '../listState.js';

export const fetchAiUsage = createAsyncThunk('ai/usage', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/ai/usage', mergeQuery(getState().ai.usage, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const fetchAiReviews = createAsyncThunk('ai/reviews', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/ai/reviews', mergeQuery(getState().ai.reviews, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const resolveAiReview = createAsyncThunk(
  'ai/resolveReview',
  async ({ id, status, note }, { rejectWithValue }) => {
    try {
      const body = note ? { status, note } : { status };
      return await api.post(`/admin/ai/reviews/${id}/resolve`, body);
    } catch (error) {
      return rejectWithValue(reject(error));
    }
  },
);

export const runAiTest = createAsyncThunk('ai/test', async (_arg, { rejectWithValue }) => {
  try {
    return await api.post('/admin/ai/test');
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

function addNestedListCases(builder, thunk, key, onFulfilled) {
  builder
    .addCase(thunk.pending, (state, action) => {
      const arg = action.meta.arg ?? {};
      const list = state[key];
      list.status = 'loading';
      list.error = null;
      if (arg.filters) list.filters = { ...list.filters, ...arg.filters };
      if (arg.limit !== undefined) list.limit = arg.limit;
      if (arg.skip !== undefined) list.skip = arg.skip;
    })
    .addCase(thunk.fulfilled, (state, action) => {
      const list = state[key];
      list.status = 'ready';
      list.items = action.payload.items ?? [];
      list.total = action.payload.total ?? list.items.length;
      list.error = null;
      list.lastFetchedAt = Date.now();
      onFulfilled?.(state, action);
    })
    .addCase(thunk.rejected, (state, action) => {
      const list = state[key];
      list.status = 'error';
      list.error = action.payload ?? { code: 'INTERNAL_ERROR', message: '', status: 0 };
    });
}

const aiSlice = createSlice({
  name: 'ai',
  initialState: {
    usage: { ...initialListState({ feature: '' }, 50), summary: null },
    reviews: initialListState({ status: 'pending', kind: '' }, 50),
    saving: false,
    saveError: null,
    test: { running: false, result: null, error: null },
  },
  reducers: {
    clearAiError(state) {
      state.saveError = null;
    },
  },
  extraReducers: (builder) => {
    addNestedListCases(builder, fetchAiUsage, 'usage', (state, action) => {
      state.usage.summary = action.payload.summary ?? null;
    });
    addNestedListCases(builder, fetchAiReviews, 'reviews');
    builder
      .addCase(resolveAiReview.pending, (state) => {
        state.saving = true;
        state.saveError = null;
      })
      .addCase(resolveAiReview.fulfilled, (state, action) => {
        state.saving = false;
        const resolved = action.payload;
        const list = state.reviews;
        if (resolved.status === list.filters.status) {
          patchItem(list, resolved.id, { status: resolved.status });
        } else {
          list.items = list.items.filter((item) => item.id !== resolved.id);
          list.total = Math.max(0, list.total - 1);
        }
      })
      .addCase(resolveAiReview.rejected, (state, action) => {
        state.saving = false;
        state.saveError = action.payload;
      })
      .addCase(runAiTest.pending, (state) => {
        state.test.running = true;
        state.test.result = null;
        state.test.error = null;
      })
      .addCase(runAiTest.fulfilled, (state, action) => {
        state.test.running = false;
        state.test.result = action.payload;
      })
      .addCase(runAiTest.rejected, (state, action) => {
        state.test.running = false;
        state.test.error = action.payload;
      });
  },
});

export const { clearAiError } = aiSlice.actions;
export default aiSlice.reducer;