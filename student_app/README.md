# student_app

Flutter student client for Mothakira (مذكرة). Server-authoritative: money,
marks, unlock state and AI fees are always decided by the API; the app only
displays what it receives.

## Running

```sh
flutter gen-l10n                 # ARB (ar default, en) -> generated localisations
flutter run                      # real API from lib/core/config/env.dart
flutter run --dart-define=USE_FAKE_API=true   # in-memory fake backend
```

`flutter analyze` and `flutter test` must stay clean; tests never use the
network.

## Backend contract notes and deviations

Recorded while wiring the screens against `api/`; the backend code wins.

- **No client-side pricing.** There is no package or AI price-quote endpoint.
  The generation screen states that the fee is set by the server at confirm and
  refreshes the wallet afterwards; it never estimates a number beforehand.
- **AI grading fees on review.** A low-confidence AI mark returns
  `status: "review"` and stays charged until a human confirms or refunds. The
  panel says so instead of promising a refund on review.
- **Rejected generations keep `credits_charged`.** The server refunds the
  wallet but does not zero the stored charge. The status screen therefore shows
  the refund wording and no numeric charge for rejected jobs; only failed jobs
  claim "nothing was charged".
- **Materials: PDF is unsupported.** The API rejects PDFs with
  `MATERIAL_PDF_NOT_SUPPORTED`, so the PDF chip is visibly disabled and the app
  asks for a photo or pasted text instead. Files are capped by the server's
  receipt byte limit (8 MB) and by type (`text/plain`, `text/markdown`,
  `image/png`, `image/jpeg`).
- **Adaptive practice has no manual controls.** `GET .../next-question`
  accepts no topic or difficulty; the server derives both from the attempt.
  The setup screen only picks a paper and explains this.
- **Grades.** Signup stores `secondary_1..3`; the AI API uses `"1".."3"`. Both
  are mapped through `gradeLabel`, and uploads send the AI form.
- **Data-saver toggle removed.** No endpoint supports it and nothing in the app
  throttled traffic, so the inert switch was dropped rather than left lying.
