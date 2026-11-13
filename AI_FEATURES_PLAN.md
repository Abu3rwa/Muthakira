# Mothakira AI Features — Plan & Decisions

Status: approved direction from the owner (2026-11-11). This document records the
feature catalogue, the owner's decisions, and the end-to-end control design.
Backend code wins over this document if they ever disagree.

## Owner decisions (locked)

| Decision | Value |
| --- | --- |
| Daily usage cap | **None** — explicitly rejected. The monthly budget is the only hard stop. |
| Model selection | Configured via env, never hard-coded in feature code. |
| Default model | `gpt-5.4-mini` — $0.75 input / $4.50 output / $0.075 cached input per 1M tokens. |
| Config location | Everything in `api/.env.example`; runtime overrides in dashboard Settings → AI. |
| API key | `OPENAI_API_KEY` already present in `api/.env` (secret — never logged/committed). |

### Pricing catalog (USD per 1M tokens, from the owner)

| Model | Input | Output | Cached input |
| --- | --- | --- | --- |
| gpt-6-astra | 10.00 | 50.00 | 1.00 |
| gpt-6.1-sol | 2.00 | 10.00 | 0.10 |
| gpt-6.1-terra | 1.00 | 5.00 | 0.05 |
| gpt-6-luna | 0.10 | 0.50 | 0.01 |
| **gpt-5.4-mini** (default) | 0.75 | 4.50 | 0.075 |
| gpt-5.4-nano (moderation) | 0.20 | 1.25 | 0.02 |
| gpt-4o-mini | 0.15 | 0.60 | 0.075 |

Unknown models are costed at the most expensive known rate (fail-closed for budget).

## Features

### 1. AI grading + feedback (open-ended answers)
- Hooks already exist: `short_answer` / `essay` types use `marking: 'ai_rubric'`;
  `markAnswer` returns `marking_status: 'pending_ai'`.
- Student explicitly requests grading for their own pending answer (spends credits).
- Server sends question text + rubric (`criteria`, `model_answer`) + student answer to
  the model with a versioned prompt and a strict JSON schema.
- Marks are **clamped server-side** to `[0, question.marks]`; the model never decides
  the maximum. Feedback is generated text — the raw paid key is never returned.
- Confidence below `AI_REVIEW_CONFIDENCE` (default 0.6) → human review queue; the
  answer stays `pending_ai` until an admin approves/rejects. Credits are still charged
  (the model ran); this is documented in the student-facing copy.
- `correct` for aggregates = awarded ≥ half of the question marks.
- Price: `AI_CREDIT_GRADING` (default 2 credits per answer).

### 2. Adaptive practice
- Deterministic server-side selection — **no AI call, no credits, always available**.
- Ability estimate from the student's own attempt history (difficulty-weighted accuracy),
  then picks the next unanswered, practice-eligible question near the target difficulty,
  preferring weak `topic_keys`. Paid-access rules still apply.
- Rationale: adaptive selection must work even when AI is off or the budget is spent.

### 3. Student materials → question generation
- Student uploads their own material (v1: `.txt` / `.md` text, PNG/JPEG images via the
  model's vision input; PDF extraction is `TODO(backend)` — coming soon) or pastes text.
- Must select secondary grade (1 / 2 / 3) and a subject; the student profile must have
  a class level (enforced at signup). Uploads follow the receipt rules: type/size
  validation, UUID filenames, auth-gated access, never trust client paths.
- Server generates a batch (5–10 questions: mcq / true_false / fill_blank / short_answer)
  with keys, difficulty and topic keys via structured output, Zod-validated, then a
  cheap moderation pass (`gpt-5.4-nano`).
- Every batch lands in the **admin review queue** before it becomes practisable.
  Approved batches create a private, free, practice-enabled exam owned by that student.
- Price: `AI_CREDIT_GENERATION` (default 10 credits per batch). Failed/rejected jobs
  refund the reservation.

## End-to-end control spine (every AI call)

```
authenticate → feature flag (env master + env feature + runtime setting)
→ per-user rate limit → credit reservation (withTransaction, conditional atomic)
→ monthly budget pre-check (estimated cost, fail-closed)
→ versioned server prompt → model router (env per-feature model)
→ OpenAI structured output (timeout, no key in logs)
→ Zod validation → clamp marks / moderation
→ ai_usage ledger (tokens, cost, credits — success AND failure)
→ commit reservation on success / release on failure
→ low confidence or generated content → human review queue
```

- **Kill switches**: `AI_ENABLED` master + per-feature env flags + runtime dashboard
  settings (`ai.enabled`, `ai.grading_enabled`, `ai.generation_enabled`). Any of them
  off → 503 `AI_DISABLED`. No daily cap anywhere.
- **Budget**: `AI_MONTHLY_BUDGET_USD` (default 50, runtime-overridable). Sum of
  `ai_usage.cost_usd` in the current UTC month + estimate must stay under it, else
  503 `AI_BUDGET_EXCEEDED`. Usage is recorded even for failed calls.
- **Money**: credits reserved before the call, committed after success, released on
  failure — reusing the wallet reservation lifecycle (`withTransaction`, conditional
  atomic lot updates, unique partial indexes). Client never supplies prices or marks.
- **Audit**: every admin AI mutation (settings, review resolve, refunds) writes an
  audit entry with actor/action/target/before/after.
- **IDOR**: students can only grade their own answers, see their own materials/jobs/
  usage. Admin endpoints are role-guarded (`owner` for settings/diagnostics).
- **Self-test**: owner-only `POST /admin/ai/test` runs a real tiny completion and
  reports pass/fail + cause (mirrors the SMTP test-email pattern). Never silent.

## Data model (new)

- `AiUsage` — one row per model call: user, feature, model, prompt_version, tokens
  (input/output/cached), cost_usd, credits, reservation_id, status, error_code.
- `AiReview` — review queue: kind (`grading` | `generation`), refs, payload snapshot,
  status (`pending`/`approved`/`rejected`), resolver, note.
- `AiMaterial` — student upload: owner, grade, subject, language, UUID storage name,
  mime, bytes, sha256, extracted text, status.
- `AiGenerationJob` — material → batch: owner, grade, subject, count, status
  (`running`/`review`/`ready`/`failed`/`rejected`), draft questions, reservation, error.

## Phases

1. Env config + this plan. **(done)**
2. Control spine: pricing, flags/settings, usage ledger, budget guard, OpenAI client
   with test seam, prompts, admin usage/review/test endpoints + tests.
3. AI grading + feedback wired into practice + tests (incl. security rules).
4. Adaptive practice selection + tests.
5. Materials upload + generation + review→publish + tests.
6. Dashboard: AI settings, usage/cost view, review queue (Redux Toolkit) + tests.

## Standing rules honoured

No commits/pushes/deploys. No production data. Every new behaviour has tests; existing
tests stay green. Secrets never echoed, logged or committed. Files kept small.