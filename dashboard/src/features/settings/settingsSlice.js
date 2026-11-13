import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { reject } from '../listState.js';

export const fetchSettings = createAsyncThunk('settings/list', async (_arg, { rejectWithValue }) => {
  try {
    return await api.get('/admin/settings');
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const updateSetting = createAsyncThunk('settings/update', async ({ key, value }, { rejectWithValue }) => {
  try {
    return await api.put('/admin/settings', { key, value });
  } catch (error) {
    return rejectWithValue({ ...reject(error), key });
  }
});

export const fetchMailStatus = createAsyncThunk('settings/mailStatus', async (_arg, { rejectWithValue }) => {
  try {
    return await api.get('/admin/settings/mail-status');
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const sendTestEmail = createAsyncThunk(
  'settings/testEmail',
  async ({ to, language }, { rejectWithValue }) => {
    try {
      return await api.post('/admin/settings/test-email', { to, language });
    } catch (error) {
      return rejectWithValue(reject(error));
    }
  },
);

const settingsSlice = createSlice({
  name: 'settings',
  initialState: {
    status: 'idle',
    items: [],
    error: null,
    savingKey: null,
    rowErrors: {},
    mail: { status: 'idle', data: null, error: null, sending: false, result: null, sendError: null },
  },
  reducers: {
    clearRowError(state, action) {
      delete state.rowErrors[action.payload];
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchSettings.pending, (state) => {
        state.status = 'loading';
        state.error = null;
      })
      .addCase(fetchSettings.fulfilled, (state, action) => {
        state.status = 'ready';
        state.items = action.payload.items ?? [];
      })
      .addCase(fetchSettings.rejected, (state, action) => {
        state.status = 'error';
        state.error = action.payload;
      })
      .addCase(updateSetting.pending, (state, action) => {
        state.savingKey = action.meta.arg.key;
        delete state.rowErrors[action.meta.arg.key];
        const row = state.items.find((item) => item.key === action.meta.arg.key);
        if (row) {
          row.previousValue = row.value;
          row.value = action.meta.arg.value;
        }
      })
      .addCase(updateSetting.fulfilled, (state, action) => {
        state.savingKey = null;
        const row = state.items.find((item) => item.key === action.payload.key);
        if (row) {
          row.value = action.payload.value;
          row.overridden = true;
          row.updated_at = action.payload.updated_at;
          delete row.previousValue;
        }
      })
      .addCase(updateSetting.rejected, (state, action) => {
        state.savingKey = null;
        const key = action.payload?.key ?? action.meta.arg.key;
        state.rowErrors[key] = action.payload;
        const row = state.items.find((item) => item.key === key);
        if (row?.previousValue !== undefined) {
          row.value = row.previousValue;
          delete row.previousValue;
        }
      })
      .addCase(fetchMailStatus.pending, (state) => {
        state.mail.status = 'loading';
        state.mail.error = null;
      })
      .addCase(fetchMailStatus.fulfilled, (state, action) => {
        state.mail.status = 'ready';
        state.mail.data = action.payload;
      })
      .addCase(fetchMailStatus.rejected, (state, action) => {
        state.mail.status = 'error';
        state.mail.error = action.payload;
      })
      .addCase(sendTestEmail.pending, (state) => {
        state.mail.sending = true;
        state.mail.result = null;
        state.mail.sendError = null;
      })
      .addCase(sendTestEmail.fulfilled, (state, action) => {
        state.mail.sending = false;
        state.mail.result = action.payload;
      })
      .addCase(sendTestEmail.rejected, (state, action) => {
        state.mail.sending = false;
        state.mail.sendError = action.payload;
      });
  },
});

export const { clearRowError } = settingsSlice.actions;
export default settingsSlice.reducer;
