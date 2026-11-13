# Mothakira — complete student UI redesign plan

Status: design proposal ready for review; not approved for implementation.
Date: 2026-11-12.
Scope: the Flutter student app only. No application code, configuration, API, dependency, or build changes are authorized by this document.

## 1. Deliverables and design boundaries

- Existing visual proposal: newest exams, paper detail, and multiple-choice answering (`three-screens-v1.png`).
- Additional visual board: Home, Practice, Results, Wallet, Bankak instructions, and Receipt submission (`more-screens-v1.png`).
- This document specifies the remaining screens, navigation, component rules, states, release boundaries, and acceptance checks. Those remaining screens have written designs, not individual rendered mockups.
- All visual-board names, grades, amounts, account information, questions, and results are illustrative, not live student data.
- The written specification controls labels, actions, states, accessibility, and data boundaries if a raster illustration differs. Raster illustrations communicate visual direction; they are not pixel-perfect implementation contracts.
- Preserve the existing three-screen proposal. Apply the refinements below when the design is approved; do not silently overwrite prior versions.

## 2. The design direction

A contemporary Sudanese study space, not a generic finance dashboard or a decorative heritage theme. The identity comes from Arabic typography, Sudanese school context, restrained local language, Nile blue, warm paper, and sparse architectural geometry.

### Palette

| Role | Light | Dark |
| --- | --- | --- |
| Background | #F7F4ED | #14262B |
| Raised surface | #FFFEFA | #20353A |
| Primary button | #173F48 | #9ECDD2 with dark text |
| Main text | #203E43 | #E7EEEC |
| Supporting text | #596967 | #B1C2BE |
| Borders | #D8DDD4 | #42585B |
| Accent | #985A3B | #E9AD86 |
| Quiet success surface | #EAF0E9 | #2B4242 |

Semantic error, warning, and success colors remain separate tokens. Never use color alone to communicate a grade, payment state, or availability. Verify contrast before implementation acceptance.

### Typography and spacing

- Keep the bundled IBM Plex Sans Arabic for navigation, labels, and UI; Amiri for Arabic questions, passages, and answers that benefit from reading typography. No network fonts.
- UI body: 15–16 logical pixels; secondary information: 13; navigation labels: 12–13; card titles: 18–20; screen headings: 24–28.
- Arabic reading: 22 by default, at least 1.8 line height. Preserve diacritics. Long passages can use 20 with generous leading; never shrink text to squeeze content into a card.
- Screen gutters: 20 at normal phone widths, 16 at 320. Use 8/12/16/24/32 spacing steps.
- Buttons and tappable rows: minimum 48 logical pixels high. Icons: 20–22, with 10–12 between icon and label. Icon-only actions still have a 48-square target and accessible name.
- Card radius: 16; button/input radius: 12. Use separators or whitespace for simple lists instead of wrapping every row in a card.
- One restrained motif on a cover or balance card. No repeated ornamental wallpaper, flags, mosque imagery, gradients, badges on every word, or oversized welcome banners.
- Text must remain usable at 1.5× scaling. Multi-line action labels increase button height; they must not ellipsize.

### Writing

- Friendly Sudanese phrasing only where helpful: “أهلًا بيك”, “خطوة لقدّام”, “جرّب تاني”. Keep questions, payment instructions, legal text, and errors precise and broadly understandable.
- Stable labels: “الامتحانات”, “التدريب”, “المحفظة”, “فتح الورقة”, “معاينة الأسئلة”, “تحقّق من الإجابة”, “إرسال للمراجعة”.
- Display exact server-provided class and subject names. Do not label first- or second-year students as certificate candidates everywhere; reserve “الشهادة السودانية” for the relevant context.
- Prices and balances use localized numbers; SDG appears only for cash amounts, “رصيد” for credits. Never show token costs or OpenAI model names to students.

## 3. Navigation and screen anatomy

Keep the five existing primary destinations: Home, Exams, Practice, Wallet, Profile. RTL order starts at the right. Icons sit above full labels, not squeezed beside them. Preserve tab state and list position when returning.

Use a focus layout for answering, paper reading, results, authentication, and the payment wizard: a simple app bar with a right-side back arrow in Arabic, a clear title, and at most one utility action. No five-tab navigation competing with question actions or payment submission.

Sheets are for short choices: filters, unlock confirmation, report reason, logout confirmation. Full screens are for passages, receipts, long forms, results, and multi-step workflows.

