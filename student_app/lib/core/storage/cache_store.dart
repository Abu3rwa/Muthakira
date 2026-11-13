/// Stale-while-revalidate JSON cache, scoped per user, with optional encryption
/// for sensitive payloads such as paid answer keys. Also owns answer drafts,
/// the local copy of submitted answers, and the offline answer queue.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';
import 'secret_box.dart';

class CacheHit {
  const CacheHit({required this.value, required this.updatedAt});

  final Object? value;
  final DateTime updatedAt;
}

class CacheStore {
  CacheStore(this._db, this._secrets);

  final AppDatabase _db;
  final SecretBox _secrets;

  Future<void> put(String userId, String key, Object? value, {bool sensitive = false}) async {
    final String encoded = jsonEncode(value);
    final String payload = sensitive ? await _secrets.seal(encoded) : encoded;
    await _db.into(_db.cacheEntries).insertOnConflictUpdate(
      CacheEntriesCompanion.insert(
        userId: userId,
        key: key,
        payload: payload,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        encrypted: Value<bool>(sensitive),
      ),
    );
  }

  Future<CacheHit?> read(String userId, String key) async {
    final CacheEntry? row = await (_db.select(_db.cacheEntries)
          ..where((CacheEntries entry) => entry.userId.equals(userId) & entry.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    try {
      final String decoded = row.encrypted ? await _secrets.open(row.payload) : row.payload;
      return CacheHit(value: jsonDecode(decoded), updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt));
    } on Object {
      await remove(userId, key);
      return null;
    }
  }

  Future<void> remove(String userId, String key) async {
    await (_db.delete(_db.cacheEntries)
          ..where((CacheEntries entry) => entry.userId.equals(userId) & entry.key.equals(key)))
        .go();
  }

  Future<void> removePrefix(String userId, String prefix) async {
    await (_db.delete(_db.cacheEntries)
          ..where((CacheEntries entry) => entry.userId.equals(userId) & entry.key.like('$prefix%')))
        .go();
  }

  Future<void> wipeUser(String userId) => _db.wipeUser(userId);

  // ---------------------------------------------------------------- drafts

  Future<void> saveDraft(String userId, String attemptId, String questionId, Object? answer) async {
    await _db.into(_db.answerDrafts).insertOnConflictUpdate(
      AnswerDraftsCompanion.insert(
        userId: userId,
        attemptId: attemptId,
        questionId: questionId,
        payload: jsonEncode(answer),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<Map<String, Object?>> loadDrafts(String userId, String attemptId) async {
    final List<AnswerDraft> rows = await (_db.select(_db.answerDrafts)
          ..where((AnswerDrafts row) => row.userId.equals(userId) & row.attemptId.equals(attemptId)))
        .get();
    return <String, Object?>{for (final AnswerDraft row in rows) row.questionId: _tryDecode(row.payload)};
  }

  Future<void> deleteDraft(String userId, String attemptId, String questionId) async {
    await (_db.delete(_db.answerDrafts)
          ..where(
            (AnswerDrafts row) =>
                row.userId.equals(userId) & row.attemptId.equals(attemptId) & row.questionId.equals(questionId),
          ))
        .go();
  }

  // ------------------------------------------------------------ submissions

  Future<void> saveSubmitted({
    required String userId,
    required String attemptId,
    required String questionId,
    required Object? answer,
    required String markingStatus,
    required bool? correct,
    required double? awardedMarks,
    required int attemptsCount,
    required DateTime answeredAt,
  }) async {
    await _db.into(_db.submittedAnswers).insertOnConflictUpdate(
      SubmittedAnswersCompanion.insert(
        userId: userId,
        attemptId: attemptId,
        questionId: questionId,
        payload: jsonEncode(answer),
        markingStatus: markingStatus,
        correct: Value<bool?>(correct),
        awardedMarks: Value<double?>(awardedMarks),
        attemptsCount: Value<int>(attemptsCount),
        answeredAt: answeredAt.millisecondsSinceEpoch,
      ),
    );
  }

  Future<Map<String, Object?>> loadSubmitted(String userId, String attemptId) async {
    final List<SubmittedAnswer> rows = await (_db.select(_db.submittedAnswers)
          ..where((SubmittedAnswers row) => row.userId.equals(userId) & row.attemptId.equals(attemptId)))
        .get();
    return <String, Object?>{
      for (final SubmittedAnswer row in rows)
        row.questionId: <String, Object?>{
          'answer': _tryDecode(row.payload),
          'marking_status': row.markingStatus,
          'correct': row.correct,
          'awarded_marks': row.awardedMarks,
          'attempts_count': row.attemptsCount,
          'answered_at': DateTime.fromMillisecondsSinceEpoch(row.answeredAt).toIso8601String(),
        },
    };
  }

  // ---------------------------------------------------------------- queue

  Future<void> enqueueAnswer({
    required String userId,
    required String attemptId,
    required String questionId,
    required Object? payload,
  }) async {
    final PendingAnswer? existing = await (_db.select(_db.pendingAnswers)
          ..where(
            (PendingAnswers row) =>
                row.userId.equals(userId) & row.attemptId.equals(attemptId) & row.questionId.equals(questionId),
          ))
        .getSingleOrNull();
    final String json = jsonEncode(payload);
    if (existing != null) {
      await (_db.update(_db.pendingAnswers)..where((PendingAnswers row) => row.id.equals(existing.id)))
          .write(PendingAnswersCompanion(payload: Value<String>(json)));
      return;
    }
    await _db.into(_db.pendingAnswers).insert(
      PendingAnswersCompanion.insert(
        userId: userId,
        attemptId: attemptId,
        questionId: questionId,
        payload: json,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<List<QueuedAnswer>> pendingAnswers(String userId) async {
    final List<PendingAnswer> rows = await (_db.select(_db.pendingAnswers)
          ..where((PendingAnswers row) => row.userId.equals(userId))
          ..orderBy(<OrderClauseGenerator<PendingAnswers>>[
            (PendingAnswers row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    return <QueuedAnswer>[
      for (final PendingAnswer row in rows)
        QueuedAnswer(
          id: row.id,
          attemptId: row.attemptId,
          questionId: row.questionId,
          payload: _tryDecode(row.payload),
          attempts: row.attempts,
        ),
    ];
  }

  Future<void> removePending(int id) async {
    await (_db.delete(_db.pendingAnswers)..where((PendingAnswers row) => row.id.equals(id))).go();
  }

  Future<void> markPendingFailed(int id, String error) async {
    final PendingAnswer? row = await (_db.select(_db.pendingAnswers)
          ..where((PendingAnswers item) => item.id.equals(id)))
        .getSingleOrNull();
    final int tries = (row?.attempts ?? 0) + 1;
    await (_db.update(_db.pendingAnswers)..where((PendingAnswers item) => item.id.equals(id))).write(
      PendingAnswersCompanion(attempts: Value<int>(tries), lastError: Value<String>(error)),
    );
  }

  static Object? _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return raw;
    }
  }
}

class QueuedAnswer {
  const QueuedAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.payload,
    required this.attempts,
  });

  final int id;
  final String attemptId;
  final String questionId;
  final Object? payload;
  final int attempts;
}
