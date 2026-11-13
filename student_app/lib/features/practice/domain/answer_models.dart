/// Answers, feedback and the AI-marking outcome returned by the server.
library;

import '../../../core/utils/parse.dart';
import 'practice_models.dart';

/// Human-review hand-off attached to an answer. The server owns its status.
class AiReviewState {
  const AiReviewState({required this.status, this.id});

  final String status;
  final String? id;

  bool get isPending => status == 'pending';

  static AiReviewState? parse(Object? raw) {
    if (raw is! Map) return null;
    final Map<String, Object?> json = raw.cast<String, Object?>();
    final String status = Parse.string(json['status']);
    if (status.isEmpty) return null;
    return AiReviewState(status: status, id: Parse.stringOrNull(json['id']));
  }

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'status': status};
}

/// One definition of "correct" for every surface: full credit only.
enum CreditStatus { full, partial, zero, pending }

CreditStatus creditStatusOf({
  required MarkingStatus markingStatus,
  required double? awardedMarks,
  required double totalMarks,
}) {
  if (markingStatus != MarkingStatus.marked || awardedMarks == null) return CreditStatus.pending;
  if (totalMarks > 0 && awardedMarks >= totalMarks - 1e-9) return CreditStatus.full;
  if (awardedMarks > 0) return CreditStatus.partial;
  return CreditStatus.zero;
}

/// True when a submitted value carries at least one non-empty element.
bool hasAnswerContent(Object? value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is num) return value.isFinite;
  if (value is bool) return true;
  if (value is List) return value.any(hasAnswerContent);
  if (value is Map) return value.values.any(hasAnswerContent);
  return false;
}

class AnswerRecord {
  const AnswerRecord({
    required this.id,
    required this.questionId,
    required this.markingStatus,
    required this.correct,
    required this.awardedMarks,
    required this.attemptsCount,
    required this.answeredAt,
    this.answer,
    this.markingMethod,
    this.aiFeedback,
    this.missingPoints = const <String>[],
    this.aiReview,
    this.aiInflight = false,
    this.modelAnswer,
    this.key,
    this.explanation,
  });

  final String id;
  final String questionId;
  final MarkingStatus markingStatus;
  final bool? correct;
  final double? awardedMarks;
  final int attemptsCount;
  final DateTime? answeredAt;

  /// The student's own submitted value, echoed by the server so answered
  /// questions can show it locked. Never the answer key.
  final Object? answer;

  /// Server marking route: `ai_rubric`, `self_mark` or an auto-* method.
  final String? markingMethod;

  /// Present once AI marking succeeded for this answer.
  final String? aiFeedback;
  final List<String> missingPoints;
  final AiReviewState? aiReview;

  /// True while an AI marking request is running on the server.
  final bool aiInflight;

  /// Revealed by the server for self-marked answers once keys are accessible.
  final String? modelAnswer;
  final Object? key;
  final String? explanation;

  /// Partial credit is not exposed as a flag, so we infer it from the marks.
  bool get hasPartialCredit =>
      markingStatus == MarkingStatus.marked && correct == false && (awardedMarks ?? 0) > 0;

  CreditStatus creditStatus(double totalMarks) => creditStatusOf(
    markingStatus: markingStatus,
    awardedMarks: awardedMarks,
    totalMarks: totalMarks,
  );

  bool get aiMarked =>
      markingStatus == MarkingStatus.marked &&
      (markingMethod == 'ai_rubric' || (aiFeedback?.trim().isNotEmpty ?? false));

  /// The AI panel stays visible for every ai_rubric state, not just pending.
  bool get isAiRubric =>
      markingMethod == 'ai_rubric' || markingStatus == MarkingStatus.pendingAi || aiReview != null;

  bool get reviewRejected => aiReview?.status == 'rejected';
  bool get reviewVoided => aiReview?.status == 'voided';

