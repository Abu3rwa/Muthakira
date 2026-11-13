import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { fetchAiUsage, runAiTest } from '../features/ai/aiSlice.js';
import { AI_FEATURES, AI_FEATURE_TONES } from '../lib/constants.js';
import { can } from '../app/permissions.js';
import { formatNumber } from '../lib/format.js';
import Badge from '../components/Badge.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import { Credits, DateCell, Ltr, Num } from '../components/Data.jsx';
import { InlineError, Loading } from '../components/States.jsx';

function Usd({ value }) {
  const { i18n } = useTranslation();
  return (
    <Ltr className="num nowrap">
      ${formatNumber(value, i18n.language, { minimumFractionDigits: 2, maximumFractionDigits: 6 })}
    </Ltr>
  );
}

function AiTestCard() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const test = useAppSelector((slice) => slice.ai.test);
  const result = test.result;

  return (
    <div className="card">
      <div className="card__head">
        <Icon name="spark" />
        <div className="grow">
          <h2>{t('ai.test.title')}</h2>
          <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>
            {t('ai.test.subtitle')}
          </p>
        </div>
        {result ? (
          <Badge tone={result.ok ? 'success' : 'danger'}>
            {result.ok ? t('ai.test.working') : t('ai.test.broken')}
          </Badge>
        ) : null}
        <button
          type="button"
          className="btn btn--primary btn--sm"
          onClick={() => dispatch(runAiTest())}
          disabled={test.running}
        >
          {test.running ? <span className="spinner" aria-hidden="true" /> : <Icon name="spark" size={14} />}
          {test.running ? t('ai.test.running') : t('ai.test.run')}
        </button>
      </div>
      <div className="card__body">
        <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>{t('ai.test.hint')}</p>
        {result ? (
          <dl className="split split--even" style={{ marginBottom: 'var(--space-4)' }}>
            <div>
              <dt className="muted">{t('ai.test.model')}</dt>
              <dd><Ltr className="mono">{result.model}</Ltr></dd>
            </div>
            <div>
              <dt className="muted">{t('ai.test.endpoint')}</dt>
              <dd><Ltr className="mono">{result.base_url}</Ltr></dd>
            </div>
            <div>
              <dt className="muted">{t('ai.test.latency')}</dt>
              <dd><Ltr className="mono">{result.latency_ms != null ? `${result.latency_ms} ms` : '—'}</Ltr></dd>
            </div>
            <div>
              <dt className="muted">{t('ai.test.flags')}</dt>
              <dd>
                {t('ai.test.configured')}: {result.configured ? t('app.yes') : t('app.no')}
                {' · '}
                {t('ai.test.enabled')}: {result.enabled ? t('app.yes') : t('app.no')}
              </dd>
            </div>
          </dl>
        ) : null}
        {result ? (
          <div className={result.ok ? 'notice notice--success' : 'notice notice--danger'} role="status">
            <Icon name={result.ok ? 'check' : 'alert'} />
            <div className="grow">
              <strong>{result.ok ? t('ai.test.pass') : t('ai.test.fail')}</strong>
              {result.ok ? null : (
                <div className="mono" style={{ fontSize: 'var(--text-sm)', wordBreak: 'break-word' }}>
                  {result.code ? `${result.code}: ` : ''}
                  {result.error}
                </div>
              )}
            </div>
          </div>
        ) : null}
        <InlineError error={test.error} />
      </div>
    </div>
  );
}

