import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import {
  clearReportError,
  clearSelected,
  fetchReports,
  resolveReport,
  selectAll,
  toggleSelected,
} from '../features/reports/reportsSlice.js';
import { REPORT_STATUSES, REPORT_TONES } from '../lib/constants.js';
import { can } from '../app/permissions.js';
import { toast } from '../app/feedback.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import Modal from '../components/Modal.jsx';
import { DateCell, IdChip, Ltr } from '../components/Data.jsx';
import { InlineError } from '../components/States.jsx';

export default function ReportsPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const state = useAppSelector((slice) => slice.reports);
  const role = useAppSelector((slice) => slice.auth.user?.role);
  const writable = can(role, 'reports.write');
  const status = state.filters.status;
  const [review, setReview] = useState(null);
  const [note, setNote] = useState('');

  useEffect(() => {
    dispatch(fetchReports({ skip: 0 }));
  }, [dispatch]);

  const openReview = (ids, nextStatus) => {
    dispatch(clearReportError());
    setNote('');
    setReview({ ids, status: nextStatus });
  };

  const closeReview = () => {
    setReview(null);
    dispatch(clearReportError());
  };

  const submitReview = async (event) => {
    event.preventDefault();
    if (!review) return;
    const trimmed = note.trim();
    let done = 0;
    for (const id of review.ids) {
      try {
        await dispatch(
          resolveReport({ id, status: review.status, ...(trimmed ? { note: trimmed } : {}) }),
        ).unwrap();
        done += 1;
      } catch {
        break;
      }
    }
    if (done) {
      dispatch(toast(done === 1 ? t('reports.done') : t('reports.bulkDone', { count: done }), 'success'));
      closeReview();
    }
  };

  const columns = [
    {
      key: 'reason',
      label: t('reports.reason'),
      render: (row) => <span className="clamp-2">{row.reason}</span>,
    },
    {
      key: 'question',
      label: t('reports.question'),
      render: (row) => (
        <span className="stack stack--tight" style={{ gap: 0 }}>
          <Ltr className="mono">{row.question?.path ?? '—'}</Ltr>
          <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
            {t(`questionType.${row.question?.type}`, { defaultValue: row.question?.type ?? '' })}
          </span>
        </span>
      ),
    },
    {
      key: 'exam',
      label: t('reports.exam'),
      render: (row) =>
        row.exam?.id ? (
          <Link
            to={`/exams/${row.exam.id}`}
            className="mono ltr"
            onClick={(event) => event.stopPropagation()}
          >
            {row.exam.exam_key}
          </Link>
        ) : (
          <span className="muted">—</span>
        ),
    },
    {
      key: 'user',
      label: t('reports.student'),
      render: (row) => (
        <span className="stack stack--tight" style={{ gap: 0 }}>
          <span>{row.user?.name ?? t('app.unknown')}</span>
          {row.user?.email ? (
            <Ltr className="muted mono">{row.user.email}</Ltr>
          ) : row.user?.phone ? (
            <Ltr className="muted mono">{row.user.phone}</Ltr>
          ) : null}
        </span>
      ),
    },
    {
      key: 'created_at',
      label: t('reports.reportedAt'),
      render: (row) => <DateCell value={row.created_at} />,
    },
    {
      key: 'status',
      label: t('app.status'),
      render: (row) => (
        <Badge tone={REPORT_TONES[row.status] ?? 'neutral'}>{t(`reports.${row.status}`)}</Badge>
      ),
    },
    {
      key: 'actions',
      label: t('app.actions'),
      render: (row) =>
        row.status === 'open' && writable ? (
          <div className="row" style={{ gap: 4 }}>
            <button
              type="button"
              className="btn btn--success btn--sm"
              onClick={(event) => {
                event.stopPropagation();
                openReview([row.id], 'resolved');
              }}
            >
              <Icon name="check" size={14} />
              {t('reports.resolve')}
            </button>
            <button
              type="button"
              className="btn btn--ghost btn--sm"
              onClick={(event) => {
                event.stopPropagation();
                openReview([row.id], 'dismissed');
              }}
            >
              {t('reports.dismiss')}
            </button>
          </div>
        ) : row.status === 'open' ? (
          <span className="muted">{t('reports.open')}</span>
        ) : (
          <span className="stack stack--tight" style={{ gap: 0 }}>
            <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
              <DateCell value={row.resolved_at} />
            </span>
            {row.resolved_by ? <IdChip value={row.resolved_by} /> : null}
          </span>
        ),
    },
  ];

  const selection =
    writable && status === 'open'
      ? {
          selected: state.selected,
          onToggle: (id) => dispatch(toggleSelected(id)),
          onSelectAll: (ids) => dispatch(selectAll(ids)),
          onClear: () => dispatch(clearSelected()),
        }
      : undefined;

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('reports.title')}</h1>
          <p>{t('reports.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchReports())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      <div className="tabs" role="tablist" aria-label={t('app.status')}>
        {REPORT_STATUSES.map((value) => (
          <button
            key={value}
            type="button"
            role="tab"
            aria-selected={status === value}
            className={`tab${status === value ? ' tab--active' : ''}`}
            onClick={() => dispatch(fetchReports({ filters: { status: value }, skip: 0 }))}
          >
            {t(`reports.${value}`)}
            {status === value ? <span className="tab__count">{state.total}</span> : null}
          </button>
        ))}
      </div>

      {selection && state.selected.length ? (
        <div className="bulk-bar">
          <strong>{t('app.selected', { count: state.selected.length })}</strong>
          <span className="grow" />
          <button
            type="button"
            className="btn btn--success btn--sm"
            onClick={() => openReview(state.selected, 'resolved')}
            disabled={state.saving}
          >
            <Icon name="check" size={14} />
            {t('reports.bulkResolve')}
          </button>
          <button
            type="button"
            className="btn btn--ghost btn--sm"
            onClick={() => openReview(state.selected, 'dismissed')}
            disabled={state.saving}
          >
            {t('reports.bulkDismiss')}
          </button>
          <button type="button" className="btn btn--ghost btn--sm" onClick={() => dispatch(clearSelected())}>
            {t('app.clearSelection')}
          </button>
        </div>
      ) : null}

      <ListPanel
        state={state}
        columns={columns}
        selection={selection}
        onRetry={() => dispatch(fetchReports())}
        onPage={(skip) => dispatch(fetchReports({ skip }))}
        emptyText={t('reports.empty')}
        emptyIcon="flag"
      />

      {review ? (
        <Modal
          title={t('reports.reviewTitle')}
          description={
            review.ids.length === 1
              ? t(review.status === 'resolved' ? 'reports.confirmResolve' : 'reports.confirmDismiss')
              : t('app.selected', { count: review.ids.length })
          }
          onClose={state.saving ? undefined : closeReview}
          labelledBy="report-modal-title"
          footer={
            <>
              <button type="button" className="btn btn--ghost" onClick={closeReview} disabled={state.saving}>
                {t('app.cancel')}
              </button>
              <button
                type="submit"
                form="report-review-form"
                className={`btn btn--${review.status === 'resolved' ? 'success' : 'primary'}`}
                disabled={state.saving}
              >
                {state.saving ? <span className="spinner" aria-hidden="true" /> : <Icon name="check" />}
                {t(review.status === 'resolved' ? 'reports.resolve' : 'reports.dismiss')}
              </button>
            </>
          }
        >
          <form id="report-review-form" onSubmit={submitReview} noValidate className="stack">
            <InlineError error={state.saveError} />
            <Field label={t('reports.note')} htmlFor="report-note">
              <textarea
                id="report-note"
                className="textarea"
                rows={4}
                maxLength={1000}
                value={note}
                placeholder={t('reports.notePlaceholder')}
                onChange={(event) => setNote(event.target.value)}
              />
            </Field>
          </form>
        </Modal>
      ) : null}
    </div>
  );
}