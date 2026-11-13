import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app/core/config/constants.dart';
import 'package:student_app/core/errors/error_codes.dart';
import 'package:student_app/core/errors/failure.dart';
import 'package:student_app/core/network/api_client.dart';
import 'package:student_app/core/storage/cache_store.dart';
import 'package:student_app/core/storage/user_scope.dart';
import 'package:student_app/features/materials/data/api_materials_repository.dart';
import 'package:student_app/features/materials/domain/material_models.dart';
import 'package:student_app/features/practice/data/api_practice_repository.dart';
import 'package:student_app/features/practice/domain/practice_models.dart';

class _MockApi extends Mock implements ApiClient {}

class _MockCache extends Mock implements CacheStore {}

class _MockScope extends Mock implements UserScope {}

AnswerRecord _stored({
  MarkingStatus status = MarkingStatus.marked,
  AiReviewState? review,
  bool inflight = false,
}) => AnswerRecord(
  id: 'a1',
  questionId: 'q1',
  markingStatus: status,
  correct: status == MarkingStatus.marked ? false : null,
  awardedMarks: status == MarkingStatus.marked ? 2.5 : null,
  attemptsCount: 1,
  answeredAt: null,
  answer: 'إجابة الطالب',
  markingMethod: 'ai_rubric',
  aiFeedback: status == MarkingStatus.marked ? 'ينقصك تعريف المصطلح.' : null,
  missingPoints: status == MarkingStatus.marked ? const <String>['تعريف المصطلح'] : const <String>[],
  aiReview: review,
  aiInflight: inflight,
);

Map<String, Object?> _attemptJson(AnswerRecord record) => <String, Object?>{
  'attempt': <String, Object?>{'id': 'att1', 'exam_id': 'e1', 'status': 'open'},
  'answers': <Map<String, Object?>>[record.toJson()],
};

GenerationJob _job({String id = 'gen1', String materialId = 'm1', int count = 5}) => GenerationJob(
  id: id,
  materialId: materialId,
  classLevel: '3',
  subject: 'أحياء',
  count: count,
  status: GenerationStatus.review,
  creditsCharged: 0,
  createdAt: DateTime.now(),
);

