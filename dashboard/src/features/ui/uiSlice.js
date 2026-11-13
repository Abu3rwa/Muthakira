import { createSlice } from '@reduxjs/toolkit';

const LANG_KEY = 'mothakira.lang';

const storedLanguage = () => {
  try {
    return localStorage.getItem(LANG_KEY) === 'en' ? 'en' : 'ar';
  } catch {
    return 'ar';
  }
};

let sequence = 0;

const uiSlice = createSlice({
  name: 'ui',
  initialState: {
    language: storedLanguage(),
    sidebarOpen: false,
    toasts: [],
    confirm: null,
  },
  reducers: {
    setLanguage(state, action) {
      state.language = action.payload;
      try {
        localStorage.setItem(LANG_KEY, action.payload);
      } catch {
        /* ignore */
      }
    },
    toggleSidebar(state, action) {
      state.sidebarOpen = action.payload ?? !state.sidebarOpen;
    },
    pushToast: {
      reducer(state, action) {
        state.toasts.push(action.payload);
        if (state.toasts.length > 4) state.toasts.shift();
      },
      prepare(toast) {
        sequence += 1;
        return { payload: { id: `toast-${sequence}`, tone: 'info', ...toast } };
      },
    },
    dismissToast(state, action) {
      state.toasts = state.toasts.filter((toast) => toast.id !== action.payload);
    },
    openConfirm(state, action) {
      state.confirm = action.payload;
    },
    closeConfirm(state) {
      state.confirm = null;
    },
  },
});

export const { setLanguage, toggleSidebar, pushToast, dismissToast, openConfirm, closeConfirm } = uiSlice.actions;

export default uiSlice.reducer;