  factory AnswerRecord.fromJson(Map<String, Object?> json) => AnswerRecord(
    id: Parse.string(json['id']),
    questionId: Parse.string(json['question_id']),
    markingStatus: MarkingStatus.parse(json['marking_status']),
    correct: json['correct'] is bool ? json['correct'] as bool : null,
    awardedMarks: json['awarded_marks'] == null ? null : Parse.decimal(json['awarded_marks']),
    attemptsCount: Parse.integer(json['attempts_count']),
    answeredAt: Parse.date(json['answered_at']),
    answer: json['answer'],
    markingMethod: Parse.stringOrNull(json['marking_method']),
    aiFeedback: Parse.stringOrNull(json['ai_feedback']),
    missingPoints: Parse.stringList(json['ai_missing_points'] ?? json['missing_points']),
    aiReview: AiReviewState.parse(json['ai_review']),
    aiInflight: Parse.boolean(json['ai_inflight']),
    modelAnswer: Parse.stringOrNull(json['model_answer']),
    key: json['key'],
    explanation: Parse.stringOrNull(json['explanation']),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'question_id': questionId,
    'marking_status': switch (markingStatus) {
      MarkingStatus.marked => 'marked',
      MarkingStatus.pendingSelf => 'pending_self',
      MarkingStatus.pendingAi => 'pending_ai',
      MarkingStatus.unknown => 'unknown',
    },
    'correct': correct,
    'awarded_marks': awardedMarks,
    'attempts_count': attemptsCount,
    'answered_at': answeredAt?.toIso8601String(),
    'answer': answer,
    'marking_method': markingMethod,
    'ai_feedback': aiFeedback,
    'ai_missing_points': missingPoints,
    'ai_review': aiReview?.toJson(),
    'ai_inflight': aiInflight,
    'model_answer': modelAnswer,
    'key': key,
    'explanation': explanation,
  };

  AnswerRecord copyWith({
    MarkingStatus? markingStatus,
    bool? correct,
    double? awardedMarks,
    String? markingMethod,
    String? aiFeedback,
    List<String>? missingPoints,
    AiReviewState? aiReview,
    bool? aiInflight,
    String? modelAnswer,
    Object? key,
    String? explanation,
  }) => AnswerRecord(
    id: id,
    questionId: questionId,
    markingStatus: markingStatus ?? this.markingStatus,
    correct: correct ?? this.correct,
    awardedMarks: awardedMarks ?? this.awardedMarks,
    attemptsCount: attemptsCount,
    answeredAt: answeredAt,
    answer: answer,
    markingMethod: markingMethod ?? this.markingMethod,
    aiFeedback: aiFeedback ?? this.aiFeedback,
    missingPoints: missingPoints ?? this.missingPoints,
    aiReview: aiReview ?? this.aiReview,
    aiInflight: aiInflight ?? this.aiInflight,
    modelAnswer: modelAnswer ?? this.modelAnswer,
    key: key ?? this.key,
    explanation: explanation ?? this.explanation,
  );
}

class AttemptView {
  const AttemptView({required this.attempt, required this.answers});

  final Attempt attempt;
  final List<AnswerRecord> answers;

  Map<String, AnswerRecord> get byQuestion => {for (final answer in answers) answer.questionId: answer};

  factory AttemptView.fromJson(Map<String, Object?> json) => AttemptView(
    attempt: Attempt.fromJson(Parse.map(json['attempt'])),
    answers: Parse.mapList(json['answers']).map(AnswerRecord.fromJson).toList(growable: false),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'attempt': attempt.toJson(),
    'answers': answers.map((answer) => answer.toJson()).toList(growable: false),
  };

  AttemptView replaceAttempt(Attempt attempt) => AttemptView(attempt: attempt, answers: answers);
}

class AnswerFeedback {
  const AnswerFeedback({
    required this.markingStatus,
    required this.pending,
    this.correct,
    this.awardedMarks,
    this.key,
    this.explanation,
    this.modelAnswer,
  });

  final MarkingStatus markingStatus;
  final bool pending;
  final bool? correct;
  final double? awardedMarks;
  final Object? key;
  final String? explanation;
  final String? modelAnswer;

  bool get keyRevealed => key != null;

  CreditStatus creditStatus(double totalMarks) => creditStatusOf(
    markingStatus: pending ? MarkingStatus.unknown : MarkingStatus.marked,
    awardedMarks: awardedMarks,
    totalMarks: totalMarks,
  );

  String? get keyText => switch (key) {
    final String value => value,
    final num value => value.toString(),
    final bool value => value ? 'true' : 'false',
    _ => null,
  };

  List<String>? get keyLetters => switch (key) {
    final List<dynamic> values => values
        .map((dynamic value) => value is List ? value.map((dynamic cell) => cell.toString()).join(' | ') : value.toString())
        .toList(growable: false),
    _ => null,
  };

  bool? get keyBool => key is bool ? key as bool : null;

