import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { addListCases, initialDetailState, initialListState, mergeQuery, reject } from '../listState.js';

export const fetchPayments = createAsyncThunk('payments/list', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/payments', mergeQuery(getState().payments, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const fetchPayment = createAsyncThunk('payments/detail', async (id, { rejectWithValue }) => {
  try {
    return await api.get(`/admin/payments/${id}`);
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const approvePayment = createAsyncThunk(
  'payments/approve',
  async ({ id, checklist }, { rejectWithValue }) => {
    try {
      return await api.post(`/admin/payments/${id}/approve`, { checklist });
    } catch (error) {
      return rejectWithValue(reject(error));
    }
  },
);

export const rejectPayment = createAsyncThunk('payments/reject', async ({ id, reason }, { rejectWithValue }) => {
  try {
    return await api.post(`/admin/payments/${id}/reject`, { reason });
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

const paymentsSlice = createSlice({
  name: 'payments',
  initialState: {
    ...initialListState({ status: 'submitted' }, 50),
    detail: initialDetailState(),
    lastDecision: null,
  },
  reducers: {
    resetPayments(state) {
      state.status = 'idle';
      state.items = [];
      state.total = 0;
      state.skip = 0;
      state.error = null;
    },
    clearDecision(state) {
      state.lastDecision = null;
    },
  },
  extraReducers: (builder) => {
    addListCases(builder, fetchPayments);
    builder
      .addCase(fetchPayment.pending, (state, action) => {
        state.detail.status = 'loading';
        state.detail.currentId = action.meta.arg;
        state.detail.error = null;
      })
      .addCase(fetchPayment.fulfilled, (state, action) => {
        state.detail.status = 'ready';
        state.detail.byId[action.payload.id] = action.payload;
        state.detail.currentId = action.payload.id;
      })
      .addCase(fetchPayment.rejected, (state, action) => {
        state.detail.status = 'error';
        state.detail.error = action.payload;
      })
      .addCase(approvePayment.pending, (state, action) => {
        state.detail.saving = true;
        state.detail.error = null;
        const item = state.items.find((row) => row.id === action.meta.arg.id);
        if (item) {
          item.previousStatus = item.status;
          item.status = 'under_review';
        }
      })
      // Approve answers { message, request_id, credits } — not the request document.
      .addCase(approvePayment.fulfilled, (state, action) => {
        const id = action.meta.arg.id;
        const decidedAt = new Date().toISOString();
        state.detail.saving = false;
        state.lastDecision = { id, status: 'approved', credits: action.payload.credits ?? null };
        const detail = state.detail.byId[id];
        if (detail) {
          detail.status = 'approved';
          detail.decided_at = decidedAt;
          detail.checklist = action.meta.arg.checklist;
        }
        const item = state.items.find((row) => row.id === id);
        if (item) {
          item.status = 'approved';
          item.decided_at = decidedAt;
          delete item.previousStatus;
        }
      })
      .addCase(approvePayment.rejected, (state, action) => {
        state.detail.saving = false;
        const item = state.items.find((row) => row.id === action.meta.arg.id);
        if (item?.previousStatus) {
          item.status = item.previousStatus;
          delete item.previousStatus;
        }
        state.detail.error = action.payload;
      })
      .addCase(rejectPayment.pending, (state) => {
        state.detail.saving = true;
        state.detail.error = null;
      })
      .addCase(rejectPayment.fulfilled, (state, action) => {
        const { id, reason } = action.meta.arg;
        const decidedAt = new Date().toISOString();
        state.detail.saving = false;
        state.lastDecision = { id, status: 'rejected', credits: null };
        const detail = state.detail.byId[id];
        if (detail) {
          detail.status = 'rejected';
          detail.decided_at = decidedAt;
          detail.reject_reason = reason;
        }
        const item = state.items.find((row) => row.id === id);
        if (item) {
          item.status = 'rejected';
          item.decided_at = decidedAt;
          item.reject_reason = reason;
        }
      })
      .addCase(rejectPayment.rejected, (state, action) => {
        state.detail.saving = false;
        state.detail.error = action.payload;
      });
  },
});

export const { resetPayments, clearDecision } = paymentsSlice.actions;
export default paymentsSlice.reducer;
