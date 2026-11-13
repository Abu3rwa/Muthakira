import { configureStore } from '@reduxjs/toolkit';
import { setAuthBridge } from '../lib/api.js';
import auth, { logout, sessionRefreshed } from '../features/auth/authSlice.js';
import ui from '../features/ui/uiSlice.js';
import payments from '../features/payments/paymentsSlice.js';
import users from '../features/users/usersSlice.js';
import exams from '../features/exams/examsSlice.js';
import topics from '../features/topics/topicsSlice.js';
import packages from '../features/packages/packagesSlice.js';
import settings from '../features/settings/settingsSlice.js';
import audit from '../features/audit/auditSlice.js';
import reports from '../features/reports/reportsSlice.js';
import ai from '../features/ai/aiSlice.js';

const reducer = { auth, ui, payments, users, exams, topics, packages, settings, audit, reports, ai };

export function makeStore(preloadedState) {
  return configureStore({ reducer, preloadedState });
}

export const store = makeStore();

setAuthBridge({
  onRefreshed: (session) => store.dispatch(sessionRefreshed(session)),
  onExpired: () => store.dispatch(logout({ reason: 'session_expired' })),
});