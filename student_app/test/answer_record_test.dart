import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/practice/domain/practice_models.dart';

void main() {
  test('the submitted answer value round-trips through JSON', () {
    final AnswerRecord record = AnswerRecord.fromJson(<String, Object?>{
      'id': 'a1',
      'question_id': 'q1',
      'marking_status': 'marked',
      'correct': false,
      'awarded_marks': 0,
      'attempts_count': 1,
      'answer': <String>['الخرطوم', 'أم درمان'],
    });

    expect(record.answer, <String>['الخرطوم', 'أم درمان']);
    expect(AnswerRecord.fromJson(record.toJson()).answer, record.answer);
  });

  test('AI marking updates keep the submitted answer intact', () {
    const AnswerRecord record = AnswerRecord(
      id: 'a1',
      questionId: 'q1',
      markingStatus: MarkingStatus.pendingAi,
      correct: null,
      awardedMarks: null,
      attemptsCount: 1,
      answeredAt: null,
      answer: 'إجابة الطالب',
    );

    final AnswerRecord updated = record.copyWith(
      markingStatus: MarkingStatus.marked,
      correct: true,
      awardedMarks: 3,
    );

    expect(updated.answer, 'إجابة الطالب');
  });

  test('older payloads without an answer still parse', () {
    final AnswerRecord record = AnswerRecord.fromJson(<String, Object?>{
      'id': 'a1',
      'question_id': 'q1',
      'marking_status': 'marked',
    });

    expect(record.answer, isNull);
  });

  test('the server AI fields parse: marking_method, ai_missing_points, ai_inflight', () {
    final AnswerRecord record = AnswerRecord.fromJson(<String, Object?>{
      'id': 'a1',
      'question_id': 'q1',
      'marking_status': 'marked',
      'marking_method': 'ai_rubric',
      'correct': false,
      'awarded_marks': 2.5,
      'ai_feedback': 'ينقصك تعريف المصطلح.',
      'ai_missing_points': <String>['تعريف المصطلح'],
      'ai_inflight': false,
    });

    expect(record.markingMethod, 'ai_rubric');
    expect(record.missingPoints, <String>['تعريف المصطلح']);
    expect(record.aiInflight, isFalse);
    expect(record.aiMarked, isTrue);
    expect(record.isAiRubric, isTrue);
    expect(record.hasPartialCredit, isTrue);
    final AnswerRecord roundTrip = AnswerRecord.fromJson(record.toJson());
    expect(roundTrip.markingMethod, 'ai_rubric');
    expect(roundTrip.missingPoints, record.missingPoints);
  });

  test('every ai_rubric state keeps the AI panel eligible', () {
    AnswerRecord parse(String status, {Map<String, Object?>? review, bool inflight = false}) =>
        AnswerRecord.fromJson(<String, Object?>{
          'id': 'a1',
          'question_id': 'q1',
          'marking_status': status,
          'marking_method': 'ai_rubric',
          'ai_review': review,
          'ai_inflight': inflight,
        });

    expect(parse('pending_ai').isAiRubric, isTrue);
    expect(parse('pending_ai', inflight: true).aiInflight, isTrue);
    expect(parse('pending_ai', review: <String, Object?>{'id': 'r1', 'status': 'pending'}).aiReview!.isPending, isTrue);
    final AnswerRecord rejected = parse('pending_ai', review: <String, Object?>{'id': 'r1', 'status': 'rejected'});
    expect(rejected.reviewRejected, isTrue);
    expect(rejected.isAiRubric, isTrue);
    final AnswerRecord voided = parse('pending_ai', review: <String, Object?>{'id': 'r1', 'status': 'voided'});
    expect(voided.reviewVoided, isTrue);
    expect(parse('marked').aiMarked, isTrue);
  });

  test('a self-marked answer is not AI-marked', () {
    final AnswerRecord record = AnswerRecord.fromJson(<String, Object?>{
      'id': 'a1',
      'question_id': 'q1',
      'marking_status': 'marked',
      'marking_method': 'self_mark',
      'correct': true,
      'awarded_marks': 4,
    });

    expect(record.aiMarked, isFalse);
    expect(record.isAiRubric, isFalse);
  });

  test('a replayed outcome parses without a new charge', () {
    final AiGradeOutcome outcome = AiGradeOutcome.fromJson(<String, Object?>{
      'status': 'marked',
      'awarded_marks': 3,
      'correct': false,
      'feedback': 'محفوظة',
      'missing_points': <String>[],
      'credits_charged': 0,
      'replayed': true,
    });

    expect(outcome.replayed, isTrue);
    expect(outcome.creditsCharged, 0);
    expect(outcome.awaitingReview, isFalse);
  });
}