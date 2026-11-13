/// Exams: catalogue, paper structure, unlocks and paid answer keys.
library;

import 'dart:convert';

import '../../../core/config/constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/storage/user_scope.dart';
import '../../../core/utils/parse.dart';
import '../domain/exam_models.dart';
import '../domain/exam_repository.dart';

class ApiExamRepository implements ExamRepository {
  ApiExamRepository({required ApiClient api, required CacheStore cache, required UserScope scope})
    : _api = api,
      _cache = cache,
      _scope = scope;

  static const Duration _catalogueTtl = Duration(hours: 12);

  final ApiClient _api;
  final CacheStore _cache;
  final UserScope _scope;

  String get _owner => _scope.cacheOwner;

  @override
  Future<ExamPage> list(ExamFilter filter, {int limit = Limits.pageSize, int skip = 0}) async {
    final Map<String, dynamic> query = filter.toQuery(limit: limit, skip: skip);
    final String key = _listKey(query);
    try {
      final ExamPage page = _pageFrom(await _api.getJson(ApiPaths.exams, query: query), limit, skip);
      await _cache.put(_owner, key, <String, Object?>{
        'items': page.items.map(_summaryJson).toList(growable: false),
        'total': page.total,
        'limit': page.limit,
        'skip': page.skip,
      });
      return page;
    } on AppFailure catch (failure) {
      if (!failure.isOffline) rethrow;
      final CacheHit? hit = await _cache.read(_owner, key);
      if (hit == null) rethrow;
      return _pageFrom(Parse.map(hit.value), limit, skip);
    }
  }

  @override
  Future<ExamDetail> detail(String id) async {
    try {
      final ExamDetail detail = ExamDetail.fromJson(await _api.getJson(ApiPaths.exam(id)));
      await _cache.put(_owner, 'exams.detail.$id', _detailJson(detail));
      return detail;
    } on AppFailure catch (failure) {
      if (!failure.isOffline) rethrow;
      final CacheHit? hit = await _cache.read(_owner, 'exams.detail.$id');
      if (hit == null) rethrow;
      return ExamDetail.fromJson(Parse.map(hit.value));
    }
  }

  @override
  Future<UnlockRecord> unlock(String id) async {
    final UnlockRecord record = UnlockRecord.fromJson(await _api.postJson(ApiPaths.examUnlock(id)));
    await _cache.remove(_owner, 'exams.detail.$id');
    await _cache.remove(_owner, 'exams.keys.$id');
    return record;
  }

  @override
  Future<Map<String, AnswerKeyItem>> keys(String id) async {
    try {
      final Map<String, AnswerKeyItem> keys = _keysFrom(await _api.getJson(ApiPaths.examKeys(id)));
      await _cache.put(_owner, 'exams.keys.$id', <String, Object?>{
        'items': keys.values.map(_keyJson).toList(growable: false),
      }, sensitive: true);
      return keys;
    } on AppFailure catch (failure) {
      if (!failure.isOffline) rethrow;
      final CacheHit? hit = await _cache.read(_owner, 'exams.keys.$id');
      if (hit == null) rethrow;
      return _keysFrom(Parse.map(hit.value));
    }
  }

