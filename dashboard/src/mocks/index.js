import { ADMIN_PASSWORD, admins, createSeed, oid } from './data.js';

const BASE = '/api/v1';
const state = createSeed();
let tokenSequence = 0;

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const json = (status, body) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

const failure = (status, code, message, details = null) =>
  json(status, { error: { code, message, details, request_id: `mock-${Date.now()}` } });

class HttpError extends Error {
  constructor(status, code, message, details) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

const paginate = (rows, query) => {
  const limit = Number(query.get('limit') ?? 50);
  const skip = Number(query.get('skip') ?? 0);
  return { items: rows.slice(skip, skip + limit), total: rows.length, limit, skip };
};

const examSummary = (exam, admin = true) => {
  const base = {
    id: exam.id,
    exam_key: exam.exam_key,
    exam_year: exam.exam_year,
    session: exam.session,
    class_level: exam.class_level,
    stream: exam.stream,
    subject: exam.subject,
    language: exam.language,
    duration_minutes: exam.duration_minutes,
    total_marks: exam.total_marks,
    status: exam.status,
    is_free: exam.is_free,
    unlock_cost: exam.unlock_cost,
    practice_enabled: exam.practice_enabled,
    question_count: exam.questions.length,
    leaf_question_count: exam.questions.filter((q) => !q.is_container).length,
    published_at: exam.published_at,
  };
  if (!admin) return base;
  return {
    ...base,
    source: exam.source,
    rights_note: exam.rights_note,
    rights_status: exam.rights_status,
    imported_at: exam.imported_at,
    blocked_reason: exam.blocked_reason,
    created_at: exam.created_at,
    updated_at: exam.updated_at,
  };
};

const examDetail = (exam) => ({
  ...examSummary(exam),
  instructions: exam.instructions,
  published_by: exam.published_by,
  unpublished_at: exam.unpublished_at,
  blocked_at: exam.blocked_at,
  stimuli: exam.stimuli,
  questions: exam.questions,
});

const userRow = (user) => ({
  id: user.id,
  email: user.email ?? null,
  phone: user.phone ?? null,
  name: user.name,
  kind: user.kind,
  status: user.status,
  created_at: user.created_at,
  last_login_at: user.last_login_at,
  blocked_reason: user.blocked_reason,
  blocked_at: user.blocked_at,
  wallet_available: user.wallet_available,
});

const record = (actor, action, targetType, targetId, before, after) => {
  state.audit.unshift({
    id: oid(state.nextId++),
    _id: oid(state.nextId),
    actor_user_id: actor?.id ?? null,
    actor_role: actor?.role ?? null,
    action,
    target_type: targetType,
    target_id: String(targetId),
    before,
    after,
    ip: '127.0.0.1',
    user_agent: 'mock dashboard',
    created_at: new Date().toISOString(),
  });
};

const settingValue = (key) => state.settings.find((item) => item.key === key)?.value;

function authenticate(headers) {
  const header = headers.get('Authorization') ?? '';
  const token = header.replace(/^Bearer\s+/i, '');
  const userId = state.sessions.get(token);
  const user = state.users.find((item) => item.id === userId);
  if (!user) throw new HttpError(401, 'UNAUTHORIZED', 'Sign in again');
  if (user.status !== 'active') throw new HttpError(403, 'ACCOUNT_BLOCKED', 'Account blocked');
  return user;
}

function allow(user, roles) {
  if (!roles.includes(user.role)) throw new HttpError(403, 'FORBIDDEN', 'Your role cannot do this');
}

const issue = (user) => {
  tokenSequence += 1;
  const accessToken = `mock-access-${user.id}-${tokenSequence}`;
  const refreshToken = `mock-refresh-${user.id}-${tokenSequence}`;
  state.sessions.set(accessToken, user.id);
  state.sessions.set(refreshToken, user.id);
  return { access_token: accessToken, refresh_token: refreshToken };
};

const publicUser = (user) => ({
  id: user.id,
  email: user.email ?? null,
  phone: user.phone ?? null,
  name: user.name,
  kind: user.kind,
  role: user.role,
  status: user.status,
  language: user.language,
});

/* ------------------------------------------------------------------ receipts */

function receiptPng(lines) {
  const canvas = document.createElement('canvas');
  canvas.width = 520;
  canvas.height = 700;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = '#fdfbf6';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.strokeStyle = '#c9bfa6';
  ctx.lineWidth = 2;
  ctx.strokeRect(14, 14, canvas.width - 28, canvas.height - 28);
  ctx.fillStyle = '#0f766e';
  ctx.fillRect(14, 14, canvas.width - 28, 74);
  ctx.fillStyle = '#ffffff';
  ctx.font = 'bold 26px sans-serif';
  ctx.fillText('Bankak — بنكك', 36, 60);
  ctx.fillStyle = '#1f2933';
  ctx.font = '18px monospace';
  lines.forEach((line, index) => ctx.fillText(line, 36, 140 + index * 40));
  ctx.strokeStyle = '#94a3b8';
  ctx.beginPath();
  ctx.moveTo(36, 560);
  ctx.lineTo(484, 560);
  ctx.stroke();
  ctx.font = '14px monospace';
  ctx.fillStyle = '#64748b';
  ctx.fillText('MOCK RECEIPT — not a real transfer', 36, 600);
  return new Promise((resolve) => canvas.toBlob(resolve, 'image/png'));
}

function receiptPdf(lines) {
  const content = ['BT /F1 16 Tf 40 760 Td (Bankak receipt) Tj ET', ...lines.map((line, index) => `BT /F1 12 Tf 40 ${720 - index * 24} Td (${line.replace(/[()\\]/g, '')}) Tj ET`)].join('\n');
  const objects = [
    '<</Type/Catalog/Pages 2 0 R>>',
    '<</Type/Pages/Kids[3 0 R]/Count 1>>',
    '<</Type/Page/Parent 2 0 R/MediaBox[0 0 595 842]/Resources<</Font<</F1 4 0 R>>>>/Contents 5 0 R>>',
    '<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>',
    `<</Length ${content.length}>>\nstream\n${content}\nendstream`,
  ];
  let pdf = '%PDF-1.4\n';
  const offsets = [];
  objects.forEach((body, index) => {
    offsets.push(pdf.length);
    pdf += `${index + 1} 0 obj\n${body}\nendobj\n`;
  });
  const xref = pdf.length;
  pdf += `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`;
  for (const offset of offsets) pdf += `${String(offset).padStart(10, '0')} 00000 n \n`;
  pdf += `trailer\n<</Size ${objects.length + 1}/Root 1 0 R>>\nstartxref\n${xref}\n%%EOF`;
  return new Blob([pdf], { type: 'application/pdf' });
}

/* --------------------------------------------------------------------- import */

function splitCsvLine(line) {
  const cells = [];
  let current = '';
  let quoted = false;
  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    if (quoted) {
      if (char === '"' && line[index + 1] === '"') {
        current += '"';
        index += 1;
      } else if (char === '"') quoted = false;
      else current += char;
    } else if (char === '"') quoted = true;
    else if (char === ',') {
      cells.push(current);
      current = '';
    } else current += char;
  }
  cells.push(current);
  return cells.map((cell) => cell.trim());
}