  factory AnswerFeedback.fromJson(Map<String, Object?> json) {
    final MarkingStatus status = MarkingStatus.parse(json['marking_status']);
    final bool pending = Parse.boolean(json['pending']);
    return AnswerFeedback(
      markingStatus: pending && status == MarkingStatus.unknown ? MarkingStatus.pendingSelf : status,
      pending: pending,
      correct: json['correct'] is bool ? json['correct'] as bool : null,
      awardedMarks: json['awarded_marks'] == null ? null : Parse.decimal(json['awarded_marks']),
      key: json['key'],
      explanation: Parse.stringOrNull(json['explanation']),
      modelAnswer: Parse.stringOrNull(json['model_answer']),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'pending': pending,
    'marking_status': switch (markingStatus) {
      MarkingStatus.marked => 'marked',
      MarkingStatus.pendingSelf => 'pending_self',
      MarkingStatus.pendingAi => 'pending_ai',
      MarkingStatus.unknown => 'unknown',
    },
    'correct': correct,
    'awarded_marks': awardedMarks,
    'key': key,
    'explanation': explanation,
    'model_answer': modelAnswer,
  };

  bool get hasPartialCredit => !pending && correct == false && (awardedMarks ?? 0) > 0;
}

/// Outcome of resolving a pending_self answer. Marks stay server-owned.
class SelfMarkResult {
  const SelfMarkResult({required this.answer, required this.feedback});

  final AnswerRecord answer;
  final AnswerFeedback feedback;

  factory SelfMarkResult.fromJson(Map<String, Object?> json) => SelfMarkResult(
    answer: AnswerRecord.fromJson(Parse.map(json['answer'])),
    feedback: AnswerFeedback.fromJson(Parse.map(json['feedback'])),
  );
}

class AnswerResult {
  const AnswerResult({required this.answer, required this.feedback, required this.attempt});

  final AnswerRecord answer;
  final AnswerFeedback feedback;
  final Attempt attempt;

  factory AnswerResult.fromJson(Map<String, Object?> json) => AnswerResult(
    answer: AnswerRecord.fromJson(Parse.map(json['answer'])),
    feedback: AnswerFeedback.fromJson(Parse.map(json['feedback'])),
    attempt: Attempt.fromJson(Parse.map(json['attempt'])),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'answer': answer.toJson(),
    'feedback': feedback.toJson(),
    'attempt': attempt.toJson(),
  };
}

class QuestionReport {
  const QuestionReport({required this.id, required this.status, required this.reason, this.code, this.createdAt});

  final String id;
  final String status;
  final String reason;
  final String? code;
  final DateTime? createdAt;

  factory QuestionReport.fromJson(Map<String, Object?> json) => QuestionReport(
    id: Parse.string(json['id']),
    status: Parse.string(json['status'], fallback: 'open'),
    reason: Parse.string(json['reason']),
    code: Parse.stringOrNull(json['code']),
    createdAt: Parse.date(json['created_at']),
  );
}

/// Server outcome of one AI-marking request. Marks and the fee are server-owned.
class AiGradeOutcome {
  const AiGradeOutcome({
    required this.awaitingReview,
    required this.creditsCharged,
    this.awardedMarks,
    this.correct,
    this.feedback,
    this.missingPoints = const <String>[],
    this.reviewId,
    this.replayed = false,
  });

  final bool awaitingReview;
  final int creditsCharged;
  final double? awardedMarks;
  final bool? correct;
  final String? feedback;
  final List<String> missingPoints;
  final String? reviewId;

  /// True when the server (or the app's timeout recovery) returned an already
  /// stored result instead of running a new paid call.
  final bool replayed;

  factory AiGradeOutcome.fromJson(Map<String, Object?> json) {
    final bool review = Parse.string(json['status']) == 'review';
    return AiGradeOutcome(
      awaitingReview: review,
      creditsCharged: Parse.integer(json['credits_charged']),
      awardedMarks: Parse.decimalOrNull(json['awarded_marks']),
      correct: json['correct'] is bool ? json['correct'] as bool : null,
      feedback: Parse.stringOrNull(json['feedback']),
      missingPoints: Parse.stringList(json['missing_points']),
      reviewId: Parse.stringOrNull(json['review_id']),
      replayed: Parse.boolean(json['replayed']),
    );
  }

  AiReviewState? get review => awaitingReview
      ? AiReviewState(status: 'pending', id: reviewId)
      : null;
}
