import { closeConfirm, openConfirm, pushToast } from '../features/ui/uiSlice.js';

let sequence = 0;
const handlers = new Map();

export const toast = (title, tone = 'info', text = null) => pushToast({ title, text, tone });

export function confirmAction(options, handler) {
  sequence += 1;
  const id = `confirm-${sequence}`;
  handlers.set(id, handler);
  return openConfirm({ ...options, id });
}

export function takeConfirmHandler(id) {
  const handler = handlers.get(id);
  handlers.delete(id);
  return handler;
}

export function dropConfirmHandler(id) {
  handlers.delete(id);
  return closeConfirm();
}