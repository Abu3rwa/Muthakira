import { useTranslation } from 'react-i18next';
import { errorDetails, errorText } from '../../lib/errors.js';
import Button from '../Button.jsx';
import Icon from '../Icon.jsx';

export function LoadingState({ label }) {
  const { t } = useTranslation();
  return (
    <div className="state" role="status" aria-live="polite">
      <span className="spinner" style={{ width: 22, height: 22, color: 'var(--ink-500)' }} />
      <span className="state__text">{label ?? t('states.loading')}</span>
    </div>
  );
}

export function SkeletonRows({ rows = 6, columns = 5 }) {
  return (
    <div aria-hidden="true">
      {Array.from({ length: rows }, (_, index) => (
        <div className="skeleton-row" key={index}>
          {Array.from({ length: columns }, (__, cell) => (
            <span
              className="skeleton"
              key={cell}
              style={{ flex: cell === 0 ? '0 0 90px' : 1, opacity: 1 - index * 0.1 }}
            />
          ))}
        </div>
      ))}
    </div>
  );
}

export function EmptyState({ title, text, icon = 'inbox', action }) {
  const { t } = useTranslation();
  return (
    <div className="state">
      <span className="state__icon">
        <Icon name={icon} size={22} />
      </span>
      <p className="state__title">{title ?? t('states.emptyTitle')}</p>
      {text ? <p className="state__text">{text}</p> : null}
      {action}
    </div>
  );
}

export function ErrorState({ error, onRetry, compact = false }) {
  const { t } = useTranslation();
  const details = errorDetails(error);
  return (
    <div className="state state--error" role="alert">
      <span className="state__icon">
        <Icon name={error?.code === 'NETWORK_ERROR' ? 'offline' : 'alert'} size={22} />
      </span>
      <p className="state__title">{t('states.error.title')}</p>
      <p className="state__text">{errorText(t, error)}</p>
      {!compact && error?.requestId ? (
        <p className="state__meta">{t('states.requestId', { id: error.requestId })}</p>
      ) : null}
      {details.length ? (
        <ul className="state__details">
          {details.slice(0, 8).map((line, index) => (
            <li key={index}>{line}</li>
          ))}
        </ul>
      ) : null}
      {onRetry ? (
        <Button variant="outline" icon="refresh" onClick={onRetry}>
          {t('common.actions.retry')}
        </Button>
      ) : null}
    </div>
  );
}

export function ForbiddenState() {
  const { t } = useTranslation();
  return (
    <div className="state state--forbidden">
      <span className="state__icon">
        <Icon name="shield" size={22} />
      </span>
      <p className="state__title">{t('states.forbidden.title')}</p>
      <p className="state__text">{t('states.forbidden.text')}</p>
    </div>
  );
}