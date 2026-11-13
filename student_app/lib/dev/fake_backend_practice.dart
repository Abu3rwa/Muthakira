part of 'fake_backend.dart';

class FakeAttemptState {
  FakeAttemptState({required this.id, required this.examId}) : startedAt = DateTime.now();

  final String id;
  final String examId;
  String status = 'open';
  DateTime startedAt;
  DateTime lastActivity = DateTime.now();
  DateTime? closedAt;
  final Map<String, Map<String, Object?>> records = <String, Map<String, Object?>>{};
}

extension _FakePracticeRoutes on FakeBackend {
  FakeReply _practice(RequestOptions options, String method, List<String> segments) {
  if (segments.length == 4 && segments[1] == 'answers' && segments[3] == 'ai-grade') {
    if (method != 'POST') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    return FakeReply.json(200, _aiGrade(segments[2]));
  }
  if (segments.length == 4 && segments[1] == 'answers' && segments[3] == 'self-mark') {
    if (method != 'POST') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    return FakeReply.json(200, _selfMark(segments[2], _body(options)));
  }
  if (segments.length == 2 && segments[1] == 'attempts') {
    if (method != 'POST') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    return FakeReply.json(200, _startAttempt(_body(options)));
  }
  if (segments.length < 3 || segments[1] != 'attempts') {
    throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
  }
  final String attemptId = segments[2];
  final FakeAttemptState? attempt = store.attempts[attemptId];
  if (attempt == null) throw const _FakeHttpError(404, ErrorCodes.attemptNotFound, 'Attempt not found');
  if (segments.length == 3) {
    if (method != 'GET') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    return FakeReply.json(200, <String, Object?>{
      'attempt': _attemptJson(attempt),
      'answers': attempt.records.values.toList(growable: false),
    });
  }
  switch (segments[3]) {
    case 'next-question':
      if (method != 'GET') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      return FakeReply.json(200, _nextQuestion(attempt));
    case 'answers':
      if (method != 'POST') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      return FakeReply.json(200, _submitAnswer(attempt, _body(options)));
    case 'close':
      if (method != 'POST') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      if (attempt.status == 'open') {
        attempt
          ..status = 'closed'
          ..closedAt = DateTime.now();
      }
      return FakeReply.json(200, <String, Object?>{'attempt': _attemptJson(attempt)});
    default:
      throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
  }
}

Map<String, Object?> _startAttempt(Map<String, Object?> body) {
  final String examId = _string(body['examId']);
  final FakeExam? exam = store.exams[examId];
  if (exam == null) throw const _FakeHttpError(404, ErrorCodes.examNotFound, 'Exam not found');
  if (exam.summary['practice_enabled'] != true) {
    throw const _FakeHttpError(409, ErrorCodes.practiceDisabled, 'Practice is disabled for this paper');
  }
  if (!_canOpen(exam)) throw const _FakeHttpError(402, ErrorCodes.examLocked, 'Unlock the paper first');

  for (final FakeAttemptState attempt in store.attempts.values) {
    if (attempt.examId == examId && attempt.status == 'open') {
      return <String, Object?>{'attempt': _attemptJson(attempt), 'created': false};
    }
  }
  final FakeAttemptState created = FakeAttemptState(id: store.nextId('att'), examId: examId);
  store.attempts[created.id] = created;
  return <String, Object?>{'attempt': _attemptJson(created), 'created': true};
}

Map<String, Object?> _submitAnswer(FakeAttemptState attempt, Map<String, Object?> body) {
  if (attempt.status != 'open') {
    throw const _FakeHttpError(409, ErrorCodes.attemptClosed, 'This attempt is closed');
  }
  final FakeExam? exam = store.exams[attempt.examId];
  if (exam == null) throw const _FakeHttpError(404, ErrorCodes.examNotFound, 'Exam not found');
  final String questionId = _string(body['questionId']);
  Map<String, Object?>? question;
  for (final Map<String, Object?> candidate in exam.questions) {
    if (candidate['id'] == questionId) {
      question = candidate;
      break;
    }
  }
  if (question == null) throw const _FakeHttpError(404, ErrorCodes.questionNotFound, 'Question not found');
  if (question['is_container'] == true || question['practice_eligible'] != true) {
    throw const _FakeHttpError(409, ErrorCodes.questionNotAnswerable, 'This question cannot be answered');
  }
  if (!_canOpen(exam) && question['access'] != 'trial') {
    throw const _FakeHttpError(402, ErrorCodes.examLocked, 'Unlock the paper first');
  }

  final _Mark mark = _mark(question, body['answer']);
  final Map<String, Object?>? previous = attempt.records[questionId];
  final Map<String, Object?> record = <String, Object?>{
    'id': previous?['id'] ?? store.nextId('ans'),
    'question_id': questionId,
    'answer': body['answer'],
    'marking_status': mark.pending ? 'pending_ai' : 'marked',
    'marking_method': mark.pending ? 'ai_rubric' : 'auto',
    'correct': mark.correct,
    'awarded_marks': mark.awarded,
    'attempts_count': ((previous?['attempts_count'] as num?)?.toInt() ?? 0) + 1,
    'answered_at': _iso(DateTime.now()),
    'ai_inflight': false,
  };
  attempt
    ..records[questionId] = record
    ..lastActivity = DateTime.now();

  final bool reveal = _canOpen(exam) || question['access'] == 'trial' || question['access'] == 'free';
  return <String, Object?>{
    'answer': record,
    'feedback': <String, Object?>{
      'pending': mark.pending,
      'marking_status': mark.pending ? 'pending_ai' : 'marked',
      'correct': mark.correct,
      'awarded_marks': mark.awarded,
      'key': reveal ? question['key'] : null,
      'explanation': reveal ? question['explanation'] : null,
    },
    'attempt': _attemptJson(attempt),
  };
}

Map<String, Object?> _attemptJson(FakeAttemptState attempt) {
  var correctCount = 0;
  var awarded = 0.0;
  for (final Map<String, Object?> record in attempt.records.values) {
    if (record['correct'] == true) correctCount += 1;
    awarded += (record['awarded_marks'] as num?)?.toDouble() ?? 0;
  }
  return <String, Object?>{
    'id': attempt.id,
    'exam_id': attempt.examId,
    'status': attempt.status,
    'answers_count': attempt.records.length,
    'correct_count': correctCount,
    'awarded_marks': awarded,
    'started_at': _iso(attempt.startedAt),
    'last_activity_at': _iso(attempt.lastActivity),
    'closed_at': attempt.closedAt == null ? null : _iso(attempt.closedAt!),
  };
}

Map<String, Object?> _nextQuestion(FakeAttemptState attempt) {
  if (attempt.status != 'open') {
    throw const _FakeHttpError(409, ErrorCodes.attemptClosed, 'This attempt is closed');
  }
  final FakeExam? exam = store.exams[attempt.examId];
  if (exam == null) throw const _FakeHttpError(404, ErrorCodes.examNotFound, 'Exam not found');
  final bool open = _canOpen(exam);
  final List<Map<String, Object?>> candidates = exam.questions
      .where((Map<String, Object?> question) =>
          question['is_container'] != true &&
          (open || question['access'] == 'trial' || question['access'] == 'free'))
      .toList(growable: false);
  final List<Map<String, Object?>> remaining = candidates
      .where((Map<String, Object?> question) => !attempt.records.containsKey(question['id']))
      .toList(growable: false);
  if (remaining.isEmpty) {
    return <String, Object?>{
      'question': null,
      'reason_code': candidates.isEmpty ? 'no_access' : 'exhausted',
      'remaining_count': 0,
    };
  }
  final Map<String, Object?> question = remaining.first;
  Map<String, Object?>? stimulus;
  for (final Map<String, Object?> candidate in exam.stimuli) {
    if (candidate['id'] == question['stimulus_id']) {
      stimulus = <String, Object?>{
        'id': candidate['id'],
        'kind': candidate['kind'],
        'title': candidate['title'],
        'text': candidate['text'],
      };
      break;
    }
  }
  return <String, Object?>{
    'question': <String, Object?>{
      'id': question['id'],
      'path': question['path'],
      'type': question['type'],
      'text': question['text'],
      'options': question['options'] ?? const <String>[],
      'marks': question['marks'],
      'difficulty': question['difficulty'] ?? 3,
      'topic_keys': const <String>[],
      'stimulus': stimulus,
    },
    'reason_code': 'level_match',
    'target_difficulty': 3,
    'ability': 0.5,
    'remaining_count': remaining.length,
  };
}

Map<String, Object?> _selfMark(String answerId, Map<String, Object?> body) {
  for (final FakeAttemptState attempt in store.attempts.values) {
    for (final Map<String, Object?> record in attempt.records.values) {
      if (record['id'] != answerId) continue;
      if (record['marking_status'] != 'pending_self') {
        throw const _FakeHttpError(409, ErrorCodes.notAiMarkable, 'This answer is not waiting for self marking');
      }
      final FakeExam? exam = store.exams[attempt.examId];
      double marks = 1;
      Map<String, Object?>? question;
      for (final Map<String, Object?> candidate in exam?.questions ?? const <Map<String, Object?>>[]) {
        if (candidate['id'] == record['question_id']) {
          question = candidate;
          marks = (candidate['marks'] as num?)?.toDouble() ?? 1;
        }
      }
      final double awarded = ((body['awarded_marks'] as num?)?.toDouble() ?? 0).clamp(0, marks).toDouble();
      final bool correct = awarded >= marks;
      record
        ..['marking_status'] = 'marked'
        ..['marking_method'] = 'self_mark'
        ..['correct'] = correct
        ..['awarded_marks'] = awarded;
      return <String, Object?>{
        'answer': record,
        'feedback': <String, Object?>{
          'correct': correct,
          'awarded_marks': awarded,
          'key': question?['key'],
          'explanation': question?['explanation'],
          'model_answer': question?['model_answer'],
        },
        'attempt': _attemptJson(attempt),
      };
    }
  }
  throw const _FakeHttpError(404, ErrorCodes.answerNotFound, 'Answer not found');
}

Map<String, Object?> _aiGrade(String answerId) {
  for (final FakeAttemptState attempt in store.attempts.values) {
    for (final Map<String, Object?> record in attempt.records.values) {
      if (record['id'] != answerId) continue;
      if (record['marking_status'] == 'marked') {
        // Server parity: an AI-marked answer replays its stored result for free.
        if (record['marking_method'] == 'ai_rubric') {
          return <String, Object?>{
            'status': 'marked',
            'awarded_marks': record['awarded_marks'],
            'correct': record['correct'],
            'feedback': record['ai_feedback'] ?? '',
            'missing_points': record['ai_missing_points'] ?? const <String>[],
            'credits_charged': 0,
            'replayed': true,
          };
        }
        throw const _FakeHttpError(409, ErrorCodes.answerAlreadyMarked, 'This answer is already marked');
      }
      if (record['marking_status'] != 'pending_ai') {
        throw const _FakeHttpError(409, ErrorCodes.notAiMarkable, 'This answer is not waiting for AI marking');
      }
      if (store.balance - store.reserved < 1) {
        throw const _FakeHttpError(402, ErrorCodes.insufficientCredits, 'Not enough credits');
      }
      final FakeExam? exam = store.exams[attempt.examId];
      double marks = 1;
      for (final Map<String, Object?> question in exam?.questions ?? const <Map<String, Object?>>[]) {
        if (question['id'] == record['question_id']) marks = (question['marks'] as num?)?.toDouble() ?? 1;
      }
      store.balance -= 1;
      store.addLedger(type: 'ai_grading', amount: -1, reason: 'تصحيح بالذكاء الاصطناعي');
      final double awarded = marks * 0.75;
      const String feedback = 'إجابة قريبة من المطلوب، لكن ينقصها شرح المصطلح الأساسي.';
      const List<String> missing = <String>['اذكر التعريف بدقة', 'أضف مثالًا واحدًا'];
      final bool correct = awarded >= marks;
      record
        ..['marking_status'] = 'marked'
        ..['marking_method'] = 'ai_rubric'
        ..['correct'] = correct
        ..['awarded_marks'] = awarded
        ..['ai_feedback'] = feedback
        ..['ai_missing_points'] = missing
        ..['ai_inflight'] = false;
      return <String, Object?>{
        'status': 'marked',
        'awarded_marks': awarded,
        'correct': correct,
        'feedback': feedback,
        'missing_points': missing,
        'credits_charged': 1,
      };
    }
  }
  throw const _FakeHttpError(404, ErrorCodes.answerNotFound, 'Answer not found');
}

FakeReply _questions(RequestOptions options, String method, List<String> segments) {
  if (segments.length == 3 && segments[2] == 'report') {
    if (method != 'POST') throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    final String reason = _string(_body(options)['reason']);
    if (reason.length < 5) {
      throw const _FakeHttpError(422, ErrorCodes.validationError, 'Describe the problem briefly');
    }
    return FakeReply.json(200, <String, Object?>{
      'id': store.nextId('report'),
      'status': 'open',
      'reason': reason,
      'created_at': _iso(DateTime.now()),
    });
  }
  throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
  }
}

