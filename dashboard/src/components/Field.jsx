import { useId } from 'react';
import { useTranslation } from 'react-i18next';

export default function Field({ label, hint, error, required, htmlFor, children, inline = false }) {
  const { t } = useTranslation();
  const generated = useId();
  const id = htmlFor ?? generated;
  return (
    <div className={`field${inline ? ' field--inline' : ''}`}>
      {label ? (
        <label className="field__label" htmlFor={id}>
          {label}
          {required ? <span aria-hidden="true"> *</span> : null}
          {!required && label ? <span className="sr-only"> ({t('app.optional')})</span> : null}
        </label>
      ) : null}
      {typeof children === 'function' ? children(id) : children}
      {error ? (
        <span className="field__error" role="alert">
          {error}
        </span>
      ) : hint ? (
        <span className="field__hint">{hint}</span>
      ) : null}
    </div>
  );
}