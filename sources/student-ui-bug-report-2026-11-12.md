# Student app UI bug report — pasted 2026-11-12

Source: screenshots 1000096428–1000096437 (pasted as filenames; files not found on disk).
This is a captured work order, not a plan. Verify each item against the app before fixing.

## Directives from the owner

- Students do not wait for manual review. Generation goes straight to practice.
- When they upload a material, prompt them to start practicing right away.

## Screens 1–2 (1000096428, 1000096429) — matching question in practice

- Question type mismatch: prompt says "match each word with its proper meaning" and
  "choose the right letter for each item", but the UI is a single-choice radio list
  showing one word (المدرسة). Wrong widget for the question type, or wrong data.
- Clipped header: "سؤال 5 من 17" and "أجبت عن 4" are cut off under the app bar;
  content is not offset properly and the progress bar overlaps it.
- "Check answer" is only visible after scrolling; should be sticky/visible without
  scrolling.
- Two next-style controls: labeled "السؤال التالي" button plus an unlabeled circular
  arrow, with inconsistent directions in RTL.
- Layout jump: the "saved on this device" row appears after selection and shifts
  the layout.
- Helper text "اختر الحرف المناسب لكل عنصر" is wrong for a single-choice question.
- A Debug banner / debug build is visible; must not exist in production.

## Screen 1 (1000096430) — correct answer feedback

- "إجابة صحيحة" shows the correct answer as just the letter "أ"; it should show the
  full option text ("مكان للتعلم").
- "أُرسل للتصحيح" status sits alone with no visual link to the result card beneath it.
- Options still look tappable after grading; they should be locked and the correct
  one marked green.
- "حاول مرة أخرى" appears after a correct answer; it only makes sense after a wrong one.

## Screen 2 (1000096431) — table question partial result

- "1 من 2 صحيحة" does not show which row was wrong; "الإجابة الصحيحة" box is empty.
- Rows are not marked correct/incorrect (ذهب = ماضٍ, يقرأ = مضارع); the student
  cannot tell which failed.
- A percent icon (%) is used for a "1 of 2" result.
- Table cells look like text inputs rather than dropdowns/choices; answering is unclear.
- Header text clipped under the app bar again (the word "يقرأ" cut off at the top).

## Screen 3 (1000096432) — home

- "secondary_3 · literary" is a raw English database key; localize it
  ("الثالث الثانوي - أدبي").
- Balance block: "إضافة رصيد" sits far from the balance it relates to; the expiry
  line is easy to miss.
- Exam card shows "# سؤالًا" and "# دقيقة" — unfilled # placeholders (template bug).
- Exam card title is English and left-aligned inside an RTL layout while metadata is
  right-aligned; mixed alignment.
- Date "April 2026" is English next to Arabic text.

## Materials / generation flow (1000096435–1000096437)

Fix prompt the owner pasted, reflecting the no-review flow:

1. Materials screen (موادي)
   - Subtitle: "ارفع درسك وابدأ التدريب فورًا." Remove "بعد مراجعة الفريق".
   - Remove "بانتظار المراجعة" badge and the "حالة الإنشاء" hourglass row.
   - Card states:
     - No questions: gray badge "لم تُنشأ أسئلة" + primary button "ابدأ التدريب الآن"
       (sparkle) opening the generate sheet.
     - Generating: "جارٍ الإنشاء…" with progress, no review wording.
     - Ready: green badge "جاهز" + primary "ابدأ التدريب" that opens practice directly.
   - Friendly filename: one-line ellipsis or a student-editable title; never show
     "scaled_1000095886.jpg" wrapped over two lines.

2. After upload
   - Bottom sheet: "تم رفع المادة! هل تريد البدء بالتدريب الآن؟" with
     "ابدأ التدريب الآن" (primary) and "لاحقًا" (secondary).
   - Primary opens the generate sheet with 5 questions preselected, then straight into
     the practice session when generation completes.

3. Generate Questions screen (إنشاء أسئلة)
   - Remove the "فهمت أن الأسئلة تحتاج مراجعة قبل التدريب" checkbox and its validation.
   - Remove "تُراجع الأسئلة المولّدة قبل الاستخدام…" and "لا يبدأ التدريب قبل الاعتماد".
   - Question-count chips in one consistent row or 3-column grid, logical order
     (5–10), RTL handled.
   - Show the actual cost before confirming ("ستُخصم X من رصيدك"), not
     "تحدد الرسوم من الخادم". Keep the refund note as one short line.
   - Button "ابدأ التدريب" enabled immediately, no checkbox.
   - After confirming: loading state, then navigate into the first question. On failure,
     error with "حاول مرة أخرى" + note that the balance was refunded.

4. Backend/state
   - Remove pending_review from the flow; generated questions go directly to ready.
   - Keep the refund on failure.
