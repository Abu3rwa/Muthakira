import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { addListCases, initialListState, mergeQuery, reject } from '../listState.js';

export const fetchReports = createAsyncThunk('reports/list', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/reports', mergeQuery(getState().reports, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const resolveReport = createAsyncThunk(
  'reports/resolve',
  async ({ id, status, note }, { rejectWithValue }) => {
    try {
      const body = note ? { status, note } : { status };
      return await api.post(`/admin/reports/${id}/resolve`, body);
    } catch (error) {
      return rejectWithValue(reject(error));
    }
  },
);

const reportsSlice = createSlice({
  name: 'reports',
  initialState: { ...initialListState({ status: 'open' }, 50), selected: [], saving: false, saveError: null },
  reducers: {
    toggleSelected(state, action) {
      const id = action.payload;
      state.selected = state.selected.includes(id)
        ? state.selected.filter((item) => item !== id)
        : [...state.selected, id];
    },
    selectAll(state, action) {
      state.selected = action.payload;
    },
    clearSelected(state) {
      state.selected = [];
    },
    clearReportError(state) {
      state.saveError = null;
    },
  },
  extraReducers: (builder) => {
    addListCases(builder, fetchReports);
    builder
      .addCase(resolveReport.pending, (state) => {
        state.saving = true;
        state.saveError = null;
      })
      .addCase(resolveReport.fulfilled, (state, action) => {
        state.saving = false;
        const reviewed = action.payload;
        const index = state.items.findIndex((item) => item.id === reviewed.id);
        if (reviewed.status === state.filters.status) {
          if (index >= 0) state.items[index] = { ...state.items[index], ...reviewed };
        } else {
          state.items = state.items.filter((item) => item.id !== reviewed.id);
          state.total = Math.max(0, state.total - 1);
        }
        state.selected = state.selected.filter((id) => id !== reviewed.id);
      })
      .addCase(resolveReport.rejected, (state, action) => {
        state.saving = false;
        state.saveError = action.payload;
      })
      .addMatcher(fetchReports.fulfilled.match, (state) => {
        state.selected = [];
      });
  },
});

export const { toggleSelected, selectAll, clearSelected, clearReportError } = reportsSlice.actions;
export default reportsSlice.reducer;
