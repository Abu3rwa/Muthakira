# Master Prompt – Mothakira (مذكرة) Flutter Student App

> Paste everything below the line into your AI coding agent (Copilot / Claude / Cursor / Kilo).
> It is written against the **real, already-built backend** in `api/` (Node 20 + Express + MongoDB, base path `/api/v1`) and the product plan in `PLAN.md`.
> Where the backend does not yet support something, the prompt says so explicitly and tells the agent what to do instead (stub behind an interface, never invent endpoints).

---

## 0. ROLE AND MISSION

You are a senior Flutter engineer. Build **Mothakira**, an **Arabic-first (RTL) + English**, modern, clean Android study app for **Sudanese Secondary School Certificate students**. Students browse past exam papers, unlock them with credits, practise question by question with instant server-side marking, buy credits by manual **Bankak** bank transfer (upload receipt, an admin approves it), and track their wallet.

Deliver a **complete, compiling, runnable app** in a new folder `student_app/` at the repo root (`A:\business\sudaxam\student_app`). Work feature by feature, run `flutter analyze` and `flutter test` after each feature, and do not stop at a skeleton. Every screen must have real loading / empty / error / offline states.

Hard rules:

1. **Never trust or compute money, marks, prices or access on the client.** The server is the authority. The client sends answers, never marks.
2. **Never invent API endpoints or fields.** Use only what is documented in section 4. If something is missing (section 14), hide it behind a repository interface with a clearly marked `TODO(backend)` and a graceful "coming soon" UI. Never fake data in production code paths.
3. **No hard-coded user-facing strings.** Everything goes through ARB localisation (`ar` default, `en`).
4. **No secrets in the repo.** The only configuration is the API base URL, supplied via `--dart-define=API_BASE_URL=...`.
5. Plain, readable code. Comment only non-obvious logic.

### 0.1 Priorities (in this order when they conflict)

1. **Performance and responsiveness first.** The app must feel instant on a 2 GB phone and a weak network. Follow 7.1 strictly. Any feature, animation or dependency that causes jank, slow startup or a larger APK must be simplified or dropped. Measure; don't guess.
2. **Features complete and working.** Every feature in section 5 must work end to end against the real API, including all states. A smaller set of finished, polished features beats many half-done ones; follow the build order in section 12.
3. **Easy-to-read, easy-to-change code.** Another developer must understand any file in under a minute.
4. Visual polish (section 3) must never cost priority 1.

### 0.2 Readability rules (enforced in review and lints)

- **Small units:** files under ~250 lines, widgets under ~80 lines of `build`, functions do one thing and fit on one screen. Split big screens into small named widgets (`_ExamCard`, `_PriceRow`) in the same feature's `presentation/widgets`.
- **Names over comments:** descriptive names (`unlockExam`, `isPaperUnlocked`, `expectedAmountSdg`), no abbreviations, no single-letter variables except loop indexes. Booleans read as questions (`isLoading`, `hasError`).
- **One pattern everywhere:** every screen = `Screen` (layout) + `ViewModel` (`ChangeNotifier`, state + actions) + use cases/repositories. No business logic in widgets, no widgets in view-models, no dio calls outside `data`.
- **Explicit states:** use sealed classes or enums for screen state (`loading / data / empty / error`) and `switch` expressions in the UI; avoid scattered booleans and nullable soup.
- **Immutable models** with `copyWith`; parsing in one place (`fromJson`) and defensive about nulls; no `dynamic` leaking out of the data layer.
- **No magic values:** colours, spacing, radii, durations, endpoint paths, storage keys and error codes live in named constants/tokens, never inline.
- **Consistent structure and style:** `dart format`, `flutter_lints` + extra rules (`prefer_const_constructors`, `avoid_print`, `public_member_api_docs` off, `always_declare_return_types`, `unawaited_futures`, `use_build_context_synchronously`). Imports ordered; relative imports within a feature, package imports across features.
- **Short doc comment** (one line) on each repository, use case and view-model class saying what it is for. Do not comment obvious code.
- **Tests double as documentation:** name tests as sentences ("shows paywall when unlock returns 402").
- **No premature abstraction or clever code:** prefer straightforward code over generics, mixins or code generation unless it removes real duplication. No dead code, no commented-out code, no TODOs except the marked `TODO(backend)` items.
- Each feature folder gets a 10-line `README.md` (what it does, its screens, its endpoints) so the next developer can navigate quickly.

---

## 1. PRODUCT CONTEXT

- Brand: **Mothakira / مذكرة**. Tagline ideas: "ذاكر بذكاء" / "Study smart". Brand colour is open: choose a calm deep teal/indigo primary plus semantic colours (success, warning, error, info) and keep all colours in design tokens so they can change in one place.
- Audience: Sudanese secondary-school students, many on **2 GB RAM Android phones**, slow/intermittent mobile data, Arabic as the primary language. Currency is **SDG**, payments are via **Bankak** (Bank of Khartoum mobile banking) by manual transfer.
- Content: official past exam papers (by subject, year, session, class level, stream, language `ar`/`en`) with a question tree (containers → leaf questions), shared stimuli (reading passages), 10+ question types, answer keys.
- Business model: free signup bonus credits (admin-configurable) → unlock a paper for N credits → practise it → buy more credits via Bankak packages.
- Admin side (React dashboard) already exists; **this task is only the student app**.

---

## 2. TECH STACK AND PROJECT SETUP

- Flutter stable (3.32+), Dart 3.x, **Material 3** (`useMaterial3: true`), Android first (iOS must at least compile, no platform-specific work required).
- Packages (pin latest stable, justify any extra):
  - State: **`provider`** (one `ChangeNotifier` view-model per screen/flow; repositories injected via `MultiProvider` at the root; use `context.select`/`Selector` to limit rebuilds; dispose with the route).
  - Routing: **`go_router`** (with redirect guard for auth, deep-link ready).
  - HTTP: **`dio`** with interceptors (auth, refresh, error mapping, request-id logging in debug only).
  - Secure storage: **`flutter_secure_storage`** (tokens). Preferences: **`shared_preferences`** (language, theme, text scale, digits, onboarding flags).
  - Local DB for offline cache: **`drift`** (+ `sqlite3_flutter_libs`, `drift_dev`, `build_runner`).
  - Localisation: **`flutter_localizations`**, **`intl`**, ARB files `app_ar.arb` (template/default) and `app_en.arb`, ICU plurals (Arabic has 6 plural forms).
  - Images/files: **`image_picker`** (camera + gallery), **`file_picker`** (PDF), **`image`** or **`flutter_image_compress`** (compress receipts client-side below 8 MB, target ~1.5 MB), **`mime`**.
  - Utilities: **`connectivity_plus`**, **`url_launcher`** (support links), **`share_plus`**, **`cached_network_image`** only if images are ever served by URL, **`flutter_svg`**, **`google_fonts` is NOT allowed** (bundle fonts, see 3.3).
  - Models: hand-written immutable classes or **`freezed` + `json_serializable`** (pick one and be consistent).
  - Tests: `flutter_test`, **`mocktail`**, `integration_test`, golden tests for key components.
  - Lints: `flutter_lints` + `very_good_analysis`-style strictness; **zero analyzer warnings** at the end.
- `applicationId`: `sd.mothakira.student`. Min SDK 23 (Android 6). Enable R8/shrink for release. Provide `--dart-define=API_BASE_URL`; defaults: Android emulator `http://10.0.2.2:4000/api/v1`, physical device = LAN IP of the dev machine. Use HTTPS in production; allow cleartext only in the debug manifest.

