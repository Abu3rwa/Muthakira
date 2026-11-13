import '../../../core/config/constants.dart';
import '../../../core/errors/error_codes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/storage/user_scope.dart';
import '../../../core/utils/parse.dart';
import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';

/// Practice API. Answers submitted while offline are queued locally and
/// replayed by [flushPending]; the server stays the only marker.
class ApiPracticeRepository implements PracticeRepository {
  ApiPracticeRepository(this._api, this._cache, this._scope);

  final ApiClient _api;
  final CacheStore _cache;
  final UserScope _scope;

  String? get _userId => _scope.userId;

  @override
  Future<StartAttemptResult> start(String examId) async {
    final Map<String, dynamic> json = await _api.postJson(
      ApiPaths.attempts,
      body: <String, Object?>{'examId': examId},
    );
    return StartAttemptResult.fromJson(json);
  }

  @override
  Future<AttemptView> fetch(String attemptId) async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.attempt(attemptId));
    return AttemptView.fromJson(json);
  }

  @override
  Future<AnswerResult> submit(String attemptId, String questionId, Object answer) async {
    late final AnswerResult result;
    try {
      final Map<String, dynamic> json = await _api.postJson(
        ApiPaths.attemptAnswers(attemptId),
        body: <String, Object?>{'questionId': questionId, 'answer': answer},
      );
      result = AnswerResult.fromJson(json);
    } on AppFailure catch (failure) {
      final String? userId = _userId;
      if (userId != null && failure.isOffline) {
        await _cache.enqueueAnswer(
          userId: userId,
          attemptId: attemptId,
          questionId: questionId,
          payload: answer,
        );
      }
      rethrow;
    }

    final String? userId = _userId;
    if (userId != null) {
      await _remember(userId, attemptId, questionId, answer, result.answer);
      await _cache.deleteDraft(userId, attemptId, questionId);
    }
    return result;
  }

  @override
  Future<AdaptiveStep> nextAdaptive(String attemptId) async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.attemptNextQuestion(attemptId));
    return AdaptiveStep.fromJson(json);
  }

  @override
  Future<AiGradeOutcome> aiGrade(String attemptId, String answerId) async {
    try {
      final Map<String, dynamic> json = await _api.postJson(
        ApiPaths.answerAiGrade(answerId),
        receiveTimeout: Limits.aiGradeTimeout,
      );
      return AiGradeOutcome.fromJson(json);
    } on AppFailure catch (failure) {
      final bool recoverable = failure.isTimeout ||
          failure.code == ErrorCodes.answerAlreadyMarked ||
          failure.code == ErrorCodes.reviewAlreadyPending ||
          failure.code == ErrorCodes.aiInFlight;
      if (!recoverable) rethrow;
      final AiGradeOutcome? stored = await _storedOutcome(attemptId, answerId);
      if (stored != null) return stored;
      if (failure.isTimeout) {
        // The server may still be marking; never present that as a failure
        // that invites paying again.
        throw AppFailure.api(code: ErrorCodes.aiInFlight, status: 409);
      }
      rethrow;
    }
  }

  /// Re-reads the attempt after a timeout/conflict and rebuilds the outcome
  /// from what the server actually stored. Free: no new AI call is made.
  Future<AiGradeOutcome?> _storedOutcome(String attemptId, String answerId) async {
    try {
      final AttemptView view = await fetch(attemptId);
      for (final AnswerRecord record in view.answers) {
        if (record.id != answerId) continue;
        if (record.aiMarked) {
          return AiGradeOutcome(
            awaitingReview: false,
            creditsCharged: 0,
            awardedMarks: record.awardedMarks,
            correct: record.correct,
            feedback: record.aiFeedback,
            missingPoints: record.missingPoints,
            replayed: true,
          );
        }
        if (record.aiReview?.isPending == true) {
          return AiGradeOutcome(
            awaitingReview: true,
            creditsCharged: 0,
            reviewId: record.aiReview!.id,
            replayed: true,
          );
        }
        return null;
      }
      return null;
    } on AppFailure {
      return null;
    }
  }

  @override
  Future<SelfMarkResult> selfMark(String answerId, double awardedMarks) async {
    final Map<String, dynamic> json = await _api.postJson(
      ApiPaths.answerSelfMark(answerId),
      body: <String, Object?>{'awarded_marks': awardedMarks},
    );
    return SelfMarkResult.fromJson(json);
  }

  @override
  Future<Attempt> close(String attemptId) async {
    final Map<String, dynamic> json = await _api.postJson(ApiPaths.attemptClose(attemptId));
    return Attempt.fromJson(Parse.map(json['attempt']));
  }

  @override
  Future<QuestionReport> report(String questionId, String reason, {String? code}) async {
    final Map<String, dynamic> json = await _api.postJson(
      ApiPaths.reportQuestion(questionId),
      body: <String, Object?>{'reason': reason, if (code != null) 'code': code},
    );
    return QuestionReport.fromJson(json);
  }

  @override
  Future<void> saveDraft(String attemptId, String questionId, Object answer) async {
    final String? userId = _userId;
    if (userId == null) return;
    await _cache.saveDraft(userId, attemptId, questionId, answer);
  }

  @override
  Future<Map<String, Object?>> drafts(String attemptId) async {
    final String? userId = _userId;
    if (userId == null) return const <String, Object?>{};
    return _cache.loadDrafts(userId, attemptId);
  }

  @override
  Future<Map<String, Object?>> submittedAnswers(String attemptId) async {
    final String? userId = _userId;
    if (userId == null) return const <String, Object?>{};
    return _cache.loadSubmitted(userId, attemptId);
  }

  @override
  Future<int> pendingCount() async {
    final String? userId = _userId;
    if (userId == null) return 0;
    return (await _cache.pendingAnswers(userId)).length;
  }

  @override
  Future<int> flushPending() async {
    final String? userId = _userId;
    if (userId == null) return 0;
    final List<QueuedAnswer> queued = await _cache.pendingAnswers(userId);
    var flushed = 0;
    for (final QueuedAnswer pending in queued) {
      try {
        final Map<String, dynamic> json = await _api.postJson(
          ApiPaths.attemptAnswers(pending.attemptId),
          body: <String, Object?>{'questionId': pending.questionId, 'answer': pending.payload},
        );
        final AnswerResult result = AnswerResult.fromJson(json);
        await _remember(userId, pending.attemptId, pending.questionId, pending.payload, result.answer);
        await _cache.removePending(pending.id);
        flushed += 1;
      } on ApiFailure catch (failure) {
        if (failure.code == ErrorCodes.attemptClosed) {
          await _cache.removePending(pending.id);
        } else {
          await _cache.markPendingFailed(pending.id, failure.code);
        }
      } on AppFailure catch (failure) {
        await _cache.markPendingFailed(pending.id, failure.code);
      }
    }
    return flushed;
  }

  Future<void> _remember(
    String userId,
    String attemptId,
    String questionId,
    Object? answer,
    AnswerRecord record,
  ) {
    return _cache.saveSubmitted(
      userId: userId,
      attemptId: attemptId,
      questionId: questionId,
      answer: answer,
      markingStatus: _statusWire(record.markingStatus),
      correct: record.correct,
      awardedMarks: record.awardedMarks,
      attemptsCount: record.attemptsCount,
      answeredAt: record.answeredAt ?? DateTime.now(),
    );
  }

  static String _statusWire(MarkingStatus status) => switch (status) {
    MarkingStatus.marked => 'marked',
    MarkingStatus.pendingSelf => 'pending_self',
    MarkingStatus.pendingAi => 'pending_ai',
    MarkingStatus.unknown => 'unknown',
  };
}
