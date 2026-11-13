import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { addListCases, initialListState, mergeQuery, reject } from '../listState.js';

export const fetchAudit = createAsyncThunk('audit/list', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/audit', mergeQuery(getState().audit, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

const auditSlice = createSlice({
  name: 'audit',
  initialState: initialListState(
    { actorUserId: '', action: '', targetType: '', targetId: '', from: '', to: '' },
    50,
  ),
  reducers: {
    resetAudit(state) {
      state.status = 'idle';
      state.items = [];
      state.total = 0;
      state.skip = 0;
      state.error = null;
    },
  },
  extraReducers: (builder) => addListCases(builder, fetchAudit),
});

export const { resetAudit } = auditSlice.actions;
export default auditSlice.reducer;