  @override
  Future<List<UnlockedExam>> myUnlocks() async {
    final Map<String, dynamic> body = await _api.getJson(ApiPaths.unlocks);
    return Parse.mapList(body['items'])
        .map(
          (Map<String, Object?> item) => UnlockedExam(
            examId: Parse.string(item['exam_id']),
            creditsSpent: Parse.integer(item['credits_spent']),
            unlockedAt: Parse.date(item['unlocked_at']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<CatalogueValues> catalogue() async {
    const String key = 'exams.catalogue';
    final CacheHit? cached = await _cache.read(_owner, key);
    if (cached != null && DateTime.now().difference(cached.updatedAt) < _catalogueTtl) {
      return _catalogueFrom(Parse.map(cached.value));
    }
    try {
      final Map<String, dynamic> body = await _api.getJson(
        ApiPaths.exams,
        query: <String, dynamic>{'limit': Limits.cataloguePageSize, 'skip': 0},
      );
      final CatalogueValues values = _derive(_pageFrom(body, Limits.cataloguePageSize, 0).items);
      await _cache.put(_owner, key, <String, Object?>{
        'subjects': values.subjects,
        'class_levels': values.classLevels,
        'streams': values.streams,
        'sessions': values.sessions,
        'years': values.years,
      });
      return values;
    } on AppFailure catch (failure) {
      if (cached != null && failure.isOffline) return _catalogueFrom(Parse.map(cached.value));
      rethrow;
    }
  }

  ExamPage _pageFrom(Map<String, Object?> body, int limit, int skip) => ExamPage(
    items: Parse.mapList(body['items']).map(ExamSummary.fromJson).toList(growable: false),
    total: Parse.integer(body['total']),
    limit: Parse.integer(body['limit'], fallback: limit),
    skip: Parse.integer(body['skip'], fallback: skip),
  );

  Map<String, AnswerKeyItem> _keysFrom(Map<String, Object?> body) {
    final Iterable<AnswerKeyItem> items = Parse.mapList(body['items']).map(AnswerKeyItem.fromJson);
    return <String, AnswerKeyItem>{for (final AnswerKeyItem item in items) item.id: item};
  }

  String _listKey(Map<String, dynamic> query) =>
      'exams.list.${base64Url.encode(utf8.encode(jsonEncode(query)))}';

  CatalogueValues _derive(List<ExamSummary> items) {
    final Set<String> subjects = <String>{};
    final Set<String> levels = <String>{};
    final Set<String> streams = <String>{};
    final Set<String> sessions = <String>{};
    final Set<int> years = <int>{};
    for (final ExamSummary exam in items) {
      if (exam.subject.isNotEmpty) subjects.add(exam.subject);
      if (exam.classLevel.isNotEmpty) levels.add(exam.classLevel);
      final String? stream = exam.stream;
      if (stream != null && stream.isNotEmpty) streams.add(stream);
      if (exam.session.isNotEmpty) sessions.add(exam.session);
      if (exam.examYear > 0) years.add(exam.examYear);
    }
    final List<int> sortedYears = years.toList()..sort((int a, int b) => b.compareTo(a));
    return CatalogueValues(
      subjects: subjects.toList()..sort(),
      classLevels: levels.toList()..sort(),
      streams: streams.toList()..sort(),
      sessions: sessions.toList()..sort(),
      years: sortedYears,
    );
  }

  CatalogueValues _catalogueFrom(Map<String, Object?> data) => CatalogueValues(
    subjects: Parse.stringList(data['subjects']),
    classLevels: Parse.stringList(data['class_levels']),
    streams: Parse.stringList(data['streams']),
    sessions: Parse.stringList(data['sessions']),
    years: Parse.list(data['years']).map((Object? value) => Parse.integer(value)).toList(growable: false),
  );

  Map<String, Object?> _summaryJson(ExamSummary exam) => <String, Object?>{
    'id': exam.id,
    'exam_key': exam.examKey,
    'exam_year': exam.examYear,
    'session': exam.session,
    'class_level': exam.classLevel,
    'stream': exam.stream,
    'subject': exam.subject,
    'language': exam.language,
    'duration_minutes': exam.durationMinutes,
    'total_marks': exam.totalMarks,
    'question_count': exam.questionCount,
    'leaf_question_count': exam.leafQuestionCount,
    'is_free': exam.isFree,
    'unlock_cost': exam.unlockCost,
    'practice_enabled': exam.practiceEnabled,
    'status': exam.status,
    'published_at': exam.publishedAt?.toIso8601String(),
  };

  Map<String, Object?> _detailJson(ExamDetail detail) => <String, Object?>{
    ..._summaryJson(detail.summary),
    'instructions': detail.instructions,
    'unlocked': detail.unlocked,
    'unlock_cost': detail.unlockCost,
    'stimuli': detail.stimuli
        .map(
          (Stimulus stimulus) => <String, Object?>{
            'id': stimulus.id,
            'kind': stimulus.kind,
            'title': stimulus.title,
            'text': stimulus.text,
            'sort_order': stimulus.sortOrder,
          },
        )
        .toList(growable: false),
    'questions': detail.questions.map(_questionJson).toList(growable: false),
  };

  Map<String, Object?> _questionJson(Question question) => <String, Object?>{
    'id': question.id,
    'parent_id': question.parentId,
    'path': question.path,
    'type': question.type,
    'stimulus_id': question.stimulusId,
    'text': question.text,
    'options': question.options,
    'marks': question.marks,
    'sort_order': question.sortOrder,
    'difficulty': question.difficulty,
    'access': question.access,
    'practice_eligible': question.practiceEligible,
    'key_status': question.keyStatus,
    'marking_method': question.markingMethod,
    'is_container': question.isContainer,
    'children_count': question.childrenCount,
    'key': question.rawKey,
    'accepted_alternatives': question.acceptedAlternatives,
    'explanation': question.explanation,
    'model_answer': question.modelAnswer,
  };

  Map<String, Object?> _keyJson(AnswerKeyItem item) => <String, Object?>{
    'id': item.id,
    'path': item.path,
    'key': item.key,
    'explanation': item.explanation,
    'criteria': item.criteria,
    'model_answer': item.modelAnswer,
  };
}