Back means return to the prior screen; it must not silently submit, finish, cancel payment, or spend credits. Explicit destructive/financial actions receive confirmation and busy states.

## 4. Core learning screens

### S01 — Home

Order: compact greeting and class context → available-credit summary/top-up → two clear study/payment shortcuts → newest papers.

- Keep the first paper visible near the initial viewport; avoid a tall hero, streak board, or large statistics grid.
- Existing data supports the greeting, wallet balance, expiry, paper list, and shortcuts. Do not invent study time, performance trends, or a resumable attempt.
- Primary action: “تصفّح الامتحانات”. Practice and payment requests are separate rows or two comfortably sized tiles, not three crammed buttons.
- Paper feed and wallet fail independently. A failed wallet read shows unavailable/stale state, never zero. A failed paper feed shows retry, never an empty message.

### S02 — Exam library and newest papers

Order: title → search → compact selected filters → paper list → pagination.

- Card: subject title and session/year; separate class context; one factual metadata row; bottom row for cost/free state and “عرض الورقة”. Avoid an icon for every fact.
- Search behavior must match the source. Current search covers loaded items; label it “ابحث في الأوراق المعروضة” until server-wide search is explicitly implemented. Never imply a complete catalog search.
- Filters use subject/session/year supported by the current screen. Class and stream filters require supported API/query wiring before becoming active.
- “Newest” requires verified server ordering. Do not sort just the loaded page and claim it is the newest catalog; use a neutral list label if ordering is unavailable.
- Separate all-free, paid-locked, and confirmed-unlocked appearances. A cost badge alone is not proof of entitlement.
- Preserve search, filters, and position on return from detail.

### S03 — Paper detail

Order: small subject cover → question/marks/duration facts → original paper instructions → access explanation → actions.

- Locked: primary “فتح الورقة · [server price]”; secondary “معاينة الأسئلة”. No key/model-answer action before access is granted.
- Unlocked/free: primary “ابدأ التدريب”; secondary reading and model-answer actions as separate full-width rows.
- Practice disabled: keep its action visibly disabled with a reason; reading access follows the actual contract.
- Cover art cannot push the main action excessively far down; long instructions use an expandable section with the beginning visible.
- Missing duration is omitted, not shown as zero. Question count means actual answerable leaf questions, not section headings.

### S04 — Unlock confirmation sheet

Show paper title, server cost, current available balance, and the effect on balance only if supported by authoritative data. Primary confirmation; secondary cancel.

Insufficient balance changes the main action to “شحن الرصيد” and preserves a return path. Recheck eligibility after purchase. Do not trust a client-computed amount or mark an unlock successful before the server confirms it. Never retry a charge blindly after an uncertain response.

### S05 — Read-only paper viewer

A paper-like reading surface, not a collection of nested boxes. Section headings, full passages, original numbering, marks, and choices remain distinct. Put a contents action in the app bar; use a sheet for navigation.

Preserve passage/poem line structure and all source text. Images have meaningful alternatives, tap-to-zoom, loading and failure states. Only display content the server permits. This is typed paper viewing, not an invented PDF download feature.

### S06 — Practice hub

Heading “التدريب”, subheading “أوراقك المفتوحة”. Show accessible paper cards with a single “عرض الورقة” action leading to detail. “تصفّح الامتحانات” handles the empty state.

Do not label the existing hub as attempt history or show a resume button: it currently resolves unlocked papers, not active attempts. Surface partial-loading errors rather than silently turning failed reads into an apparently complete list. Load-more must expose additional records instead of silently treating the first 20 as the full collection.

### S07 — Question answering shell

Order: title/back + contents action → compact question position/progress → section/passage → question and marks → input → answer status → primary check action. Previous/next remain a separate, quiet bottom row.

- The check action is disabled and explained until an answer is valid. Only one primary-colored action is visible; next/previous are secondary.
- Report-question is a quiet text action or menu item with a clear label. It must not crowd check/next controls.
- Show “saved on this device”, “waiting to send”, and “submitted” as different states; do not call a local draft server-saved.
- Keyboard visibility keeps the input and check action reachable. Draft persistence follows existing repository behavior; leaving does not silently submit.
- No mock-exam countdown is introduced unless a timed-attempt contract exists.

### S08 — All answer input designs

