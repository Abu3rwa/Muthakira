import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { closeConfirm, dismissToast } from '../features/ui/uiSlice.js';
import { dropConfirmHandler, takeConfirmHandler } from '../app/feedback.js';
import Icon from './Icon.jsx';
import Modal from './Modal.jsx';

function Toast({ toast }) {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();

  useEffect(() => {
    const timer = setTimeout(() => dispatch(dismissToast(toast.id)), 6000);
    return () => clearTimeout(timer);
  }, [dispatch, toast.id]);

  return (
    <div className={`toast toast--${toast.tone}`} role="status">
      <div className="toast__body">
        <strong>{toast.title}</strong>
        {toast.text ? <span>{toast.text}</span> : null}
      </div>
      <button
        type="button"
        className="icon-btn"
        onClick={() => dispatch(dismissToast(toast.id))}
        aria-label={t('app.close')}
      >
        <Icon name="close" size={14} />
      </button>
    </div>
  );
}

export function ToastHost() {
  const toasts = useAppSelector((state) => state.ui.toasts);
  if (!toasts.length) return null;
  return (
    <div className="toast-stack" aria-live="polite">
      {toasts.map((toast) => (
        <Toast key={toast.id} toast={toast} />
      ))}
    </div>
  );
}

export function ConfirmHost() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const confirm = useAppSelector((state) => state.ui.confirm);
  const [busy, setBusy] = useState(false);

  if (!confirm) return null;

  const close = () => {
    setBusy(false);
    dispatch(dropConfirmHandler(confirm.id));
  };

  const run = async () => {
    const handler = takeConfirmHandler(confirm.id);
    setBusy(true);
    try {
      await handler?.();
    } finally {
      setBusy(false);
      dispatch(closeConfirm());
    }
  };

  return (
    <Modal
      title={confirm.title}
      description={confirm.body}
      onClose={busy ? undefined : close}
      labelledBy="confirm-title"
      footer={
        <>
          <button type="button" className="btn btn--ghost" onClick={close} disabled={busy}>
            {t('app.cancel')}
          </button>
          <button
            type="button"
            className={`btn btn--${confirm.tone ?? 'primary'}`}
            onClick={run}
            disabled={busy}
          >
            {busy ? <span className="spinner" aria-hidden="true" /> : null}
            {confirm.confirmLabel ?? t('app.confirm')}
          </button>
        </>
      }
    />
  );
}