export default function AiPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const usage = useAppSelector((slice) => slice.ai.usage);
  const role = useAppSelector((slice) => slice.auth.user?.role);
  const owner = can(role, 'ai.write');
  const summary = usage.summary;
  const feature = usage.filters.feature || 'all';

  useEffect(() => {
    dispatch(fetchAiUsage({ skip: 0 }));
  }, [dispatch]);

  const columns = [
    { key: 'created_at', label: t('ai.when'), render: (row) => <DateCell value={row.created_at} /> },
    {
      key: 'user',
      label: t('ai.student'),
      render: (row) => (row.user?.name ? row.user.name : <span className="muted">{t('ai.system')}</span>),
    },
    {
      key: 'feature',
      label: t('ai.featureLabel'),
      render: (row) => (
        <Badge tone={AI_FEATURE_TONES[row.feature] ?? 'neutral'}>{t(`ai.feature.${row.feature}`)}</Badge>
      ),
    },
    { key: 'model', label: t('ai.model'), render: (row) => <Ltr className="mono">{row.model}</Ltr> },
    {
      key: 'tokens',
      label: t('ai.tokens'),
      render: (row) => (
        <Ltr className="mono num">
          {formatNumber(row.input_tokens, 'en')} / {formatNumber(row.output_tokens, 'en')}
          {row.cached_tokens ? ` (${formatNumber(row.cached_tokens, 'en')})` : ''}
        </Ltr>
      ),
    },
    { key: 'cost_usd', label: t('ai.cost'), render: (row) => <Usd value={row.cost_usd} /> },
    { key: 'credits_charged', label: t('ai.credits'), render: (row) => <Credits value={row.credits_charged} /> },
    {
      key: 'status',
      label: t('app.status'),
      render: (row) => (
        <span className="stack stack--tight" style={{ gap: 0 }}>
          <Badge tone={row.status === 'ok' ? 'success' : 'danger'}>{t(`ai.usageStatus.${row.status}`)}</Badge>
          {row.error_code ? (
            <Ltr className="muted mono" >{row.error_code}</Ltr>
          ) : null}
        </span>
      ),
    },
  ];

  return (
    <div className="page">
      <div className="page-head">
        <div className="page-head__title">
          <h1>{t('ai.title')}</h1>
          <p>{t('ai.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchAiUsage())}
            disabled={usage.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      {usage.status === 'loading' && !summary ? <Loading /> : null}

      {summary ? (
        <>
          <div className="row" style={{ gap: 8, flexWrap: 'wrap' }}>
            <Badge tone={summary.enabled ? 'success' : 'danger'}>
              {summary.enabled ? t('ai.on') : t('ai.off')}
            </Badge>
            {summary.configured ? null : <Badge tone="warning">{t('ai.notConfigured')}</Badge>}
            <Badge tone="neutral" plain>
              <Ltr className="mono">{summary.model}</Ltr>
            </Badge>
            <span className="muted" style={{ fontSize: 'var(--text-sm)' }}>
              {t('ai.month')}: <Ltr className="mono">{summary.month}</Ltr>
            </span>
          </div>

          <div className="metric-grid">
            <div className="metric metric--amber">
              <div className="metric__label">{t('ai.spend')}</div>
              <div className="metric__value"><Usd value={summary.spend_usd} /></div>
              <div className="metric__hint">
                {t('ai.budgetHint', { budget: `$${formatNumber(summary.budget_usd, 'en')}` })}
              </div>
            </div>
            <div className="metric metric--electric">
              <div className="metric__label">{t('ai.remaining')}</div>
              <div className="metric__value"><Usd value={summary.remaining_usd} /></div>
              <div className="metric__hint">{t('ai.budgetNote')}</div>
            </div>
            <div className="metric metric--acid">
              <div className="metric__label">{t('ai.calls')}</div>
              <div className="metric__value"><Num value={summary.calls} /></div>
              <div className="metric__hint">{t('ai.failedHint', { count: summary.failed_calls })}</div>
            </div>
            <div className="metric metric--magenta">
              <div className="metric__label">{t('ai.credits')}</div>
              <div className="metric__value"><Credits value={summary.credits_charged} /></div>
              <div className="metric__hint">
                <Ltr className="mono">
                  {formatNumber(summary.input_tokens, 'en')} / {formatNumber(summary.output_tokens, 'en')}
                </Ltr>{' '}
                {t('ai.tokens')}
              </div>
            </div>
          </div>

          {summary.by_feature?.length ? (
            <div className="card">
              <div className="card__head">
                <Icon name="sliders" />
                <h2 className="grow">{t('ai.byFeature')}</h2>
              </div>
              <div className="card__body card__body--flush">
                <table className="table">
                  <thead>
                    <tr>
                      <th>{t('ai.featureLabel')}</th>
                      <th>{t('ai.calls')}</th>
                      <th>{t('ai.cost')}</th>
                      <th>{t('ai.credits')}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {summary.by_feature.map((row) => (
                      <tr key={row.feature}>
                        <td>
                          <Badge tone={AI_FEATURE_TONES[row.feature] ?? 'neutral'}>
                            {t(`ai.feature.${row.feature}`)}
                          </Badge>
                        </td>
                        <td><Num value={row.calls} /></td>
                        <td><Usd value={row.spend_usd} /></td>
                        <td><Credits value={row.credits} /></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          ) : null}
        </>
      ) : null}

      {owner ? <AiTestCard /> : null}

      <div className="tabs" role="tablist" aria-label={t('ai.featureLabel')}>
        {['all', ...AI_FEATURES].map((value) => (
          <button
            key={value}
            type="button"
            role="tab"
            aria-selected={feature === value}
            className={`tab${feature === value ? ' tab--active' : ''}`}
            onClick={() =>
              dispatch(fetchAiUsage({ filters: { feature: value === 'all' ? '' : value }, skip: 0 }))
            }
          >
            {value === 'all' ? t('app.all') : t(`ai.feature.${value}`)}
          </button>
        ))}
      </div>

      <ListPanel
        state={usage}
        columns={columns}
        onRetry={() => dispatch(fetchAiUsage())}
        onPage={(skip) => dispatch(fetchAiUsage({ skip }))}
        emptyText={t('ai.empty')}
        emptyIcon="spark"
      />
    </div>
  );
}