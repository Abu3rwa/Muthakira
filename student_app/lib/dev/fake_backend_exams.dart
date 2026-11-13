part of 'fake_backend.dart';

extension _FakeExamRoutes on FakeBackend {
  FakeReply _exams(RequestOptions options, String method, List<String> segments) {
  if (segments.length == 1) {
    if (method != 'GET') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    return FakeReply.json(200, _examPage(options.queryParameters));
  }
  if (segments[1] == 'unlocks') {
    if (method != 'GET') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    return FakeReply.json(200, <String, Object?>{
      'items': store.unlocks.entries
          .map(
            (MapEntry<String, Map<String, Object?>> entry) => <String, Object?>{
              'exam_id': entry.key,
              'credits_spent': entry.value['credits_spent'],
              'unlocked_at': entry.value['unlocked_at'],
            },
          )
          .toList(growable: false),
    });
  }
  final String examId = segments[1];
  final FakeExam? exam = store.exams[examId];
  if (exam == null) throw const _FakeHttpError(404, ErrorCodes.examNotFound, 'Exam not found');
  if (segments.length == 2) {
    if (method != 'GET') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    return FakeReply.json(200, _examDetail(exam));
  }
  switch (segments[2]) {
    case 'keys':
      if (method != 'GET') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      if (!_canOpen(exam)) {
        throw const _FakeHttpError(402, ErrorCodes.examLocked, 'Unlock the paper to see its keys');
      }
      return FakeReply.json(200, <String, Object?>{'items': _keyItems(exam)});
    case 'unlock':
      if (method != 'POST') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      return FakeReply.json(200, _unlock(exam));
    default:
      throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
  }
}

Map<String, Object?> _examPage(Map<String, dynamic> query) {
  final String? language = _query(query, 'language');
  final String? subject = _query(query, 'subject');
  final String? classLevel = _query(query, 'class_level');
  final String? stream = _query(query, 'stream');
  final String? session = _query(query, 'session');
  final String? year = _query(query, 'exam_year');

  final List<FakeExam> filtered = <FakeExam>[];
  for (final FakeExam exam in store.exams.values) {
    final Map<String, Object?> summary = exam.summary;
    if (summary['status'] != 'published') continue;
    if (language != null && summary['language'] != language) continue;
    if (subject != null && summary['subject'] != subject) continue;
    if (classLevel != null && summary['class_level'] != classLevel) continue;
    if (session != null && summary['session'] != session) continue;
    if (year != null && summary['exam_year'].toString() != year) continue;
    if (stream != null && summary['stream'] != stream) continue;
    filtered.add(exam);
  }
  filtered.sort(
    (FakeExam left, FakeExam right) =>
        _string(right.summary['published_at']).compareTo(_string(left.summary['published_at'])),
  );

  final int limit = int.tryParse(_query(query, 'limit') ?? '') ?? 20;
  final int skip = int.tryParse(_query(query, 'skip') ?? '') ?? 0;
  final List<FakeExam> page = filtered.skip(skip).take(limit).toList(growable: false);
  return <String, Object?>{
    'items': page.map(_summaryJson).toList(growable: false),
    'total': filtered.length,
    'limit': limit,
    'skip': skip,
  };
}

String? _query(Map<String, dynamic> query, String key) {
  final Object? value = query[key];
  if (value == null) return null;
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<Map<String, Object?>> _leaves(FakeExam exam) =>
    exam.questions.where((Map<String, Object?> question) => question['is_container'] != true).toList(growable: false);

double _totalMarks(FakeExam exam) => _leaves(exam).fold<double>(
  0,
  (double sum, Map<String, Object?> question) => sum + ((question['marks'] as num?)?.toDouble() ?? 0),
);

int _unlockCost(FakeExam exam) {
  if (exam.summary['is_free'] == true) return 0;
  return (exam.summary['unlock_cost'] as num?)?.toInt() ?? 0;
}

bool _canOpen(FakeExam exam) =>
    exam.summary['is_free'] == true || store.unlocks.containsKey(exam.summary['id']);

Map<String, Object?> _summaryJson(FakeExam exam) => <String, Object?>{
  ...exam.summary,
  'total_marks': _totalMarks(exam),
  'question_count': _leaves(exam).length,
  'leaf_question_count': _leaves(exam).length,
  'unlock_cost': _unlockCost(exam),
};

Map<String, Object?> _examDetail(FakeExam exam) {
  final bool canOpen = _canOpen(exam);
  return <String, Object?>{
    ..._summaryJson(exam),
    'instructions': exam.instructions,
    'unlocked': canOpen,
    'unlock_cost': _unlockCost(exam),
    'stimuli': exam.stimuli,
    'questions': exam.questions
        .map((Map<String, Object?> question) => _visibleQuestion(question, canOpen))
        .toList(growable: false),
  };
}

/// Paid keys never leave the fake server before unlock; trial and free
/// questions keep theirs, exactly like the real API.
Map<String, Object?> _visibleQuestion(Map<String, Object?> question, bool canOpen) {
  final bool reveal = canOpen || question['access'] == 'trial' || question['access'] == 'free';
  if (reveal || question['is_container'] == true) {
    return Map<String, Object?>.of(question);
  }
  return <String, Object?>{
    ...question,
    'key': null,
    'explanation': null,
    'model_answer': null,
  };
}

List<Map<String, Object?>> _keyItems(FakeExam exam) => _leaves(exam)
    .where((Map<String, Object?> question) => question['key'] != null && question['key_status'] == 'approved')
    .map(
      (Map<String, Object?> question) => <String, Object?>{
        'id': question['id'],
        'path': question['path'],
        'key': question['key'],
        'explanation': question['explanation'],
        'criteria': const <String>[],
        'model_answer': question['model_answer'],
      },
    )
    .toList(growable: false);

Map<String, Object?> _unlock(FakeExam exam) {
  final String examId = _string(exam.summary['id']);
  final Map<String, Object?>? existing = store.unlocks[examId];
  if (existing != null) {
    return <String, Object?>{'unlock': existing, 'charged': false, 'cost': _unlockCost(exam)};
  }
  final int cost = _unlockCost(exam);
  if (cost > 0) {
    if (store.balance - store.reserved < cost) {
      throw const _FakeHttpError(402, ErrorCodes.insufficientCredits, 'Not enough credits');
    }
    store.balance -= cost;
    store.addLedger(
      type: 'exam_unlock',
      amount: -cost,
      lotId: examId,
      reason: 'فتح ${exam.summary['subject']}',
    );
  }
  final Map<String, Object?> record = <String, Object?>{
    'exam_id': examId,
    'credits_spent': cost,
    'unlocked_at': _iso(DateTime.now()),
  };
  store.unlocks[examId] = record;
  return <String, Object?>{'unlock': record, 'charged': cost > 0, 'cost': cost};
}

}
