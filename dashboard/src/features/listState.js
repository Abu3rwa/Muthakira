import { errorPayload } from '../lib/api.js';

export const initialListState = (filters = {}, limit = 50) => ({
  status: 'idle',
  items: [],
  total: 0,
  limit,
  skip: 0,
  filters,
  error: null,
  lastFetchedAt: null,
});

export const initialDetailState = () => ({
  byId: {},
  currentId: null,
  status: 'idle',
  error: null,
  saving: false,
});

export const reject = (error) => errorPayload(error);

export function mergeQuery(state, arg = {}) {
  return {
    ...state.filters,
    ...(arg.filters ?? {}),
    limit: arg.limit ?? state.limit,
    skip: arg.skip ?? state.skip,
  };
}

export function addListCases(builder, thunk) {
  builder
    .addCase(thunk.pending, (state, action) => {
      const arg = action.meta.arg ?? {};
      state.status = 'loading';
      state.error = null;
      if (arg.filters) state.filters = { ...state.filters, ...arg.filters };
      if (arg.limit !== undefined) state.limit = arg.limit;
      if (arg.skip !== undefined) state.skip = arg.skip;
    })
    .addCase(thunk.fulfilled, (state, action) => {
      state.status = 'ready';
      state.items = action.payload.items ?? [];
      state.total = action.payload.total ?? state.items.length;
      state.error = null;
      state.lastFetchedAt = Date.now();
    })
    .addCase(thunk.rejected, (state, action) => {
      state.status = 'error';
      state.error = action.payload ?? { code: 'INTERNAL_ERROR', message: '', status: 0 };
    });
}

export function patchItem(state, id, patch) {
  const index = state.items.findIndex((item) => item.id === id);
  if (index >= 0) state.items[index] = { ...state.items[index], ...patch };
}
