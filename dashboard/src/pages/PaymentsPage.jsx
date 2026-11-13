import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { fetchPayments } from '../features/payments/paymentsSlice.js';
import { PAYMENT_STATUSES, PAYMENT_TONES } from '../lib/constants.js';
import Badge from '../components/Badge.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import { Credits, DateCell, Ltr, Money } from '../components/Data.jsx';

export default function PaymentsPage() {
  const { t, i18n } = useTranslation();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const state = useAppSelector((slice) => slice.payments);
  const status = state.filters.status;

  const load = (arg = {}) => dispatch(fetchPayments(arg));

  useEffect(() => {
    dispatch(fetchPayments({ skip: 0 }));
  }, [dispatch]);

  const columns = [
    {
      key: 'payment_code',
      label: t('payments.code'),
      render: (row) => <Ltr className="mono">{row.payment_code}</Ltr>,
    },
    {
      key: 'package',
      label: t('payments.package'),
      render: (row) => (
        <span className="stack stack--tight" style={{ gap: 0 }}>
          <span>{row.package?.name?.[i18n.language] ?? row.package?.name?.ar}</span>
          <span className="muted" style={{ fontSize: 'var(--text-xs)' }}>
            {t('payments.credits')}: <Credits value={row.package?.credits} />
          </span>
        </span>
      ),
    },
    {
      key: 'expected_amount_sdg',
      label: t('payments.amount'),
      align: 'num',
      render: (row) => <Money value={row.expected_amount_sdg} />,
    },
    {
      key: 'reference',
      label: t('payments.reference'),
      render: (row) =>
        row.reference ? (
          <Ltr className="mono">{row.reference}</Ltr>
        ) : (
          <span className="muted">{t('payments.noReference')}</span>
        ),
    },
    {
      key: 'status',
      label: t('app.status'),
      render: (row) => (
        <Badge tone={PAYMENT_TONES[row.status] ?? 'neutral'}>{t(`paymentStatus.${row.status}`)}</Badge>
      ),
    },
    {
      key: 'created_at',
      label: t('payments.created'),
      render: (row) => <DateCell value={row.created_at} />,
    },
    {
      key: 'submitted_at',
      label: t('payments.submitted'),
      render: (row) => <DateCell value={row.submitted_at} />,
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
            navigate(`/payments/${row.id}`);
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
          <h1>{t('payments.title')}</h1>
          <p>{t('payments.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <span className="muted mono">
            {t('app.showing', {
              from: state.total ? state.skip + 1 : 0,
              to: Math.min(state.skip + state.limit, state.total),
              total: state.total,
            })}
          </span>
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => load()}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('payments.refresh')}
          </button>
        </div>
      </div>

      <div className="tabs" role="tablist" aria-label={t('payments.filterStatus')}>
        <button
          type="button"
          role="tab"
          aria-selected={status === ''}
          className={`tab${status === '' ? ' tab--active' : ''}`}
          onClick={() => load({ filters: { status: '' }, skip: 0 })}
        >
          {t('app.all')}
        </button>
        {PAYMENT_STATUSES.map((value) => (
          <button
            key={value}
            type="button"
            role="tab"
            aria-selected={status === value}
            className={`tab${status === value ? ' tab--active' : ''}`}
            onClick={() => load({ filters: { status: value }, skip: 0 })}
          >
            {t(`paymentStatus.${value}`)}
          </button>
        ))}
      </div>

      <ListPanel
        state={state}
        columns={columns}
        onRowClick={(row) => navigate(`/payments/${row.id}`)}
        onRetry={() => load()}
        onPage={(skip) => load({ skip })}
        emptyText={t('payments.empty')}
        emptyIcon="wallet"
      />
    </div>
  );
}