| Type | Layout and behavior |
| --- | --- |
| Single choice / true-false | Full-width selectable rows, letter/label at reading start, selection control at opposite edge; answer text wraps. |
| Multi-select | Same rhythm with checkboxes and explicit “اختر كل الإجابات الصحيحة”; no auto-submit on selection. |
| Short answer / essay | Multi-line field with readable line height, clear question context, server limit/help text, and a separate submit action. |
| Numeric | Number field and unit as separate labeled elements; localized digit handling; no client grading. |
| Fill blanks | Each blank is labeled by its position and surrounding prompt. Never reveal answer keys to derive the input structure. |
| Matching | One stem per row/card and a full-width option selector; avoid intersecting draggable lines on a small phone. |
| Ordering | Numbered rows with accessible move-up/down controls; drag is an enhancement, not the only method. |
| Table fill | Preserve row/column labels. At narrow width, convert to grouped row fields where semantics survive; otherwise scroll only the table region. |
| Diacritics / language analysis | Reading font, ample vertical padding, no forced stripping of marks, appropriate text input. |
| Unknown / unsupported structure | Show the existing supported fallback or an explicit unavailable state; do not silently coerce answers or guess the structure. |

Structural data for blanks, ordering and tables must come from a permitted input schema, never from paid keys. Where the current backend/client lacks that structure, keep the renderer gated and explain why rather than inventing content.

### S09 — Feedback panel

Lives below the submitted answer, not in a modal covering the question. Order: textual status + awarded/maximum marks → explanation → permitted model answer/criteria. Pending feedback is not wrong. Missing feedback is not zero. Show error and retry separately from the student's answer.

Objective/self-mark/AI feedback must be clearly distinguished. Reveal keys only when the response permits it. Do not predict correctness on-device.

### S10 — Question navigator and finish confirmation

Navigator: numbered 48-square targets, legend for answered/unanswered/current/pending, state labels accessible without color. Show section grouping when available. Finish is separated from navigation.

Finish confirmation summarizes authoritative or clearly local answer counts, mentions pending uploads, and offers “إنهاء التدريب” and “العودة للأسئلة”. Offline or uncertain close behavior follows the actual repository; never imply a completed attempt before confirmation.

### S11 — Results

Order: subject/session → score with explicit final/provisional/pending state → section breakdown → question review list. No giant ring chart, celebratory confetti, or invented mastery metrics.

Primary action opens answer review. “تدريب جديد” restarts the whole paper. Do not say “أعد الأسئلة الخاطئة” unless a wrong-only attempt is supported; the current implementation restarts the full exam.

Review filters operate only on available marking data. If the local submitted answer is absent on another device, say it is unavailable; do not render it as an unanswered question. Keep server marking records visible.

### S12 — Model answers and criteria

Use the same numbering and reading anatomy as the paper. Each block: question identifier → answer → explanation → criterion marks if provided. Container headings do not receive meaningless answer rows. Locked, corrected/unavailable, empty, and network-error states remain distinct.

## 5. Wallet and payments

### S13 — Wallet

Order: available balance → separate total/reserved labels → next-expiry notice if returned → “شحن الرصيد” → recent ledger.

The balance panel is the primary identity moment; a small architectural line motif is enough. Pending reservations are not spendable credits. Cached data shows a last-updated/stale indicator, not a false live balance.

### S14 — Full ledger

Chronological rows with transaction description, signed credit movement, date, and status/reference when provided. Group dates visually without changing server order. Pagination is a footer, not an endless spinner. Distinguish initial failure from failure to load the next page; keep already-loaded rows visible.

### S15 — Packages

One selectable package row/card per real server package: localized name, credits, SDG price, selected state. Do not invent “best value”, discounts, or bonuses. After selection, one bottom action “متابعة الدفع”; confirmation creates the request. No request on each selection change.

Empty catalog, loading, open-request limit, expired availability, and service-configuration errors each have a useful explanation.

### S16 — Bankak payment instructions

Order: request status/reference → exact amount → labeled bank/account information with independent copy actions → numbered transfer/receipt/review steps → main receipt action.

“فتح بنكك” is a separate secondary external-app action. If opening fails, keep the copyable details and instructions visible. No QR code or automatic bank confirmation is invented.

All financial details come from the request/server. Never use a real account number in design assets. Explain that the receipt is manually reviewed before credits are added.

### S17 — Receipt submission

