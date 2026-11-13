import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { fetchAudit } from '../features/audit/auditSlice.js';
import { AUDIT_ACTIONS } from '../lib/constants.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import Modal from '../components/Modal.jsx';
import { DateCell, IdChip, KeyValue, Ltr } from '../components/Data.jsx';

const TARGET_TYPES = ['exam', 'user', 'payment_request', 'credit_package', 'topic', 'setting', 'question_report'];
const OBJECT_ID = /^[0-9a-f]{24}$/i;
const EMPTY_FILTERS = { actorUserId: '', action: '', targetType: '', targetId: '', from: '', to: '' };

export const actionLabel = (t, action) => t(`audit.actions.${action}`, { defaultValue: action });
export const targetLabel = (t, type) => t(`audit.targetTypes.${type}`, { defaultValue: type });

const isPlainObject = (value) => value !== null && typeof value === 'object' && !Array.isArray(value);

function Value({ value }) {
  if (value === null || value === undefined) return <span className="muted">—</span>;
  if (typeof value === 'object') return <pre className="code-block">{JSON.stringify(value, null, 2)}</pre>;
  return <Ltr className="mono">{String(value)}</Ltr>;
}

function DiffView({ before, after }) {
  const { t } = useTranslation();
  if (!isPlainObject(before) && !isPlainObject(after)) {
    if (before == null && after == null) return <p className="muted">{t('audit.noChanges')}</p>;
    return (
      <div className="split split--even">
        <div className="stack stack--tight">
          <strong>{t('audit.before')}</strong>
          <Value value={before} />
        </div>
        <div className="stack stack--tight">
          <strong>{t('audit.after')}</strong>
          <Value value={after} />
        </div>
      </div>
    );
  }

  const left = isPlainObject(before) ? before : {};
  const right = isPlainObject(after) ? after : {};
  const keys = [...new Set([...Object.keys(left), ...Object.keys(right)])];
  if (!keys.length) return <p className="muted">{t('audit.noChanges')}</p>;

  const same = (a, b) => JSON.stringify(a ?? null) === JSON.stringify(b ?? null);

  return (
    <div className="diff">
      <div className="diff__head">{t('audit.field')}</div>
      <div className="diff__head">{t('audit.before')}</div>
      <div className="diff__head">{t('audit.after')}</div>
      {keys.map((key) => {
        const unchanged = same(left[key], right[key]);
        return (
          <div key={key} style={{ display: 'contents' }}>
            <div className="mono">{key}</div>
            <div className={unchanged ? 'diff__same' : 'diff__before'}>
              <Value value={left[key]} />
            </div>
            <div className={unchanged ? 'diff__same' : 'diff__after'}>
              <Value value={right[key]} />
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default function AuditPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const state = useAppSelector((slice) => slice.audit);
  const [draft, setDraft] = useState(EMPTY_FILTERS);
  const [actorError, setActorError] = useState(null);
  const [open, setOpen] = useState(null);

  useEffect(() => {
    dispatch(fetchAudit({ skip: 0 }));
  }, [dispatch]);

  const set = (key) => (event) => setDraft((current) => ({ ...current, [key]: event.target.value }));

  const apply = (event) => {
    event.preventDefault();
    const actor = draft.actorUserId.trim();
    if (actor && !OBJECT_ID.test(actor)) {
      setActorError(t('audit.actorIdInvalid'));
      return;
    }
    setActorError(null);
    dispatch(fetchAudit({ filters: { ...draft, actorUserId: actor }, skip: 0 }));
  };

  const reset = () => {
    setDraft(EMPTY_FILTERS);
    setActorError(null);
    dispatch(fetchAudit({ filters: EMPTY_FILTERS, skip: 0 }));
  };

  const columns = [
    { key: 'created_at', label: t('audit.when'), render: (row) => <DateCell value={row.created_at} /> },
    {
      key: 'actor_user_id',
      label: t('audit.actor'),
      render: (row) =>
        row.actor_user_id ? (
          <span className="row" style={{ gap: 6 }}>
            <IdChip value={row.actor_user_id} />
            {row.actor_role ? <Badge tone="plain">{t(`roles.${row.actor_role}`, { defaultValue: row.actor_role })}</Badge> : null}
          </span>
        ) : (
          <span className="muted">{t('audit.system')}</span>
        ),
    },
    { key: 'action', label: t('audit.action'), render: (row) => <Ltr className="mono">{actionLabel(t, row.action)}</Ltr> },
    {
      key: 'target_id',
      label: t('audit.target'),
      render: (row) => (
        <span className="row" style={{ gap: 6 }}>
          <span className="muted">{targetLabel(t, row.target_type)}</span>
          <IdChip value={row.target_id} />
        </span>
      ),
    },
    {
      key: 'open',
      label: t('app.actions'),
      render: (row) => (
        <button
          type="button"
          className="btn btn--outline btn--sm"
          onClick={(event) => {
            event.stopPropagation();
            setOpen(row);
          }}
        >
          <Icon name="eye" size={14} />
          {t('app.view')}
        </button>
      ),
    },
  ];

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('audit.title')}</h1>
          <p>{t('audit.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchAudit())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      <form className="card" onSubmit={apply} noValidate>
        <div className="card__head">
          <Icon name="search" />
          <h2 className="grow">{t('app.filters')}</h2>
        </div>
        <div className="card__body stack">
          <div className="split split--even" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(190px, 1fr))' }}>
            <Field label={t('audit.action')} htmlFor="audit-action">
              <select id="audit-action" className="select" value={draft.action} onChange={set('action')}>
                <option value="">{t('app.all')}</option>
                {AUDIT_ACTIONS.map((action) => (
                  <option key={action} value={action}>
                    {actionLabel(t, action)}
                  </option>
                ))}
              </select>
            </Field>
            <Field label={t('audit.targetType')} htmlFor="audit-target-type">
              <select id="audit-target-type" className="select" value={draft.targetType} onChange={set('targetType')}>
                <option value="">{t('app.all')}</option>
                {TARGET_TYPES.map((type) => (
                  <option key={type} value={type}>
                    {targetLabel(t, type)}
                  </option>
                ))}
              </select>
            </Field>
            <Field label={t('audit.actorId')} hint={t('audit.actorIdHint')} error={actorError} htmlFor="audit-actor">
              <input
                id="audit-actor"
                className="input ltr mono"
                value={draft.actorUserId}
                maxLength={24}
                aria-invalid={Boolean(actorError)}
                onChange={set('actorUserId')}
              />
            </Field>
            <Field label={t('audit.targetId')} htmlFor="audit-target">
              <input id="audit-target" className="input ltr mono" value={draft.targetId} maxLength={120} onChange={set('targetId')} />
            </Field>
            <Field label={t('audit.from')} htmlFor="audit-from">
              <input id="audit-from" className="input ltr" type="datetime-local" value={draft.from} onChange={set('from')} />
            </Field>
            <Field label={t('audit.to')} htmlFor="audit-to">
              <input id="audit-to" className="input ltr" type="datetime-local" value={draft.to} onChange={set('to')} />
            </Field>
          </div>
          <div className="row">
            <button type="submit" className="btn btn--primary btn--sm" disabled={state.status === 'loading'}>
              <Icon name="search" size={14} />
              {t('app.apply')}
            </button>
            <button type="button" className="btn btn--ghost btn--sm" onClick={reset}>
              {t('app.reset')}
            </button>
          </div>
        </div>
      </form>

      <ListPanel
        state={state}
        columns={columns}
        onRowClick={setOpen}
        onRetry={() => dispatch(fetchAudit())}
        onPage={(skip) => dispatch(fetchAudit({ skip }))}
        emptyText={t('audit.empty')}
        emptyIcon="history"
      />

      {open ? (
        <Modal
          title={t('audit.detail')}
          description={actionLabel(t, open.action)}
          onClose={() => setOpen(null)}
          labelledBy="audit-modal-title"
          wide
          footer={
            <button type="button" className="btn btn--ghost" onClick={() => setOpen(null)}>
              {t('app.close')}
            </button>
          }
        >
          <div className="stack">
            <KeyValue
              items={[
                [t('audit.action'), <Ltr className="mono">{open.action}</Ltr>],
                [
                  t('audit.actor'),
                  open.actor_user_id ? (
                    <span className="row" style={{ gap: 6 }}>
                      <IdChip value={open.actor_user_id} />
                      {open.actor_role ? t(`roles.${open.actor_role}`, { defaultValue: open.actor_role }) : null}
                    </span>
                  ) : (
                    t('audit.system')
                  ),
                ],
                [t('audit.targetType'), targetLabel(t, open.target_type)],
                [t('audit.targetId'), <Ltr className="mono">{open.target_id}</Ltr>],
                [t('audit.when'), <DateCell value={open.created_at} />],
                [t('audit.ip'), open.ip ? <Ltr className="mono">{open.ip}</Ltr> : '—'],
              ]}
            />
            <DiffView before={open.before} after={open.after} />
          </div>
        </Modal>
      ) : null}
    </div>
  );
}