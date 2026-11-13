import { useState } from 'react';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppDispatch, useAppSelector } from '../app/hooks.js';
import { clearNotice, login } from '../features/auth/authSlice.js';
import { setLanguage } from '../features/ui/uiSlice.js';
import { landingFor } from '../app/permissions.js';
import Field from '../components/Field.jsx';
import Icon from '../components/Icon.jsx';
import { InlineError } from '../components/States.jsx';

export default function LoginPage() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const location = useLocation();
  const auth = useAppSelector((state) => state.auth);
  const language = useAppSelector((state) => state.ui.language);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fieldErrors, setFieldErrors] = useState({});

  if (auth.status === 'authenticated' && auth.user?.kind === 'admin') {
    return <Navigate to={location.state?.from ?? landingFor(auth.user?.role)} replace />;
  }

  const submit = async (event) => {
    event.preventDefault();
    const errors = {};
    const value = email.trim();
    if (!value) errors.email = t('login.emailRequired');
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) errors.email = t('login.emailInvalid');
    if (!password) errors.password = t('login.passwordRequired');
    setFieldErrors(errors);
    if (Object.keys(errors).length) return;

    dispatch(clearNotice());
    try {
      const session = await dispatch(login({ email: value.toLowerCase(), password })).unwrap();
      navigate(location.state?.from ?? landingFor(session.user?.role), { replace: true });
    } catch {
      /* the slice holds the translated error */
    }
  };

  return (
    <div className="login">
      <section className="login__art">
        <div className="row" style={{ gap: 12 }}>
          <span className="brand-mark" aria-hidden="true">
            <Icon name="paper" size={20} />
          </span>
          <span className="brand-text">
            <strong>{t('app.name')}</strong>
            <span>{t('app.tagline')}</span>
          </span>
        </div>
        <div>
          <h1 className="login__headline">{t('login.headline')}</h1>
          <p className="login__lede">{t('login.lede')}</p>
        </div>
        <div className="login__facts">
          {[1, 2, 3].map((index) => (
            <div className="login__fact" key={index}>
              <Icon name={index === 1 ? 'wallet' : index === 2 ? 'lock' : 'history'} size={18} />
              <div>
                <strong>{t(`login.fact${index}Title`)}</strong>
                <span>{t(`login.fact${index}Body`)}</span>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="login__panel">
        <form className="login__form" onSubmit={submit} noValidate>
          <div className="row row--between">
            <div>
              <h2>{t('login.title')}</h2>
              <p className="muted" style={{ fontSize: 'var(--text-sm)' }}>
                {t('login.subtitle')}
              </p>
            </div>
            <div className="lang-toggle" role="group" aria-label={t('app.language')}>
              <button type="button" aria-pressed={language === 'ar'} onClick={() => dispatch(setLanguage('ar'))}>
                {t('app.arabic')}
              </button>
              <button type="button" aria-pressed={language === 'en'} onClick={() => dispatch(setLanguage('en'))}>
                {t('app.english')}
              </button>
            </div>
          </div>

          {auth.notice === 'account_blocked' ? (
            <div className="notice notice--danger" role="alert">
              <Icon name="alert" />
              <span>{t('app.blockedNotice')}</span>
            </div>
          ) : auth.notice === 'session_expired' ? (
            <div className="notice notice--warning" role="alert">
              <Icon name="alert" />
              <span>{t('app.sessionExpiredNotice')}</span>
            </div>
          ) : null}

          <InlineError error={auth.error} />

          <Field label={t('login.email')} required error={fieldErrors.email} htmlFor="email">
            <input
              id="email"
              className="input ltr"
              type="email"
              inputMode="email"
              autoComplete="username"
              dir="ltr"
              placeholder={t('login.emailPlaceholder')}
              value={email}
              aria-invalid={Boolean(fieldErrors.email)}
              onChange={(event) => setEmail(event.target.value)}
            />
          </Field>

          <Field label={t('login.password')} required error={fieldErrors.password} htmlFor="password">
            <input
              id="password"
              className="input"
              type="password"
              autoComplete="current-password"
              value={password}
              aria-invalid={Boolean(fieldErrors.password)}
              onChange={(event) => setPassword(event.target.value)}
            />
          </Field>

          <button type="submit" className="btn btn--primary btn--block" disabled={auth.pending}>
            {auth.pending ? <span className="spinner" aria-hidden="true" /> : <Icon name="logout" />}
            {auth.pending ? t('login.signingIn') : t('login.submit')}
          </button>

          <p className="login__hint">{t('login.hint')}</p>
        </form>
      </section>
    </div>
  );
}