Order: small request/amount summary → attachment picker or attached-file preview → reference field → optional sender → submission action.

- Picker sources are three spacious labeled choices: camera, gallery, file. Explain permissions before opening the system permission prompt.
- Display accepted file types and maximum size from the actual configured limit next to the picker; do not bury them in an error.
- After selection: thumbnail/file name, file type/size, explicit replace/remove actions, and preparation status. Do not claim a file is uploaded while only selected locally.
- Validate reference and receipt, then submit once. Show indeterminate upload state unless real byte progress exists; no fake percentages.
- Duplicate reference, invalid type/size, preparation failure, network failure, and final submission failure have different recovery messages.
- A failed final submit after successful upload should reuse the attachment where supported, not make the student upload blindly again.

### S18 — Payment history and detail

History: open requests first, then finished requests; one row shows package, amount, date, status, and a clear detail action. Avoid a row of status badges.

Detail: a status explanation and next action at the top, followed by a textual timeline, server amount/reference, receipt, and admin note where provided.

| Server state | Design and next action |
| --- | --- |
| Pending payment | Transfer instructions; attach receipt; cancel only if allowed. |
| Submitted / under review | Clear waiting message, no fake countdown or approval promise; bounded refresh behavior. |
| Needs information | Admin reason above the correction/resubmission action. |
| Approved | Show confirmation; refresh wallet and reflect the actual returned state. |
| Rejected | Show the reason and only server-permitted next actions; do not promise resubmission automatically. |
| Expired / cancelled | Read-only summary; start a new request only through package selection. |
| Unknown | Neutral status and refresh/support; never map it to approved. |

### S19 — Receipt viewing

Images get a dedicated zoomable viewer. PDF receipts follow the existing system open/share path. Show loading, access denied, missing attachment, and device-viewer failure. Do not introduce public share links or unprotected receipt URLs.

## 6. Account and utility screens

### S20 — Welcome

Small brand mark, one calm local identity accent, a short study-focused sentence. Main “إنشاء حساب”; secondary “تسجيل الدخول”; language choice remains visible. No carousel, claims of guaranteed grades, or unnecessary onboarding questions.

### S21 — Login

One column: email → password with separate visibility action → forgot password → sign in → signup link. Use the real login identifier contract; never send incompatible payloads just because the field was redesigned. Keep entered values after recoverable errors. No success navigation until authentication completes.

### S22 — Signup and recovery-code handoff

Fields: name, email, password, class, optional stream, preferred language, terms acceptance. Show grade/stream choices from configured data and explain password rules next to the input. Use a single form with clear grouping unless keyboard length requires two lightweight steps; if split, preserve inputs and send only once on final confirmation.

Recovery-code handoff: readable grouped code in an isolated direction, copy action, why it matters, explicit acknowledgment before continuation. Never send the secret to analytics or include a real code in previews.

### S23 — Password recovery

Three deliberate states: request an email code → enter the six-digit code and new password → success with login action. Keep resend visually secondary and reflect real cooldown/rate-limit behavior. Provide the supported saved-recovery-code alternative.

Code inputs support full-code paste. Invalid/expired code and mail delivery/network failure get useful messages. Saved-code recovery still needs a network request; do not call it offline recovery. Preserve the replacement recovery-code handoff where required.

### S24 — Profile

Compact identity block with name, email, class and stream. Simple grouped navigation rows: settings, payment requests, support, about/legal. Destructive logout sits apart.

Current profile is read-only. Do not show fake edit or self-service delete buttons. Any future editing or deletion flow requires its own supported account contract and approval.

### S25 — Settings

Separate groups: appearance, reading, data, support/diagnostics. Theme uses system/light/dark choices with a small sample; text size shows a live sample sentence with diacritics; language and digit style are clearly distinguished.

Data saver and cache clearing explain exactly what changes. Cache-clear confirmation must not imply drafts, queued answers, or authentication will be deleted unless that is genuinely the contract. Settings persist through the existing controller/repository paths.

### S26 — Support, About, Legal, Diagnostics

Support uses distinct labeled contact/WhatsApp rows and copy fallback, not an invented in-app chat. Keep account and payment references shareable without exposing tokens or secrets.

About: product name, actual version, legal links. Legal content is not rewritten casually during a visual redesign. Diagnostics show connection/API mode/pending-answer count with explanations and refresh; never label unknown conditions as healthy.

