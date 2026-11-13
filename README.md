# Mothakira (مذكرة)

Android study app for Sudanese students: past exam papers, practice, and AI study tools paid for with credits bought through Bankak transfers. The full product and technical plan is in [PLAN.md](PLAN.md).

## Current build status

Phase 1 backend foundation, implemented and test-covered:

- Phone + password auth, one-time recovery code, password reset with code rotation, JWT access/refresh tokens, role guards.
- Append-only credit ledger, price-locked credit lots, atomic spends, reservations with expiry, sweeper, reconciliation.
- Bankak payment requests: unique exact amounts, payment codes, transaction-reference uniqueness per receiving account, cross-account flags, reviewer checklist, atomic approval that grants credits exactly once, reject/resubmit, cancel before submission (the amount is released back for reuse).
- Exam content: papers, shared stimuli, a self-referencing question tree addressed by dotted `path`, per-question keys/criteria/marking method, canonical topics, CSV import with row-level validation and a dry run, publish/unpublish, owner-only takedown (block), and student read endpoints that expose keys only for `trial` and `free` questions.
- Audit log for approvals, rejections, manual credit changes, imports, publishing and takedowns.
- EN/AR-ready error codes (the clients map codes to localized text).

Not built yet: practice and objective auto-marking, exam unlock, dashboard UI, Flutter app, question images, receipt file storage, 2FA, AI pipeline, key history/re-marking.

## Layout

```
api/            Node.js + Express + Mongoose (plain JavaScript, ES modules)
  src/config/   validated environment configuration
  src/core/     db, transactions, auth, errors, validation, audit, rate limits
  src/modules/  auth, users, wallet, payments, packages, exams, topics, settings, audit
  scripts/      seed owner, seed dev data, reconcile wallets
  tests/        node:test suites on an in-memory MongoDB replica set
dashboard/      React dashboard (next slice)
app/            Flutter student app (next slice)
```

## Setup

```bash
cd api
cp .env.example .env
npm install
```

Fill `.env`:

- `MONGODB_URI` — Atlas cluster or a local **single-node replica set** (transactions are required; the server refuses to start on a standalone MongoDB).
- `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` — 32+ random characters each.
- `BANKAK_ACCOUNT_NAME`, `BANKAK_ACCOUNT_NUMBER` — the receiving account shown in the app.
- `ADMIN_BOOTSTRAP_PHONE`, `ADMIN_BOOTSTRAP_PASSWORD`, `ADMIN_BOOTSTRAP_NAME` — used once to create the owner account.

Then:

```bash
npm run seed:dev     # owner + three starter packages + Bankak settings
npm run dev          # http://localhost:4000/health
```

## Tests

```bash
npm test
```

The suite runs against an in-memory MongoDB **replica set**, so transactions are exercised. The first run downloads the MongoDB binary (large, one-time). Covered invariants:

- Signup, duplicate phone, blocked account, recovery-code reset and rotation, admin/student role separation.
- Sequential and concurrent credit spends cannot overdraw; oldest-expiry lots are consumed first.
- Reservations reserve without charging, expire back to available, and still settle if their lot expires mid-job.
- Lot expiry writes one idempotent ledger entry.
- Payment amounts are unique while open; a reference is unique per receiving account and only flagged across accounts.
- Approval requires the full checklist and two concurrent approvals create exactly one credit grant and one purchase ledger row.
- Reject → resubmit → approve works; review endpoints are closed to students and content editors.
- A pending request can be cancelled (its unique amount is reused by the next request); a submitted request cannot, and another student cannot cancel someone else's request.
- A valid paper imports as a tree, container marks are derived bottom-up, Arabic-Indic digits and marks are normalised, and the dry run writes nothing.
- Metrics that block import: leaf marks that do not add up to `total_marks`, duplicate paths, missing parents, duplicate sibling `sort_order`, auto-marked questions without a key, criteria that do not sum to the question marks, unknown topics, unknown stimuli, and image columns while image storage is unavailable.
- A paper with `draft` keys cannot be published; verified keys unblock publishing; unpublish hides it from students; only the owner can block, and a blocked paper cannot be published.
- Students see published papers only, and receive keys/criteria/model answers only on `trial` and `free` questions.
- Re-importing the same `exam_key` replaces the paper in place without duplicating rows; a blocked paper stays blocked.

## API

