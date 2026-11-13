import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { blockUser, fetchUser, unblockUser } from '../features/users/usersSlice.js';
import { confirmAction, toast } from '../app/feedback.js';
import { PAYMENT_TONES } from '../lib/constants.js';
import { formatCredits, formatDate, formatMoney } from '../lib/format.js';
import Badge from '../components/Badge.jsx';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import Modal from '../components/Modal.jsx';
import { DateCell, KeyValue, Ltr } from '../components/Data.jsx';
import { EmptyState, ErrorState, InlineError, Loading, NotFound } from '../components/States.jsx';

export default function UserDetailPage() {
  const { t, i18n } = useTranslation();
  const { id } = useParams();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const detail = useAppSelector((state) => state.users.detail);
  const record = detail.byId[id];
  const [blockOpen, setBlockOpen] = useState(false);
  const [reason, setReason] = useState('');
  const [reasonError, setReasonError] = useState(null);

  useEffect(() => {
    dispatch(fetchUser(id));
  }, [dispatch, id]);

  if (detail.status === 'loading' && !record) return <div className="page"><Loading /></div>;

  if (detail.status === 'error' && !record) {
    return (
      <div className="page">
        <div className="card">
          {detail.error?.status === 404 ? (
            <NotFound />
          ) : (
            <ErrorState error={detail.error} onRetry={() => dispatch(fetchUser(id))} />
          )}
        </div>
      </div>
    );
  }

  if (!record) return <div className="page"><Loading /></div>;

  const { user, profile, wallet, ledger = [], payments = [], unlocks_count: unlocks = 0 } = record;
  const isStudent = user.kind === 'student';

  const submitBlock = async (event) => {
    event.preventDefault();
    const trimmed = reason.trim();
    if (trimmed.length < 2) {
      setReasonError(t('users.blockReasonRequired'));
      return;
    }
    setReasonError(null);
    try {
      await dispatch(blockUser({ id, reason: trimmed })).unwrap();
      setBlockOpen(false);
      setReason('');
      dispatch(toast(t('users.blockedDone'), 'warning'));
    } catch {
      /* surfaced in the modal */
    }
  };

  const unblock = () => {
    dispatch(
      confirmAction(
        { title: t('users.confirmUnblock'), body: t('users.confirmUnblockBody'), confirmLabel: t('users.unblock') },
        async () => {
          try {
            await dispatch(unblockUser(id)).unwrap();
            dispatch(toast(t('users.unblockedDone'), 'success'));
          } catch {
            dispatch(toast(t('app.errorTitle'), 'danger'));
          }
        },
      ),
    );
  };

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1 className="row">
            {user.name}
            <Badge tone={user.status === 'active' ? 'success' : 'danger'}>
              {user.status === 'active' ? t('users.active') : t('users.blocked')}
            </Badge>
            <Badge tone={user.kind === 'admin' ? 'info' : 'neutral'} plain>
              {t(`userKind.${user.kind}`)}
            </Badge>
          </h1>
          <p>
            <Ltr className="mono">{user.email ?? '—'}</Ltr>
            {user.phone ? (
              <>
                {' · '}
                <Ltr className="mono">{user.phone}</Ltr>
              </>
            ) : null}
            {user.role && user.kind === 'admin' ? ` · ${t(`roles.${user.role}`)}` : ''}
          </p>
        </div>
        <div className="page-head__actions">
          <button type="button" className="btn btn--ghost btn--sm" onClick={() => navigate('/users')}>
            <Icon name="chevronRight" size={14} className="flip-rtl" />
            {t('app.back')}
          </button>
          {isStudent ? (
            user.status === 'active' ? (
              <button
                type="button"
                className="btn btn--danger btn--sm"
                disabled={detail.saving}
                onClick={() => setBlockOpen(true)}
              >
                <Icon name="lock" size={14} />
                {t('users.block')}
              </button>
            ) : (
              <button type="button" className="btn btn--success btn--sm" disabled={detail.saving} onClick={unblock}>
                <Icon name="check" size={14} />
                {t('users.unblock')}
              </button>
            )
          ) : (
            <span className="muted" style={{ fontSize: 'var(--text-sm)' }}>{t('users.adminAccount')}</span>
          )}
        </div>
      </div>

      <InlineError error={detail.status === 'error' ? detail.error : null} />

      {user.status === 'blocked' ? (
        <div className="notice notice--danger">
          <Icon name="lock" />
          <span>
            <strong>{t('users.blockedReason')}: </strong>
            {user.blocked_reason ?? '—'} · {formatDate(user.blocked_at, i18n.language)}
          </span>
        </div>
      ) : null}

      <div className="metric-grid">
        <div className="metric metric--amber">
          <div className="metric__label">{t('users.available')}</div>
          <div className="metric__value">{formatCredits(wallet?.available ?? 0, i18n.language)}</div>
          <div className="metric__hint">
            {t('users.balance')}: {formatCredits(wallet?.balance ?? 0, i18n.language)}
          </div>
        </div>
        <div className="metric metric--electric">
          <div className="metric__label">{t('users.reserved')}</div>
          <div className="metric__value">{formatCredits(wallet?.reserved ?? 0, i18n.language)}</div>
          <div className="metric__hint">
            {t('users.nextExpiry')}: {formatDate(wallet?.next_expiry_at, i18n.language, { withTime: false })}
          </div>
        </div>
        <div className="metric metric--acid">
          <div className="metric__label">{t('users.unlocks')}</div>
          <div className="metric__value">{formatCredits(unlocks, i18n.language)}</div>
          <div className="metric__hint">{t('exams.title')}</div>
        </div>
        <div className="metric metric--magenta">
          <div className="metric__label">{t('users.payments')}</div>
          <div className="metric__value">{formatCredits(payments.length, i18n.language)}</div>
          <div className="metric__hint">{t('users.lastLogin')}: {formatDate(user.last_login_at, i18n.language)}</div>
        </div>
      </div>

      <div className="split">
        <div className="card">
          <div className="card__head">
            <Icon name="history" />
            <h2 className="grow">{t('users.ledger')}</h2>
            <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>{t('app.rows', { count: ledger.length })}</span>
          </div>
          <div className="card__body card__body--flush">
            {ledger.length === 0 ? (
              <EmptyState text={t('users.noLedger')} />
            ) : (
              <div className="table-wrap" style={{ maxHeight: 420, border: 0, borderRadius: 0, boxShadow: 'none' }}>
                <table className="table table--responsive">
                  <thead>
                    <tr>
                      <th>{t('users.entryType')}</th>
                      <th className="num">{t('users.amount')}</th>
                      <th>{t('users.reason')}</th>
                      <th>{t('users.date')}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {ledger.map((entry) => (
                      <tr key={entry.id}>
                        <td data-label={t('users.entryType')}>
                          {t(`ledgerType.${entry.entry_type}`, { defaultValue: entry.entry_type })}
                        </td>
                        <td className="num" data-label={t('users.amount')}>
                          <span className={entry.amount >= 0 ? 'ledger-amount--in' : 'ledger-amount--out'}>
                            {entry.amount > 0 ? '+' : ''}
                            {formatCredits(entry.amount, i18n.language)}
                          </span>
                        </td>
                        <td data-label={t('users.reason')}>
                          <Ltr className="mono">{entry.reason ?? '—'}</Ltr>
                        </td>
                        <td data-label={t('users.date')}>
                          <DateCell value={entry.created_at} />
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>

        <div className="stack">
          <div className="card">
            <div className="card__head">
              <Icon name="users" />
              <h2 className="grow">{t('users.profile')}</h2>
            </div>
            <div className="card__body">
              <KeyValue
                items={[
                  [t('app.id'), <Ltr className="mono">{user.id}</Ltr>],
                  [t('users.classLevel'), profile?.class_level ?? '—'],
                  [t('users.stream'), profile?.stream ?? '—'],
                  [
                    t('users.language'),
                    profile?.language ? (profile.language === 'ar' ? t('app.arabic') : t('app.english')) : '—',
                  ],
                  [t('users.joined'), <DateCell value={user.created_at} />],
                  [t('users.lastLogin'), <DateCell value={user.last_login_at} />],
                ]}
              />
            </div>
          </div>

          <div className="card">
            <div className="card__head">
              <Icon name="wallet" />
              <h2 className="grow">{t('users.payments')}</h2>
            </div>
            <div className="card__body card__body--flush">
              {payments.length === 0 ? (
                <EmptyState text={t('users.noPayments')} icon="wallet" />
              ) : (
                <ul className="stack stack--tight" style={{ padding: 'var(--space-3)' }}>
                  {payments.map((payment) => (
                    <li key={payment.id} className="row row--between" style={{ gap: 'var(--space-2)' }}>
                      <Link to={`/payments/${payment.id}`} className="mono">
                        {payment.payment_code}
                      </Link>
                      <span className="muted nowrap" style={{ fontSize: 'var(--text-xs)' }}>
                        {formatMoney(payment.expected_amount_sdg, i18n.language)}
                      </span>
                      <Badge tone={PAYMENT_TONES[payment.status] ?? 'neutral'}>
                        {t(`paymentStatus.${payment.status}`)}
                      </Badge>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        </div>
      </div>

      {blockOpen ? (
        <Modal
          title={t('users.confirmBlock')}
          description={t('users.confirmBlockBody')}
          onClose={() => setBlockOpen(false)}
          labelledBy="block-user-title"
          footer={
            <>
              <button type="button" className="btn btn--ghost" onClick={() => setBlockOpen(false)}>
                {t('app.cancel')}
              </button>
              <button type="submit" form="block-user-form" className="btn btn--danger" disabled={detail.saving}>
                {detail.saving ? <span className="spinner" aria-hidden="true" /> : null}
                {detail.saving ? t('users.blocking') : t('users.block')}
              </button>
            </>
          }
        >
          <form id="block-user-form" className="stack" onSubmit={submitBlock} noValidate>
            <InlineError error={detail.error} />
            <Field label={t('users.blockReason')} required error={reasonError} htmlFor="block-reason">
              <textarea
                id="block-reason"
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