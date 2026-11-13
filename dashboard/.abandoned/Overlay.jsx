import { useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { IconButton } from './Button.jsx';

function useDismiss(open, onClose) {
  const panel = useRef(null);

  useEffect(() => {
    if (!open) return undefined;
    const onKey = (event) => {
      if (event.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', onKey);
    const previous = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    panel.current?.focus();
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = previous;
    };
  }, [open, onClose]);

  return panel;
}

export function Drawer({ open, title, subtitle, onClose, children, footer, wide = false }) {
  const { t } = useTranslation();
  const panel = useDismiss(open, onClose);
  if (!open) return null;

  return (
    <>
      <div className="scrim" onClick={onClose} aria-hidden="true" />
      <aside
        className={`drawer__panel ${wide ? 'drawer__panel--wide' : ''}`}
        role="dialog"
        aria-modal="true"
        aria-label={title}
        tabIndex={-1}
        ref={panel}
      >
        <header className="drawer__head">
          <div className="grow">
            <h2>{title}</h2>
            {subtitle ? <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>{subtitle}</p> : null}
          </div>
          <IconButton icon="close" label={t('common.actions.close')} onClick={onClose} />
        </header>
        <div className="drawer__body">{children}</div>
        {footer ? <footer className="drawer__foot">{footer}</footer> : null}
      </aside>
    </>
  );
}

export function Modal({ open, title, subtitle, onClose, children, footer, wide = false }) {
  const { t } = useTranslation();
  const panel = useDismiss(open, onClose);
  if (!open) return null;

  return (
    <div className="modal" onClick={(event) => event.target === event.currentTarget && onClose()}>
      <div
        className={`modal__panel ${wide ? 'modal__panel--wide' : ''}`}
        role="dialog"
        aria-modal="true"
        aria-label={title}
        tabIndex={-1}
        ref={panel}
      >
        <header className="modal__head">
          <div className="row row--between">
            <h2>{title}</h2>
            <IconButton icon="close" label={t('common.actions.close')} onClick={onClose} />
          </div>
          {subtitle ? <p>{subtitle}</p> : null}
        </header>
        <div className="modal__body">{children}</div>
        {footer ? <footer className="modal__foot">{footer}</footer> : null}
      </div>
    </div>
  );
}