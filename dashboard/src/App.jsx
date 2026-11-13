import { useEffect } from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAppSelector } from './app/hooks.js';
import { landingFor } from './app/permissions.js';
import AppShell from './components/AppShell.jsx';
import { RequireAuth, RequireCapability } from './components/guards.jsx';
import { ConfirmHost, ToastHost } from './components/Toasts.jsx';
import { NotFound } from './components/States.jsx';
import LoginPage from './pages/LoginPage.jsx';
import PaymentsPage from './pages/PaymentsPage.jsx';
import PaymentDetailPage from './pages/PaymentDetailPage.jsx';
import UsersPage from './pages/UsersPage.jsx';
import UserDetailPage from './pages/UserDetailPage.jsx';
import ExamsPage from './pages/ExamsPage.jsx';
import ExamImportPage from './pages/ExamImportPage.jsx';
import ExamDetailPage from './pages/ExamDetailPage.jsx';
import TopicsPage from './pages/TopicsPage.jsx';
import PackagesPage from './pages/PackagesPage.jsx';
import SettingsPage from './pages/SettingsPage.jsx';
import AuditPage from './pages/AuditPage.jsx';
import ReportsPage from './pages/ReportsPage.jsx';
import AiPage from './pages/AiPage.jsx';
import AiReviewsPage from './pages/AiReviewsPage.jsx';

function Missing() {
  return (
    <div className="page">
      <div className="card">
        <NotFound />
      </div>
    </div>
  );
}

export default function App() {
  const { i18n } = useTranslation();
  const language = useAppSelector((state) => state.ui.language);
  const role = useAppSelector((state) => state.auth.user?.role);

  useEffect(() => {
    if (i18n.language !== language) i18n.changeLanguage(language);
  }, [i18n, language]);

  return (
    <>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route element={<RequireAuth />}>
          <Route element={<AppShell />}>
            <Route index element={<Navigate to={landingFor(role)} replace />} />

            <Route element={<RequireCapability capability="payments.read" />}>
              <Route path="payments" element={<PaymentsPage />} />
              <Route path="payments/:id" element={<PaymentDetailPage />} />
            </Route>

            <Route element={<RequireCapability capability="users.read" />}>
              <Route path="users" element={<UsersPage />} />
              <Route path="users/:id" element={<UserDetailPage />} />
            </Route>

            <Route element={<RequireCapability capability="exams.read" />}>
              <Route path="exams" element={<ExamsPage />} />
              <Route path="exams/:id" element={<ExamDetailPage />} />
            </Route>
            <Route element={<RequireCapability capability="exams.import" />}>
              <Route path="exams/import" element={<ExamImportPage />} />
            </Route>

            <Route element={<RequireCapability capability="reports.read" />}>
              <Route path="reports" element={<ReportsPage />} />
            </Route>
            <Route element={<RequireCapability capability="ai.read" />}>
              <Route path="ai" element={<AiPage />} />
            </Route>
            <Route element={<RequireCapability capability="ai.review" />}>
              <Route path="ai/reviews" element={<AiReviewsPage />} />
            </Route>
            <Route element={<RequireCapability capability="topics.read" />}>
              <Route path="topics" element={<TopicsPage />} />
            </Route>
            <Route element={<RequireCapability capability="packages.read" />}>
              <Route path="packages" element={<PackagesPage />} />
            </Route>
            <Route element={<RequireCapability capability="settings.read" />}>
              <Route path="settings" element={<SettingsPage />} />
            </Route>
            <Route element={<RequireCapability capability="audit.read" />}>
              <Route path="audit" element={<AuditPage />} />
            </Route>

            <Route path="*" element={<Missing />} />
          </Route>
        </Route>
      </Routes>
      <ToastHost />
      <ConfirmHost />
    </>
  );
}