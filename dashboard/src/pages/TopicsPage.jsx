import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { clearTopicError, createTopic, fetchTopics } from '../features/topics/topicsSlice.js';
import { can } from '../app/permissions.js';
import { toast } from '../app/feedback.js';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import { DateCell, Ltr } from '../components/Data.jsx';
import { InlineError } from '../components/States.jsx';

const KEY_PATTERN = /^[\p{L}\p{N}_.-]{2,80}$/u;

export default function TopicsPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const state = useAppSelector((slice) => slice.topics);
  const role = useAppSelector((slice) => slice.auth.user?.role);
  const writable = can(role, 'topics.write');
  const [form, setForm] = useState({ key: '', nameAr: '', nameEn: '' });
  const [errors, setErrors] = useState({});

  useEffect(() => {
    dispatch(fetchTopics());
  }, [dispatch]);

  const submit = async (event) => {
    event.preventDefault();
    const next = {};
    const key = form.key.trim();
    if (!key) next.key = t('topics.keyRequired');
    else if (!KEY_PATTERN.test(key)) next.key = t('topics.keyHint');
    setErrors(next);
    if (Object.keys(next).length) return;

    dispatch(clearTopicError());
    try {
      await dispatch(
        createTopic({
          key,
          ...(form.nameAr.trim() ? { nameAr: form.nameAr.trim() } : {}),
          ...(form.nameEn.trim() ? { nameEn: form.nameEn.trim() } : {}),
        }),
      ).unwrap();
      setForm({ key: '', nameAr: '', nameEn: '' });
      dispatch(toast(t('topics.created'), 'success'));
    } catch {
      /* the slice keeps the translated error */
    }
  };

  const columns = [
    { key: 'key', label: t('topics.key'), render: (row) => <Ltr className="mono">{row.key}</Ltr> },
    { key: 'name_ar', label: t('topics.nameAr'), render: (row) => row.name_ar ?? '—' },
    { key: 'name_en', label: t('topics.nameEn'), render: (row) => <Ltr>{row.name_en ?? '—'}</Ltr> },
    { key: 'created_at', label: t('app.createdAt'), render: (row) => <DateCell value={row.created_at} /> },
  ];

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('topics.title')}</h1>
          <p>{t('topics.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <span className="muted mono">{t('topics.count', { count: state.total })}</span>
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchTopics())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      {writable ? (
        <form className="card" onSubmit={submit} noValidate>
          <div className="card__head">
            <Icon name="plus" />
            <h2 className="grow">{t('topics.create')}</h2>
          </div>
          <div className="card__body stack">
            <InlineError error={state.createError} />
            <div className="split split--even" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))' }}>
              <Field label={t('topics.key')} required hint={t('topics.keyHint')} error={errors.key} htmlFor="topic-key">
                <input
                  id="topic-key"
                  className="input ltr"
                  value={form.key}
                  maxLength={80}
                  aria-invalid={Boolean(errors.key)}
                  onChange={(event) => setForm((current) => ({ ...current, key: event.target.value }))}
                />
              </Field>
              <Field label={t('topics.nameAr')} htmlFor="topic-ar">
                <input
                  id="topic-ar"
                  className="input"
                  value={form.nameAr}
                  maxLength={200}
                  onChange={(event) => setForm((current) => ({ ...current, nameAr: event.target.value }))}
                />
              </Field>
              <Field label={t('topics.nameEn')} htmlFor="topic-en">
                <input
                  id="topic-en"
                  className="input ltr"
                  value={form.nameEn}
                  maxLength={200}
                  onChange={(event) => setForm((current) => ({ ...current, nameEn: event.target.value }))}
                />
              </Field>
            </div>
            <div className="row">
              <button type="submit" className="btn btn--primary" disabled={state.creating}>
                {state.creating ? <span className="spinner" aria-hidden="true" /> : <Icon name="plus" />}
                {state.creating ? t('topics.creating') : t('topics.create')}
              </button>
            </div>
          </div>
        </form>
      ) : null}

      <ListPanel
        state={state}
        columns={columns}
        onRetry={() => dispatch(fetchTopics())}
        emptyText={t('topics.empty')}
        emptyIcon="tag"
      />
    </div>
  );
}