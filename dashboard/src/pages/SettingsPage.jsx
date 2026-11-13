import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import {
  fetchMailStatus,
  fetchSettings,
  sendTestEmail,
  updateSetting,
} from '../features/settings/settingsSlice.js';
import { toast } from '../app/feedback.js';
import Badge from '../components/Badge.jsx';
import Icon from '../components/Icon.jsx';
import { DateCell, Ltr } from '../components/Data.jsx';
import { EmptyState, ErrorState, InlineError, Loading } from '../components/States.jsx';

const GROUPS = ['bankak', 'credits', 'payments', 'ai'];

const labelKey = (key) => `settings.labels.${key.replaceAll('.', '_')}`;

function validate(item, draft) {
  if (item.type === 'boolean') return null;
  if (item.type === 'integer' || item.type === 'number') {
    const pattern = item.type === 'integer' ? /^\d+$/ : /^\d+(\.\d+)?$/;
    if (!pattern.test(draft.trim())) return 'invalidNumber';
    const value = Number(draft);
    if (value < item.min || value > item.max) return 'outOfRange';
    return null;
  }
  const length = draft.trim().length;
  if (length < item.min || length > item.max) return 'outOfRange';
  return null;
}

function SettingRow({ item, draft, saving, error, onChange, onSave }) {
  const { t } = useTranslation();
  const id = `setting-${item.key.replaceAll('.', '-')}`;
  const problem = validate(item, draft);
  const unchanged = draft.trim() === String(item.value ?? '').trim();
  const numeric = item.type === 'integer' || item.type === 'number';
  const hasRange = item.min !== undefined && item.max !== undefined;

  return (
    <div className="field">
      <label className="field__label" htmlFor={id}>
        {t(labelKey(item.key), { defaultValue: item.key })}
      </label>
      <div className="row">
        {item.type === 'boolean' ? (
          <label className="row" style={{ gap: 8, cursor: 'pointer' }}>
            <input
              id={id}
              type="checkbox"
              checked={draft === 'true'}
              disabled={saving}
              aria-describedby={`${id}-hint`}
              onChange={(event) => onChange(String(event.target.checked))}
            />
            <span>{draft === 'true' ? t('app.yes') : t('app.no')}</span>
          </label>
        ) : (
          <input
            id={id}
            className={`input${numeric ? ' num ltr' : ''}`}
            type={numeric ? 'number' : 'text'}
            inputMode={numeric ? (item.type === 'number' ? 'decimal' : 'numeric') : undefined}
            min={numeric ? item.min : undefined}
            max={numeric ? item.max : undefined}
            step={item.type === 'number' ? 'any' : numeric ? 1 : undefined}
            maxLength={numeric ? undefined : item.max}
            value={draft}
            disabled={saving}
            aria-invalid={Boolean(problem)}
            aria-describedby={`${id}-hint`}
            style={{ maxWidth: numeric ? 180 : 320 }}
            onChange={(event) => onChange(event.target.value)}
          />
        )}
        <button
          type="button"
          className="btn btn--primary btn--sm"
          onClick={onSave}
          disabled={saving || unchanged || Boolean(problem)}
          title={unchanged ? t('settings.unchanged') : undefined}
        >
          {saving ? <span className="spinner" aria-hidden="true" /> : <Icon name="check" size={14} />}
          {saving ? t('app.saving') : t('settings.save')}
        </button>
        {item.overridden ? <Badge tone="info">{t('settings.overridden')}</Badge> : null}
      </div>
      <span className="field__hint" id={`${id}-hint`}>
        {t('settings.default')}:{' '}
        {item.type === 'boolean' ? (
          item.default_value ? t('app.yes') : t('app.no')
        ) : (
          <Ltr className="mono">{numeric ? item.default_value : String(item.default_value ?? '—')}</Ltr>
        )}
        {hasRange ? (
          <>
            {' · '}
            {t('settings.range')}: <Ltr className="mono">{`${item.min}–${item.max}`}</Ltr>
          </>
        ) : null}
        {item.updated_at ? (
          <>
            {' · '}
            {t('settings.lastUpdated')}: <DateCell value={item.updated_at} />
          </>
        ) : null}
      </span>
      {problem ? (
        <span className="field__error" role="alert">
          {problem === 'invalidNumber'
            ? t('settings.invalidNumber')
            : t('settings.outOfRange', { min: item.min, max: item.max })}
        </span>
      ) : null}
      <InlineError error={error} />
    </div>
  );
}

