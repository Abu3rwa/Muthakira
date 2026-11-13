import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { approvePayment, fetchPayment, rejectPayment } from '../features/payments/paymentsSlice.js';
import { confirmAction, toast } from '../app/feedback.js';
import { CHECKLIST_KEYS, PAYMENT_TONES, REVIEWABLE_STATUSES } from '../lib/constants.js';
import { formatDate, formatMoney } from '../lib/format.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import Modal from '../components/Modal.jsx';
import ReceiptPreview from '../components/ReceiptPreview.jsx';
import { Credits, DateCell, KeyValue, Ltr, Money } from '../components/Data.jsx';
import { ErrorState, InlineError, Loading, NotFound } from '../components/States.jsx';

const CHECKLIST_LABELS = {
  amount_matches: ['payments.amountMatches', 'payments.amountMatchesHint'],
  date_recent: ['payments.dateRecent', 'payments.dateRecentHint'],
  reference_matches: ['payments.referenceMatches', 'payments.referenceMatchesHint'],
  receiver_account_ours: ['payments.receiverOurs', 'payments.receiverOursHint'],
};

const emptyChecklist = () => Object.fromEntries(CHECKLIST_KEYS.map((key) => [key, false]));

export default function PaymentDetailPage() {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const detail = useAppSelector((state) => state.payments.detail);
  const payment = detail.byId[id];
  const [checklist, setChecklist] = useState(emptyChecklist);
  const [rejectOpen, setRejectOpen] = useState(false);
  const [reason, setReason] = useState('');
  const [reasonError, setReasonError] = useState(null);

  useEffect(() => {
    dispatch(fetchPayment(id));
  }, [dispatch, id]);

  useEffect(() => {
    setChecklist(emptyChecklist());
    setReason('');
    setReasonError(null);
  }, [id]);

  if (detail.status === 'loading' && !payment) return <div className="page"><Loading /></div>;

  if (detail.status === 'error' && !payment) {
    return (
      <div className="page">
        <div className="card">
          {detail.error?.status === 404 ? (
            <NotFound />
          ) : (
            <ErrorState error={detail.error} onRetry={() => dispatch(fetchPayment(id))} />
          )}
        </div>
      </div>
    );
  }

  if (!payment) return <div className="page"><Loading /></div>;

  const reviewable = REVIEWABLE_STATUSES.includes(payment.status);
  const complete = CHECKLIST_KEYS.every((key) => checklist[key] === true);
  const account = payment.receiving_account || payment.bank?.account_number || '';
  const hintValues = {
    amount: formatMoney(payment.expected_amount_sdg, i18n.language),
    reference: payment.reference ?? '—',
    account: account || '—',
  };

  const approve = () => {
    dispatch(
      confirmAction(
        {
          title: t('payments.confirmApprove'),
          body: t('payments.confirmApproveBody', {
            credits: payment.package?.credits ?? 0,
            student: payment.student?.name ?? payment.student?.email ?? '—',
          }),
          confirmLabel: t('payments.approve'),
          tone: 'success',
        },
        async () => {
          try {
            const result = await dispatch(approvePayment({ id, checklist })).unwrap();
            dispatch(
              toast(t('payments.approved'), 'success', t('payments.grantNote', { credits: result.credits ?? 0 })),
            );
          } catch {
            dispatch(toast(t('app.errorTitle'), 'danger'));
          }
        },
      ),
    );
  };

  const submitReject = async (event) => {
    event.preventDefault();
    const trimmed = reason.trim();
    if (trimmed.length < 2) {
      setReasonError(t('payments.rejectReasonRequired'));
      return;
    }
    setReasonError(null);
    try {
      await dispatch(rejectPayment({ id, reason: trimmed })).unwrap();
      setRejectOpen(false);
      setReason('');
      dispatch(toast(t('payments.rejected'), 'warning'));
    } catch {
      /* the slice keeps the translated error for the modal */
    }
  };

  const facts = [
    [t('payments.code'), <Ltr className="mono">{payment.payment_code}</Ltr>],
    [
      t('payments.student'),
      payment.student ? (
        <Link to={`/users/${payment.student.id}`}>
          {payment.student.name}
          {payment.student.email ? (
            <>
              {' · '}
              <Ltr className="mono">{payment.student.email}</Ltr>
            </>
          ) : payment.student.phone ? (
            <>
              {' · '}
              <Ltr className="mono">{payment.student.phone}</Ltr>
            </>
          ) : null}
        </Link>
      ) : (
        '—'
      ),
    ],
    [t('payments.package'), payment.package?.name?.[i18n.language] ?? payment.package?.name?.ar ?? '—'],
    [t('payments.credits'), <Credits value={payment.package?.credits} />],
    [t('payments.baseAmount'), <Money value={payment.base_amount_sdg} />],
    [t('payments.increment'), <Ltr className="mono">+{payment.amount_increment ?? 0}</Ltr>],
    [t('payments.amount'), <strong className="num">{formatMoney(payment.expected_amount_sdg, i18n.language)}</strong>],
    [t('payments.reference'), payment.reference ? <Ltr className="mono">{payment.reference}</Ltr> : '—'],
    [t('payments.senderName'), payment.sender_name ?? '—'],
    [
      t('payments.receivingAccount'),
      <span className="stack stack--tight" style={{ gap: 0 }}>
        <span>{payment.bank?.account_name ?? payment.receiving_account ?? '—'}</span>
        <Ltr className="mono">{account || '—'}</Ltr>
        <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>{payment.bank?.bank_name ?? ''}</span>
      </span>,
    ],
    [t('payments.created'), <DateCell value={payment.created_at} />],
    [t('payments.submitted'), <DateCell value={payment.submitted_at} />],
    [t('payments.decided'), <DateCell value={payment.decided_at} />],
    [t('payments.resubmissions'), payment.resubmission_count ?? 0],
  ];

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1 className="row">
            {t('payments.detail')}
            <Badge tone={PAYMENT_TONES[payment.status] ?? 'neutral'}>{t(`paymentStatus.${payment.status}`)}</Badge>
          </h1>
          <p>
            <span className="mono">{payment.payment_code}</span> ·{' '}
            {t('payments.grantNote', { credits: payment.package?.credits ?? 0 })}
          </p>
        </div>
        <div className="page-head__actions">
          <button type="button" className="btn btn--ghost btn--sm" onClick={() => navigate('/payments')}>
            <Icon name="chevronRight" size={14} className="flip-rtl" />
            {t('app.back')}
          </button>
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchPayment(id))}
            disabled={detail.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      {payment.duplicate_across_accounts ? (
        <div className="notice notice--danger" role="alert">
          <Icon name="alert" />
          <span>{t('payments.duplicate')}</span>
        </div>
      ) : null}

      {payment.status === 'rejected' && payment.reject_reason ? (
        <div className="notice notice--warning">
          <Icon name="alert" />
          <span>
            <strong>{t('payments.rejectReason')}: </strong>
            {payment.reject_reason}
          </span>
        </div>
      ) : null}

      <div className="split">
        <div className="card">
          <div className="card__head">
            <Icon name="paper" />
            <h2 className="grow">{t('payments.receipt')}</h2>
            <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
              {formatDate(payment.submitted_at, i18n.language)}
            </span>
          </div>
          <div className="card__body">
            <ReceiptPreview receipts={payment.receipts ?? []} />
          </div>
        </div>

        <div className="stack">
          <div className="card">
            <div className="card__head">
              <Icon name="wallet" />
              <h2 className="grow">{t('payments.detail')}</h2>
            </div>
            <div className="card__body">
              <KeyValue items={facts} />
            </div>
          </div>

          <div className="card">
            <div className="card__head">
              <Icon name="check" />
              <h2 className="grow">{t('payments.checklist')}</h2>
            </div>
            <div className="card__body stack">
              <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>
                {reviewable ? t('payments.checklistHint') : t('payments.notReviewable')}
              </p>

              <InlineError error={detail.error} />

              <div className="checklist">
                {CHECKLIST_KEYS.map((key) => {
                  const [labelKey, hintKey] = CHECKLIST_LABELS[key];
                  const on = checklist[key];
                  return (
                    <label key={key} className={`check${on ? ' check--on' : ''}`}>
                      <input
                        type="checkbox"
                        checked={on}
                        disabled={!reviewable || detail.saving}
                        onChange={(event) =>
                          setChecklist((current) => ({ ...current, [key]: event.target.checked }))
                        }
                      />
                      <span className="check__box" aria-hidden="true">
                        <Icon name="check" size={13} />
                      </span>
                      <span className="check__text">
                        <strong>{t(labelKey)}</strong>
                        <span>{t(hintKey, hintValues)}</span>
                      </span>
                    </label>
                  );
                })}
              </div>

              <div className="row wrap">
                <button
                  type="button"
                  className="btn btn--success grow"
                  disabled={!reviewable || !complete || detail.saving}
                  onClick={approve}
                  title={complete ? undefined : t('payments.checklistHint')}
                >
                  {detail.saving ? <span className="spinner" aria-hidden="true" /> : <Icon name="check" />}
                  {detail.saving ? t('payments.approving') : t('payments.approve')}
                </button>
                <button
                  type="button"
                  className="btn btn--danger"
                  disabled={!reviewable || detail.saving}
                  onClick={() => setRejectOpen(true)}
                >
                  <Icon name="close" />
                  {t('payments.reject')}
                </button>
              </div>
              {!complete && reviewable ? (
                <p className="field__hint">{t('payments.checklistHint')}</p>
              ) : null}
            </div>
          </div>
        </div>
      </div>

      {rejectOpen ? (
        <Modal
          title={t('payments.confirmReject')}
          description={t('payments.rejectReason')}
          onClose={() => setRejectOpen(false)}
          labelledBy="reject-title"
          footer={
            <>
              <button type="button" className="btn btn--ghost" onClick={() => setRejectOpen(false)}>
                {t('app.cancel')}
              </button>
              <button type="submit" form="reject-form" className="btn btn--danger" disabled={detail.saving}>
                {detail.saving ? <span className="spinner" aria-hidden="true" /> : null}
                {detail.saving ? t('payments.rejecting') : t('payments.reject')}
              </button>
            </>
          }
        >
          <form id="reject-form" onSubmit={submitReject} className="stack" noValidate>
            <InlineError error={detail.error} />
            <Field label={t('payments.rejectReason')} required error={reasonError} htmlFor="reject-reason">
              <textarea
                id="reject-reason"
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