### 2.1 Folder structure (feature-first, strict)

```
student_app/
  lib/
    main.dart / app.dart / bootstrap.dart
    core/
      config/        env (API_BASE_URL), constants
      network/       dio client, interceptors, api_exception, error_codes, connectivity
      storage/       secure_token_store, prefs_store, drift database
      theme/         tokens (colors, spacing 8dp grid, radius, type scale), light/dark ThemeData
      l10n/          generated + locale controller, digit formatter, date/number/currency formatters
      routing/       app_router.dart (go_router), route names, guards
      errors/        failure types, error-to-message mapper (code -> localized text)
      utils/         bidi helpers (isolate LTR runs), debouncer, result type
    shared/
      widgets/       question_card, answer inputs, feedback_panel, credit_chip, price_sheet,
                     paywall_sheet, payment_timeline, offline_banner, saved_badge, skeleton,
                     empty_state, error_state, copy_field, primary_button, section_header
    features/
      auth/ onboarding/ home/ exams/ practice/ wallet/ payments/ profile/ settings/ system/
        data/          api client (dio), DTOs, local (drift) data source, repository impl
        domain/        entities, repository interfaces, use cases
        presentation/  screens, widgets, view-models (ChangeNotifier)
  test/ integration_test/ assets/{fonts,images,icons} l10n/
```

Rules: a feature never imports another feature's `presentation`; cross-feature needs go through `domain` interfaces or routes. Repositories return a `Result<T, Failure>` (or throw typed exceptions caught in the view-model) – pick one and keep it consistent.

---

## 3. DESIGN SYSTEM AND UX

### 3.1 Principles
Modern, calm, focused, **fast on 2 GB phones**, trustworthy where money is involved. One primary action per screen, anchored at the bottom within thumb reach. Tap targets ≥ 48 dp. 8 dp spacing grid. Corner radius 12–20. Short transitions (150–250 ms), no heavy animation libraries, **respect reduced motion**. Colour is never the only signal (icon + text for correct/incorrect/pending).

### 3.2 Themes
Light + dark, follow system by default, user override in Settings. Colour roles from tokens. Text scale up to **1.5×** must not overflow or clip Arabic diacritics (check line height).

### 3.3 Typography and fonts
Bundle two Arabic-capable fonts with full diacritics (tashkeel) support: a **reading font** for question/passage text (e.g. Amiri or Noto Naskh Arabic) and a **UI font** (e.g. IBM Plex Sans Arabic / Cairo / Tajawal) plus a Latin pairing for English. Question text is large and high-contrast, follows the text-scale setting. Measure and report APK size impact.

### 3.4 Shared components (build once in `shared/widgets`)
Question card per type (optional stimulus, zoom for images), answer inputs, **feedback panel** (correct / incorrect / pending with icon + text + awarded marks, shows the key and explanation only when the server returned them), credit chip (balance in the app bar), **price-preview sheet** ("Unlock for N credits – you have M"), **paywall sheet** (insufficient credits → add credit), **payment status timeline**, offline banner, "saved / pending sync" badge, skeleton loaders, empty and error states with retry, copy-to-clipboard field with large copy button.

### 3.6 Modern visual language (concrete spec – implement in `core/theme`)

- **Palette (define as `ColorScheme` seeds, then tune; WCAG AA contrast ≥ 4.5:1 for text, 3:1 for UI):**
  primary deep indigo-teal (e.g. `#0F5C5C` light / `#7FD6D0` dark), secondary warm amber accent (`#F2A93B`) used sparingly for credits/highlights, tertiary soft violet for practice/progress, neutral surfaces with subtle tint (`surfaceContainerLow/High` tonal layers, no pure black/white), semantic: success `#2E9E6B`, warning `#E0A100`, error `#D64545`, info `#3B82C4`. Never rely on colour alone.
- **Material 3 tonal surfaces**, large rounded shapes (cards 20 dp, sheets 28 dp top radius, buttons fully rounded/stadium or 16 dp, inputs 14 dp), soft low elevation (prefer tonal colour over shadows), generous whitespace, 16–24 dp screen padding, 8 dp grid.
- **Type scale** via tokens: display/headline for hero numbers (credits, score), title for cards, body 16 sp minimum for question text (18 sp default for Arabic reading font, line height ≥ 1.6 so tashkeel is never clipped), label 12–14 sp. Tabular figures for amounts.
- **Hero elements:** gradient wallet card (primary → tertiary), circular/linear **progress rings** for score and attempt progress, subtle illustration-style empty states (SVG, tiny), segmented controls and filter chips, bottom sheets instead of dialogs, sticky bottom action bar, large pill CTAs.
- **Navigation bar:** M3 `NavigationBar` with animated pill indicator, badge dots (e.g. pending payment), mirrored automatically in RTL.
- **Motion (150–250 ms, `Curves.easeOutCubic`):** shared-axis page transitions, `AnimatedSwitcher` for feedback panel, count-up on credits, skeleton shimmer (lightweight, own implementation), haptic feedback on correct/incorrect and copy. **Honour `MediaQuery.disableAnimations`** (reduce motion) and keep everything GPU-cheap (no blur/backdrop filters on low-end devices; gate any glass/blur effect behind a "device capable" flag).
- **Dark theme:** true design pass, not an inversion: lower-saturation primaries, elevated surfaces lighter than the background, AMOLED-friendly deep background, tested contrast. Optional Android 12+ dynamic colour toggle in Settings (off by default so the brand stays consistent).
- **Iconography:** one consistent rounded icon set (Material Symbols Rounded), 24 dp, icons + labels for key actions.
- **Feedback components:** correct = check icon + green tonal container; incorrect = cross icon + red tonal container; pending = hourglass + neutral container; each also has text. Receipt/payment status uses a vertical timeline with filled/outlined nodes.
- **Accessibility:** `Semantics` labels in both languages, logical focus order, 48 dp targets, supports TalkBack, large text 1.5×, bold-text and high-contrast system settings respected, no information conveyed by colour alone.
- **Deliverable:** a hidden debug "Design gallery" screen (debug builds only) showing every token, component and state in light/dark and ar/en, used for golden tests.

### 3.5 States every screen must define
Loading (skeleton) · empty · error with retry · offline (what still works) · locked (unlock CTA) · insufficient credits · processing/long-running · permission rationale (camera/storage).

---

## 4. BACKEND CONTRACT (SOURCE OF TRUTH)

Base URL: `{API_BASE_URL}` = `http://<host>:4000/api/v1`. JSON everywhere except receipt upload (multipart). Health check (not under `/api/v1`): `GET /health`.

### 4.1 Auth model and token handling
- Header on every authenticated call: `Authorization: Bearer <accessToken>`.
- Login/signup/refresh return `tokens` = `{access_token, refresh_token, token_type:'Bearer', expires_in}` (**snake_case**; access TTL ~15 min, refresh ~30 days). The refresh **request** body is camelCase: `{"refreshToken": "..."}`. **Refresh tokens rotate on every use**: always store the new pair returned by `/auth/refresh`, and never reuse an old refresh token.
- Dio interceptor: on `401`, call `/auth/refresh` **once** (single-flight lock so parallel requests share one refresh), retry the original request once; if refresh fails with `401 INVALID_REFRESH_TOKEN` or `403 ACCOUNT_BLOCKED`, clear tokens and route to login (blocked → show a dedicated blocked screen).
- Store tokens only in secure storage. On logout: delete tokens and wipe all user-scoped local data (drift tables, cached keys).
- Phone numbers: send as typed after trimming; the server normalises. Show/input phone as an LTR-isolated run; accept Arabic-Indic digits and convert to Western before sending.

