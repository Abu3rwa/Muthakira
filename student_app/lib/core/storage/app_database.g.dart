// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CacheEntriesTable extends CacheEntries
    with TableInfo<$CacheEntriesTable, CacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedMeta = const VerificationMeta(
    'encrypted',
  );
  @override
  late final GeneratedColumn<bool> encrypted = GeneratedColumn<bool>(
    'encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("encrypted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    key,
    payload,
    updatedAt,
    encrypted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('encrypted')) {
      context.handle(
        _encryptedMeta,
        encrypted.isAcceptableOrUnknown(data['encrypted']!, _encryptedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, key};
  @override
  CacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheEntry(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      encrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}encrypted'],
      )!,
    );
  }

  @override
  $CacheEntriesTable createAlias(String alias) {
    return $CacheEntriesTable(attachedDatabase, alias);
  }
}

class CacheEntry extends DataClass implements Insertable<CacheEntry> {
  final String userId;
  final String key;
  final String payload;
  final int updatedAt;
  final bool encrypted;
  const CacheEntry({
    required this.userId,
    required this.key,
    required this.payload,
    required this.updatedAt,
    required this.encrypted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<int>(updatedAt);
    map['encrypted'] = Variable<bool>(encrypted);
    return map;
  }

  CacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return CacheEntriesCompanion(
      userId: Value(userId),
      key: Value(key),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      encrypted: Value(encrypted),
    );
  }

