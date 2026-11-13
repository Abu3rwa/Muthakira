import 'practice_models.dart';

abstract interface class PracticeRepository {
  Future<StartAttemptResult> start(String examId);

  Future<AttemptView> fetch(String attemptId);

  Future<AnswerResult> submit(String attemptId, String questionId, Object answer);

  /// The server's next chosen question for an open attempt. Free, no AI call.
  Future<AdaptiveStep> nextAdaptive(String attemptId);

  /// Requests AI marking for one pending answer. The server quotes and charges.
  /// On a timeout or an already-marked conflict the stored result is re-fetched
  /// from [attemptId] so a slow request never reads as a lost payment.
  Future<AiGradeOutcome> aiGrade(String attemptId, String answerId);

  /// Resolves a pending_self answer after the model answer was revealed.
  /// The server validates the range 0..max and owns the final marks.
  Future<SelfMarkResult> selfMark(String answerId, double awardedMarks);

  Future<Attempt> close(String attemptId);

  /// [code] is a stable reason code (wrong_key, typo, unclear, other);
  /// [reason] is the human-readable text stored with the report.
  Future<QuestionReport> report(String questionId, String reason, {String? code});

  Future<void> saveDraft(String attemptId, String questionId, Object answer);

  Future<Map<String, Object?>> drafts(String attemptId);

  /// Locally kept answer text; the server only returns marks and status.
  Future<Map<String, Object?>> submittedAnswers(String attemptId);

  Future<int> pendingCount();

  /// Replays answers queued while offline and returns how many were accepted.
  Future<int> flushPending();
}