### 4.2 Error envelope (all non-2xx)
```json
{ "error": { "code": "INSUFFICIENT_CREDITS", "message": "...", "details": [...], "request_id": "..." } }
```
Map **`code`** (never the English `message`) to localised text. `422 VALIDATION_ERROR` carries `details: [{path, message}]` → show inline under the matching field. Known codes to map (provide an Arabic + English string for each, and a generic fallback):
`UNAUTHORIZED, INVALID_CREDENTIALS, INVALID_TOKEN, INVALID_REFRESH_TOKEN, ACCOUNT_BLOCKED, FORBIDDEN, NOT_FOUND, PHONE_TAKEN, INVALID_RECOVERY_CODE, VALIDATION_ERROR, RATE_LIMITED (429), INSUFFICIENT_CREDITS (402), EXAM_NOT_FOUND, EXAM_LOCKED (403), PRACTICE_DISABLED (409), QUESTION_NOT_FOUND, QUESTION_NOT_ANSWERABLE (422), ATTEMPT_NOT_FOUND, DUPLICATE_VALUE, PACKAGE_NOT_FOUND, PAYMENT_ACCOUNT_NOT_CONFIGURED, TOO_MANY_OPEN_PAYMENTS (409), PAYMENT_AMOUNTS_EXHAUSTED (409), PAYMENT_REQUEST_NOT_FOUND, PAYMENT_NOT_SUBMITTABLE, PAYMENT_NOT_CANCELLABLE, INVALID_REFERENCE, RECEIPT_NOT_FOUND, RECEIPT_ALREADY_ATTACHED, RECEIPT_TOO_LARGE (413), RECEIPT_FIELD_INVALID, RECEIPT_REQUIRED, RECEIPT_FILE_MISSING, ATTEMPT_CLOSED, REPORT_ALREADY_OPEN (409), INVALID_CURSOR, INTERNAL_ERROR`.
Also handle network failures (timeout, no connection, DNS) as a distinct `NetworkFailure`, and `5xx` as a `ServerFailure` with "server waking up / try again" copy (free-tier hosting can cold-start; use 30 s timeouts for GETs and a visible "server waking up" state after 6 s).

### 4.3 Endpoints the student app uses

