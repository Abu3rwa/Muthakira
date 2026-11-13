import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';
import { api } from '../../lib/api.js';
import { addListCases, initialDetailState, initialListState, mergeQuery, patchItem, reject } from '../listState.js';

export const fetchExams = createAsyncThunk('exams/list', async (arg = {}, { getState, rejectWithValue }) => {
  try {
    return await api.get('/admin/exams', mergeQuery(getState().exams, arg));
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const fetchExam = createAsyncThunk('exams/detail', async (id, { rejectWithValue }) => {
  try {
    return await api.get(`/admin/exams/${id}`);
  } catch (error) {
    return rejectWithValue(reject(error));
  }
});

export const dryRunImport = createAsyncThunk('exams/dryRun', async (files, { rejectWithValue }) => {
  try {
    const result = await api.post('/admin/exams/import', { ...files, dryRun: true });
    return { ok: true, errors: [], warnings: result.warnings ?? [], exams: result.exams ?? [] };
  } catch (error) {
    if (error.code === 'EXAM_IMPORT_INVALID') {
      return {
        ok: false,
        errors: error.details?.errors ?? [],
        warnings: error.details?.warnings ?? [],
        exams: [],
      };
    }
    return rejectWithValue(reject(error));
  }
});

export const applyImport = createAsyncThunk('exams/apply', async (files, { rejectWithValue }) => {
  try {
    const result = await api.post('/admin/exams/import', { ...files, dryRun: false });
    return { ok: true, errors: [], warnings: result.warnings ?? [], exams: result.exams ?? [] };
  } catch (error) {
    if (error.code === 'EXAM_IMPORT_INVALID') {
      return { ok: false, errors: error.details?.errors ?? [], warnings: error.details?.warnings ?? [], exams: [] };
    }
    return rejectWithValue(reject(error));
  }
});

const mutation = (name, fn) =>
  createAsyncThunk(`exams/${name}`, async ({ id, ...body }, { rejectWithValue }) => {
    try {
      return await fn(id, body);
    } catch (error) {
      return rejectWithValue(reject(error));
    }
  });

export const publishExam = mutation('publish', (id) => api.post(`/admin/exams/${id}/publish`));
export const unpublishExam = mutation('unpublish', (id) => api.post(`/admin/exams/${id}/unpublish`));
export const blockExam = mutation('block', (id, body) => api.post(`/admin/exams/${id}/block`, body));
export const configExam = mutation('config', (id, body) => api.patch(`/admin/exams/${id}/config`, body));

const emptyImport = {
  phase: 'idle',
  ok: null,
  errors: [],
  warnings: [],
  exams: [],
  error: null,
};

const examsSlice = createSlice({
  name: 'exams',
  initialState: {
    ...initialListState({ status: '', language: '', subject: '', class_level: '', exam_year: '', session: '' }, 20),
    detail: { ...initialDetailState(), saving: false },
    import: emptyImport,
  },
  reducers: {
    resetImport(state) {
      state.import = { ...emptyImport };
    },
    resetExams(state) {
      state.status = 'idle';
      state.items = [];
      state.total = 0;
      state.skip = 0;
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    addListCases(builder, fetchExams);
    builder
      .addCase(fetchExam.pending, (state, action) => {
        state.detail.status = 'loading';
        state.detail.currentId = action.meta.arg;
        state.detail.error = null;
      })
      .addCase(fetchExam.fulfilled, (state, action) => {
        state.detail.status = 'ready';
        state.detail.byId[action.payload.id] = action.payload;
        state.detail.currentId = action.payload.id;
      })
      .addCase(fetchExam.rejected, (state, action) => {
        state.detail.status = 'error';
        state.detail.error = action.payload;
      });

    for (const [thunk, phase] of [
      [dryRunImport, 'checking'],
      [applyImport, 'applying'],
    ]) {
      builder
        .addCase(thunk.pending, (state) => {
          state.import = { ...emptyImport, phase };
        })
        .addCase(thunk.fulfilled, (state, action) => {
          state.import = {
            phase: phase === 'checking' ? 'checked' : 'applied',
            ok: action.payload.ok,
            errors: action.payload.errors,
            warnings: action.payload.warnings,
            exams: action.payload.exams,
            error: null,
          };
        })
        .addCase(thunk.rejected, (state, action) => {
          state.import = { ...emptyImport, phase: 'failed', error: action.payload };
        });
    }

    for (const thunk of [publishExam, unpublishExam, blockExam, configExam]) {
      builder
        .addCase(thunk.pending, (state) => {
          state.detail.saving = true;
        })
        .addCase(thunk.fulfilled, (state, action) => {
          state.detail.saving = false;
          state.detail.byId[action.payload.id] = { ...state.detail.byId[action.payload.id], ...action.payload };
          patchItem(state, action.payload.id, action.payload);
        })
        .addCase(thunk.rejected, (state, action) => {
          state.detail.saving = false;
          state.detail.error = action.payload;
        });
    }
  },
});

export const { resetImport, resetExams } = examsSlice.actions;
export default examsSlice.reducer;
