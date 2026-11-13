import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import {
  clearAiError,
  fetchAiReviews,
  resolveAiReview,
} from '../features/ai/aiSlice.js';
import { AI_REVIEW_STATUSES, AI_REVIEW_TONES } from '../lib/constants.js';
import { can } from '../app/permissions.js';
import { toast } from '../app/feedback.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import Modal from '../components/Modal.jsx';
import { DateCell, IdChip, Ltr } from '../components/Data.jsx';
import { InlineError } from '../components/States.jsx';

function GradingPayload({ payload }) {
  const { t } = useTranslation();
  return (
    <dl className="kv">
      <div style={{ display: 'contents' }}>
        <dt className="kv__k">{t('ai.review.proposedMarks')}</dt>
        <dd className="kv__v">
          <Ltr className="mono num">
            {payload.proposed_marks} / {payload.maximum_marks}
          </Ltr>
        </dd>
      </div>
      <div style={{ display: 'contents' }}>
        <dt className="kv__k">{t('ai.review.confidence')}</dt>
        <dd className="kv__v"><Ltr className="mono num">{payload.confidence}</Ltr></dd>
      </div>
      <div style={{ display: 'contents' }}>
        <dt className="kv__k">{t('ai.review.feedback')}</dt>
        <dd className="kv__v">{payload.feedback}</dd>
      </div>
      {payload.missing_points?.length ? (
        <div style={{ display: 'contents' }}>
          <dt className="kv__k">{t('ai.review.missingPoints')}</dt>
          <dd className="kv__v">{payload.missing_points.join(' · ')}</dd>
        </div>
      ) : null}
    </dl>
  );
}

function GenerationPayload({ payload }) {
  const { t } = useTranslation();
  const questions = payload.questions ?? [];
  return (
    <div className="stack">
      <span className="muted" style={{ fontSize: 'var(--text-sm)' }}>
        {t('ai.review.questionCount', { count: questions.length })}
      </span>
      {questions.map((question, index) => (
        <div className="card" key={index}>
          <div className="card__body stack stack--tight">
            <div className="row" style={{ gap: 8 }}>
              <Badge tone="info">{t(`questionType.${question.type}`, { defaultValue: question.type })}</Badge>
              <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
                {t('exams.difficulty')}: <Ltr className="mono">{question.difficulty}</Ltr>
              </span>
            </div>
            <p>{question.text}</p>
            {question.options?.length ? (
              <ul className="muted" style={{ fontSize: 'var(--text-sm)', margin: 0, paddingInlineStart: 18 }}>
                {question.options.map((option, optionIndex) => (
                  <li key={optionIndex}>{option}</li>
                ))}
              </ul>
            ) : null}
            <span style={{ fontSize: 'var(--text-sm)' }}>
              {t('exams.key')}: <Ltr className="mono">{String(question.key)}</Ltr>
            </span>
            {question.explanation ? (
              <span className="muted" style={{ fontSize: 'var(--text-sm)' }}>{question.explanation}</span>
            ) : null}
          </div>
        </div>
      ))}
    </div>
  );
}