### S27 — Splash, blocked, offline, maintenance, update, not found

Each state has a headline, brief cause, and a real next action. Splash must resolve or show recovery; avoid permanent spinners. Blocked uses support/logout. Offline distinguishes cached content from unavailable network-only actions. Maintenance does not discard drafts. Update requires an approved destination before offering a working update button. Not-found returns to a known safe destination.

## 7. AI and student materials — designed separately, not claimed as current app UI

The student app inventory has no dedicated materials or AI routes. The existing AI feature plan describes backend capabilities; implementation must verify their current response contracts before enabling these new surfaces. These designs do not authorize new endpoints or unrelated backend changes.

### S28 — Adaptive practice setup

Entry under Practice, not a sixth bottom tab. Order: class context → configured subject → supported topic/difficulty choices → availability/selection explanation → start.

Only enable controls supported by the selection contract. Explain that adaptive selection itself is free, while paid-question access and optional AI grading follow their respective rules. No invented daily cap, mastery percentage, or “AI generated this question” label for deterministic selection. No eligible questions is an explicit state with a browse-paper alternative.

### S29 — Open-answer AI grading and feedback

Extend S07/S09 rather than building a chat screen. After a supported submitted answer: show server-quoted credit cost, explanation, and “تصحيح بالذكاء الاصطناعي”. This is an explicit separate spend, never automatic on every keystroke or answer edit.

States: eligible → confirming → processing → graded, needs human review, disabled, insufficient credit, service-budget unavailable, or failed. Do not reveal paid keys or compute marks locally. Low confidence does not create a final grade.

Label returned AI marking as unofficial. Review-pending copy must explain the actual charged/reserved state; the current feature plan says a successful grading call awaiting human review can remain charged. Failed-call refund/release copy must match server settlement, not assume every error is refunded instantly.

### S30 — My materials

Entry under Practice; header “موادي”. Rows show material name, grade, subject, source type, and real status. Main “إضافة مادة”. Student-owned items only. Do not invent folders, public sharing, or cross-device guarantees.

### S31 — Add material

Order: required secondary grade 1/2/3 and configured subject → supported source mode → source preview → validation/privacy note → save/continue.

Offer pasted text, text/Markdown, and supported image uploads only after verifying current capabilities. The existing AI plan marks PDF extraction as not implemented; keep PDF disabled with an explicit explanation rather than pretending it works. Do not conflate PDF receipt support with PDF learning-material extraction.

Put exact allowed formats/limits at the input. Preserve draft text after a failed request. No continuous upload or generation while typing.

### S32 — Generate questions confirmation

Show selected material, grade, subject, supported question count/types, and authoritative credit cost. Primary “إنشاء أسئلة”; confirmation before reservation/spend. Do not offer configuration fields absent from the generation contract.

Explain before purchase that generated questions require review before practice. An unreviewed batch cannot expose answer keys or a working “ابدأ التدريب” action.

### S33 — Generation status and generated set

Keep the status page inspectable without forcing the student to wait on a spinner. Present returned states: processing, awaiting review, ready, failed, rejected. No invented percentage or ETA. Show rejection/failure reason and actual credit settlement. Do not start another charged job just because a status request failed.

Ready: a private set detail with grade/subject and question count, then reuse the existing paper/practice/result layouts. Explicitly label origin as generated from the student's material. Do not claim the batch is an official exam or publicly reviewed content.

## 8. Shared component inventory

Build or adapt existing components, rather than creating parallel systems: app bars; five-tab navigation; section headings; paper cards; fact rows; primary/secondary/text buttons; icon actions; field/help/error groups; chips; status banners; answer rows; reading blocks; loading/empty/error panels; price confirmation; credit display; ledger rows; payment timeline; file picker/preview; results summary; modal sheets.

Every button variant has default, pressed, focus, disabled, and busy states. Busy replaces the icon without collapsing the label width. Decorative icons are not announced twice. Status labels remain understandable in grayscale.

## 9. State, accessibility, and interaction acceptance

