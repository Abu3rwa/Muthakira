import '../../../core/utils/parse.dart';

export 'adaptive_models.dart';
export 'answer_models.dart';

enum AttemptStatus {
  open,
  closed,
  unknown;

  static AttemptStatus parse(Object? raw) => switch (raw) {
    'open' => AttemptStatus.open,
    'closed' => AttemptStatus.closed,
    _ => AttemptStatus.unknown,
  };
}

enum MarkingStatus {
  marked,
  pendingSelf,
  pendingAi,
  unknown;

  static MarkingStatus parse(Object? raw) => switch (raw) {
    'marked' => MarkingStatus.marked,
    'pending_self' => MarkingStatus.pendingSelf,
    'pending_ai' => MarkingStatus.pendingAi,
    _ => MarkingStatus.unknown,
  };
}

class Attempt {
  const Attempt({
    required this.id,
    required this.examId,
    required this.status,
    required this.answersCount,
    required this.correctCount,
    required this.awardedMarks,
    required this.startedAt,
    required this.lastActivityAt,
    this.closedAt,
  });

  final String id;
  final String examId;
  final AttemptStatus status;
  final int answersCount;
  final int correctCount;
  final double awardedMarks;
  final DateTime? startedAt;
  final DateTime? lastActivityAt;
  final DateTime? closedAt;

  bool get isOpen => status == AttemptStatus.open;

  factory Attempt.fromJson(Map<String, Object?> json) => Attempt(
    id: Parse.string(json['id']),
    examId: Parse.string(json['exam_id']),
    status: AttemptStatus.parse(json['status']),
    answersCount: Parse.integer(json['answers_count']),
    correctCount: Parse.integer(json['correct_count']),
    awardedMarks: Parse.decimal(json['awarded_marks']),
    startedAt: Parse.date(json['started_at']),
    lastActivityAt: Parse.date(json['last_activity_at']),
    closedAt: Parse.date(json['closed_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'exam_id': examId,
    'status': status.name,
    'answers_count': answersCount,
    'correct_count': correctCount,
    'awarded_marks': awardedMarks,
    'started_at': startedAt?.toIso8601String(),
    'last_activity_at': lastActivityAt?.toIso8601String(),
    'closed_at': closedAt?.toIso8601String(),
  };

  Attempt copyWith({
    AttemptStatus? status,
    int? answersCount,
    int? correctCount,
    double? awardedMarks,
    DateTime? lastActivityAt,
    DateTime? closedAt,
  }) => Attempt(
    id: id,
    examId: examId,
    status: status ?? this.status,
    answersCount: answersCount ?? this.answersCount,
    correctCount: correctCount ?? this.correctCount,
    awardedMarks: awardedMarks ?? this.awardedMarks,
    startedAt: startedAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    closedAt: closedAt ?? this.closedAt,
  );
}

class StartAttemptResult {
  const StartAttemptResult({required this.attempt, required this.created});

  final Attempt attempt;
  final bool created;

  factory StartAttemptResult.fromJson(Map<String, Object?> json) => StartAttemptResult(
    attempt: Attempt.fromJson(Parse.map(json['attempt'])),
    created: Parse.boolean(json['created']),
  );
}