function parseCsv(text) {
  const lines = String(text).replace(/^\uFEFF/, '').split(/\r?\n/).filter((line) => line.trim().length);
  if (!lines.length) return { header: [], rows: [] };
  return {
    header: splitCsvLine(lines[0]),
    rows: lines.slice(1).map((line, index) => ({ line: index + 2, cells: splitCsvLine(line) })),
  };
}

const QUESTION_TYPES = new Set([
  'container', 'mcq', 'multi_select', 'true_false', 'matching', 'matching_item', 'fill_blank',
  'table_fill', 'matrix_input', 'truth_table', 'ordering', 'numeric', 'math_expression', 'diacritics', 'language_analysis',
  'short_answer', 'essay',
]);

function runImport(body) {
  const errors = [];
  const warnings = [];
  const examsFile = parseCsv(body.exams);
  const questionsFile = parseCsv(body.questions);
  const stimuliFile = body.stimuli ? parseCsv(body.stimuli) : { header: [], rows: [] };

  const need = (file, name, columns) => {
    for (const column of columns) {
      if (!file.header.includes(column)) {
        errors.push({ file: name, line: 1, field: column, message: `Missing required column "${column}"` });
      }
    }
  };
  need(examsFile, 'exams.csv', ['exam_key', 'subject', 'language', 'class_level', 'exam_year']);
  need(questionsFile, 'questions.csv', ['exam_key', 'path', 'type', 'marks']);

  const readRows = (file, name) =>
    file.rows
      .map((row) => {
        if (row.cells.length !== file.header.length) {
          errors.push({
            file: name,
            line: row.line,
            message: `Expected ${file.header.length} columns but found ${row.cells.length}`,
          });
          return null;
        }
        return Object.fromEntries(file.header.map((column, index) => [column, row.cells[index]]));
      })
      .filter(Boolean);

  const examRows = errors.length ? [] : readRows(examsFile, 'exams.csv');
  const questionRows = errors.length ? [] : readRows(questionsFile, 'questions.csv');
  const stimulusRows = errors.length ? [] : readRows(stimuliFile, 'stimuli.csv');

  const examKeys = new Set(examRows.map((row) => row.exam_key));
  const seenPaths = new Set();
  const topicKeys = new Set(state.topics.map((topic) => topic.key));

  for (const row of examRows) {
    if (!row.exam_key) errors.push({ file: 'exams.csv', line: row.line ?? 0, field: 'exam_key', message: 'exam_key is required' });
    if (!['ar', 'en'].includes(row.language)) {
      errors.push({ file: 'exams.csv', line: 0, field: 'language', message: `language must be ar or en (got "${row.language}")` });
    }
  }

  for (const [index, row] of questionRows.entries()) {
    const line = questionsFile.rows[index]?.line ?? index + 2;
    if (!examKeys.has(row.exam_key)) {
      errors.push({ file: 'questions.csv', line, field: 'exam_key', message: `Unknown exam_key "${row.exam_key}"` });
    }
    if (!QUESTION_TYPES.has(row.type)) {
      errors.push({ file: 'questions.csv', line, field: 'type', message: `Unknown question type "${row.type}"` });
    }
    if (row.marks !== '' && Number.isNaN(Number(row.marks))) {
      errors.push({ file: 'questions.csv', line, field: 'marks', message: `marks must be a number (got "${row.marks}")` });
    }
    const path = `${row.exam_key}/${row.path}`;
    if (seenPaths.has(path)) {
      errors.push({ file: 'questions.csv', line, field: 'path', message: `Duplicate path "${row.path}" in ${row.exam_key}` });
    }
    seenPaths.add(path);
    for (const topic of (row.topic_keys ?? '').split('|').filter(Boolean)) {
      if (!topicKeys.has(topic)) {
        warnings.push({ file: 'questions.csv', line, field: 'topic_keys', message: `Unknown topic "${topic}" — it will be created` });
      }
    }
    if (row.type !== 'container' && !row.key) {
      warnings.push({ file: 'questions.csv', line, field: 'key', message: 'No answer key supplied; the question stays a draft key' });
    }
  }

  if (errors.length) throw new HttpError(422, 'EXAM_IMPORT_INVALID', 'Import has errors', { errors, warnings });

  const summaries = examRows.map((row) => {
    const existing = state.exams.find((exam) => exam.exam_key === row.exam_key);
    const rows = questionRows.filter((question) => question.exam_key === row.exam_key);
    const leaves = rows.filter((question) => question.type !== 'container');
    return {
      row,
      existing,
      exam_key: row.exam_key,
      status: existing?.status ?? 'draft',
      action: existing ? 'updated' : 'created',
      question_count: rows.length,
      leaf_question_count: leaves.length,
      leaf_marks: leaves.reduce((total, question) => total + Number(question.marks || 0), 0),
    };
  });

  if (body.dryRun) {
    return json(200, {
      dry_run: true,
      warnings,
      exams: summaries.map(({ row, ...rest }) => rest),
    });
  }

  const applied = summaries.map((summary) => {
    const id = summary.existing?.id ?? oid(state.nextId++);
    const rows = questionRows.filter((question) => question.exam_key === summary.exam_key);
    const byPath = new Map(rows.map((row, index) => [row.path, { row, id: `${id}q${index + 1}` }]));
    const questions = rows.map((row, index) => {
      const parentPath = row.path.includes('.') ? row.path.split('.').slice(0, -1).join('.') : null;
      const parent = parentPath ? byPath.get(parentPath) : null;
      const isContainer = row.type === 'container';
      return {
        id: `${id}q${index + 1}`,
        parent_id: parent?.id ?? null,
        path: row.path,
        type: row.type,
        stimulus_id: row.stimulus_key ? `${id}s-${row.stimulus_key}` : null,
        text: row.text ?? '',
        options: (row.options ?? '').split('|').filter(Boolean),
        marks: Number(row.marks || 0),
        sort_order: index + 1,
        difficulty: Number(row.difficulty || 2),
        access: row.access || 'paid',
        practice_eligible: row.practice_eligible !== 'false',
        key_status: row.key ? 'official' : 'draft',
        marking_method: isContainer ? null : row.marking_method || 'auto_exact',
        is_container: isContainer,
        children_count: rows.filter((child) => child.path.startsWith(`${row.path}.`)).length,
        key: row.key ? (row.key.includes('|') ? row.key.split('|') : row.key) : null,
        accepted_alternatives: (row.accepted_alternatives ?? '').split('|').filter(Boolean),
        criteria: [],
        model_answer: row.model_answer || null,
        explanation: row.explanation || null,
        key_raw: row.key || null,
        topic_keys: (row.topic_keys ?? '').split('|').filter(Boolean),
        normalisation: (row.normalisation ?? '').split('|').filter(Boolean),
        misconceptions: [],
        key_version: 1,
        key_verifier_ids: [],
        key_verified_at: null,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
    });

    const stimuli = stimulusRows
      .filter((stimulus) => stimulus.exam_key === summary.exam_key)
      .map((stimulus, index) => ({
        id: `${id}s-${stimulus.stimulus_key}`,
        stimulus_key: stimulus.stimulus_key,
        kind: stimulus.kind || 'text',
        title: stimulus.title || null,
        text: stimulus.text ?? '',
        sort_order: index + 1,
      }));

    const doc = {
      ...(summary.existing ?? {}),
      id,
      exam_key: summary.row.exam_key,
      exam_year: Number(summary.row.exam_year || new Date().getFullYear()),
      session: summary.row.session || null,
      class_level: summary.row.class_level,
      stream: summary.row.stream || null,
      subject: summary.row.subject,
      language: summary.row.language,
      duration_minutes: Number(summary.row.duration_minutes || 0),
      total_marks: questions.reduce((total, question) => total + question.marks, 0),
      status: summary.existing?.status === 'blocked' ? 'blocked' : summary.existing?.status ?? 'draft',
      is_free: summary.row.is_free === 'true',
      unlock_cost: summary.row.unlock_cost ? Number(summary.row.unlock_cost) : null,
      practice_enabled: summary.row.practice_enabled !== 'false',
      question_count: questions.length,
      leaf_question_count: questions.filter((question) => !question.is_container).length,
      published_at: summary.existing?.published_at ?? null,
      source: summary.row.source || 'CSV import',
      rights_note: summary.row.rights_note || null,
      rights_status: summary.row.rights_status || 'pending',
      imported_at: new Date().toISOString(),
      blocked_reason: summary.existing?.blocked_reason ?? null,
      created_at: summary.existing?.created_at ?? new Date().toISOString(),
      updated_at: new Date().toISOString(),
      instructions: summary.row.instructions || null,
      published_by: summary.existing?.published_by ?? null,
      unpublished_at: summary.existing?.unpublished_at ?? null,
      blocked_at: summary.existing?.blocked_at ?? null,
      stimuli,
      questions,
    };

    if (summary.existing) Object.assign(summary.existing, doc);
    else state.exams.unshift(doc);

    return {
      id,
      exam_key: doc.exam_key,
      status: doc.status,
      action: summary.action,
      question_count: questions.length,
      leaf_question_count: doc.leaf_question_count,
    };
  });

  return json(201, { dry_run: false, warnings, exams: applied });
}

/* --------------------------------------------------------------------- router */

async function route(method, path, query, body, headers) {
  if (method === 'POST' && path === '/auth/login') {
    const email = String(body.email ?? '').trim().toLowerCase();
    const user = state.users.find((item) => item.email === email);
    if (!user || body.password !== ADMIN_PASSWORD) {
      throw new HttpError(401, 'INVALID_CREDENTIALS', 'Email or password is incorrect');
    }
    if (user.status !== 'active') throw new HttpError(403, 'ACCOUNT_BLOCKED', 'Account blocked');
    return json(200, { user: publicUser(user), tokens: issue(user) });
  }

  if (method === 'POST' && path === '/auth/refresh') {
    const userId = state.sessions.get(body.refreshToken);
    const user = state.users.find((item) => item.id === userId);
    if (!user) throw new HttpError(401, 'INVALID_REFRESH_TOKEN', 'Sign in again');
    return json(200, { user: publicUser(user), tokens: issue(user) });
  }

  if (method === 'GET' && path === '/topics') {
    return json(200, { items: state.topics });
  }

  const user = authenticate(headers);

  if (method === 'GET' && path === '/auth/me') {
    return json(200, { user: publicUser(user), profile: user.profile, wallet: user.wallet });
  }

  if (path === '/admin/payments' && method === 'GET') {
    allow(user, ['owner', 'payment_reviewer']);
    const status = query.get('status');
    const rows = state.payments
      .filter((row) => !status || row.status === status)
      .sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
    return json(200, paginate(rows, query));
  }

  const paymentMatch = path.match(/^\/admin\/payments\/([^/]+)(\/approve|\/reject)?$/);
  if (paymentMatch) {
    allow(user, ['owner', 'payment_reviewer']);
    const payment = state.payments.find((row) => row.id === paymentMatch[1]);
    if (!payment) throw new HttpError(404, 'PAYMENT_REQUEST_NOT_FOUND', 'Payment request not found');
    const action = paymentMatch[2];

    if (!action && method === 'GET') return json(200, payment);

    if (!['submitted', 'under_review'].includes(payment.status)) {
      throw new HttpError(409, 'PAYMENT_NOT_REVIEWABLE', 'This request is not waiting for review');
    }

    if (action === '/approve' && method === 'POST') {
      const checklist = body.checklist ?? {};
      const complete = ['amount_matches', 'date_recent', 'reference_matches', 'receiver_account_ours'].every(
        (key) => checklist[key] === true,
      );
      if (!complete) throw new HttpError(422, 'CHECKLIST_INCOMPLETE', 'Complete the checklist first');
      const before = { status: payment.status };
      payment.status = 'approved';
      payment.decided_at = new Date().toISOString();
      payment.checklist = checklist;
      const student = state.users.find((item) => item.id === payment.student.id);
      if (student) {
        student.wallet.balance += payment.package.credits;
        student.wallet.available += payment.package.credits;
        student.wallet_available = student.wallet.available;
        student.ledger.unshift({
          id: `${student.id}l${student.ledger.length + 1}`,
          entry_type: 'purchase',
          amount: payment.package.credits,
          lot_id: `${payment.id}lot`,
          payment_id: payment.id,
          reason: `شراء ${payment.package.name.ar}`,
          created_at: new Date().toISOString(),
        });
      }
      record(user, 'payment.approved', 'payment_request', payment.id, before, {
        status: 'approved',
        credits: payment.package.credits,
      });
      return json(200, { message: 'Payment approved', request_id: payment.id, credits: payment.package.credits });
    }

    if (action === '/reject' && method === 'POST') {
      const reason = String(body.reason ?? '').trim();
      if (reason.length < 2) throw new HttpError(422, 'REJECT_REASON_REQUIRED', 'A reason is required');
      const before = { status: payment.status };
      payment.status = 'rejected';
      payment.decided_at = new Date().toISOString();
      payment.reject_reason = reason;
      record(user, 'payment.rejected', 'payment_request', payment.id, before, { status: 'rejected', reject_reason: reason });
      return json(200, { message: 'Payment rejected', request_id: payment.id });
    }
  }

  const receiptMatch = path.match(/^\/admin\/receipts\/([^/]+)\/file$/);
  if (receiptMatch && method === 'GET') {
    allow(user, ['owner', 'payment_reviewer']);
    const payment = state.payments.find((row) => row.receipts.some((receipt) => receipt.id === receiptMatch[1]));
    const receipt = payment?.receipts.find((item) => item.id === receiptMatch[1]);
    if (!receipt) throw new HttpError(404, 'RECEIPT_NOT_FOUND', 'Receipt not found');
    const lines = [
      `Reference: ${payment.reference ?? '—'}`,
      `Amount: ${payment.expected_amount_sdg} SDG`,
      `To: ${payment.bank.account_name}`,
      `Account: ${payment.bank.account_number}`,
      `Sender: ${payment.sender_name}`,
      `Date: ${new Date(payment.submitted_at).toISOString().slice(0, 16).replace('T', ' ')}`,
      `Code: ${payment.payment_code}`,
    ];
    const blob = receipt.content_type === 'application/pdf' ? receiptPdf(lines) : await receiptPng(lines);
    return new Response(blob, {
      status: 200,
      headers: { 'Content-Type': receipt.content_type, 'Content-Length': String(blob.size) },
    });
  }

  if (path === '/admin/users' && method === 'GET') {
    allow(user, ['owner']);
    const term = (query.get('q') ?? '').trim().toLowerCase();
    const rows = state.users.filter(
      (row) =>
        !term ||
        row.name.toLowerCase().includes(term) ||
        (row.email ?? '').includes(term) ||
        (row.phone ?? '').includes(term),
    );
    return json(200, paginate(rows.map(userRow), query));
  }

  const userMatch = path.match(/^\/admin\/users\/([^/]+)(\/block|\/unblock)?$/);
  if (userMatch) {
    allow(user, ['owner']);
    const target = state.users.find((row) => row.id === userMatch[1]);
    if (!target) throw new HttpError(404, 'USER_NOT_FOUND', 'Account not found');
    const action = userMatch[2];

    if (!action && method === 'GET') {
      return json(200, {
        user: { ...userRow(target), blocked_by: target.blocked_by, role: target.role, language: target.language },
        profile: target.profile,
        wallet: target.wallet,
        ledger: target.ledger,
        payments: state.payments
          .filter((row) => row.student.id === target.id)
          .map((row) => ({
            id: row.id,
            status: row.status,
            payment_code: row.payment_code,
            expected_amount_sdg: row.expected_amount_sdg,
            credits: row.package.credits,
            package_name: row.package.name.ar,
            reference: row.reference,
            created_at: row.created_at,
            decided_at: row.decided_at,
          })),
        unlocks_count: target.unlocks_count,
      });
    }

    if (target.kind !== 'student') throw new HttpError(422, 'ADMIN_CANNOT_BE_BLOCKED', 'Staff accounts cannot be blocked');

    if (action === '/block' && method === 'POST') {
      const reason = String(body.reason ?? '').trim();
      if (reason.length < 2) throw new HttpError(422, 'REASON_REQUIRED', 'A reason is required');
      const before = { status: target.status };
      const changed = target.status !== 'blocked';
      target.status = 'blocked';
      target.blocked_reason = reason;
      target.blocked_at = new Date().toISOString();
      target.blocked_by = user.id;
      record(user, 'users.blocked', 'user', target.id, before, { status: 'blocked', blocked_reason: reason });
      return json(200, { user: { ...userRow(target), role: target.role, language: target.language }, changed });
    }

    if (action === '/unblock' && method === 'POST') {
      const before = { status: target.status };
      const changed = target.status !== 'active';
      target.status = 'active';
      target.blocked_reason = null;
      target.blocked_at = null;
      target.blocked_by = null;
      record(user, 'users.unblocked', 'user', target.id, before, { status: 'active' });
      return json(200, { user: { ...userRow(target), role: target.role, language: target.language }, changed });
    }
  }

  if (path === '/admin/exams/import' && method === 'POST') {
    allow(user, ['owner', 'content_editor']);
    const response = runImport(body);
    if (response.status === 201) record(user, 'exams.imported', 'exam', 'bundle', null, { papers: body.exams.length });
    return response;
  }

  if (path === '/admin/exams' && method === 'GET') {
    allow(user, ['owner', 'content_editor']);
    const rows = state.exams.filter((exam) => {
      const status = query.get('status');
      const language = query.get('language');
      const subject = query.get('subject');
      const classLevel = query.get('class_level');
      const year = query.get('exam_year');
      if (status && exam.status !== status) return false;
      if (language && exam.language !== language) return false;
      if (subject && !exam.subject.toLowerCase().includes(subject.toLowerCase())) return false;
      if (classLevel && !exam.class_level.toLowerCase().includes(classLevel.toLowerCase())) return false;
      if (year && exam.exam_year !== Number(year)) return false;
      return true;
    });
    return json(200, paginate(rows.map((exam) => examSummary(exam)), query));
  }

  const examMatch = path.match(/^\/admin\/exams\/([^/]+)(\/publish|\/unpublish|\/block|\/config)?$/);
  if (examMatch) {
    allow(user, ['owner', 'content_editor']);
    const exam = state.exams.find((row) => row.id === examMatch[1]);
    if (!exam) throw new HttpError(404, 'EXAM_NOT_FOUND', 'Paper not found');
    const action = examMatch[2];

    if (!action && method === 'GET') return json(200, examDetail(exam));

    if (action === '/config' && method === 'PATCH') {
      allow(user, ['owner']);
      const before = { is_free: exam.is_free, unlock_cost: exam.unlock_cost, practice_enabled: exam.practice_enabled };
      if ('isFree' in body) exam.is_free = Boolean(body.isFree);
      if ('unlockCost' in body) exam.unlock_cost = body.unlockCost === null ? null : Number(body.unlockCost);
      if ('practiceEnabled' in body) exam.practice_enabled = Boolean(body.practiceEnabled);
      exam.updated_at = new Date().toISOString();
      record(user, 'exams.configured', 'exam', exam.id, before, {
        is_free: exam.is_free,
        unlock_cost: exam.unlock_cost,
        practice_enabled: exam.practice_enabled,
      });
      return json(200, examDetail(exam));
    }

    if (action === '/block' && method === 'POST') {
      allow(user, ['owner']);
      const reason = String(body.reason ?? '').trim();
      if (reason.length < 2) throw new HttpError(422, 'REASON_REQUIRED', 'A reason is required');
      const before = { status: exam.status };
      exam.status = 'blocked';
      exam.blocked_reason = reason;
      exam.blocked_at = new Date().toISOString();
      record(user, 'exams.blocked', 'exam', exam.id, before, { status: 'blocked', blocked_reason: reason });
      return json(200, examDetail(exam));
    }

    if (action === '/publish' && method === 'POST') {
      if (!exam.questions.length) throw new HttpError(422, 'EXAM_NOT_PUBLISHABLE', 'This paper has no questions');
      if (exam.status === 'blocked') throw new HttpError(409, 'EXAM_BLOCKED', 'This paper has been taken down');
      const before = { status: exam.status };
      exam.status = 'published';
      exam.published_at = new Date().toISOString();
      exam.published_by = user.id;
      exam.unpublished_at = null;
      record(user, 'exams.published', 'exam', exam.id, before, { status: 'published' });
      return json(200, examDetail(exam));
    }

    if (action === '/unpublish' && method === 'POST') {
      const before = { status: exam.status };
      exam.status = 'draft';
      exam.unpublished_at = new Date().toISOString();
      record(user, 'exams.unpublished', 'exam', exam.id, before, { status: 'draft' });
      return json(200, examDetail(exam));
    }
  }

  if (path === '/admin/topics' && method === 'POST') {
    allow(user, ['owner', 'content_editor']);
    const key = String(body.key ?? '').trim();
    if (state.topics.some((topic) => topic.key === key)) throw new HttpError(409, 'TOPIC_TAKEN', 'That topic key already exists');
    const topic = {
      key,
      name_ar: body.nameAr ?? null,
      name_en: body.nameEn ?? null,
      created_at: new Date().toISOString(),
    };
    state.topics.push(topic);
    record(user, 'topics.created', 'topic', key, null, topic);
    return json(201, topic);
  }

  if (path === '/admin/packages' && method === 'GET') {
    allow(user, ['owner']);
    const active = query.get('active');
    const rows = state.packages
      .filter((pkg) => !active || String(pkg.active) === active)
      .sort((a, b) => a.sort_order - b.sort_order);
    return json(200, paginate(rows, query));
  }

  if (path === '/admin/packages' && method === 'POST') {
    allow(user, ['owner']);
    const pkg = {
      id: oid(state.nextId++),
      name: body.name,
      credits: body.credits,
      price_sdg: body.price_sdg,
      active: body.active ?? true,
      sort_order: body.sort_order ?? 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    state.packages.push(pkg);
    record(user, 'packages.created', 'credit_package', pkg.id, null, pkg);
    return json(201, pkg);
  }

  const packageMatch = path.match(/^\/admin\/packages\/([^/]+)$/);
  if (packageMatch && method === 'PATCH') {
    allow(user, ['owner']);
    const pkg = state.packages.find((row) => row.id === packageMatch[1]);
    if (!pkg) throw new HttpError(404, 'PACKAGE_NOT_FOUND', 'Credit package not found');
    const before = { ...pkg };
    Object.assign(pkg, body, { updated_at: new Date().toISOString() });
    record(user, 'packages.updated', 'credit_package', pkg.id, before, pkg);
    return json(200, pkg);
  }

  if (path === '/admin/settings' && method === 'GET') {
    allow(user, ['owner']);
    return json(200, { items: state.settings });
  }

  if (path === '/admin/settings' && method === 'PUT') {
    allow(user, ['owner']);
    const row = state.settings.find((item) => item.key === body.key);
    if (!row) throw new HttpError(404, 'SETTING_NOT_FOUND', 'Unknown setting');
    const value = body.value;
    if (row.type === 'integer') {
      if (typeof value !== 'number' || !Number.isInteger(value)) throw new HttpError(422, 'SETTING_INVALID', 'Whole number required');
      if (value < row.min || value > row.max) throw new HttpError(422, 'SETTING_OUT_OF_RANGE', `Allowed ${row.min}–${row.max}`);
    } else if (typeof value !== 'string' || value.trim().length < row.min || value.trim().length > row.max) {
      throw new HttpError(422, 'SETTING_OUT_OF_RANGE', `Allowed length ${row.min}–${row.max}`);
    }
    const previous = row.value;
    row.value = row.type === 'integer' ? value : value.trim();
    row.overridden = true;
    row.updated_at = new Date().toISOString();
    record(user, 'settings.updated', 'setting', row.key, { value: previous }, { value: row.value });
    return json(200, { key: row.key, value: row.value, previous, updated_at: row.updated_at });
  }

  if (path === '/admin/settings/mail-status' && method === 'GET') {
    allow(user, ['owner']);
    return json(200, {
      configured: true,
      host: 'smtp.mock.test',
      port: 587,
      secure: false,
      user: 'mailer@mothakira.test',
      from: 'mailer@mothakira.test',
      ok: true,
      code: null,
      error: null,
    });
  }

  if (path === '/admin/settings/test-email' && method === 'POST') {
    allow(user, ['owner']);
    const to = String(body.to ?? '').trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(to)) throw new HttpError(400, 'INVALID_EMAIL', 'Enter a valid email address');
    record(user, 'settings.test_email', 'system', 'mail', null, { to, ok: true, code: null });
    return json(200, { ok: true, to, message_id: '<mock@mothakira.test>', code: null, error: null });
  }

  if (path === '/admin/audit' && method === 'GET') {
    allow(user, ['owner', 'content_editor']);
    const rows = state.audit.filter((entry) => {
      const actor = query.get('actorUserId');
      const action = query.get('action');
      const targetType = query.get('targetType');
      const targetId = query.get('targetId');
      const from = query.get('from');
      const to = query.get('to');
      if (actor && entry.actor_user_id !== actor) return false;
      if (action && entry.action !== action) return false;
      if (targetType && entry.target_type !== targetType) return false;
      if (targetId && entry.target_id !== targetId) return false;
      if (from && new Date(entry.created_at) < new Date(from)) return false;
      if (to && new Date(entry.created_at) > new Date(to)) return false;
      return true;
    });
    return json(200, paginate(rows, query));
  }

  if (path === '/admin/reports' && method === 'GET') {
    allow(user, ['owner', 'content_editor']);
    const status = query.get('status') ?? 'open';
    const rows = state.reports
      .filter((row) => row.status === status)
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    return json(200, paginate(rows, query));
  }

  const reportMatch = path.match(/^\/admin\/reports\/([^/]+)\/resolve$/);
  if (reportMatch && method === 'POST') {
    allow(user, ['owner', 'content_editor']);
    const report = state.reports.find((row) => row.id === reportMatch[1]);
    if (!report) throw new HttpError(404, 'REPORT_NOT_FOUND', 'Report not found');
    if (report.status !== 'open') throw new HttpError(409, 'REPORT_NOT_OPEN', 'This report has already been reviewed');
    const before = { status: report.status };
    report.status = body.status;
    report.resolution_note = body.note ?? null;
    report.resolved_at = new Date().toISOString();
    report.resolved_by = user.id;
    record(user, 'reports.resolved', 'question_report', report.id, before, { status: report.status });
    return json(200, report);
  }

  throw new HttpError(404, 'NOT_FOUND', `No mock handler for ${method} ${path}`);
}

export function installMockApi() {
  const original = window.fetch.bind(window);
  window.fetch = async (input, init = {}) => {
    const url = typeof input === 'string' ? input : input.url;
    if (!url.startsWith(BASE)) return original(input, init);

    const parsed = new URL(url, window.location.origin);
    const path = parsed.pathname.slice(BASE.length);
    const method = (init.method ?? 'GET').toUpperCase();
    const headers = new Headers(init.headers ?? {});
    let body = {};
    if (init.body) {
      try {
        body = JSON.parse(init.body);
      } catch {
        body = {};
      }
    }

    await wait(140);
    try {
      return await route(method, path, parsed.searchParams, body, headers);
    } catch (error) {
      if (error instanceof HttpError) return failure(error.status, error.code, error.message, error.details);
      return failure(500, 'INTERNAL_ERROR', error?.message ?? 'Mock failure');
    }
  };

  console.info('[mock] dev API enabled — sign in with', admins.map((admin) => `${admin.email} (${admin.role})`).join(', '), 'password', ADMIN_PASSWORD);
}