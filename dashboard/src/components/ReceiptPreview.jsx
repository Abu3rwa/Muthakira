import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { api, errorPayload } from '../lib/api.js';
import { formatBytes, formatDate } from '../lib/format.js';
import Icon from './Icon.jsx';
import { EmptyState, InlineError } from './States.jsx';

export default function ReceiptPreview({ receipts = [] }) {
  const { t, i18n } = useTranslation();
  const ids = receipts.map((receipt) => receipt.id).join(',');
  const [activeId, setActiveId] = useState(receipts[0]?.id ?? null);
  const [attempt, setAttempt] = useState(0);
  const [view, setView] = useState({ status: 'idle', url: null, type: null, error: null });

  useEffect(() => {
    setActiveId(receipts[0]?.id ?? null);
  }, [ids]);

  const active = receipts.find((receipt) => receipt.id === activeId) ?? receipts[0] ?? null;
  const loadedId = active?.id;

  useEffect(() => {
    if (!loadedId) {
      setView({ status: 'idle', url: null, type: null, error: null });
      return undefined;
    }
    let cancelled = false;
    let objectUrl = null;
    setView({ status: 'loading', url: null, type: null, error: null });
    api
      .blob(`/admin/receipts/${loadedId}/file`)
      .then((blob) => {
        if (cancelled) return;
        objectUrl = URL.createObjectURL(blob);
        setView({ status: 'ready', url: objectUrl, type: blob.type || null, error: null });
      })
      .catch((error) => {
        if (!cancelled) setView({ status: 'error', url: null, type: null, error: errorPayload(error) });
      });
    return () => {
      cancelled = true;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
    };
  }, [loadedId, attempt]);

  if (!receipts.length) {
    return <EmptyState icon="inbox" title={t('payments.noReceipt')} text={t('payments.checklistHint')} />;
  }

  const type = view.type || active?.content_type || '';
  const isImage = type.startsWith('image/');
  const isPdf = type === 'application/pdf';

  return (
    <div className="receipt">
      {receipts.length > 1 ? (
        <div className="receipt__thumbs" role="tablist" aria-label={t('payments.receipt')}>
          {receipts.map((receipt, index) => (
            <button
              key={receipt.id}
              type="button"
              role="tab"
              aria-selected={receipt.id === active?.id}
              className={`receipt__thumb${receipt.id === active?.id ? ' receipt__thumb--active' : ''}`}
              onClick={() => setActiveId(receipt.id)}
            >
              {index + 1} · {formatDate(receipt.uploaded_at, i18n.language)}
            </button>
          ))}
        </div>
      ) : null}

      <div className="receipt__frame" aria-busy={view.status === 'loading'}>
        {view.status === 'loading' ? (
          <span className="row" role="status">
            <span className="spinner" aria-hidden="true" />
            {t('payments.receiptLoading')}
          </span>
        ) : view.status === 'error' ? (
          <div className="stack" style={{ padding: 'var(--space-4)', width: '100%' }}>
            <InlineError error={view.error} />
            <button
              type="button"
              className="btn btn--outline btn--sm"
              onClick={() => setAttempt((value) => value + 1)}
            >
              <Icon name="refresh" size={14} />
              {t('app.retry')}
            </button>
          </div>
        ) : isImage ? (
          <img className="receipt__img" src={view.url} alt={t('payments.preview')} />
        ) : isPdf ? (
          <iframe className="receipt__pdf" src={view.url} title={t('payments.preview')} />
        ) : (
          <span className="muted">{t('payments.receiptMissing')}</span>
        )}
      </div>

      <div className="receipt__meta">
        <span>{type || t('app.unknown')}</span>
        <span>{formatBytes(active?.size_bytes, i18n.language)}</span>
        <span>
          {t('app.uploadedAt')}: {formatDate(active?.uploaded_at, i18n.language)}
        </span>
        {view.url ? (
          <a href={view.url} target="_blank" rel="noreferrer" className="row" style={{ gap: 4 }}>
            <Icon name="external" size={13} />
            {t('app.download')}
          </a>
        ) : null}
      </div>
      <div className="receipt__meta">
        <span className="mono truncate" title={active?.sha256 ?? ''} style={{ maxWidth: '100%' }}>
          {t('app.checksum')}: {active?.sha256 ?? '—'}
        </span>
      </div>
    </div>
  );
}