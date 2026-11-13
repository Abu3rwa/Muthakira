export const PAYMENT_STATUSES = [
  'pending_payment',
  'submitted',
  'under_review',
  'needs_info',
  'approved',
  'rejected',
  'expired',
  'cancelled',
];

export const PAYMENT_TONES = {
  pending_payment: 'neutral',
  submitted: 'warning',
  under_review: 'info',
  needs_info: 'magenta',
  approved: 'success',
  rejected: 'danger',
  expired: 'neutral',
  cancelled: 'neutral',
};

export const EXAM_STATUSES = ['draft', 'published', 'blocked'];
export const EXAM_TONES = { draft: 'neutral', published: 'success', blocked: 'danger' };

export const REPORT_STATUSES = ['open', 'resolved', 'dismissed'];
export const REPORT_TONES = { open: 'warning', resolved: 'success', dismissed: 'neutral' };

export const AI_REVIEW_STATUSES = ['pending', 'approved', 'rejected'];
export const AI_REVIEW_TONES = { pending: 'warning', approved: 'success', rejected: 'danger' };
export const AI_FEATURES = ['grading', 'generation', 'moderation', 'test'];
export const AI_FEATURE_TONES = { grading: 'info', generation: 'success', moderation: 'warning', test: 'neutral' };

export const CHECKLIST_KEYS = ['amount_matches', 'date_recent', 'reference_matches', 'receiver_account_ours'];

export const REVIEWABLE_STATUSES = ['submitted', 'under_review'];

export const QUESTION_TYPES = [
  'container',
  'mcq',
  'multi_select',
  'true_false',
  'matching',
  'matching_item',
  'fill_blank',
  'table_fill',
  'matrix_input',
  'truth_table',
  'ordering',
  'numeric',
  'math_expression',
  'diacritics',
  'language_analysis',
  'short_answer',
  'essay',
];

export const ACCESS_TONES = { trial: 'info', paid: 'warning', free: 'success' };
export const KEY_STATUS_TONES = { official: 'success', verified: 'info', draft: 'danger' };

export const AUDIT_ACTIONS = [
  'payment.approved',
  'payment.rejected',
  'credits.granted',
  'credits.adjusted',
  'exams.imported',
  'exams.published',
  'exams.unpublished',
  'exams.blocked',
  'exams.configured',
  'exams.unlocked',
  'topics.created',
  'packages.created',
  'packages.updated',
  'settings.updated',
  'users.blocked',
  'users.unblocked',
  'reports.resolved',
  'ai.review_resolved',
  'ai.test',
];

export const PAGE_SIZES = [20, 50, 100];