function MailCard() {
  const { t, i18n } = useTranslation();
  const dispatch = useAppDispatch();
  const mail = useAppSelector((slice) => slice.settings.mail);
  const [to, setTo] = useState('');
  const [invalid, setInvalid] = useState(false);

  useEffect(() => {
    dispatch(fetchMailStatus());
  }, [dispatch]);

  const check = mail.data;
  const send = async (event) => {
    event.preventDefault();
    const value = to.trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
      setInvalid(true);
      return;
    }
    setInvalid(false);
    try {
      const result = await dispatch(sendTestEmail({ to: value, language: i18n.language })).unwrap();
      dispatch(
        result.ok
          ? toast(t('settings.mail.pass'), 'success')
          : toast(t('settings.mail.fail'), 'danger', result.error ?? result.code ?? undefined),
      );
    } catch {
      /* the slice keeps the request error */
    }
  };

  const result = mail.result;
  return (
    <div className="card">
      <div className="card__head">
        <Icon name="inbox" />
        <div className="grow">
          <h2>{t('settings.mail.title')}</h2>
          <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>
            {t('settings.mail.subtitle')}
          </p>
        </div>
        {check ? (
          <Badge tone={check.configured && check.ok ? 'success' : 'danger'}>
            {check.configured && check.ok ? t('settings.mail.working') : t('settings.mail.broken')}
          </Badge>
        ) : null}
        <button
          type="button"
          className="btn btn--outline btn--sm"
          onClick={() => dispatch(fetchMailStatus())}
          disabled={mail.status === 'loading'}
        >
          <Icon name="refresh" size={14} />
          {t('settings.mail.recheck')}
        </button>
      </div>
      <div className="card__body">
        {mail.status === 'loading' && !check ? <Loading /> : null}
        <InlineError error={mail.error} />
        {check ? (
          <dl className="split split--even" style={{ marginBottom: 'var(--space-4)' }}>
            <div>
              <dt className="muted">{t('settings.mail.host')}</dt>
              <dd>
                <Ltr className="mono">{check.host ? `${check.host}:${check.port}` : '—'}</Ltr>
              </dd>
            </div>
            <div>
              <dt className="muted">{t('settings.mail.user')}</dt>
              <dd>
                <Ltr className="mono">{check.user || '—'}</Ltr>
              </dd>
            </div>
            <div>
              <dt className="muted">{t('settings.mail.sender')}</dt>
              <dd>
                <Ltr className="mono">{check.from || '—'}</Ltr>
              </dd>
            </div>
            <div>
              <dt className="muted">{t('settings.mail.state')}</dt>
              <dd>
                {check.configured && check.ok
                  ? t('settings.mail.working')
                  : check.error ?? t('settings.mail.notConfigured')}
              </dd>
            </div>
          </dl>
        ) : null}

        <form className="row" onSubmit={send} noValidate>
          <label className="field grow" style={{ marginBottom: 0 }}>
            <span className="field__label">{t('settings.mail.to')}</span>
            <input
              className="input ltr"
              type="email"
              inputMode="email"
              dir="ltr"
              value={to}
              placeholder={t('settings.mail.toHint')}
              aria-invalid={invalid}
              onChange={(event) => setTo(event.target.value)}
            />
            <span className="field__hint">{t('settings.mail.toHint')}</span>
            {invalid ? (
              <span className="field__error" role="alert">
                {t('settings.mail.emailInvalid')}
              </span>
            ) : null}
          </label>
          <button type="submit" className="btn btn--primary btn--sm" disabled={mail.sending}>
            {mail.sending ? <span className="spinner" aria-hidden="true" /> : <Icon name="inbox" size={14} />}
            {mail.sending ? t('settings.mail.sending') : t('settings.mail.send')}
          </button>
        </form>

        {result ? (
          <div className={result.ok ? 'notice notice--success' : 'notice notice--danger'} role="status">
            <Icon name={result.ok ? 'check' : 'alert'} />
            <div className="grow">
              <strong>{result.ok ? t('settings.mail.pass') : t('settings.mail.fail')}</strong>
              {result.ok ? null : (
                <div className="mono" style={{ fontSize: 'var(--text-sm)', wordBreak: 'break-word' }}>
                  {result.code ? `${result.code}: ` : ''}
                  {result.error}
                </div>
              )}
            </div>
          </div>
        ) : null}
        <InlineError error={mail.sendError} />
      </div>
    </div>
  );
}

