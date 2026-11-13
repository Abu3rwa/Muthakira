import { useTranslation } from 'react-i18next';
import { formatBytes, formatCredits, formatDate, formatMoney, formatNumber, shortId } from '../lib/format.js';

export function Money({ value }) {
  const { i18n } = useTranslation();
  return <span className="num nowrap">{formatMoney(value, i18n.language)}</span>;
}

export function Credits({ value }) {
  const { i18n } = useTranslation();
  return <span className="num nowrap">{formatCredits(value, i18n.language)}</span>;
}

export function Num({ value, options }) {
  const { i18n } = useTranslation();
  return <span className="num">{formatNumber(value, i18n.language, options)}</span>;
}

export function Bytes({ value }) {
  const { i18n } = useTranslation();
  return <span className="num nowrap">{formatBytes(value, i18n.language)}</span>;
}

export function DateCell({ value, withTime = true }) {
  const { i18n, t } = useTranslation();
  if (!value) return <span className="muted">{t('app.never')}</span>;
  return <span className="nowrap">{formatDate(value, i18n.language, { withTime })}</span>;
}

export function Ltr({ children, className = '' }) {
  return <span className={`ltr ${className}`}>{children}</span>;
}

export function IdChip({ value }) {
  return (
    <span className="mono muted" title={value ?? ''}>
      {shortId(value)}
    </span>
  );
}

export function KeyValue({ items }) {
  return (
    <dl className="kv">
      {items.map(([key, value]) => (
        <div key={key} style={{ display: 'contents' }}>
          <dt className="kv__k">{key}</dt>
          <dd className="kv__v">{value ?? '—'}</dd>
        </div>
      ))}
    </dl>
  );
}