class _Mark {
  const _Mark.marked(this.correct, this.awarded) : pending = false;

  const _Mark.pending() : pending = true, correct = null, awarded = null;

  final bool pending;
  final bool? correct;
  final double? awarded;
}

_Mark _mark(Map<String, Object?> question, Object? answer) {
  final String type = question['type'] as String? ?? 'unknown';
  final Object? key = question['key'];
  final List<String> alternatives = (question['accepted_alternatives'] as List<Object?>?)
          ?.whereType<String>()
          .toList(growable: false) ??
      const <String>[];
  final double marks = (question['marks'] as num?)?.toDouble() ?? 0;

  switch (type) {
    case 'mcq' || 'matching_item':
      final bool correct = _normalize(answer) == _normalize(key);
      return _Mark.marked(correct, correct ? marks : 0);
    case 'true_false':
      final bool correct = answer is bool && key is bool && answer == key;
      return _Mark.marked(correct, correct ? marks : 0);
    case 'multi_select':
      final List<String> given = _normalizeList(answer)..sort();
      final List<String> expected = _normalizeList(key)..sort();
      final bool correct = _sameList(given, expected);
      return _Mark.marked(correct, correct ? marks : 0);
    case 'numeric' || 'math_expression':
      final double? given = double.tryParse(_normalize(answer));
      final double? expected = double.tryParse(_normalize(key));
      final bool correct = given != null && expected != null && (given - expected).abs() < 0.001;
      return _Mark.marked(correct, correct ? marks : 0);
    case 'fill_blank':
      final List<String> given = _normalizeList(answer);
      final List<String> expected = _normalizeList(key);
      var correct = given.length == expected.length;
      if (correct) {
        for (var index = 0; index < expected.length; index += 1) {
          final String value = given[index];
          final bool matches = value == expected[index] ||
              alternatives.any((String alternative) => _normalize(alternative) == value);
          if (!matches) {
            correct = false;
            break;
          }
        }
      }
      return _Mark.marked(correct, correct ? marks : 0);
    case 'ordering':
      final List<String> given = _normalizeList(answer);
      final List<String> expected = _normalizeList(key);
      return _Mark.marked(_sameList(given, expected), _sameList(given, expected) ? marks : 0);
    default:
      return const _Mark.pending();
  }
}

List<String> _normalizeList(Object? value) {
  if (value is List) {
    return value.map(_normalize).toList(growable: true);
  }
  final String single = _normalize(value);
  return single.isEmpty ? <String>[] : <String>[single];
}

bool _sameList(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
