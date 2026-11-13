import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { fetchUsers } from '../features/users/usersSlice.js';
import Badge from '../components/Badge.jsx';
import Icon from '../components/Icon.jsx';
import ListPanel from '../components/ListPanel.jsx';
import SearchInput from '../components/SearchInput.jsx';
import { Credits, DateCell, Ltr } from '../components/Data.jsx';

export default function UsersPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const state = useAppSelector((slice) => slice.users);

  useEffect(() => {
    dispatch(fetchUsers({ skip: 0 }));
  }, [dispatch]);

  const columns = [
    {
      key: 'name',
      label: t('users.name'),
      render: (row) => (
        <div>
          <div>{row.name}</div>
          {row.phone ? (
            <div className="muted mono ltr" style={{ fontSize: 'var(--text-xs)' }}>
              {row.phone}
            </div>
          ) : null}
        </div>
      ),
    },
    { key: 'email', label: t('users.email'), render: (row) => <Ltr className="mono">{row.email ?? '—'}</Ltr> },
    {
      key: 'kind',
      label: t('users.kind'),
      render: (row) => (
        <Badge tone={row.kind === 'admin' ? 'info' : 'neutral'} plain>
          {t(`userKind.${row.kind}`)}
        </Badge>
      ),
    },
    {
      key: 'status',
      label: t('app.status'),
      render: (row) => (
        <Badge tone={row.status === 'active' ? 'success' : 'danger'}>
          {row.status === 'active' ? t('users.active') : t('users.blocked')}
        </Badge>
      ),
    },
    {
      key: 'wallet_available',
      label: t('users.available'),
      align: 'num',
      render: (row) => <Credits value={row.wallet_available} />,
    },
    { key: 'created_at', label: t('users.joined'), render: (row) => <DateCell value={row.created_at} withTime={false} /> },
    { key: 'last_login_at', label: t('users.lastLogin'), render: (row) => <DateCell value={row.last_login_at} /> },
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
            navigate(`/users/${row.id}`);
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
          <h1>{t('users.title')}</h1>
          <p>{t('users.subtitle')}</p>
        </div>
        <div className="page-head__actions">
          <button
            type="button"
            className="btn btn--outline btn--sm"
            onClick={() => dispatch(fetchUsers())}
            disabled={state.status === 'loading'}
          >
            <Icon name="refresh" size={14} />
            {t('app.refresh')}
          </button>
        </div>
      </div>

      <div className="toolbar">
        <SearchInput
          value={state.filters.q}
          placeholder={t('users.searchPlaceholder')}
          label={t('app.search')}
          onSearch={(q) => dispatch(fetchUsers({ filters: { q }, skip: 0 }))}
        />
        <span className="grow" />
        <span className="muted mono">{t('app.rows', { count: state.total })}</span>
      </div>

      <ListPanel
        state={state}
        columns={columns}
        onRowClick={(row) => navigate(`/users/${row.id}`)}
        onRetry={() => dispatch(fetchUsers())}
        onPage={(skip) => dispatch(fetchUsers({ skip }))}
        emptyText={t('users.empty')}
        emptyIcon="users"
      />
    </div>
  );
}