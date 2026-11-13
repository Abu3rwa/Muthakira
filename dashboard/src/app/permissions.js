export const CAPABILITIES = {
  owner: [
    'payments.read',
    'payments.review',
    'users.read',
    'users.write',
    'credits.write',
    'exams.read',
    'exams.write',
    'exams.import',
    'exams.block',
    'exams.config',
    'topics.read',
    'topics.write',
    'packages.read',
    'packages.write',
    'settings.read',
    'settings.write',
    'audit.read',
    'reports.read',
    'reports.write',
    'ai.read',
    'ai.write',
    'ai.review',
  ],
  payment_reviewer: ['payments.read', 'payments.review'],
  content_editor: [
    'exams.read',
    'exams.write',
    'exams.import',
    'topics.read',
    'topics.write',
    'audit.read',
    'reports.read',
    'reports.write',
    'ai.read',
    'ai.review',
  ],
};

export const can = (role, capability) => (CAPABILITIES[role] ?? []).includes(capability);

export const landingFor = (role) => (can(role, 'payments.read') ? '/payments' : '/exams');

export const NAV_ITEMS = [
  { to: '/payments', capability: 'payments.read', icon: 'wallet', key: 'nav.payments' },
  { to: '/users', capability: 'users.read', icon: 'users', key: 'nav.users' },
  { to: '/exams', capability: 'exams.read', icon: 'paper', key: 'nav.exams' },
  { to: '/exams/import', capability: 'exams.import', icon: 'upload', key: 'nav.import' },
  { to: '/reports', capability: 'reports.read', icon: 'flag', key: 'nav.reports' },
  { to: '/ai', capability: 'ai.read', icon: 'spark', key: 'nav.ai' },
  { to: '/ai/reviews', capability: 'ai.review', icon: 'eye', key: 'nav.aiReviews' },
  { to: '/topics', capability: 'topics.read', icon: 'tag', key: 'nav.topics' },
  { to: '/packages', capability: 'packages.read', icon: 'box', key: 'nav.packages' },
  { to: '/settings', capability: 'settings.read', icon: 'sliders', key: 'nav.settings' },
  { to: '/audit', capability: 'audit.read', icon: 'history', key: 'nav.audit' },
];
