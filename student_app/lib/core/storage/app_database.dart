/// Local cache: per-user JSON blobs, answer drafts, submitted answer text and
/// the offline answer queue. Everything is wiped on logout.
library;

import 'package:drift/drift.dart';

import 'connection.dart';

part 'app_database.g.dart';

class CacheEntries extends Table {
  TextColumn get userId => text()();
  TextColumn get key => text()();
  TextColumn get payload => text()();
  IntColumn get updatedAt => integer()();
  BoolColumn get encrypted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{userId, key};
}

class AnswerDrafts extends Table {
  TextColumn get userId => text()();
  TextColumn get attemptId => text()();
  TextColumn get questionId => text()();
  TextColumn get payload => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{userId, attemptId, questionId};
}

/// The API never returns the answer text, so the client keeps its own copy.
class SubmittedAnswers extends Table {
  TextColumn get userId => text()();
  TextColumn get attemptId => text()();
  TextColumn get questionId => text()();
  TextColumn get payload => text()();
  TextColumn get markingStatus => text()();
  BoolColumn get correct => boolean().nullable()();
  RealColumn get awardedMarks => real().nullable()();
  IntColumn get attemptsCount => integer().withDefault(const Constant(0))();
  IntColumn get answeredAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{userId, attemptId, questionId};
}

@TableIndex(name: 'pending_by_user', columns: <Object>{#userId, #attemptId})
class PendingAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get attemptId => text()();
  TextColumn get questionId => text()();
  TextColumn get payload => text()();
  IntColumn get createdAt => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

@DriftDatabase(tables: <Type>[CacheEntries, AnswerDrafts, SubmittedAnswers, PendingAnswers])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open() : super(openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> wipeUser(String userId) async {
    await (delete(cacheEntries)..where((CacheEntries row) => row.userId.equals(userId))).go();
    await (delete(answerDrafts)..where((AnswerDrafts row) => row.userId.equals(userId))).go();
    await (delete(submittedAnswers)..where((SubmittedAnswers row) => row.userId.equals(userId))).go();
    await (delete(pendingAnswers)..where((PendingAnswers row) => row.userId.equals(userId))).go();
  }

  Future<void> wipeAll() async {
    await delete(cacheEntries).go();
    await delete(answerDrafts).go();
    await delete(submittedAnswers).go();
    await delete(pendingAnswers).go();
  }
}