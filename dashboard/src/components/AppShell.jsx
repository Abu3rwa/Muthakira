import { useEffect } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { logout } from '../features/auth/authSlice.js';
import { setLanguage, toggleSidebar } from '../features/ui/uiSlice.js';
import { NAV_ITEMS, can } from '../app/permissions.js';
import { shortId } from '../lib/format.js';
import Icon from './Icon.jsx';

function initialsOf(name) {
  const parts = String(name ?? '').trim().split(/\s+/).filter(Boolean);
  if (!parts.length) return '؟';
  return parts.slice(0, 2).map((part) => part[0]).join('');
}

export default function AppShell() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const location = useLocation();
  const user = useAppSelector((state) => state.auth.user);
  const language = useAppSelector((state) => state.ui.language);
  const sidebarOpen = useAppSelector((state) => state.ui.sidebarOpen);
  const items = NAV_ITEMS.filter((item) => can(user?.role, item.capability));
  const active = [...items].reverse().find((item) => location.pathname.startsWith(item.to));

  useEffect(() => {
    dispatch(toggleSidebar(false));
  }, [dispatch, location.pathname]);

  const signOut = () => {
    dispatch(logout());
    navigate('/login', { replace: true });
  };

  return (
    <div className="app">
      <a className="sr-only" href="#main">
        {t('app.skipToContent')}
      </a>
      <aside className={`sidebar${sidebarOpen ? ' sidebar--open' : ''}`} aria-label={t('app.menu')}>
        <div className="sidebar__brand">
          <span className="brand-mark" aria-hidden="true">
            <Icon name="paper" size={20} />
          </span>
          <span className="brand-text">
            <strong>{t('app.name')}</strong>
            <span>{t('app.tagline')}</span>
          </span>
        </div>
        <nav className="sidebar__nav">
          {items.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) => `navlink${isActive ? ' navlink--active' : ''}`}
            >
              <Icon name={item.icon} />
              <span className="grow">{t(item.key)}</span>
            </NavLink>
          ))}
        </nav>
        <div className="sidebar__foot">
          <span>{t('app.signedInAs')}</span>
          <strong>{user?.name}</strong>
          <span>{t(`roles.${user?.role ?? 'student'}`)}</span>
        </div>
      </aside>

      {sidebarOpen ? (
        <div className="scrim" onClick={() => dispatch(toggleSidebar(false))} aria-hidden="true" />
      ) : null}

      <div className="app__main">
        <header className="topbar">
          <button
            type="button"
            className="icon-btn menu-btn"
            onClick={() => dispatch(toggleSidebar())}
            aria-label={t('app.menu')}
            aria-expanded={sidebarOpen}
          >
            <Icon name="menu" size={18} />
          </button>
          <div className="topbar__crumb">
            <strong>{active ? t(active.key) : t('app.name')}</strong>
            {active && location.pathname !== active.to && !location.pathname.endsWith('/import') ? (
              <>
                <span aria-hidden="true">/</span>
                <span className="mono">{shortId(location.pathname.split('/').pop())}</span>
              </>
            ) : null}
          </div>
          <div className="topbar__spacer" />
          <div className="lang-toggle" role="group" aria-label={t('app.language')}>
            <button
              type="button"
              aria-pressed={language === 'ar'}
              onClick={() => dispatch(setLanguage('ar'))}
            >
              {t('app.arabic')}
            </button>
            <button
              type="button"
              aria-pressed={language === 'en'}
              onClick={() => dispatch(setLanguage('en'))}
            >
              {t('app.english')}
            </button>
          </div>
          <div className="identity">
            <span className="avatar" aria-hidden="true">
              {initialsOf(user?.name)}
            </span>
            <span className="identity__text">
              <strong>{user?.name}</strong>
              <span>{t(`roles.${user?.role ?? 'student'}`)}</span>
            </span>
          </div>
          <button type="button" className="btn btn--ghost btn--sm" onClick={signOut}>
            <Icon name="logout" />
            {t('app.signOut')}
          </button>
        </header>
        <main id="main">
          <Outlet />
        </main>
      </div>
    </div>
  );
}