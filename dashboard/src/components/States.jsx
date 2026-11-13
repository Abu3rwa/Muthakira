import { useTranslation } from 'react-i18next';
import Icon from './Icon.jsx';
import { errorDetails, errorMessage } from '../lib/errors.js';

export function Spinner({ label }) {
  return (
    <span className="row" style={{ gap: 8 }}>
      <span className="spinner" aria-hidden="true" />
      {label ? <span>{label}</span> : null}
    </span>
  );
}

export function Loading({ label }) {
  const { t } = useTranslation();
  return (
    <div className="state" role="status" aria-live="polite">
      <span className="state__icon">
        <span className="spinner" aria-hidden="true" />
      </span>
      <p className="state__text">{label ?? t('app.loading')}</p>
    </div>
  );
}

export function SkeletonRows({ rows = 6, columns = 4 }) {
  return (
    <div aria-hidden="true">
      {Array.from({ length: rows }, (_, index) => (
        <div className="skeleton-row" key={index}>
          {Array.from({ length: columns }, (__, column) => (
            <span
              className="skeleton"
              key={column}
              style={{ flex: column === 0 ? '0 0 28%' : 1, opacity: 1 - index * 0.08 }}
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
      <p className="state__title">{title ?? t('app.emptyTitle')}</p>
      {text ? <p className="state__text">{text}</p> : null}
      {action}
    </div>
  );
}

export function ErrorState({ error, onRetry, title }) {
  const { t } = useTranslation();
  const details = errorDetails(error);
  return (
    <div className="state state--error" role="alert">
      <span className="state__icon">
        <Icon name="offline" size={22} />
      </span>
      <p className="state__title">{title ?? t('app.errorTitle')}</p>
      <p className="state__text">{errorMessage(t, error) || t('app.errorHint')}</p>
      {error?.code ? <p className="state__meta">{error.code}</p> : null}
      {details.length ? (
        <ul className="state__details">
          {details.map((line, index) => (
            <li key={index}>{line}</li>
          ))}
        </ul>
      ) : null}
      {onRetry ? (
        <button type="button" className="btn btn--outline btn--sm" onClick={onRetry}>
          <Icon name="refresh" />
          {t('app.retry')}
        </button>
      ) : null}
    </div>
  );
}

export function Forbidden() {
  const { t } = useTranslation();
  return (
    <div className="state state--forbidden">
      <span className="state__icon">
        <Icon name="lock" size={22} />
      </span>
      <p className="state__title">{t('app.forbiddenTitle')}</p>
      <p className="state__text">{t('app.forbiddenBody')}</p>
    </div>
  );
}

export function NotFound({ text }) {
  const { t } = useTranslation();
  return (
    <div className="state">
      <span className="state__icon">
        <Icon name="search" size={22} />
      </span>
      <p className="state__title">{t('app.notFoundTitle')}</p>
      <p className="state__text">{text ?? t('app.notFoundBody')}</p>
    </div>
  );
}

export function InlineError({ error }) {
  const { t } = useTranslation();
  if (!error) return null;
  const details = errorDetails(error);
  return (
    <div className="notice notice--danger" role="alert">
      <Icon name="alert" />
      <div className="grow">
        <div>{errorMessage(t, error)}</div>
        {details.length ? (
          <ul style={{ margin: 0, paddingInlineStart: 18, listStyle: 'disc' }}>
            {details.map((line, index) => (
              <li key={index}>{line}</li>
            ))}
          </ul>
        ) : null}
      </div>
    </div>
  );
}