export default function AiReviewsPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const state = useAppSelector((slice) => slice.ai.reviews);
  const saving = useAppSelector((slice) => slice.ai.saving);
  const saveError = useAppSelector((slice) => slice.ai.saveError);
  const role = useAppSelector((slice) => slice.auth.user?.role);
  const writable = can(role, 'ai.review');
  const status = state.filters.status;
  const kind = state.filters.kind || '';
  const [review, setReview] = useState(null);
  const [note, setNote] = useState('');

  useEffect(() => {
    dispatch(fetchAiReviews({ skip: 0 }));
  }, [dispatch]);

  const openReview = (item) => {
    dispatch(clearAiError());
    setNote('');
    setReview(item);
  };

  const closeReview = () => {
    setReview(null);
    dispatch(clearAiError());
  };

  const submit = async (nextStatus) => {
    if (!review) return;
    const trimmed = note.trim();
    try {
      await dispatch(
        resolveAiReview({ id: review.id, status: nextStatus, ...(trimmed ? { note: trimmed } : {}) }),
      ).unwrap();
      dispatch(toast(t('ai.review.done'), 'success'));
      closeReview();
    } catch {
      /* the slice keeps the error in the modal */
    }
  };

  const columns = [
    {
      key: 'kind',
      label: t('ai.review.kind'),
      render: (row) => (
        <Badge tone={row.kind === 'grading' ? 'info' : 'success'}>{t(`ai.kind.${row.kind}`)}</Badge>
      ),
    },
    {
      key: 'user',
      label: t('ai.student'),
      render: (row) => row.user?.name ?? t('app.unknown'),
    },
    {
      key: 'reason',
      label: t('ai.review.reason'),
      render: (row) => <span className="clamp-2">{row.reason}</span>,
    },
    { key: 'ref_id', label: t('ai.review.ref'), render: (row) => <IdChip value={row.ref_id} /> },
    { key: 'created_at', label: t('ai.when'), render: (row) => <DateCell value={row.created_at} /> },
    {
      key: 'status',
      label: t('app.status'),
      render: (row) =>
        row.status === 'pending' && writable ? (
          <div className="row" style={{ gap: 4 }}>
            <button
              type="button"
              className="btn btn--success btn--sm"
              onClick={(event) => {
                event.stopPropagation();
                openReview(row);
              }}
            >
              <Icon name="check" size={14} />
              {t('ai.review.open')}
            </button>
          </div>
        ) : (
          <span className="stack stack--tight" style={{ gap: 0 }}>
            <Badge tone={AI_REVIEW_TONES[row.status] ?? 'neutral'}>{t(`ai.review.${row.status}`)}</Badge>
            {row.resolved_at ? (
              <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
                <DateCell value={row.resolved_at} />
              </span>
            ) : null}
          </span>
        ),
    },
  ];

  const reviewPending = review?.status === 'pending' && writable;

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('ai.review.title')}</h1>
          <p>{t('ai.review.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <label className="field" style={{ marginBottom: 0 }}>
            <span className="field__label">{t('ai.review.kind')}</span>
            <select
              className="input"
              value={kind}
              onChange={(event) => dispatch(fetchAiReviews({ filters: { kind: event.target.value }, skip: 0 }))}
            >
              <option value="">{t('app.all')}</option>
              <option value="grading">{t('ai.kind.grading')}</option>
              <option value="generation">{t('ai.kind.generation')}</option>
            </select>
          </label>
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchAiReviews())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      <div className="tabs" role="tablist" aria-label={t('app.status')}>
        {AI_REVIEW_STATUSES.map((value) => (
          <button
            key={value}
            type="button"
            role="tab"
            aria-selected={status === value}
            className={`tab${status === value ? ' tab--active' : ''}`}
            onClick={() => dispatch(fetchAiReviews({ filters: { status: value }, skip: 0 }))}
          >
            {t(`ai.review.${value}`)}
            {status === value ? <span className="tab__count">{state.total}</span> : null}
          </button>
        ))}
      </div>

      <ListPanel
        state={state}
        columns={columns}
        onRowClick={openReview}
        onRetry={() => dispatch(fetchAiReviews())}
        onPage={(skip) => dispatch(fetchAiReviews({ skip }))}
        emptyText={t('ai.review.empty')}
        emptyIcon="spark"
      />

      {review ? (
        <Modal
          wide={review.kind === 'generation'}
          title={t('ai.review.modalTitle')}
          description={`${review.user?.name ?? t('app.unknown')} · ${review.reason}`}
          onClose={saving ? undefined : closeReview}
          labelledBy="ai-review-modal-title"
          footer={
            reviewPending ? (
              <>
                <button type="button" className="btn btn--ghost" onClick={closeReview} disabled={saving}>
                  {t('app.cancel')}
                </button>
                <button
                  type="button"
                  className="btn btn--danger"
                  onClick={() => submit('rejected')}
                  disabled={saving}
                >
                  {saving ? <span className="spinner" aria-hidden="true" /> : <Icon name="close" />}
                  {t('ai.review.reject')}
                </button>
                <button
                  type="button"
                  className="btn btn--success"
                  onClick={() => submit('approved')}
                  disabled={saving}
                >
                  {saving ? <span className="spinner" aria-hidden="true" /> : <Icon name="check" />}
                  {t('ai.review.approve')}
                </button>
              </>
            ) : (
              <button type="button" className="btn btn--ghost" onClick={closeReview}>
                {t('app.close')}
              </button>
            )
          }
        >
          <div className="stack">
            <InlineError error={saveError} />
            {reviewPending ? (
              <div className="notice notice--warning" role="note">
                <Icon name="alert" />
                <span>
                  {review.kind === 'generation'
                    ? t('ai.review.generationHint')
                    : t('ai.review.gradingHint')}
                </span>
              </div>
            ) : null}
            {review.kind === 'grading' ? (
              <GradingPayload payload={review.payload ?? {}} />
            ) : (
              <GenerationPayload payload={review.payload ?? {}} />
            )}
            {reviewPending ? (
              <Field label={t('ai.review.note')} htmlFor="ai-review-note">
                <textarea
                  id="ai-review-note"
                  className="textarea"
                  rows={3}
                  maxLength={1000}
                  value={note}
                  placeholder={t('ai.review.notePlaceholder')}
                  onChange={(event) => setNote(event.target.value)}
                />
              </Field>
            ) : review.resolution_note ? (
              <Field label={t('ai.review.note')} htmlFor="ai-review-note-readonly">
                <p id="ai-review-note-readonly">{review.resolution_note}</p>
              </Field>
            ) : null}
          </div>
        </Modal>
      ) : null}
    </div>
  );
}