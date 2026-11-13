import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { bootstrap } from '../features/auth/authSlice.js';
import { can } from '../app/permissions.js';
import Icon from './Icon.jsx';
import { Forbidden, Loading } from './States.jsx';

export function RequireAuth() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const location = useLocation();
  const status = useAppSelector((state) => state.auth.status);

  if (status === 'restoring') return <Loading />;

  if (status === 'offline') {
    return (
      <div className="state state--error" role="alert">
        <span className="state__icon">
          <Icon name="offline" size={22} />
        </span>
        <p className="state__title">{t('app.offlineTitle')}</p>
        <p className="state__text">{t('app.offlineBody')}</p>
        <button type="button" className="btn btn--outline btn--sm" onClick={() => dispatch(bootstrap())}>
          <Icon name="refresh" />
          {t('app.retry')}
        </button>
      </div>
    );
  }

  if (status !== 'authenticated') {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }

  return <Outlet />;
}

export function RequireCapability({ capability }) {
  const role = useAppSelector((state) => state.auth.user?.role);
  if (!can(role, capability)) {
    return (
      <div className="page">
        <div className="card">
          <Forbidden />
        </div>
      </div>
    );
  }
  return <Outlet />;
}