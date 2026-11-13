import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { blockExam, configExam, fetchExam, publishExam, unpublishExam } from '../features/exams/examsSlice.js';
import { fetchSettings } from '../features/settings/settingsSlice.js';
import { can } from '../app/permissions.js';
import { confirmAction, toast } from '../app/feedback.js';
import { EXAM_TONES } from '../lib/constants.js';
import { formatMarks } from '../lib/format.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import Modal from '../components/Modal.jsx';
import QuestionTree from '../components/QuestionTree.jsx';
import { DateCell, KeyValue, Ltr } from '../components/Data.jsx';
import { EmptyState, ErrorState, InlineError, Loading, NotFound } from '../components/States.jsx';

export default function ExamDetailPage() {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const detail = useAppSelector((state) => state.exams.detail);
  const role = useAppSelector((state) => state.auth.user?.role);
  const settings = useAppSelector((state) => state.settings);
  const exam = detail.byId[id];
  const [config, setConfig] = useState({ isFree: false, unlockCost: '', practiceEnabled: true });
  const [blockOpen, setBlockOpen] = useState(false);
  const [reason, setReason] = useState('');
  const [reasonError, setReasonError] = useState(null);

  const canConfig = can(role, 'exams.config');
  const canBlock = can(role, 'exams.block');

  useEffect(() => {
    dispatch(fetchExam(id));
  }, [dispatch, id]);

  useEffect(() => {
    if (canConfig && settings.status === 'idle') dispatch(fetchSettings());
  }, [dispatch, canConfig, settings.status]);

  useEffect(() => {
    if (!exam) return;
    setConfig({
      isFree: Boolean(exam.is_free),
      unlockCost: exam.unlock_cost == null ? '' : String(exam.unlock_cost),
      practiceEnabled: exam.practice_enabled !== false,
    });
  }, [exam?.id, exam?.is_free, exam?.unlock_cost, exam?.practice_enabled]);

  if (detail.status === 'loading' && !exam) return <div className="page"><Loading /></div>;

  if (detail.status === 'error' && !exam) {
    return (
      <div className="page">
        <div className="card">
          {detail.error?.status === 404 ? (
            <NotFound />
          ) : (
            <ErrorState error={detail.error} onRetry={() => dispatch(fetchExam(id))} />
          )}
        </div>
      </div>
    );
  }

  if (!exam) return <div className="page"><Loading /></div>;

  const defaultCost = settings.items.find((item) => item.key === 'credits.exam_unlock')?.value;

  const run = (thunk, arg, message, tone = 'success') => {
    dispatch(
      confirmAction(
        { title: message, body: t(`exams.confirm${arg.confirm}Body`), confirmLabel: message },
        async () => {
          try {
            await dispatch(thunk(arg.payload)).unwrap();
            dispatch(toast(message, tone));
          } catch {
            dispatch(toast(t('app.errorTitle'), 'danger'));
          }
        },
      ),
    );
  };

  const saveConfig = async (event) => {
    event.preventDefault();
    const cost = config.unlockCost === '' ? null : Number(config.unlockCost);
    try {
      await dispatch(
        configExam({ id, isFree: config.isFree, unlockCost: cost, practiceEnabled: config.practiceEnabled }),
      ).unwrap();
      dispatch(toast(t('exams.saved'), 'success'));
    } catch {
      dispatch(toast(t('app.errorTitle'), 'danger'));
    }
  };

  const submitBlock = async (event) => {
    event.preventDefault();
    const trimmed = reason.trim();
    if (trimmed.length < 2) {
      setReasonError(t('exams.blockReasonRequired'));
      return;
    }
    setReasonError(null);
    try {
      await dispatch(blockExam({ id, reason: trimmed })).unwrap();
      setBlockOpen(false);
      setReason('');
      dispatch(toast(t('exams.blocked'), 'warning'));
    } catch {
      /* surfaced in the modal */
    }
  };

  const facts = [
    [t('exams.examKey'), <Ltr className="mono">{exam.exam_key}</Ltr>],
    [t('exams.subject'), exam.subject],
    [t('exams.year'), `${exam.exam_year}${exam.session ? ` · ${exam.session}` : ''}`],
    [t('exams.classLevel'), exam.class_level ?? '—'],
    [t('exams.stream'), exam.stream ?? '—'],
    [t('exams.language'), exam.language === 'ar' ? t('app.arabic') : t('app.english')],
    [t('exams.duration'), exam.duration_minutes ?? '—'],
    [t('exams.totalMarks'), formatMarks(exam.total_marks, i18n.language)],
    [t('exams.questions'), `${exam.question_count} · ${t('exams.leaves')}: ${exam.leaf_question_count}`],
    [t('exams.source'), exam.source ?? '—'],
    [t('exams.rightsStatus'), exam.rights_status ?? '—'],
    [t('exams.rights'), exam.rights_note ?? '—'],
    [t('exams.importedAt'), <DateCell value={exam.imported_at ?? exam.created_at} />],
    [t('exams.publishedAt'), <DateCell value={exam.published_at} />],
    [t('app.updatedAt'), <DateCell value={exam.updated_at} />],
  ];

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1 className="row">
            <span className="ltr">{exam.exam_key}</span>
            <Badge tone={EXAM_TONES[exam.status] ?? 'neutral'}>{t(`examStatus.${exam.status}`)}</Badge>
            {exam.is_free ? <Badge tone="success" plain>{t('exams.isFree')}</Badge> : null}
          </h1>
          <p>
            {exam.subject} · {exam.exam_year} · {exam.class_level}
          </p>
        </div>
        <div className="page-head__actions">
          <button type="button" className="btn btn--ghost btn--sm" onClick={() => navigate('/exams')}>
            <Icon name="chevronRight" size={14} className="flip-rtl" />
            {t('app.back')}
          </button>
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchExam(id))}
            disabled={detail.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
          {exam.status === 'published' ? (
            <button
              type="button"
              className="btn btn--outline btn--sm"
              disabled={detail.saving}
              onClick={() =>
                run(unpublishExam, { payload: { id }, confirm: 'Unpublish' }, t('exams.unpublished'), 'warning')
              }
            >
              <Icon name="eye" size={14} />
              {t('exams.unpublish')}
            </button>
          ) : (
            <button
              type="button"
              className="btn btn--success btn--sm"
              disabled={detail.saving || exam.status === 'blocked'}
              onClick={() => run(publishExam, { payload: { id }, confirm: 'Publish' }, t('exams.published'))}
            >
              <Icon name="check" size={14} />
              {t('exams.publish')}
            </button>
          )}
          {canBlock && exam.status !== 'blocked' ? (
            <button
              type="button"
              className="btn btn--danger btn--sm"
              disabled={detail.saving}
              onClick={() => setBlockOpen(true)}
            >
              <Icon name="lock" size={14} />
              {t('exams.block')}
            </button>
          ) : null}
        </div>
      </div>

      <InlineError error={detail.error} />

      {exam.status === 'blocked' ? (
        <div className="notice notice--danger">
          <Icon name="lock" />
          <span>
            <strong>{t('exams.blockReason')}: </strong>
            {exam.blocked_reason ?? '—'}
          </span>
        </div>
      ) : null}

      <div className="split">
        <div className="stack">
          <div className="card">
            <div className="card__head">
              <Icon name="paper" />
              <h2 className="grow">{t('exams.detail')}</h2>
            </div>
            <div className="card__body stack">
              <KeyValue items={facts} />
              {exam.instructions ? (
                <div className="field">
                  <span className="field__label">{t('exams.instructions')}</span>
                  <p style={{ whiteSpace: 'pre-wrap' }}>{exam.instructions}</p>
                </div>
              ) : null}
            </div>
          </div>

          <div className="card">
            <div className="card__head">
              <Icon name="inbox" />
              <h2 className="grow">{t('exams.stimuli')}</h2>
              <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
                {t('app.rows', { count: exam.stimuli?.length ?? 0 })}
              </span>
            </div>
            <div className="card__body">
              {exam.stimuli?.length ? (
                <div className="stack">
                  {exam.stimuli.map((stimulus) => (
                    <div key={stimulus.id} className="field">
                      <span className="field__label row">
                        <Ltr className="mono">{stimulus.stimulus_key}</Ltr>
                        <Badge tone="neutral" plain>
                          {stimulus.kind}
                        </Badge>
                        {stimulus.title ? <span>{stimulus.title}</span> : null}
                      </span>
                      <p style={{ whiteSpace: 'pre-wrap' }}>{stimulus.text}</p>
                    </div>
                  ))}
                </div>
              ) : (
                <EmptyState text={t('exams.noStimuli')} />
              )}
            </div>
          </div>
        </div>

        <div className="card">
          <div className="card__head">
            <Icon name="sliders" />
            <h2 className="grow">{t('exams.config')}</h2>
          </div>
          <div className="card__body">
            {canConfig ? (
              <form className="stack" onSubmit={saveConfig}>
                <label className={`check${config.isFree ? ' check--on' : ''}`}>
                  <input
                    type="checkbox"
                    checked={config.isFree}
                    onChange={(event) => setConfig((current) => ({ ...current, isFree: event.target.checked }))}
                  />
                  <span className="check__box" aria-hidden="true">
                    <Icon name="check" size={13} />
                  </span>
                  <span className="check__text">
                    <strong>{t('exams.isFree')}</strong>
                    <span>{t('access.free')}</span>
                  </span>
                </label>

                <Field
                  label={t('exams.unlockCost')}
                  hint={t('exams.unlockCostHint')}
                  htmlFor="unlock-cost"
                >
                  <input
                    id="unlock-cost"
                    className="input"
                    type="number"
                    min={0}
                    max={100000}
                    disabled={config.isFree}
                    value={config.unlockCost}
                    placeholder={defaultCost == null ? '' : String(defaultCost)}
                    onChange={(event) => setConfig((current) => ({ ...current, unlockCost: event.target.value }))}
                  />
                </Field>
                {defaultCost != null ? (
                  <p className="field__hint">{t('exams.defaultCost', { cost: defaultCost })}</p>
                ) : null}

                <label className={`check${config.practiceEnabled ? ' check--on' : ''}`}>
                  <input
                    type="checkbox"
                    checked={config.practiceEnabled}
                    onChange={(event) =>
                      setConfig((current) => ({ ...current, practiceEnabled: event.target.checked }))
                    }
                  />
                  <span className="check__box" aria-hidden="true">
                    <Icon name="check" size={13} />
                  </span>
                  <span className="check__text">
                    <strong>{t('exams.practiceEnabled')}</strong>
                    <span>{t('exams.practiceEligible')}</span>
                  </span>
                </label>

                <button type="submit" className="btn btn--primary" disabled={detail.saving}>
                  {detail.saving ? <span className="spinner" aria-hidden="true" /> : <Icon name="check" />}
                  {detail.saving ? t('app.saving') : t('app.save')}
                </button>
              </form>
            ) : (
              <div className="stack">
                <KeyValue
                  items={[
                    [t('exams.isFree'), exam.is_free ? t('app.yes') : t('app.no')],
                    [
                      t('exams.unlockCost'),
                      exam.is_free ? 0 : (exam.unlock_cost ?? defaultCost ?? '—'),
                    ],
                    [t('exams.practiceEnabled'), exam.practice_enabled === false ? t('app.no') : t('app.yes')],
                  ]}
                />
                <p className="field__hint">{t('exams.onlyOwner')}</p>
              </div>
            )}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card__head">
          <Icon name="tag" />
          <h2 className="grow">{t('exams.tree')}</h2>
        </div>
        <div className="card__body">
          <QuestionTree questions={exam.questions ?? []} language={exam.language} />
        </div>
      </div>

      {blockOpen ? (
        <Modal
          title={t('exams.confirmBlock')}
          description={t('exams.confirmBlockBody')}
          onClose={() => setBlockOpen(false)}
          labelledBy="block-exam-title"
          footer={
            <>
              <button type="button" className="btn btn--ghost" onClick={() => setBlockOpen(false)}>
                {t('app.cancel')}
              </button>
              <button type="submit" form="block-exam-form" className="btn btn--danger" disabled={detail.saving}>
                {detail.saving ? <span className="spinner" aria-hidden="true" /> : null}
                {t('exams.block')}
              </button>
            </>
          }
        >
          <form id="block-exam-form" className="stack" onSubmit={submitBlock} noValidate>
            <InlineError error={detail.error} />
            <Field label={t('exams.blockReason')} required error={reasonError} htmlFor="exam-block-reason">
              <textarea
                id="exam-block-reason"
                className="textarea"
                value={reason}
                maxLength={500}
                aria-invalid={Boolean(reasonError)}
                onChange={(event) => setReason(event.target.value)}
              />
            </Field>
          </form>
        </Modal>
      ) : null}
    </div>
  );
}