All routes are under `/api/v1`. Errors use `{ error: { code, message, details, request_id } }`; clients should translate `code`.

| Method | Route | Access | Purpose |
| --- | --- | --- | --- |
| POST | `/auth/student/signup` | public | Create student, returns recovery code once |
| POST | `/auth/login` | public | Student or admin login |
| POST | `/auth/refresh` | public | Rotate access token |
| POST | `/auth/recovery/reset` | public | Reset password with recovery code |
| GET | `/auth/me` | auth | Profile + wallet summary |
| GET | `/packages` | public | Active credit packages |
| GET | `/topics` | public | Canonical topic keys |
| GET | `/exams` | auth | Published papers, filterable by language, subject, class level, year, session, stream |
| GET | `/exams/:id` | auth | One published paper with stimuli and questions (keys only on trial/free items) |
| POST | `/admin/topics` | owner, editor | Create a canonical topic |
| POST | `/admin/exams/import` | owner, editor | Validate (dry run) or apply the three CSVs |
| GET | `/admin/exams` | owner, editor | All papers, any status |
| GET | `/admin/exams/:id` | owner, editor | Full paper including keys and verification fields |
| POST | `/admin/exams/:id/publish` | owner, editor | Publish if sources and keys allow it |
| POST | `/admin/exams/:id/unpublish` | owner, editor | Return a paper to draft |
| POST | `/admin/exams/:id/block` | owner | Takedown; unpublishes and keeps the block on re-import |
| GET | `/wallet` | student | Balance, reserved, available, next expiry |
| GET | `/wallet/ledger` | student | Paged ledger |
| POST | `/payments/requests` | student | Open a payment request with an exact amount |
| GET | `/payments/requests` | student | My payment requests |
| GET | `/payments/requests/:id` | student | One request |
| POST | `/payments/requests/:id/receipt` | student | Submit reference (+ receipt metadata) |
| POST | `/payments/requests/:id/cancel` | student | Cancel a request that is still pending payment |
| GET | `/admin/payments` | owner, reviewer | Review queue, oldest first |
| GET | `/admin/payments/:id` | owner, reviewer | Request + receipts |
| POST | `/admin/payments/:id/approve` | owner, reviewer | Checklist-gated approval |
| POST | `/admin/payments/:id/reject` | owner, reviewer | Reject with reason |
| GET | `/admin/credits/users/:userId` | owner | Wallet summary for a user |
| POST | `/admin/credits/users/:userId/grant` | owner | Grant credits with reason |
| POST | `/admin/credits/users/:userId/adjust` | owner | Signed adjustment with reason |
| GET | `/admin/audit` | owner | Audit log |

## Exam import

`POST /api/v1/admin/exams/import` takes `{ exams, stimuli, questions, dryRun }` where each value is the raw CSV text from `exams.csv`, `stimuli.csv` (optional) and `questions.csv` from the plan (A1b). The dashboard will send the parsed files; ZIP upload and the `images/` folder are not supported yet, so a paper that references images is rejected rather than imported with a broken question.

- Topic keys in `topic_tags` must already exist; create them with `POST /admin/topics`.
- Container marks are derived from children. Container rows may leave `marks` empty; a different stated value produces a warning.
- A successful import replaces the paper's questions and stimuli atomically. Re-importing keeps the same `exam_key` and does not duplicate rows.
- Imported `published` papers must pass the same gates as manual publish (source, rights note, no `draft` keys).
- A blocked paper stays blocked on re-import; publishing is refused until the block is lifted in the database, since there is no unblock endpoint yet.
- The importer records `key_status` as supplied. The plan's rules that `verified` needs two named admin verifiers and `official` needs the source document are stored as fields but not enforced yet; the dashboard verification flow will enforce them.

## Money rules encoded here

- Credits are integers; SDG amounts are integers.
- `credit_ledger` is append-only: there is no update or delete path.
- A purchase can be credited once — enforced by a conditional status transition, a unique lot per payment, and a unique partial index on the purchase ledger entry.
- Spend/reserve updates are conditional on `remaining - reserved` so parallel requests cannot overdraw.
- Lots are consumed earliest-expiry first; `expires_at: null` means never.
- Expired lots are unspendable immediately; the sweeper records the loss idempotently. A reservation made before expiry still settles.
- Changing the multiplier affects only future lots; each lot stores `multiplier_at_grant`.
- Manual credit changes require a reason and write an audit entry.
