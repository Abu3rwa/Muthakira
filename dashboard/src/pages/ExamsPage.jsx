import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { fetchExams } from '../features/exams/examsSlice.js';
import { fetchSettings } from '../features/settings/settingsSlice.js';
import { can } from '../app/permissions.js';
import { EXAM_STATUSES, EXAM_TONES } from '../lib/constants.js';
import { formatMarks } from '../lib/format.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import { Credits, Ltr } from '../components/Data.jsx';

export default function ExamsPage() {
  const { t, i18n } = useTranslation();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const state = useAppSelector((slice) => slice.exams);
  const role = useAppSelector((slice) => slice.auth.user?.role);
  const settings = useAppSelector((slice) => slice.settings);
  const [draft, setDraft] = useState({ subject: '', class_level: '', exam_year: '' });

  useEffect(() => {
    dispatch(fetchExams({ skip: 0 }));
  }, [dispatch]);

  useEffect(() => {
    if (can(role, 'settings.read') && settings.status === 'idle') dispatch(fetchSettings());
  }, [dispatch, role, settings.status]);

  const defaultCost = settings.items.find((item) => item.key === 'credits.exam_unlock')?.value;

  const applyText = (event) => {
    event.preventDefault();
    dispatch(fetchExams({ filters: draft, skip: 0 }));
  };

  const columns = [
    {
      key: 'exam_key',
      label: t('exams.examKey'),
      render: (row) => <Ltr className="mono">{row.exam_key}</Ltr>,
    },
    { key: 'subject', label: t('exams.subject') },
    {
      key: 'exam_year',
      label: t('exams.year'),
      render: (row) => (
        <span className="nowrap">
          <span className="num">{row.exam_year}</span>
          {row.session ? <span className="muted"> · {row.session}</span> : null}
        </span>
      ),
    },
    { key: 'class_level', label: t('exams.classLevel') },
    {
      key: 'language',
      label: t('exams.language'),
      render: (row) => (row.language === 'ar' ? t('app.arabic') : t('app.english')),
    },
    {
      key: 'status',
      label: t('app.status'),
      render: (row) => <Badge tone={EXAM_TONES[row.status] ?? 'neutral'}>{t(`examStatus.${row.status}`)}</Badge>,
    },
    {
      key: 'question_count',
      label: t('exams.questions'),
      align: 'num',
      render: (row) => (
        <span className="nowrap">
          <Credits value={row.question_count} />
          <span className="muted"> / {row.leaf_question_count ?? 0}</span>
        </span>
      ),
    },
    {
      key: 'total_marks',
      label: t('exams.totalMarks'),
      align: 'num',
      render: (row) => <span className="num">{formatMarks(row.total_marks, i18n.language)}</span>,
    },
    {
      key: 'unlock_cost',
      label: t('exams.unlockCost'),
      align: 'num',
      render: (row) =>
        row.is_free ? (
          <Badge tone="success" plain>
            {t('exams.isFree')}
          </Badge>
        ) : (
          <span className="num" title={row.unlock_cost == null ? t('exams.defaultCost', { cost: defaultCost ?? '—' }) : undefined}>
            <Credits value={row.unlock_cost ?? defaultCost ?? 0} />
            {row.unlock_cost == null ? <span className="muted">*</span> : null}
          </span>
        ),
    },
    {
      key: 'open',
      label: t('app.actions'),
      align: 'center',
      width: '1%',
      render: (row) => (
        <button
          type="button"
          className="btn btn--outline btn--sm"
          onClick={(event) => {
            event.stopPropagation();
            navigate(`/exams/${row.id}`);
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
          <h1>{t('exams.title')}</h1>
          <p>{t('exams.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchExams())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
          {can(role, 'exams.import') ? (
            <Link to="/exams/import" className="btn btn--primary btn--sm">
              <Icon name="upload" size={14} />
              {t('exams.import')}
            </Link>
          ) : null}
        </div>
      </div>

      <form className="toolbar" onSubmit={applyText}>
        <Field label={t('exams.filterStatus')} inline htmlFor="filter-status">
          <select
            id="filter-status"
            className="select"
            value={state.filters.status}
            onChange={(event) => dispatch(fetchExams({ filters: { status: event.target.value }, skip: 0 }))}
          >
            <option value="">{t('app.all')}</option>
            {EXAM_STATUSES.map((value) => (
              <option key={value} value={value}>
                {t(`examStatus.${value}`)}
              </option>
            ))}
          </select>
        </Field>
        <Field label={t('exams.filterLanguage')} inline htmlFor="filter-language">
          <select
            id="filter-language"
            className="select"
            value={state.filters.language}
            onChange={(event) => dispatch(fetchExams({ filters: { language: event.target.value }, skip: 0 }))}
          >
            <option value="">{t('app.all')}</option>
            <option value="ar">{t('app.arabic')}</option>
            <option value="en">{t('app.english')}</option>
          </select>
        </Field>
        <Field label={t('exams.filterSubject')} inline htmlFor="filter-subject">
          <input
            id="filter-subject"
            className="input"
            value={draft.subject}
            onChange={(event) => setDraft((current) => ({ ...current, subject: event.target.value }))}
          />
        </Field>
        <Field label={t('exams.filterClass')} inline htmlFor="filter-class">
          <input
            id="filter-class"
            className="input"
            value={draft.class_level}
            onChange={(event) => setDraft((current) => ({ ...current, class_level: event.target.value }))}
          />
        </Field>
        <Field label={t('exams.filterYear')} inline htmlFor="filter-year">
          <input
            id="filter-year"
            className="input"
            type="number"
            min={1900}
            max={2200}
            style={{ minWidth: 90 }}
            value={draft.exam_year}
            onChange={(event) => setDraft((current) => ({ ...current, exam_year: event.target.value }))}
          />
        </Field>
        <button type="submit" className="btn btn--secondary btn--sm">
          <Icon name="search" size={14} />
          {t('app.apply')}
        </button>
        <button
          type="button"
          className="btn btn--ghost btn--sm"
          onClick={() => {
            setDraft({ subject: '', class_level: '', exam_year: '' });
            dispatch(
              fetchExams({
                filters: { status: '', language: '', subject: '', class_level: '', exam_year: '', session: '' },
                skip: 0,
              }),
            );
          }}
        >
          {t('app.reset')}
        </button>
      </form>

      <ListPanel
        state={state}
        columns={columns}
        onRowClick={(row) => navigate(`/exams/${row.id}`)}
        onRetry={() => dispatch(fetchExams())}
        onPage={(skip) => dispatch(fetchExams({ skip }))}
        emptyText={t('exams.empty')}
        emptyIcon="paper"
        footerNote={defaultCost == null ? undefined : t('exams.defaultCost', { cost: defaultCost })}
      />
    </div>
  );
}