- Test 320/360/390/412 logical-pixel widths, Android system insets and keyboard, plus 1.0/1.3/1.5 text scale. Lists may scroll vertically; no whole-screen horizontal overflow.
- Verify light and dark independently. Contrast targets: 4.5:1 normal text, 3:1 large text and essential control boundaries.
- Arabic UI mirrors navigation; English paper text remains LTR inside it. Numbers, references and emails use directional isolation; never mirror content or symbols indiscriminately.
- Question text, options, field errors and action labels wrap instead of clipping. Passages and poems retain their source structure.
- At most one primary action per view; no icon-plus-label collisions at 320 or 1.5× text. Primary targets are at least 48 logical pixels.
- Screen readers announce label, status and availability. Option selection and matching/ordering work without drag or color recognition.
- Loading, empty, error, stale-cache, offline-queued and permission-denied states must be distinguishable. A failed request is not a zero balance, no papers, or wrong answer.
- No network request per keystroke. Debounce future server search, cancel obsolete reads, and keep current local filtering honest. Payment polling remains bounded and tied to screen/app lifecycle.
- No mutation is triggered by opening a page, changing tabs, changing a design control, or refreshing. Never retry financial or generation mutations automatically after an uncertain outcome.
- Disable and explain unsupported actions instead of presenting working-looking controls. Keep visible the alternatives that genuinely work.
- All production copy goes into Arabic/English localization resources; illustrations' literal sample text must not leak into production.

## 10. Implementation sequence after explicit approval

1. Establish tokens, typography, RTL, button hierarchy, fields, and navigation using existing widgets. First gate: component gallery at 320 and 1.5× text, light/dark.
2. Apply Home, exam library, paper detail, unlock, and paper reading as one coherent journey. Gate: list → detail → free/paid paths → return with filters preserved.
3. Apply all answer types, feedback, navigator, finish, results, and keys. Gate: long Arabic/English text, pending/offline answers, entitlement restrictions, and provisional results.
4. Apply wallet, ledger, packages, Bankak, receipt and payment states together. Gate: successful and failed uploads, manual review, needs-info, uncertain response, and confirmed approval/balance refresh.
5. Apply auth/recovery, profile/settings/support and system states. Gate: email recovery, saved-code handoff, keyboard, settings persistence, and no false success states.
6. Wire the separate AI/materials designs only after confirming supported backend contracts, pricing/settlement and review policies; preserve deterministic adaptive practice when AI is unavailable.
7. Run existing tests without weakening them, add missing widget/accessibility/state tests, and verify the app on Android. No Flutter web workaround and no APK build unless separately requested. Resolve concurrent-session edits before touching shared files.

Do not begin any implementation phase from this document alone. Approval should name the accepted direction or any requested changes first. No commits, pushes, or deployments are part of the design work.

## 11. Source evidence used for this plan

These are a read-only inventory, not a live-server or device verification:

- `student_app/lib/app/app_router.dart:49–250`: current routes and retained tabs.
- `student_app/lib/features/home/presentation/home_screen.dart:25–149`: supported home data and shortcuts.
- `student_app/lib/features/practice/presentation/practice_hub_screen.dart:26–83`: unlocked-paper hub, limited resolution and failed-read behavior.
- `student_app/lib/features/practice/presentation/result_screen.dart:47–136`: score/review data and whole-paper retry behavior.
- `student_app/lib/features/payments/presentation/payment_detail_screen.dart:57–144`: payment refresh and approved-wallet transition.
- `student_app/lib/features/payments/presentation/submit_receipt_screen.dart:54–195`: receipt picking, preparation and submission.
- `student_app/lib/features/wallet/presentation/wallet_screen.dart:25–149`: balance, expiry and ledger summary.
- `student_app/lib/features/profile/presentation/profile_screen.dart:18–137`: read-only identity and account links.
- `student_app/lib/features/profile/presentation/settings_screen.dart:16–163`: current settings.
- `student_app/lib/app/app_services.dart:64–92`: services and possible fake-API configuration.
- `AI_FEATURES_PLAN.md:33–66`: intended grading, adaptive practice and material-generation boundaries; code remains authoritative.

## 12. Raster board generation brief

One generation only, using the previous three-screen image as a style reference. Request: six new Arabic RTL mobile mockups in one 2560×1080 board—Home, Practice, Results, Wallet, Bankak instructions and Receipt submission. Borrow warm ivory, Nile blue, restrained terracotta, local typography and sparse architectural details. Use short Arabic labels, one dominant action, five tabs only on main destinations, and sample data. Label the board “PROPOSED — NOT BUILT — SAMPLE DATA”. No code generation, real bank details, invented analytics, QR code, or instant-approval claim.
