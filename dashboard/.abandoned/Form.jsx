import { useId } from 'react';
import { useTranslation } from 'react-i18next';

export function Field({ label, hint, error, required, children, htmlFor, className = '' }) {
  return (
    <div className={`field ${className}`}>
      {label ? (
        <label className="field__label" htmlFor={htmlFor}>
          {label}
          {required ? <span aria-hidden="true"> *</span> : null}
        </label>
      ) : null}
      {children}
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

export function Input({ label, hint, error, required, className = '', ...rest }) {
  const id = useId();
  return (
    <Field label={label} hint={hint} error={error} required={required} htmlFor={id} className={className}>
      <input id={id} className="input" aria-invalid={error ? 'true' : undefined} {...rest} />
    </Field>
  );
}

export function Textarea({ label, hint, error, required, className = '', ...rest }) {
  const id = useId();
  return (
    <Field label={label} hint={hint} error={error} required={required} htmlFor={id} className={className}>
      <textarea id={id} className="textarea" aria-invalid={error ? 'true' : undefined} {...rest} />
    </Field>
  );
}

export function Select({ label, hint, error, options = [], className = '', children, ...rest }) {
  const id = useId();
  return (
    <Field label={label} hint={hint} error={error} htmlFor={id} className={className}>
      <select id={id} className="select" aria-invalid={error ? 'true' : undefined} {...rest}>
        {children ??
          options.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
      </select>
    </Field>
  );
}

export function Checkbox({ label, hint, checked, disabled, onChange, className = '' }) {
  const id = useId();
  return (
    <div className={`field ${className}`}>
      <label className={`checkbox ${disabled ? 'checkbox--disabled' : ''}`} htmlFor={id}>
        <input id={id} type="checkbox" checked={checked} disabled={disabled} onChange={onChange} />
        <span>
          {label}
          {hint ? <span className="field__hint" style={{ display: 'block' }}>{hint}</span> : null}
        </span>
      </label>
    </div>
  );
}

export function NumberStepper({ label, hint, error, value, onChange, min, max, step = 1, disabled }) {
  const id = useId();
  const { t } = useTranslation();
  const numeric = value === '' || value === null || value === undefined ? '' : Number(value);

  const bump = (delta) => {
    const base = numeric === '' ? 0 : numeric;
    let next = base + delta;
    if (min !== undefined) next = Math.max(min, next);
    if (max !== undefined) next = Math.min(max, next);
    onChange(next);
  };

  return (
    <Field label={label} hint={hint} error={error} htmlFor={id}>
      <div className="stepper">
        <button
          type="button"
          onClick={() => bump(-step)}
          disabled={disabled || (min !== undefined && numeric !== '' && numeric <= min)}
          aria-label={t('common.actions.previous')}
        >
          −
        </button>
        <input
          id={id}
          type="number"
          inputMode="numeric"
          value={numeric}
          min={min}
          max={max}
          step={step}
          disabled={disabled}
          onChange={(event) => onChange(event.target.value === '' ? '' : Number(event.target.value))}
        />
        <button
          type="button"
          onClick={() => bump(step)}
          disabled={disabled || (max !== undefined && numeric !== '' && numeric >= max)}
          aria-label={t('common.actions.next')}
        >
          +
        </button>
      </div>
    </Field>
  );
}