export default function SettingsPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const state = useAppSelector((slice) => slice.settings);
  const [drafts, setDrafts] = useState({});
  const seen = useRef({});

  useEffect(() => {
    dispatch(fetchSettings());
  }, [dispatch]);

  useEffect(() => {
    setDrafts((current) => {
      const next = { ...current };
      for (const item of state.items) {
        const stamp = item.updated_at ?? 'default';
        if (seen.current[item.key] === stamp) continue;
        seen.current[item.key] = stamp;
        next[item.key] = String(item.value ?? '');
      }
      return next;
    });
  }, [state.items]);

  const save = async (item) => {
    const draft = drafts[item.key] ?? '';
    const value =
      item.type === 'boolean'
        ? draft === 'true'
        : item.type === 'integer' || item.type === 'number'
          ? Number(draft)
          : draft.trim();
    try {
      await dispatch(updateSetting({ key: item.key, value })).unwrap();
      dispatch(toast(t('settings.saved'), 'success'));
    } catch {
      /* the slice keeps the row error */
    }
  };

  if (state.status === 'loading' && !state.items.length) return <div className="page"><Loading /></div>;
  if (state.status === 'error' && !state.items.length) {
    return (
      <div className="page">
        <div className="card">
          <ErrorState error={state.error} onRetry={() => dispatch(fetchSettings())} />
        </div>
      </div>
    );
  }

  const groups = GROUPS.map((group) => ({
    group,
    items: state.items.filter((item) => item.key.startsWith(`${group}.`)),
  })).filter((entry) => entry.items.length);

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('settings.title')}</h1>
          <p>{t('settings.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchSettings())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      {state.status === 'error' ? (
        <div className="notice notice--danger" role="alert">
          <span className="grow">{t('app.errorHint')}</span>
          <button type="button" className="btn btn--outline btn--sm" onClick={() => dispatch(fetchSettings())}>
            {t('app.retry')}
          </button>
        </div>
      ) : null}

      <MailCard />

      {!groups.length ? (
        <div className="card">
          <EmptyState text={t('settings.empty')} icon="sliders" />
        </div>
      ) : (
        groups.map(({ group, items }) => (
          <div className="card" key={group}>
            <div className="card__head">
              <Icon name={group === 'bankak' ? 'wallet' : group === 'credits' ? 'box' : group === 'ai' ? 'spark' : 'sliders'} />
              <h2 className="grow">{t(`settings.groups.${group}`)}</h2>
              <span className="muted mono">{items.length}</span>
            </div>
            <div className="card__body">
              <div className="split split--even">
                {items.map((item) => (
                  <SettingRow
                    key={item.key}
                    item={item}
                    draft={drafts[item.key] ?? String(item.value ?? '')}
                    saving={state.savingKey === item.key}
                    error={state.rowErrors[item.key]}
                    onChange={(value) => setDrafts((current) => ({ ...current, [item.key]: value }))}
                    onSave={() => save(item)}
                  />
                ))}
              </div>
            </div>
          </div>
        ))
      )}

      <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>{t('settings.note')}</p>
    </div>
  );
}