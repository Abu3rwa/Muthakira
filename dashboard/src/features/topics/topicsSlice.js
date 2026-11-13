import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { addListCases, initialListState, reject } from '../listState.js';

export const fetchTopics = createAsyncThunk('topics/list', async (_arg, { rejectWithValue }) => {
  try {
    return await api.get('/topics');
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const createTopic = createAsyncThunk('topics/create', async (body, { rejectWithValue }) => {
  try {
    return await api.post('/admin/topics', body);
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

const topicsSlice = createSlice({
  name: 'topics',
  initialState: { ...initialListState({}, 100), creating: false, createError: null },
  reducers: {
    clearTopicError(state) {
      state.createError = null;
    },
  },
  extraReducers: (builder) => {
    addListCases(builder, fetchTopics);
    builder
      .addCase(createTopic.pending, (state) => {
        state.creating = true;
        state.createError = null;
      })
      .addCase(createTopic.fulfilled, (state, action) => {
        state.creating = false;
        state.items = [...state.items, action.payload].sort((a, b) => a.key.localeCompare(b.key));
        state.total = state.items.length;
      })
      .addCase(createTopic.rejected, (state, action) => {
        state.creating = false;
        state.createError = action.payload;
      });
  },
});

export const { clearTopicError } = topicsSlice.actions;
export default topicsSlice.reducer;