  factory CacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheEntry(
      userId: serializer.fromJson<String>(json['userId']),
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      encrypted: serializer.fromJson<bool>(json['encrypted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'encrypted': serializer.toJson<bool>(encrypted),
    };
  }

  CacheEntry copyWith({
    String? userId,
    String? key,
    String? payload,
    int? updatedAt,
    bool? encrypted,
  }) => CacheEntry(
    userId: userId ?? this.userId,
    key: key ?? this.key,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
    encrypted: encrypted ?? this.encrypted,
  );
  CacheEntry copyWithCompanion(CacheEntriesCompanion data) {
    return CacheEntry(
      userId: data.userId.present ? data.userId.value : this.userId,
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      encrypted: data.encrypted.present ? data.encrypted.value : this.encrypted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntry(')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('encrypted: $encrypted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, key, payload, updatedAt, encrypted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheEntry &&
          other.userId == this.userId &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.encrypted == this.encrypted);
}

class CacheEntriesCompanion extends UpdateCompanion<CacheEntry> {
  final Value<String> userId;
  final Value<String> key;
  final Value<String> payload;
  final Value<int> updatedAt;
  final Value<bool> encrypted;
  final Value<int> rowid;
  const CacheEntriesCompanion({
    this.userId = const Value.absent(),
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.encrypted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheEntriesCompanion.insert({
    required String userId,
    required String key,
    required String payload,
    required int updatedAt,
    this.encrypted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       key = Value(key),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<CacheEntry> custom({
    Expression<String>? userId,
    Expression<String>? key,
    Expression<String>? payload,
    Expression<int>? updatedAt,
    Expression<bool>? encrypted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (encrypted != null) 'encrypted': encrypted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheEntriesCompanion copyWith({
    Value<String>? userId,
    Value<String>? key,
    Value<String>? payload,
    Value<int>? updatedAt,
    Value<bool>? encrypted,
    Value<int>? rowid,
  }) {
    return CacheEntriesCompanion(
      userId: userId ?? this.userId,
      key: key ?? this.key,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      encrypted: encrypted ?? this.encrypted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (encrypted.present) {
      map['encrypted'] = Variable<bool>(encrypted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntriesCompanion(')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('encrypted: $encrypted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnswerDraftsTable extends AnswerDrafts
    with TableInfo<$AnswerDraftsTable, AnswerDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnswerDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    attemptId,
    questionId,
    payload,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'answer_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnswerDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, attemptId, questionId};
  @override
  AnswerDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnswerDraft(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AnswerDraftsTable createAlias(String alias) {
    return $AnswerDraftsTable(attachedDatabase, alias);
  }
}

class AnswerDraft extends DataClass implements Insertable<AnswerDraft> {
  final String userId;
  final String attemptId;
  final String questionId;
  final String payload;
  final int updatedAt;
  const AnswerDraft({
    required this.userId,
    required this.attemptId,
    required this.questionId,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['attempt_id'] = Variable<String>(attemptId);
    map['question_id'] = Variable<String>(questionId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AnswerDraftsCompanion toCompanion(bool nullToAbsent) {
    return AnswerDraftsCompanion(
      userId: Value(userId),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnswerDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnswerDraft(
      userId: serializer.fromJson<String>(json['userId']),
      attemptId: serializer.fromJson<String>(json['attemptId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'attemptId': serializer.toJson<String>(attemptId),
      'questionId': serializer.toJson<String>(questionId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AnswerDraft copyWith({
    String? userId,
    String? attemptId,
    String? questionId,
    String? payload,
    int? updatedAt,
  }) => AnswerDraft(
    userId: userId ?? this.userId,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AnswerDraft copyWithCompanion(AnswerDraftsCompanion data) {
    return AnswerDraft(
      userId: data.userId.present ? data.userId.value : this.userId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnswerDraft(')
          ..write('userId: $userId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, attemptId, questionId, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnswerDraft &&
          other.userId == this.userId &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class AnswerDraftsCompanion extends UpdateCompanion<AnswerDraft> {
  final Value<String> userId;
  final Value<String> attemptId;
  final Value<String> questionId;
  final Value<String> payload;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AnswerDraftsCompanion({
    this.userId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnswerDraftsCompanion.insert({
    required String userId,
    required String attemptId,
    required String questionId,
    required String payload,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       attemptId = Value(attemptId),
       questionId = Value(questionId),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<AnswerDraft> custom({
    Expression<String>? userId,
    Expression<String>? attemptId,
    Expression<String>? questionId,
    Expression<String>? payload,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnswerDraftsCompanion copyWith({
    Value<String>? userId,
    Value<String>? attemptId,
    Value<String>? questionId,
    Value<String>? payload,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AnswerDraftsCompanion(
      userId: userId ?? this.userId,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnswerDraftsCompanion(')
          ..write('userId: $userId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubmittedAnswersTable extends SubmittedAnswers
    with TableInfo<$SubmittedAnswersTable, SubmittedAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubmittedAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markingStatusMeta = const VerificationMeta(
    'markingStatus',
  );
  @override
  late final GeneratedColumn<String> markingStatus = GeneratedColumn<String>(
    'marking_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _awardedMarksMeta = const VerificationMeta(
    'awardedMarks',
  );
  @override
  late final GeneratedColumn<double> awardedMarks = GeneratedColumn<double>(
    'awarded_marks',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsCountMeta = const VerificationMeta(
    'attemptsCount',
  );
  @override
  late final GeneratedColumn<int> attemptsCount = GeneratedColumn<int>(
    'attempts_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    attemptId,
    questionId,
    payload,
    markingStatus,
    correct,
    awardedMarks,
    attemptsCount,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submitted_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubmittedAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('marking_status')) {
      context.handle(
        _markingStatusMeta,
        markingStatus.isAcceptableOrUnknown(
          data['marking_status']!,
          _markingStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markingStatusMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('awarded_marks')) {
      context.handle(
        _awardedMarksMeta,
        awardedMarks.isAcceptableOrUnknown(
          data['awarded_marks']!,
          _awardedMarksMeta,
        ),
      );
    }
    if (data.containsKey('attempts_count')) {
      context.handle(
        _attemptsCountMeta,
        attemptsCount.isAcceptableOrUnknown(
          data['attempts_count']!,
          _attemptsCountMeta,
        ),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, attemptId, questionId};
  @override
  SubmittedAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubmittedAnswer(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      markingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marking_status'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      ),
      awardedMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}awarded_marks'],
      ),
      attemptsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts_count'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $SubmittedAnswersTable createAlias(String alias) {
    return $SubmittedAnswersTable(attachedDatabase, alias);
  }
}

class SubmittedAnswer extends DataClass implements Insertable<SubmittedAnswer> {
  final String userId;
  final String attemptId;
  final String questionId;
  final String payload;
  final String markingStatus;
  final bool? correct;
  final double? awardedMarks;
  final int attemptsCount;
  final int answeredAt;
  const SubmittedAnswer({
    required this.userId,
    required this.attemptId,
    required this.questionId,
    required this.payload,
    required this.markingStatus,
    this.correct,
    this.awardedMarks,
    required this.attemptsCount,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['attempt_id'] = Variable<String>(attemptId);
    map['question_id'] = Variable<String>(questionId);
    map['payload'] = Variable<String>(payload);
    map['marking_status'] = Variable<String>(markingStatus);
    if (!nullToAbsent || correct != null) {
      map['correct'] = Variable<bool>(correct);
    }
    if (!nullToAbsent || awardedMarks != null) {
      map['awarded_marks'] = Variable<double>(awardedMarks);
    }
    map['attempts_count'] = Variable<int>(attemptsCount);
    map['answered_at'] = Variable<int>(answeredAt);
    return map;
  }

  SubmittedAnswersCompanion toCompanion(bool nullToAbsent) {
    return SubmittedAnswersCompanion(
      userId: Value(userId),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      payload: Value(payload),
      markingStatus: Value(markingStatus),
      correct: correct == null && nullToAbsent
          ? const Value.absent()
          : Value(correct),
      awardedMarks: awardedMarks == null && nullToAbsent
          ? const Value.absent()
          : Value(awardedMarks),
      attemptsCount: Value(attemptsCount),
      answeredAt: Value(answeredAt),
    );
  }

  factory SubmittedAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubmittedAnswer(
      userId: serializer.fromJson<String>(json['userId']),
      attemptId: serializer.fromJson<String>(json['attemptId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      payload: serializer.fromJson<String>(json['payload']),
      markingStatus: serializer.fromJson<String>(json['markingStatus']),
      correct: serializer.fromJson<bool?>(json['correct']),
      awardedMarks: serializer.fromJson<double?>(json['awardedMarks']),
      attemptsCount: serializer.fromJson<int>(json['attemptsCount']),
      answeredAt: serializer.fromJson<int>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'attemptId': serializer.toJson<String>(attemptId),
      'questionId': serializer.toJson<String>(questionId),
      'payload': serializer.toJson<String>(payload),
      'markingStatus': serializer.toJson<String>(markingStatus),
      'correct': serializer.toJson<bool?>(correct),
      'awardedMarks': serializer.toJson<double?>(awardedMarks),
      'attemptsCount': serializer.toJson<int>(attemptsCount),
      'answeredAt': serializer.toJson<int>(answeredAt),
    };
  }

  SubmittedAnswer copyWith({
    String? userId,
    String? attemptId,
    String? questionId,
    String? payload,
    String? markingStatus,
    Value<bool?> correct = const Value.absent(),
    Value<double?> awardedMarks = const Value.absent(),
    int? attemptsCount,
    int? answeredAt,
  }) => SubmittedAnswer(
    userId: userId ?? this.userId,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    payload: payload ?? this.payload,
    markingStatus: markingStatus ?? this.markingStatus,
    correct: correct.present ? correct.value : this.correct,
    awardedMarks: awardedMarks.present ? awardedMarks.value : this.awardedMarks,
    attemptsCount: attemptsCount ?? this.attemptsCount,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  SubmittedAnswer copyWithCompanion(SubmittedAnswersCompanion data) {
    return SubmittedAnswer(
      userId: data.userId.present ? data.userId.value : this.userId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      payload: data.payload.present ? data.payload.value : this.payload,
      markingStatus: data.markingStatus.present
          ? data.markingStatus.value
          : this.markingStatus,
      correct: data.correct.present ? data.correct.value : this.correct,
      awardedMarks: data.awardedMarks.present
          ? data.awardedMarks.value
          : this.awardedMarks,
      attemptsCount: data.attemptsCount.present
          ? data.attemptsCount.value
          : this.attemptsCount,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubmittedAnswer(')
          ..write('userId: $userId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('payload: $payload, ')
          ..write('markingStatus: $markingStatus, ')
          ..write('correct: $correct, ')
          ..write('awardedMarks: $awardedMarks, ')
          ..write('attemptsCount: $attemptsCount, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    attemptId,
    questionId,
    payload,
    markingStatus,
    correct,
    awardedMarks,
    attemptsCount,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubmittedAnswer &&
          other.userId == this.userId &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.payload == this.payload &&
          other.markingStatus == this.markingStatus &&
          other.correct == this.correct &&
          other.awardedMarks == this.awardedMarks &&
          other.attemptsCount == this.attemptsCount &&
          other.answeredAt == this.answeredAt);
}

class SubmittedAnswersCompanion extends UpdateCompanion<SubmittedAnswer> {
  final Value<String> userId;
  final Value<String> attemptId;
  final Value<String> questionId;
  final Value<String> payload;
  final Value<String> markingStatus;
  final Value<bool?> correct;
  final Value<double?> awardedMarks;
  final Value<int> attemptsCount;
  final Value<int> answeredAt;
  final Value<int> rowid;
  const SubmittedAnswersCompanion({
    this.userId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.payload = const Value.absent(),
    this.markingStatus = const Value.absent(),
    this.correct = const Value.absent(),
    this.awardedMarks = const Value.absent(),
    this.attemptsCount = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubmittedAnswersCompanion.insert({
    required String userId,
    required String attemptId,
    required String questionId,
    required String payload,
    required String markingStatus,
    this.correct = const Value.absent(),
    this.awardedMarks = const Value.absent(),
    this.attemptsCount = const Value.absent(),
    required int answeredAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       attemptId = Value(attemptId),
       questionId = Value(questionId),
       payload = Value(payload),
       markingStatus = Value(markingStatus),
       answeredAt = Value(answeredAt);
  static Insertable<SubmittedAnswer> custom({
    Expression<String>? userId,
    Expression<String>? attemptId,
    Expression<String>? questionId,
    Expression<String>? payload,
    Expression<String>? markingStatus,
    Expression<bool>? correct,
    Expression<double>? awardedMarks,
    Expression<int>? attemptsCount,
    Expression<int>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (payload != null) 'payload': payload,
      if (markingStatus != null) 'marking_status': markingStatus,
      if (correct != null) 'correct': correct,
      if (awardedMarks != null) 'awarded_marks': awardedMarks,
      if (attemptsCount != null) 'attempts_count': attemptsCount,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubmittedAnswersCompanion copyWith({
    Value<String>? userId,
    Value<String>? attemptId,
    Value<String>? questionId,
    Value<String>? payload,
    Value<String>? markingStatus,
    Value<bool?>? correct,
    Value<double?>? awardedMarks,
    Value<int>? attemptsCount,
    Value<int>? answeredAt,
    Value<int>? rowid,
  }) {
    return SubmittedAnswersCompanion(
      userId: userId ?? this.userId,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      payload: payload ?? this.payload,
      markingStatus: markingStatus ?? this.markingStatus,
      correct: correct ?? this.correct,
      awardedMarks: awardedMarks ?? this.awardedMarks,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (markingStatus.present) {
      map['marking_status'] = Variable<String>(markingStatus.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (awardedMarks.present) {
      map['awarded_marks'] = Variable<double>(awardedMarks.value);
    }
    if (attemptsCount.present) {
      map['attempts_count'] = Variable<int>(attemptsCount.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmittedAnswersCompanion(')
          ..write('userId: $userId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('payload: $payload, ')
          ..write('markingStatus: $markingStatus, ')
          ..write('correct: $correct, ')
          ..write('awardedMarks: $awardedMarks, ')
          ..write('attemptsCount: $attemptsCount, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingAnswersTable extends PendingAnswers
    with TableInfo<$PendingAnswersTable, PendingAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    attemptId,
    questionId,
    payload,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingAnswersTable createAlias(String alias) {
    return $PendingAnswersTable(attachedDatabase, alias);
  }
}

class PendingAnswer extends DataClass implements Insertable<PendingAnswer> {
  final int id;
  final String userId;
  final String attemptId;
  final String questionId;
  final String payload;
  final int createdAt;
  final int attempts;
  final String? lastError;
  const PendingAnswer({
    required this.id,
    required this.userId,
    required this.attemptId,
    required this.questionId,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['attempt_id'] = Variable<String>(attemptId);
    map['question_id'] = Variable<String>(questionId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<int>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingAnswersCompanion toCompanion(bool nullToAbsent) {
    return PendingAnswersCompanion(
      id: Value(id),
      userId: Value(userId),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingAnswer(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      attemptId: serializer.fromJson<String>(json['attemptId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'attemptId': serializer.toJson<String>(attemptId),
      'questionId': serializer.toJson<String>(questionId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingAnswer copyWith({
    int? id,
    String? userId,
    String? attemptId,
    String? questionId,
    String? payload,
    int? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => PendingAnswer(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingAnswer copyWithCompanion(PendingAnswersCompanion data) {
    return PendingAnswer(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingAnswer(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    attemptId,
    questionId,
    payload,
    createdAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingAnswer &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class PendingAnswersCompanion extends UpdateCompanion<PendingAnswer> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> attemptId;
  final Value<String> questionId;
  final Value<String> payload;
  final Value<int> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const PendingAnswersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingAnswersCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String attemptId,
    required String questionId,
    required String payload,
    required int createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : userId = Value(userId),
       attemptId = Value(attemptId),
       questionId = Value(questionId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PendingAnswer> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? attemptId,
    Expression<String>? questionId,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingAnswersCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? attemptId,
    Value<String>? questionId,
    Value<String>? payload,
    Value<int>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
  }) {
    return PendingAnswersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingAnswersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CacheEntriesTable cacheEntries = $CacheEntriesTable(this);
  late final $AnswerDraftsTable answerDrafts = $AnswerDraftsTable(this);
  late final $SubmittedAnswersTable submittedAnswers = $SubmittedAnswersTable(
    this,
  );
  late final $PendingAnswersTable pendingAnswers = $PendingAnswersTable(this);
  late final Index pendingByUser = Index(
    'pending_by_user',
    'CREATE INDEX pending_by_user ON pending_answers (user_id, attempt_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cacheEntries,
    answerDrafts,
    submittedAnswers,
    pendingAnswers,
    pendingByUser,
  ];
}

typedef $$CacheEntriesTableCreateCompanionBuilder =
    CacheEntriesCompanion Function({
      required String userId,
      required String key,
      required String payload,
      required int updatedAt,
      Value<bool> encrypted,
      Value<int> rowid,
    });
typedef $$CacheEntriesTableUpdateCompanionBuilder =
    CacheEntriesCompanion Function({
      Value<String> userId,
      Value<String> key,
      Value<String> payload,
      Value<int> updatedAt,
      Value<bool> encrypted,
      Value<int> rowid,
    });

class $$CacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get encrypted => $composableBuilder(
    column: $table.encrypted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get encrypted => $composableBuilder(
    column: $table.encrypted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get encrypted =>
      $composableBuilder(column: $table.encrypted, builder: (column) => column);
}

class $$CacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheEntriesTable,
          CacheEntry,
          $$CacheEntriesTableFilterComposer,
          $$CacheEntriesTableOrderingComposer,
          $$CacheEntriesTableAnnotationComposer,
          $$CacheEntriesTableCreateCompanionBuilder,
          $$CacheEntriesTableUpdateCompanionBuilder,
          (
            CacheEntry,
            BaseReferences<_$AppDatabase, $CacheEntriesTable, CacheEntry>,
          ),
          CacheEntry,
          PrefetchHooks Function()
        > {
  $$CacheEntriesTableTableManager(_$AppDatabase db, $CacheEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> encrypted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion(
                userId: userId,
                key: key,
                payload: payload,
                updatedAt: updatedAt,
                encrypted: encrypted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String key,
                required String payload,
                required int updatedAt,
                Value<bool> encrypted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion.insert(
                userId: userId,
                key: key,
                payload: payload,
                updatedAt: updatedAt,
                encrypted: encrypted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheEntriesTable,
      CacheEntry,
      $$CacheEntriesTableFilterComposer,
      $$CacheEntriesTableOrderingComposer,
      $$CacheEntriesTableAnnotationComposer,
      $$CacheEntriesTableCreateCompanionBuilder,
      $$CacheEntriesTableUpdateCompanionBuilder,
      (
        CacheEntry,
        BaseReferences<_$AppDatabase, $CacheEntriesTable, CacheEntry>,
      ),
      CacheEntry,
      PrefetchHooks Function()
    >;
typedef $$AnswerDraftsTableCreateCompanionBuilder =
    AnswerDraftsCompanion Function({
      required String userId,
      required String attemptId,
      required String questionId,
      required String payload,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AnswerDraftsTableUpdateCompanionBuilder =
    AnswerDraftsCompanion Function({
      Value<String> userId,
      Value<String> attemptId,
      Value<String> questionId,
      Value<String> payload,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AnswerDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $AnswerDraftsTable> {
  $$AnswerDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnswerDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnswerDraftsTable> {
  $$AnswerDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnswerDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnswerDraftsTable> {
  $$AnswerDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AnswerDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnswerDraftsTable,
          AnswerDraft,
          $$AnswerDraftsTableFilterComposer,
          $$AnswerDraftsTableOrderingComposer,
          $$AnswerDraftsTableAnnotationComposer,
          $$AnswerDraftsTableCreateCompanionBuilder,
          $$AnswerDraftsTableUpdateCompanionBuilder,
          (
            AnswerDraft,
            BaseReferences<_$AppDatabase, $AnswerDraftsTable, AnswerDraft>,
          ),
          AnswerDraft,
          PrefetchHooks Function()
        > {
  $$AnswerDraftsTableTableManager(_$AppDatabase db, $AnswerDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnswerDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnswerDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnswerDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> attemptId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnswerDraftsCompanion(
                userId: userId,
                attemptId: attemptId,
                questionId: questionId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String attemptId,
                required String questionId,
                required String payload,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AnswerDraftsCompanion.insert(
                userId: userId,
                attemptId: attemptId,
                questionId: questionId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnswerDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnswerDraftsTable,
      AnswerDraft,
      $$AnswerDraftsTableFilterComposer,
      $$AnswerDraftsTableOrderingComposer,
      $$AnswerDraftsTableAnnotationComposer,
      $$AnswerDraftsTableCreateCompanionBuilder,
      $$AnswerDraftsTableUpdateCompanionBuilder,
      (
        AnswerDraft,
        BaseReferences<_$AppDatabase, $AnswerDraftsTable, AnswerDraft>,
      ),
      AnswerDraft,
      PrefetchHooks Function()
    >;
typedef $$SubmittedAnswersTableCreateCompanionBuilder =
    SubmittedAnswersCompanion Function({
      required String userId,
      required String attemptId,
      required String questionId,
      required String payload,
      required String markingStatus,
      Value<bool?> correct,
      Value<double?> awardedMarks,
      Value<int> attemptsCount,
      required int answeredAt,
      Value<int> rowid,
    });
typedef $$SubmittedAnswersTableUpdateCompanionBuilder =
    SubmittedAnswersCompanion Function({
      Value<String> userId,
      Value<String> attemptId,
      Value<String> questionId,
      Value<String> payload,
      Value<String> markingStatus,
      Value<bool?> correct,
      Value<double?> awardedMarks,
      Value<int> attemptsCount,
      Value<int> answeredAt,
      Value<int> rowid,
    });

class $$SubmittedAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $SubmittedAnswersTable> {
  $$SubmittedAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markingStatus => $composableBuilder(
    column: $table.markingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get awardedMarks => $composableBuilder(
    column: $table.awardedMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubmittedAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $SubmittedAnswersTable> {
  $$SubmittedAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markingStatus => $composableBuilder(
    column: $table.markingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get awardedMarks => $composableBuilder(
    column: $table.awardedMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubmittedAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubmittedAnswersTable> {
  $$SubmittedAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get markingStatus => $composableBuilder(
    column: $table.markingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<double> get awardedMarks => $composableBuilder(
    column: $table.awardedMarks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptsCount => $composableBuilder(
    column: $table.attemptsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );
}

class $$SubmittedAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubmittedAnswersTable,
          SubmittedAnswer,
          $$SubmittedAnswersTableFilterComposer,
          $$SubmittedAnswersTableOrderingComposer,
          $$SubmittedAnswersTableAnnotationComposer,
          $$SubmittedAnswersTableCreateCompanionBuilder,
          $$SubmittedAnswersTableUpdateCompanionBuilder,
          (
            SubmittedAnswer,
            BaseReferences<
              _$AppDatabase,
              $SubmittedAnswersTable,
              SubmittedAnswer
            >,
          ),
          SubmittedAnswer,
          PrefetchHooks Function()
        > {
  $$SubmittedAnswersTableTableManager(
    _$AppDatabase db,
    $SubmittedAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubmittedAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubmittedAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubmittedAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> attemptId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> markingStatus = const Value.absent(),
                Value<bool?> correct = const Value.absent(),
                Value<double?> awardedMarks = const Value.absent(),
                Value<int> attemptsCount = const Value.absent(),
                Value<int> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubmittedAnswersCompanion(
                userId: userId,
                attemptId: attemptId,
                questionId: questionId,
                payload: payload,
                markingStatus: markingStatus,
                correct: correct,
                awardedMarks: awardedMarks,
                attemptsCount: attemptsCount,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String attemptId,
                required String questionId,
                required String payload,
                required String markingStatus,
                Value<bool?> correct = const Value.absent(),
                Value<double?> awardedMarks = const Value.absent(),
                Value<int> attemptsCount = const Value.absent(),
                required int answeredAt,
                Value<int> rowid = const Value.absent(),
              }) => SubmittedAnswersCompanion.insert(
                userId: userId,
                attemptId: attemptId,
                questionId: questionId,
                payload: payload,
                markingStatus: markingStatus,
                correct: correct,
                awardedMarks: awardedMarks,
                attemptsCount: attemptsCount,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubmittedAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubmittedAnswersTable,
      SubmittedAnswer,
      $$SubmittedAnswersTableFilterComposer,
      $$SubmittedAnswersTableOrderingComposer,
      $$SubmittedAnswersTableAnnotationComposer,
      $$SubmittedAnswersTableCreateCompanionBuilder,
      $$SubmittedAnswersTableUpdateCompanionBuilder,
      (
        SubmittedAnswer,
        BaseReferences<_$AppDatabase, $SubmittedAnswersTable, SubmittedAnswer>,
      ),
      SubmittedAnswer,
      PrefetchHooks Function()
    >;
typedef $$PendingAnswersTableCreateCompanionBuilder =
    PendingAnswersCompanion Function({
      Value<int> id,
      required String userId,
      required String attemptId,
      required String questionId,
      required String payload,
      required int createdAt,
      Value<int> attempts,
      Value<String?> lastError,
    });
typedef $$PendingAnswersTableUpdateCompanionBuilder =
    PendingAnswersCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> attemptId,
      Value<String> questionId,
      Value<String> payload,
      Value<int> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
    });

class $$PendingAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $PendingAnswersTable> {
  $$PendingAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingAnswersTable> {
  $$PendingAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingAnswersTable> {
  $$PendingAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingAnswersTable,
          PendingAnswer,
          $$PendingAnswersTableFilterComposer,
          $$PendingAnswersTableOrderingComposer,
          $$PendingAnswersTableAnnotationComposer,
          $$PendingAnswersTableCreateCompanionBuilder,
          $$PendingAnswersTableUpdateCompanionBuilder,
          (
            PendingAnswer,
            BaseReferences<_$AppDatabase, $PendingAnswersTable, PendingAnswer>,
          ),
          PendingAnswer,
          PrefetchHooks Function()
        > {
  $$PendingAnswersTableTableManager(
    _$AppDatabase db,
    $PendingAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> attemptId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingAnswersCompanion(
                id: id,
                userId: userId,
                attemptId: attemptId,
                questionId: questionId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String attemptId,
                required String questionId,
                required String payload,
                required int createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PendingAnswersCompanion.insert(
                id: id,
                userId: userId,
                attemptId: attemptId,
                questionId: questionId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingAnswersTable,
      PendingAnswer,
      $$PendingAnswersTableFilterComposer,
      $$PendingAnswersTableOrderingComposer,
      $$PendingAnswersTableAnnotationComposer,
      $$PendingAnswersTableCreateCompanionBuilder,
      $$PendingAnswersTableUpdateCompanionBuilder,
      (
        PendingAnswer,
        BaseReferences<_$AppDatabase, $PendingAnswersTable, PendingAnswer>,
      ),
      PendingAnswer,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CacheEntriesTableTableManager get cacheEntries =>
      $$CacheEntriesTableTableManager(_db, _db.cacheEntries);
  $$AnswerDraftsTableTableManager get answerDrafts =>
      $$AnswerDraftsTableTableManager(_db, _db.answerDrafts);
  $$SubmittedAnswersTableTableManager get submittedAnswers =>
      $$SubmittedAnswersTableTableManager(_db, _db.submittedAnswers);
  $$PendingAnswersTableTableManager get pendingAnswers =>
      $$PendingAnswersTableTableManager(_db, _db.pendingAnswers);
}