| Area | Method + path | Body / query | Notes |
| --- | --- | --- | --- |
| Auth | `POST /auth/student/signup` | `{phone(7–20), password(8–128), name(2–120), classLevel(1–80), stream?(nullable), language:'ar'\|'en'}` | `201` → `{ user, recovery_code, tokens }`. **`recovery_code` is shown exactly once.** Signup bonus credits may be granted. `409 PHONE_TAKEN` |
| Auth | `POST /auth/login` | `{phone, password}` (or `{email, password}`; students use phone) | `200` → `{ user, tokens }` |
| Auth | `POST /auth/refresh` | `{refreshToken}` | → `{ user, tokens }` (rotated) |
| Auth | `POST /auth/recovery/reset` | `{phone, recoveryCode, newPassword(8–128)}` | → `{ recovery_code }` – a **new** code, show once again. Code is case-insensitive (uppercase before send). |
| Auth | `GET /auth/me` | – | → `{ user, profile:{class_level, stream, language}, wallet:{balance, reserved, available, next_expiry_at} }` |
| Catalogue | `GET /packages` | – | public. List of `{id, name, credits, price_sdg}` |
| Catalogue | `GET /topics` | – | public. `{key, name_ar, name_en}` |
| Exams | `GET /exams` | query: `language, subject, class_level, stream, session, exam_year, limit(1–100, default 20), skip` | public. → `{items:[ExamSummary], total, limit, skip}`. Only published papers. |
| Exams | `GET /exams/:id` | – | Send the token so `unlocked` is accurate. → ExamSummary + `instructions, unlocked, unlock_cost (effective price), stimuli[], questions[]`. **Paid keys are never included**; only `access:'trial'\|'free'` questions carry `key/explanation/...` |
| Exams | `POST /exams/:id/unlock` | – | Spends credits. Idempotent; `402 INSUFFICIENT_CREDITS`; `0` price = free unlock. Response = unlock record. |
| Exams | `GET /exams/:id/keys` | – | Full keys/criteria/model answers for an **unlocked or free** paper only. |
| Exams | `GET /exams/unlocks` | – | My unlocked papers. (Route is declared before `/:id`; call it literally.) |
| Practice | `POST /practice/attempts` | `{examId}` | Start an attempt on an unlocked/free paper. → attempt |
| Practice | `GET /practice/attempts/:id` | – | Attempt with its answers |
| Practice | `POST /practice/attempts/:id/answers` | `{questionId, answer}` | `answer` = string \| number \| boolean \| list \| object (≤ 20 000 chars). → `{answer, feedback, attempt}` |
| Practice | `POST /practice/attempts/:id/close` | – | Close the attempt |
| Practice | `POST /questions/:id/report` | `{reason(5–500)}` | One open report per question per student → `409 REPORT_ALREADY_OPEN` |
| Wallet | `GET /wallet` | – | `{balance, reserved, available, next_expiry_at}` – **show `available`**, mention reserved if > 0 |
| Wallet | `GET /wallet/ledger` | query `limit(≤100)`, `cursor` (ISO date, from the last item's `created_at`) | Reverse-chronological history; infinite scroll |
| Payments | `POST /payments/requests` | `{packageId}` | Creates a request and reserves a **unique expected amount**. Max open requests per student is admin-set (default 3). |
| Payments | `GET /payments/requests` / `GET /payments/requests/:id` | – | My requests / one request |
| Payments | `POST /payments/requests/:id/cancel` | – | Cancel an unpaid request |
| Payments | `POST /payments/receipts` | multipart, field **`file`** (JPEG/PNG/WebP/PDF, ≤ 8 MB) | → receipt `{id, ...}` |
| Payments | `POST /payments/requests/:id/receipt` | `{reference(4–120), senderName?, receiptId?}` | Submit/resubmit. Allowed only when status is `pending_payment`, `needs_info` or `rejected`. |
| Payments | `GET /payments/receipts/:id/file` | – | Stream my own receipt image/PDF (auth header required → fetch bytes with dio, don't use `Image.network` without headers) |

### 4.4 Key data shapes

#### 4.4.0 Exact response envelopes (verified against the API code – use these, they override the table notes above)

```text
GET  /packages                      -> { items: [ {id, name, credits, price_sdg} ] }
GET  /exams                         -> { items:[ExamSummary], total, limit, skip }
GET  /exams/:id                     -> ExamSummary + { instructions, unlocked, unlock_cost, stimuli[], questions[] }   (works without token; send it when logged in)
POST /exams/:id/unlock              -> { unlock:{id, exam_id, source:'free'|'purchase', credits_spent, unlocked_at}, charged:bool, cost:int }   (201 if charged, 200 if already unlocked/free)
GET  /exams/:id/keys                -> { exam_id, exam_key, unlocked:true, items:[ {id, path, key, accepted_alternatives, explanation, criteria, model_answer} ] }   (403 EXAM_LOCKED if locked; leaf questions only)
GET  /exams/unlocks                 -> { items:[ unlock ] }
POST /practice/attempts             -> { attempt, created:bool, credits_spent:0 }   (201 new, 200 resumed open attempt – there is at most ONE open attempt per paper)
GET  /practice/attempts/:id         -> { attempt, answers:[ {id, question_id, marking_status, correct, awarded_marks, attempts_count, answered_at} ] }   (does NOT return the text the student typed – keep submitted answers locally)
POST /practice/attempts/:id/answers -> { answer, feedback, attempt }
POST /practice/attempts/:id/close   -> { attempt, closed:bool }
POST /questions/:id/report          -> 201 report
GET  /wallet                        -> { balance, reserved, available, next_expiry_at }
GET  /wallet/ledger                 -> { items:[ {id, entry_type, amount, lot_id, payment_id, reason, created_at} ], next_cursor }   (pass next_cursor back as ?cursor=; an empty items list = end)
POST /payments/requests             -> 201 { request: PaymentRequest, account_number }
GET  /payments/requests             -> { items:[ PaymentRequest ] }   (latest 50)
GET  /payments/requests/:id         -> PaymentRequest + { receipt: null | {id, content_type, size_bytes, sha256, uploaded_at, file_url} }
POST /payments/requests/:id/cancel  -> PaymentRequest   (409 PAYMENT_NOT_CANCELLABLE once submitted)
POST /payments/receipts (multipart) -> 201 {id, content_type, size_bytes, sha256, uploaded_at}
POST /payments/requests/:id/receipt -> 200 (updated request with receipt; re-fetch GET /payments/requests/:id to be safe)
GET  /auth/me                       -> { user:{id, phone, email, name, kind, role, status, language, created_at}, profile:{class_level, stream, language, role}, wallet }
Signup/login/refresh                -> { user, tokens:{access_token, refresh_token, token_type, expires_in}, recovery_code? }   (recovery_code only on signup)
```

Access rules worth encoding in the UI:
- **Trial/free questions are answerable without unlocking** (`question.access` is `trial` or `free`); answering a paid question on a locked paper returns `403 EXAM_LOCKED` → open the unlock/paywall sheet instead of showing an error.
- `POST /practice/attempts` returns `409 PRACTICE_DISABLED` when the admin turned practice off for that paper.
- `diacritics` questions are normally **self-marked** (returned as `pending_self`) unless the question's `marking_method` says otherwise; `short_answer`/`essay` are `pending_ai` (no AI yet).
- Fill-blank/table answers are **partially credited** per correct part: the feedback is only `{correct, awarded_marks, key?, explanation?}` (no per-part detail), so `correct:false` with `awarded_marks > 0` means partial credit. Show "partly correct – x of y marks".
- Tokens: send the refresh token only to `/auth/refresh`.

#### 4.4.1 Shapes

**User** (`publicUser`): id, phone, name, role `'student'`, language, status, etc. Treat unknown fields leniently (ignore extras, tolerate nulls).

**ExamSummary**: `id, exam_key, exam_year, session, class_level, stream, subject, language ('ar'|'en'), duration_minutes, total_marks, status, is_free, unlock_cost (null = default), practice_enabled, question_count, leaf_question_count, published_at`.

**Stimulus**: `id, stimulus_key, kind, title, text, sort_order` (a shared passage referenced by `question.stimulus_id`).

**Question**: `id, parent_id, path ("1.2.a"), type, stimulus_id, text, options[], marks, sort_order, difficulty, access ('trial'|'free'|paid), practice_eligible, key_status, marking_method, is_container, children_count` + optionally `key, accepted_alternatives, criteria, model_answer, explanation` when entitled. Build the **tree** from `parent_id`/`path`; containers (`is_container`) render as headers/sections and are **not answerable**.

**Question types and the expected `answer` payload** (verify exact shapes against `api/src/modules/practice/marking.js` before coding each input – read that file, it is the source of truth):

| type | UI | answer payload |
| --- | --- | --- |
| `mcq` | single-choice option list; option labels use the paper's language alphabet (أ ب ج د… or A B C D…) | the chosen **letter** |
| `multi_select` | checkboxes | list of letters |
| `true_false` | two big buttons | boolean |
| `matching` (container) + `matching_item` | for each item pick a lettered option from the container's option list | the chosen letter per item |
| `fill_blank` | one text field per blank | list of strings (one per blank) |
| `table_fill` | grid of cells | object keyed `"row.column"` → text |
| `ordering` | drag-and-drop reorder | ordered list |
| `numeric` | numeric keyboard, accepts Arabic-Indic digits (normalise client-side, server also normalises) | number or numeric string |
| `math_expression` | text field | string |
| `short_answer`, `essay`, `diacritics`, `language_analysis` | multiline text (diacritics: RTL field with tashkeel-capable keyboard hint) | string (or per marking.js for `language_analysis`) |

**Feedback** returned by `POST .../answers`:
- Marked: `{correct, awarded_marks, key?, explanation?}` – `key/explanation` appear only if the student is entitled.
- Pending (subjective, no auto-marking): `{pending:true, marking_status:'pending_self'|'pending_ai'}` – **no key is returned**. UI: "Answer saved. Marking for this question type is coming soon" (see section 14). Never show a made-up mark.
- `attempt`: `{id, exam_id, status, answers_count, correct_count, awarded_marks, started_at, last_activity_at, closed_at}` – use it to update the running score.
- Re-answering the same question **replaces** the previous answer (upsert) and re-marks; `attempts_count` increments.

**PaymentRequest**: `id, status ('pending_payment'|'submitted'|'under_review'|'needs_info'|'approved'|'rejected'|'expired'|'cancelled'), payment_code, package{id,name,credits,price_sdg}, receiving_account, bank{bank_name,account_name,account_number}, base_amount_sdg, amount_increment, expected_amount_sdg, reference, sender_name, submitted_at, decided_at, reject_reason, created_at`.
**The student must transfer exactly `expected_amount_sdg`** (price + unique increment). Highlight it. Show `payment_code`, bank name, account name, account number with big copy buttons.

**Wallet ledger entry**: reverse chronological with `entry_type, amount, reason, created_at` (read `wallet/service.js` `getLedger` for the exact serialised fields before building the model). Credits are whole integers. Reasons look like `exam_unlock:<exam_key>`, `Signup bonus`, `Payment <code> approved`: map known prefixes to localised labels, fall back to the raw reason.

Money and credits are **integers** (whole SDG, whole credits). Never use floating point for them. Marks may be decimals (2 dp).

---

## 5. NAVIGATION AND SCREENS

Bottom navigation (RTL-mirrored): **Home · Exams · Practice · Wallet · Profile**. (Mock exam, AI marking, study tools and materials are *not* in the backend yet – see section 14; do not add tabs for them.)

### 5.1 Onboarding / auth
1. **Language picker** (first launch only; Arabic default, English alternative; saved locally and sent as `language` on signup).
2. **Welcome** (value props: official past papers, instant marking, pay with Bankak).
3. **Sign up**: name, phone, password (+ strength hint, show/hide), class level, optional stream, language. Class level & stream: the backend takes free text; offer a **dropdown of sensible presets** matching the data (e.g. "الثاني الثانوي / Secondary 2", "الثالث الثانوي / Secondary 3 (Sudan Certificate)", streams "علمي / Science", "أدبي / Literary") and an "Other" free-text option. Before hard-coding, call `GET /exams` once and derive the distinct `class_level`/`stream` values it contains and prefer those so filters always match real data.
4. **Recovery code screen** (shown once after signup *and* after a password reset): large monospace LTR code, copy + share buttons, warning that it is the only way to reset a forgotten password, a mandatory **"I saved it" checkbox** before continuing, block back-navigation until confirmed. Optionally allow screenshot capture (do **not** set `FLAG_SECURE`; students need to save it) but never log or persist the code.
5. **Login** (phone + password), "forgot password".
6. **Forgot password**: phone + recovery code + new password → show the **new recovery code** screen.
7. **Terms & privacy** (static, bilingual, link from signup with required acceptance checkbox).
8. **Blocked account** screen for `403 ACCOUNT_BLOCKED` (contact support).

### 5.2 Home
Greeting with name, **wallet chip** (available credits, tap → Wallet), "Continue where you left off" (latest open attempt – see 14 about listing attempts; store the last attempt id locally and reopen via `GET /practice/attempts/:id`), recommended/new papers for the student's class level and stream (query `GET /exams` with their `class_level`, `stream`, `language`), unlocked papers shortcut, banner when credits expire soon (`next_expiry_at`) or `available` is low, pending-payment status banner (from `GET /payments/requests`), offline banner.

### 5.3 Exams
- **Exam list**: search/filter by subject, year, session, language, with infinite scroll (`limit/skip`, `total`). Cards show subject, year/session, duration, total marks, question count, and a clear badge: **Free · Unlocked · Locked (N credits)**. Pull to refresh. Filters persist.
- **Exam detail** (`GET /exams/:id`): title block, duration, marks, instructions, access state. CTAs:
  - Locked → **Unlock for N credits** (price-preview sheet showing balance and balance-after; confirm → `POST /exams/:id/unlock`; on `402` show the **paywall sheet** with "Add credit" → Wallet/Packages).
  - Free/Unlocked → **Start practice** (`POST /practice/attempts` with `examId`, or resume the stored open attempt).
  - Preview: allow reading the structure and any `trial/free` questions with keys; locked ones show a lock icon.
  - If `practice_enabled == false`: disable practice with an explanation.
- **Paper viewer**: read the whole paper (stimuli + question tree) with zoom/pinch on long passages; show keys only after unlock via `GET /exams/:id/keys` (cache them encrypted-at-rest or in secure storage/drift for offline; clear on logout).
- **My unlocks** (`GET /exams/unlocks`).

### 5.4 Practice session (the core screen – spend the most polish here)
- Start/resume an attempt. Flatten the tree into an ordered list of **leaf questions** (skip containers but show their text/stimulus as context above the leaf; stimuli rendered with their own text direction).
- **One question per screen**: progress bar/“question 3 of 24” at top, scrollable passage + question, answer input per type, **sticky bottom bar** with *Check* (disabled until an answer exists) then *Next*; question navigator sheet (grid of numbers, colour+icon for answered/correct/incorrect/pending); "Report this question" (reason sheet 5–500 chars; handle `409 REPORT_ALREADY_OPEN` as "you already reported this").
- On *Check*: `POST .../answers` → show the **feedback panel** (correct/incorrect + marks; key + explanation only if returned; pending state for subjective types). The student can **retry** an incorrect answer (resubmit replaces it) – show attempts count lightly.
- Running score from `attempt.awarded_marks` and `correct_count / answers_count`.
- **Finish**: `POST /practice/attempts/:id/close` → **Result screen** (marks out of the paper's `total_marks` – be honest that unmarked/pending questions are excluded, correct/incorrect/pending/unanswered counts, a per-top-level-section breakdown computed client-side from the question tree + answers, "Review answers", "Retry wrong ones", "Back to exams").
- Drafts: persist unsent text answers locally (drift) so an app kill doesn't lose typing; show "saved" badge. Answers themselves are saved server-side on Check, but `GET /practice/attempts/:id` returns only marking results, **not the answer text**: also store each submitted answer locally (per attempt + question) so that resuming an attempt and "Review answers" can show what the student wrote.
- Handle `409 ATTEMPT_CLOSED` (offer to start a new attempt), session expiry mid-attempt (silent refresh), and offline (queue the answer, show "pending sync", sync on reconnect with retry/backoff; never show marking for an unsynced answer).
- Resilience: debounce Check taps, disable while in flight, ignore stale responses.

### 5.5 Practice tab
Subject/paper chooser focused on practice: unlocked papers and free papers grouped by subject, plus "resume" for open attempt. (Adaptive/topic-mastery practice is **not** in the backend yet – see 14. `GET /topics` is available; you may show topic names read-only where a question later exposes `topic_keys`, but do not build a mastery engine.)

### 5.6 Wallet and payments
- **Wallet**: big available-credits figure, reserved (if > 0), next expiry date, ledger list (infinite scroll with `cursor`), "Add credit" CTA, empty state.
- **Packages** (`GET /packages`): cards with name, credits, price in SDG, effective price per credit; tap → confirm → `POST /payments/requests`.
- **Payment instructions screen** (step-by-step stepper, bilingual, large type):
  1. Amount to transfer – the **exact `expected_amount_sdg`** highlighted + copy.
  2. Bank name, account name, account number, payment code – each with copy buttons.
  3. "Transfer in Bankak" (optionally try to open the Bankak app via `url_launcher`; fail silently if not installed).
  4. Return and **submit receipt**: Bankak transaction reference (4–120 chars; accept Arabic-Indic digits), optional sender name, image/PDF picker (camera, gallery, PDF) with **preview**, client-side compress to < 8 MB, upload to `POST /payments/receipts` (field `file`), then `POST /payments/requests/:id/receipt` with `receiptId`, reference, senderName.
  5. Status.
- **My payments** list + **detail** with a **status timeline** (Created → Submitted → Under review → Approved/Rejected) with timestamps, reject reason (displayed as-is, it may be Arabic), **Resubmit** when status is `rejected`/`needs_info`, **Cancel** when `pending_payment`, receipt preview fetched with auth. On `approved`, refresh `/wallet` and celebrate lightly.
- Polling: while any request is `submitted`/`under_review`, poll `GET /payments/requests/:id` every ~30 s while the screen is visible, back off to 2 min, stop when terminal (`approved`, `rejected`, `expired`, `cancelled`). No push notifications exist yet (section 14).
- Nothing about money may be ambiguous: always show currency (SDG / جنيه), isolate numbers as LTR runs, and warn that a wrong amount delays approval.
- Respect rate limits (`429 RATE_LIMITED`): show "try again in a moment" and don't hammer.

### 5.7 Profile and settings
Profile: name, phone (masked), class level, stream, change language, wallet summary, my payments, my unlocks. Settings: language (ar/en), theme (system/light/dark), **text size** (0.85–1.5×), **digit style** (Arabic-Indic ١٢٣ vs Western 123 for UI numbers; content digits stay as authored), data saver (don't auto-download keys/large papers), clear cached data, support contact (WhatsApp/phone link from a constant that is easy to change), terms/privacy, app version, **logout** (confirm; wipe local data). **Delete account** is not supported by the backend yet → show a button that opens a support contact flow rather than calling a non-existent endpoint.

### 5.8 System screens
Splash with session restore, offline banner, "server waking up", maintenance/generic error, force-update placeholder (no endpoint yet: leave the interface, don't call anything), 404/unknown route.

---

## 6. LOCALISATION, RTL AND BIDI (CRITICAL)

- UI languages: **Arabic (default) and English**; switch anytime in Settings; persisted; sent to the server on signup.
- Use `Directionality`-aware layout everywhere: `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`, `BorderRadiusDirectional`. Directional icons (back, chevron, progress, send) **mirror**; logos, media, checkmarks do **not**.
- **Content language is independent of UI language.** An English paper in the Arabic UI must render question text and options **LTR**; an Arabic paper in the English UI must render **RTL**. Decide direction per text block from the exam's `language` (and auto-detect for mixed runs). Wrap numbers, phone numbers, amounts, reference numbers, payment codes and Latin words inside Arabic text with Unicode bidi isolates (`\u2066…\u2069`) or a `LtrText` widget.
- Option labels: Arabic papers use `أ ب ج د هـ و ز ح ط ي`; English use `A–J`. Display the paper's alphabet, but the backend accepts either alphabet by position – send the letter exactly as displayed.
- Digits: setting for Arabic-Indic or Western UI numbers (amounts, counts, dates). All numeric/phone/reference **inputs accept both** and normalise to Western before sending.
- Dates/times: locale-formatted, shown in **Africa/Khartoum** (UTC+2). Server timestamps are ISO UTC.
- **Server messages are codes** → map to localised strings (never display raw English `message` to users except as a last-resort fallback in debug builds). Reject reasons and similar admin-entered text are displayed as received.
- ICU plurals for counts (credits, questions, minutes) with all Arabic forms.
- QA: golden/screenshot tests of key screens in `ar` and `en` at 360 dp width and 1.5× text scale; a pseudo-localisation run to catch overflow.

---

## 7. OFFLINE AND PERFORMANCE

- **Cache (drift)**: exam list pages, exam detail (structure + stimuli), unlocked keys, wallet snapshot, last 50 ledger entries, my payment requests, drafts, pending-sync answer queue, last-open attempt id. Cache is **per user** and wiped on logout.
- Stale-while-revalidate for lists; show a "last updated" hint when offline. Reading a previously opened paper must work offline; practising online-only is acceptable but answers typed offline must be queued and synced (idempotent upsert on the server makes retries safe).
- Never cache or display paid keys for papers that are not unlocked. If an unlock is lost/refunded, purge those keys.
- Performance budgets for a 2 GB phone: cold start < 3 s to first frame, 60 fps scrolling in lists (use `ListView.builder`, `const` widgets, avoid rebuilding whole trees; `Selector`), image/PDF compression before upload, release APK < 25 MB per ABI (report the actual size; use `--split-per-abi`), no unbounded in-memory lists.

### 7.1 Extended performance checklist (all required)

- **Startup:** minimal work before first frame (defer drift open, l10n heavy init, and network to after `runApp`; native splash → app without white flash); lazy-create providers; measure with `--profile` + DevTools timeline; target cold start < 3 s on a 2 GB device.
- **Rendering:** `const` constructors everywhere possible, `ListView.builder`/`SliverList` with `itemExtent`/prototypes where possible, `RepaintBoundary` around heavy cards, avoid `Opacity`/`ClipRRect`/`saveLayer` in lists, no nested scrollables without need, split large widgets, `Selector`/`context.select` to scope rebuilds, keys on reorderable/animated items. Target no jank (< 16 ms frames) in lists, practice screens and navigator grid.
- **Memory:** cap in-memory caches (LRU), release large exam trees when leaving a paper (keep ids + drift), compress/resize images before decoding (`cacheWidth/cacheHeight`), dispose controllers/streams/timers, avoid holding full-size receipt bytes after upload.
- **Network:** `dio` with connection reuse/keep-alive, gzip (server compression accepted), request de-duplication and cancel tokens on screen exit, conditional/short-TTL caching for `GET /exams`, `/packages`, `/topics`, pagination everywhere (`limit/skip`, ledger `cursor`), prefetch next page near list end, batch/background sync of queued answers, **data-saver mode** (no auto-download of keys/large papers, smaller receipt compression).
- **Storage/DB:** drift indices on lookup columns, transactions for batch writes, background isolate (`drift` isolate / `compute`) for JSON parsing of large paper payloads and tree building so the UI thread never blocks (> 8 ms work must move off-thread).
- **Build/size:** `--split-per-abi`, R8 shrink, `--tree-shake-icons`, subset fonts (only needed glyph ranges/weights), compress assets (WebP/SVG), remove unused packages; track APK/AAB size in README; release < 25 MB per ABI.
- **Battery/data:** polling only while a screen is visible with backoff, no wakelocks, no background services, honour system battery saver by lowering polling and disabling non-essential animation.
- **Resilience:** offline-first reads, queue + retry with backoff, graceful degradation on cold-start servers ("server waking up"), never block the UI on a failed refresh.
- **Observability (local, privacy-safe):** debug-only performance overlay toggle, frame timing logging in profile mode, a documented profiling run for: startup, exam list scroll, paper open, practice answer submit.

---

## 8. SECURITY AND PRIVACY

- Tokens in secure storage only; never log tokens, passwords, recovery codes or receipt content. Strip PII from logs. No analytics SDKs unless asked.
- Release builds: obfuscation (`--obfuscate --split-debug-info`), HTTPS only (cleartext allowed in debug manifest only), optional certificate pinning behind a flag (off by default).
- Receipts: only the student's own receipts are viewable; fetch with auth and keep bytes in memory/temp, delete temp files after upload.
- Handle the clipboard carefully: copying account numbers is fine; do not auto-copy the recovery code.
- Enforce the same client validations as the server schemas (lengths, formats) for nicer UX, but always honour server `422` details.
- Idempotency/anti-double-tap: unlock, payment-request creation, receipt submission and cancel must be single-flight with loading state so the same action isn't sent twice.

### 8.1 Extended security checklist (tiered – performance still comes first)

**Tiers.** Implement **MUST** items in Phase 1–2 without exception. Implement **SHOULD** items only if they do not measurably hurt startup time, APK size or scrolling (measure before/after, record in README). **LATER** items are documented but not built.

| Tier | Items |
| --- | --- |
| **MUST** | HTTPS-only release + network security config; tokens in Keystore-backed secure storage; single-flight refresh with rotation; wipe all user data on logout/block; `allowBackup=false`; R8 + `--obfuscate`; no sensitive logging (release logger is a no-op); upload type/size validation + EXIF strip; minimum permissions requested at point of use; defensive JSON parsing; anti-double-tap on money/unlock actions; server stays authoritative for marks, prices, access |
| **SHOULD** | Encrypt only the sensitive local tables (unlocked keys, wallet snapshot) – prefer encrypting the stored key payloads with a key from secure storage (cheap) over full SQLCipher (adds ~MBs and startup cost) unless benchmarks show it is negligible; optional biometric app lock toggle (off by default); hide sensitive screens in the app switcher (not the recovery code screen); clipboard hygiene |
| **LATER** | Certificate/public-key pinning, root/tamper detection (soft warning only), Play Integrity, SQLCipher full-DB encryption |

The detailed items below are the reference for each tier; apply them according to the table above.

**Transport & network**
- HTTPS/TLS only in release (Android `network_security_config.xml` with `cleartextTrafficPermitted=false`; a debug-only override for `10.0.2.2`/LAN). Optional **certificate/public-key pinning** with a documented rotation plan, behind a build flag.
- Reject redirects to other hosts; fixed API host from `--dart-define`; set sane timeouts; send a request id (`x-request-id`) for traceability; never follow `http` downgrades.
- Respect `429` with exponential backoff + jitter; cap retries (idempotent GETs only, plus answer upserts which are safe to retry).

**Auth & session**
- Access token kept in memory + secure storage; refresh token only in secure storage (Android Keystore-backed, `encryptedSharedPreferences`). Single-flight refresh, rotation honoured, immediate wipe on refresh failure/logout/block.
- Optional **app lock** (device biometrics/PIN via `local_auth`) toggle in Settings, with auto-lock after inactivity/backgrounding.
- Session invalidation when the server says `ACCOUNT_BLOCKED`/`INVALID_TOKEN`. Local brute-force UX: after repeated `INVALID_CREDENTIALS` show a cooldown message (server also rate limits).
- Never store the password; never store or log the recovery code beyond the one-time screen; clear it from memory/controllers on leaving the screen.

**Data at rest & privacy**
- Drift DB: encrypt the stored paid-key payloads and wallet snapshot (SHOULD tier); full-DB SQLCipher is LATER tier unless benchmarks show negligible cost. Per-user scoping and full wipe on logout.
- Android `allowBackup="false"` + `dataExtractionRules`/`fullBackupContent` excluding app data, so keys/tokens are not in cloud/ADB backups.
- Exclude sensitive screens (recovery code, receipt preview, paid keys) from the recent-apps thumbnail where appropriate, but do **not** block screenshots of the recovery code screen (students need to save it).
- Clipboard: copy account/payment details only; never auto-copy the recovery code; clear sensitive temp files (compressed receipts) right after upload.
- Minimum permissions: camera and photos requested only at the moment of use, with a rationale screen; no location/contacts/phone-state permissions. Declare nothing unused.

**App hardening (release)**
- `--obfuscate --split-debug-info`, R8/ProGuard shrinking, remove debug logs (use a logger that is a no-op in release), no `print` of data, `kReleaseMode` guards.
- Detect rooted/emulated/tampered environments only as a **soft warning** (do not hard-block students on cheap rooted phones); verify the installer/signature if feasible (Play Integrity is optional and out of scope unless requested).
- Dependency hygiene: pinned versions, `dart pub outdated`/audit in CI notes, no unmaintained plugins, review each plugin's permissions in the merged manifest.
- No hard-coded keys or URLs with secrets; secrets scanning pre-commit note in README.
- Deep links (if any) validated; no exported Activities/Receivers except the launcher; `android:exported` set explicitly everywhere.

**Input & output safety**
- Validate and sanitise all inputs client-side to mirror server schemas (lengths/formats) but trust server `422`. Never build HTML/JS from server text; render question text as plain styled text (no `WebView`). If rich text is ever needed, whitelist tags.
- Validate file uploads on the client: allowed types only (JPEG/PNG/WebP/PDF), magic-byte check, ≤ 8 MB, strip EXIF/location from images before upload.
- Treat every server field as untrusted/nullable: defensive parsing, no crashes on unknown enum values (fallback `unknown`), bounded list sizes, bounded string rendering.
- A global `FlutterError`/`PlatformDispatcher.onError` handler that shows a friendly error screen and records a **PII-free** diagnostic locally (opt-in share via "Send report" to support).

**Abuse & integrity**
- All money/marks/access decisions stay on the server; the client displays only. Disable buttons while requests are in flight; ignore duplicate taps; no client-side price math except display (e.g. "balance after unlock" = `available − unlock_cost`, labelled as an estimate).
- Safe handling of time: show server timestamps, don't trust device clock for expiry decisions (display only).

---

## 9. STATE MANAGEMENT PATTERN (provider)

- Each screen/flow has a `ChangeNotifier` view-model with an explicit state enum (`idle/loading/success/error/empty`) plus typed data; it calls **use cases** in `domain`, never dio directly.
- Root `MultiProvider`: `AuthController` (session, current user, locale), `WalletController` (shared balance, refreshed after unlock/payment approval), `ConnectivityController`, `ThemeController`, repositories.
- Feature VMs are scoped to their routes and disposed with them. Cross-feature updates (e.g. wallet balance after unlock) go through the shared `WalletController`, not by importing another feature's UI.
- Handle async lifecycle safely (check `mounted`/disposed flag before `notifyListeners`).

---

## 10. TESTING AND QUALITY GATES

Required before declaring done:
1. `flutter analyze` → **0 issues**. `dart format` clean.
2. **Unit tests**: token refresh single-flight interceptor, error-code mapper, digit/bidi/currency formatters, question-tree builder (containers vs leaves, ordering), answer payload builders per type, wallet/ledger pagination, payment status → timeline mapping, offline queue replay.
3. **Widget tests**: each answer input type, feedback panel states (correct/incorrect/pending/with and without key), paywall sheet, recovery-code gate (cannot continue until confirmed), copy fields, RTL vs LTR rendering of an Arabic and an English question.
4. **Golden tests** for question card, payment instructions, exam card in `ar`/`en`, light/dark.
5. **Integration test** (against a mocked dio adapter, plus a documented manual run against the real local API): signup → recovery code → browse exams → unlock (success and 402) → practice one MCQ, one fill-blank, one subjective → close → buy package → upload receipt → see status; refresh-token rotation; blocked account.
6. Manual QA checklist at the end: Arabic + English, 360 dp width, text scale 1.5×, dark mode, offline mode, airplane-mode mid-answer, slow network, 2 GB device profile.

---

## 11. LOCAL DEVELOPMENT AND DEMO DATA

The API lives in `api/` (`npm run dev`, port 4000; needs MongoDB as a **replica set**). Seed data: `npm run seed:dev` creates the owner, starter packages and Bankak settings; sample exam CSVs can be imported via the admin dashboard (`/admin/exams/import`). Run the app with:

```
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1      # Android emulator
flutter run --dart-define=API_BASE_URL=http://<LAN-IP>:4000/api/v1      # physical device
```

The backend's CORS is irrelevant for the mobile app. Add a README in `student_app/` with setup, run, build (`flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols`), test commands and the architecture overview.

### 11.1 Fake-API mode (build the UI without the backend)

- Add `--dart-define=USE_FAKE_API=true`. When set, repositories are bound to in-memory/fixture implementations (JSON fixtures in `assets/fixtures/`) that mimic every envelope in 4.4.0 – including a locked paper, a free paper, a trial question, a `402 INSUFFICIENT_CREDITS`, a `429`, a rejected payment, partial credit, and `pending_ai` answers – with a small artificial latency (300–800 ms) so loading states are visible.
- Real and fake repositories implement the **same domain interfaces**; the switch lives only in the dependency-injection root. Fake code lives under `lib/dev/` and is **excluded from release builds** (tree-shaken via a `const bool.fromEnvironment`).
- The fake API is also what the widget/golden/integration tests use.

### 11.2 Delivery: CI, signing, versioning, diagnostics

- **CI** (`.github/workflows/student_app.yml`): on push/PR run `flutter pub get`, `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, and a debug APK build; cache the pub directory.
- **Versioning:** semantic `version: x.y.z+build` in `pubspec.yaml`; `CHANGELOG.md` maintained per release; build number increments every upload.
- **Release signing:** generate an upload keystore, keep it and `key.properties` **out of git** (`.gitignore` entries), document the steps in README, build an **AAB** for Play (`flutter build appbundle --release --obfuscate --split-debug-info=build/symbols`) and an APK per ABI for direct (WhatsApp/Telegram) distribution, which is common in Sudan. Archive the `build/symbols` folder per version.
- **Store/readiness checklist** in README: app name/icon/adaptive icon, privacy policy URL placeholder, data-safety answers (phone number, name, payment receipts are collected), minimum Android version, target SDK current.
- **Crash/diagnostics policy:** no third-party crash or analytics SDK by default (privacy + size). Instead a **local, PII-free error log** (last 50 errors: type, screen, app version, request_id from the API error envelope – never tokens, phone numbers or answers) and a Settings → "Report a problem" button that shares it via the system share sheet to support. Keep a thin `Diagnostics` interface so Sentry/Crashlytics can be added later.

### 11.3 Sudan-specific constraints (design for them explicitly)

- **Weak / expensive data:** data-saver defaults to ON on mobile data; receipts compressed to ≤ ~800 KB at quality 70–80 (still legible: keep the longest side ≥ 1280 px) and to the 8 MB limit regardless; lists are paginated and cached; no auto-download of large content; show approximate data cost hints before big downloads; resumable upload retry for receipts.
- **Intermittent power/network:** every long action (receipt upload, answer sync) survives app kill and retries; never lose a typed answer or a half-filled receipt form (persist drafts).
- **Arabic input:** answer fields use `TextInputType.multiline` with RTL direction for Arabic content, allow tashkeel and tatweel characters, never strip diacritics client-side (server normalises per question flags), accept Arabic-Indic digits and convert only for numeric/phone/reference fields.
- **Payments reality:** Bankak transfers are manual and may take hours; always show expected review time ("usually within a few hours" – wording configurable), keep the amount/reference/receipt visible, make a failed or rejected payment recoverable in two taps, and provide a Settings → "Payment help" entry (support WhatsApp/phone via `url_launcher`, number kept in one constant).
- **Low-end devices:** test on Android 6–8, 2 GB RAM; avoid blur, large Lottie files and heavy shadows; keep animation count minimal.
- **Time:** show dates in Africa/Khartoum (UTC+2) with Arabic month names; avoid relying on the device clock for anything but display.

---

## 12. BUILD ORDER AND PHASE GATES

Work in **four phases**. At the end of each phase **stop**, run `flutter analyze`, `flutter test` and a release-mode profile check, then post a short **phase report** (what works, what is stubbed, test results, APK size, startup time, any backend discrepancy found) before starting the next phase. Do not begin a phase until the previous one passes its gate. The app must be runnable and demoable (fake API or real) at the end of every phase.

**Phase 1 – Foundation, auth, wallet, exams (gate: user can sign up, log in, see credits, browse and unlock a paper)**
1. Project scaffold, packages, lints, folder structure, env config, theme tokens (light/dark), fonts, l10n skeleton (`ar` + `en`), go_router shell with bottom nav, fake-API mode (11.1).
2. Core network: dio client, auth/refresh single-flight interceptor, error envelope → `Failure`, code → localised message mapper, connectivity, secure token store, prefs.
3. Auth feature end to end (language picker, welcome, signup, **recovery-code gate**, login, forgot password, session restore, logout, blocked screen).
4. Wallet + shared `WalletController` + credit chip.
5. Exams: list/filters/infinite scroll, detail, question-tree model, paper viewer, unlock flow with price sheet and paywall, keys fetch + cache, my unlocks.

**Phase 2 – Practice (gate: a student can practise a full paper, see marking, close and see results)**
6. Practice engine: attempt lifecycle, all 10+ question-type inputs, feedback panel, navigator, report, close + results, drafts, offline answer queue.

**Phase 3 – Payments (gate: a student can buy credits end to end and see the status update)**
7. Packages + payments: request, instructions stepper, receipt capture/compress/upload, submit, status timeline, polling, resubmit/cancel.

**Phase 4 – Home, settings, offline, polish, release (gate: Definition of Done in section 13)**
8. Home dashboard, practice tab, profile, settings (language, theme, text size, digits, data saver, clear cache, payment help, report a problem).
9. Offline caching with drift across features; stale-while-revalidate; offline banners.
10. Polish: skeletons, empty/error states, accessibility (semantics labels in both languages, 48 dp targets, contrast), reduced motion, performance pass against 7.1, SHOULD-tier security items that pass the performance test.
11. Tests (section 10), golden files, README, CI workflow, signed release build, APK/AAB size report.

---

## 13. DEFINITION OF DONE

- Modern theme spec (3.6) fully implemented with design-gallery screen; security checklist (8.1: all MUST items, plus the SHOULD items that passed the performance test) and performance checklist (7.1) each verified item by item in the README with pass/notes; phase reports for all four phases delivered; fake-API mode, CI workflow and signing instructions present.
- App builds (`flutter build apk --release`) and runs against the real local API end to end: signup → recovery code → login → browse → unlock → practise → close → buy credit → receipt → status.
- No hard-coded strings; complete `ar` and `en`; verified RTL/LTR content direction; Arabic-Indic/Western digit setting works.
- All states (loading/empty/error/offline/locked/insufficient credits) implemented on every screen.
- Tokens secure, rotation handled, no secrets/PII in logs, release obfuscation on.
- `flutter analyze` clean, tests green, README written, APK size reported.
- Anything unsupported by the backend is isolated behind interfaces with `TODO(backend)` and a graceful UI (section 14).

---

## 14. KNOWN BACKEND GAPS (DO NOT FAKE – STUB BEHIND INTERFACES)

The backend README lists these as **not built yet**. Do not call endpoints for them; provide the domain interface + a "coming soon" UI only where it makes sense, and keep the architecture ready:

| Missing | What to do in the app |
| --- | --- |
| Mock exams with timers, sections, results by topic | No mock-exam tab. Practice only. Keep a `MockExamRepository` interface placeholder. |
| Adaptive practice / topic mastery / spaced repetition / trial-question allowance | Plain per-paper practice only. Show topics read-only if present. |
| AI marking of `short_answer`/`essay` and AI generation/credits | Show the "saved, marking coming soon" pending state; never fabricate marks. Provide an optional **self-mark checklist** UI only if `criteria`/`model_answer` come back after unlock (they do for unlocked papers via `/exams/:id/keys`) – student self-assesses locally, never sent as a server mark. |
| Student uploads / "My materials" / study sets / flashcards | Omit. |
| Push notifications (FCM), in-app inbox | Omit; use polling for payment status. Keep a `NotificationsRepository` placeholder. |
| Listing my attempts | No list endpoint: persist the last attempt id per exam locally; use `GET /practice/attempts/:id`. |
| Subjects/classes catalogue endpoint | Derive distinct `subject`, `class_level`, `stream`, `session`, `exam_year` values from `GET /exams` results; cache them. |
| SMS OTP, delete account, force-update/minimum-version, announcements, promo codes, Play Billing | Omit or placeholder as noted in 5.7/5.8. |
| Receipt OCR | Not needed; the human reviewer verifies. |

When the owner adds endpoints later, only the data layer should change.

---

## 15. OUTPUT EXPECTATIONS FOR THE AGENT

- Work autonomously and incrementally; after each build-order step, summarise what was done, run `flutter analyze` + `flutter test`, fix everything, then continue.
- Before implementing any question type's input or answer payload, **read `api/src/modules/practice/marking.js`** and `api/src/modules/exams/types.js`; before building the ledger and receipt models, read `api/src/modules/wallet/service.js` and `api/src/modules/payments/service.js`. If the backend contradicts this document, **the backend code wins** – note the discrepancy in the README.
- At the end, output: the final folder tree, how to run it, the test results, the release APK size per ABI, and a list of anything intentionally stubbed.