void main() {
  late _MockApi api;
  late ApiPracticeRepository practice;
  late ApiMaterialsRepository materials;

  setUp(() {
    api = _MockApi();
    practice = ApiPracticeRepository(api, _MockCache(), _MockScope());
    materials = ApiMaterialsRepository(api);
  });

  group('AI grading recovery', () {
    test('waits longer than the server AI timeout on the grade call', () async {
      when(() => api.postJson(any(), receiveTimeout: any(named: 'receiveTimeout'))).thenAnswer(
        (_) async => <String, dynamic>{'status': 'marked', 'credits_charged': 1, 'awarded_marks': 4},
      );
      await practice.aiGrade('att1', 'a1');
      verify(
        () => api.postJson(ApiPaths.answerAiGrade('a1'), receiveTimeout: Limits.aiGradeTimeout),
      ).called(1);
      expect(Limits.aiGradeTimeout, greaterThan(const Duration(seconds: 120)));
    });

    test('a timeout recovers the stored marked result instead of failing', () async {
      when(() => api.postJson(any(), receiveTimeout: any(named: 'receiveTimeout')))
          .thenThrow(const AppFailure.timeout());
      when(() => api.getJson(ApiPaths.attempt('att1')))
          .thenAnswer((_) async => _attemptJson(_stored()));

      final AiGradeOutcome outcome = await practice.aiGrade('att1', 'a1');

      expect(outcome.awaitingReview, isFalse);
      expect(outcome.replayed, isTrue);
      expect(outcome.creditsCharged, 0);
      expect(outcome.awardedMarks, 2.5);
      expect(outcome.feedback, 'ينقصك تعريف المصطلح.');
      expect(outcome.missingPoints, <String>['تعريف المصطلح']);
    });

    test('ANSWER_ALREADY_MARKED recovers the stored result for free', () async {
      when(() => api.postJson(any(), receiveTimeout: any(named: 'receiveTimeout'))).thenThrow(
        AppFailure.api(code: ErrorCodes.answerAlreadyMarked, status: 409),
      );
      when(() => api.getJson(ApiPaths.attempt('att1')))
          .thenAnswer((_) async => _attemptJson(_stored()));

      final AiGradeOutcome outcome = await practice.aiGrade('att1', 'a1');

      expect(outcome.replayed, isTrue);
      expect(outcome.creditsCharged, 0);
      expect(outcome.awardedMarks, 2.5);
    });

    test('a timeout during human review recovers the pending review', () async {
      when(() => api.postJson(any(), receiveTimeout: any(named: 'receiveTimeout')))
          .thenThrow(const AppFailure.timeout());
      when(() => api.getJson(ApiPaths.attempt('att1'))).thenAnswer(
        (_) async => _attemptJson(
          _stored(status: MarkingStatus.pendingAi, review: const AiReviewState(status: 'pending', id: 'r1')),
        ),
      );

      final AiGradeOutcome outcome = await practice.aiGrade('att1', 'a1');

      expect(outcome.awaitingReview, isTrue);
      expect(outcome.replayed, isTrue);
      expect(outcome.creditsCharged, 0);
      expect(outcome.reviewId, 'r1');
    });

    test('a timeout while the server is still marking surfaces AI_IN_FLIGHT, not a lost payment', () async {
      when(() => api.postJson(any(), receiveTimeout: any(named: 'receiveTimeout')))
          .thenThrow(const AppFailure.timeout());
      when(() => api.getJson(ApiPaths.attempt('att1'))).thenAnswer(
        (_) async => _attemptJson(_stored(status: MarkingStatus.pendingAi, inflight: true)),
      );

      await expectLater(
        practice.aiGrade('att1', 'a1'),
        throwsA(
          isA<AppFailure>().having((AppFailure f) => f.code, 'code', ErrorCodes.aiInFlight),
        ),
      );
    });

    test('a real block (insufficient credits) is rethrown without a recovery fetch', () async {
      when(() => api.postJson(any(), receiveTimeout: any(named: 'receiveTimeout'))).thenThrow(
        AppFailure.api(code: ErrorCodes.insufficientCredits, status: 402),
      );

      await expectLater(
        practice.aiGrade('att1', 'a1'),
        throwsA(
          isA<AppFailure>().having((AppFailure f) => f.code, 'code', ErrorCodes.insufficientCredits),
        ),
      );
      verifyNever(() => api.getJson(any()));
    });

    test('a timeout with an unreachable attempt still reports in-flight, never a lost payment', () async {
      when(() => api.postJson(any(), receiveTimeout: any(named: 'receiveTimeout')))
          .thenThrow(const AppFailure.timeout());
      when(() => api.getJson(ApiPaths.attempt('att1'))).thenThrow(const AppFailure.network());

      await expectLater(
        practice.aiGrade('att1', 'a1'),
        throwsA(isA<AppFailure>().having((AppFailure f) => f.code, 'code', ErrorCodes.aiInFlight)),
      );
    });
  });

  group('generation recovery', () {
    test('waits longer than the server AI timeout on the create call', () async {
      when(() => api.postJson(any(), body: any(named: 'body'), receiveTimeout: any(named: 'receiveTimeout')))
          .thenAnswer((_) async => _job().toJson());
      await materials.createGeneration('m1');
      verify(
        () => api.postJson(
          ApiPaths.aiGenerations,
          body: <String, Object?>{'materialId': 'm1', 'count': generationMinQuestions},
          receiveTimeout: Limits.aiGenerationTimeout,
        ),
      ).called(1);
      expect(Limits.aiGenerationTimeout, greaterThan(Limits.aiGradeTimeout));
    });

    test('a timeout recovers the job the server already created', () async {
      when(() => api.postJson(any(), body: any(named: 'body'), receiveTimeout: any(named: 'receiveTimeout')))
          .thenThrow(const AppFailure.timeout());
      when(() => api.getJson(ApiPaths.aiGenerations)).thenAnswer(
        (_) async => <String, dynamic>{
          'items': <Map<String, Object?>>[
            _job(id: 'gen-other', materialId: 'm2').toJson(),
            _job(id: 'gen-mine').toJson(),
          ],
        },
      );

      final GenerationJob job = await materials.createGeneration('m1');

      expect(job.id, 'gen-mine');
      expect(job.creditsCharged, 0);
    });

    test('a timeout with no matching job rethrows so the student can retry safely', () async {
      when(() => api.postJson(any(), body: any(named: 'body'), receiveTimeout: any(named: 'receiveTimeout')))
          .thenThrow(const AppFailure.timeout());
      when(() => api.getJson(ApiPaths.aiGenerations)).thenAnswer(
        (_) async => <String, dynamic>{'items': <Map<String, Object?>>[]},
      );

      await expectLater(materials.createGeneration('m1'), throwsA(isA<TimeoutFailure>()));
    });
  });
}