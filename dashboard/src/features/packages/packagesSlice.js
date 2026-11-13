import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { addListCases, initialListState, mergeQuery, patchItem, reject } from '../listState.js';

export const fetchPackages = createAsyncThunk('packages/list', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/packages', mergeQuery(getState().packages, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const createPackage = createAsyncThunk('packages/create', async (body, { rejectWithValue }) => {
  try {
    return await api.post('/admin/packages', body);
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const updatePackage = createAsyncThunk('packages/update', async ({ id, ...body }, { rejectWithValue }) => {
  try {
    return await api.patch(`/admin/packages/${id}`, body);
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

const packagesSlice = createSlice({
  name: 'packages',
  initialState: { ...initialListState({ active: '' }, 50), saving: false, saveError: null },
  reducers: {
    clearPackageError(state) {
      state.saveError = null;
    },
  },
  extraReducers: (builder) => {
    addListCases(builder, fetchPackages);
    for (const thunk of [createPackage, updatePackage]) {
      builder
        .addCase(thunk.pending, (state) => {
          state.saving = true;
          state.saveError = null;
        })
        .addCase(thunk.fulfilled, (state, action) => {
          state.saving = false;
          if (thunk === createPackage) {
            state.items = [...state.items, action.payload];
            state.total = state.items.length;
          } else {
            patchItem(state, action.payload.id, action.payload);
          }
        })
        .addCase(thunk.rejected, (state, action) => {
          state.saving = false;
          state.saveError = action.payload;
        });
    }
  },
});

export const { clearPackageError } = packagesSlice.actions;
export default packagesSlice.reducer;
