import 'exam_models.dart';

class ExamFilter {
  const ExamFilter({
    this.language,
    this.subject,
    this.classLevel,
    this.stream,
    this.session,
    this.examYear,
  });

  final String? language;
  final String? subject;
  final String? classLevel;
  final String? stream;
  final String? session;
  final int? examYear;

  Map<String, dynamic> toQuery({required int limit, required int skip}) => <String, dynamic>{
    if (language != null) 'language': language,
    if (subject != null) 'subject': subject,
    if (classLevel != null) 'class_level': classLevel,
    if (stream != null) 'stream': stream,
    if (session != null) 'session': session,
    if (examYear != null) 'exam_year': examYear,
    'limit': limit,
    'skip': skip,
  };

  ExamFilter copyWith({
    String? language,
    String? subject,
    String? classLevel,
    String? stream,
    String? session,
    int? examYear,
    bool clearSubject = false,
    bool clearClassLevel = false,
    bool clearStream = false,
    bool clearSession = false,
    bool clearYear = false,
  }) {
    return ExamFilter(
      language: language ?? this.language,
      subject: clearSubject ? null : (subject ?? this.subject),
      classLevel: clearClassLevel ? null : (classLevel ?? this.classLevel),
      stream: clearStream ? null : (stream ?? this.stream),
      session: clearSession ? null : (session ?? this.session),
      examYear: clearYear ? null : (examYear ?? this.examYear),
    );
  }

  bool get isEmpty =>
      subject == null && classLevel == null && stream == null && session == null && examYear == null;
}

class ExamPage {
  const ExamPage({required this.items, required this.total, required this.limit, required this.skip});

  final List<ExamSummary> items;
  final int total;
  final int limit;
  final int skip;

  bool get hasMore => skip + items.length < total;
}

class UnlockedExam {
  const UnlockedExam({required this.examId, required this.creditsSpent, this.unlockedAt});

  final String examId;
  final int creditsSpent;
  final DateTime? unlockedAt;
}

class CatalogueValues {
  const CatalogueValues({
    this.subjects = const <String>[],
    this.classLevels = const <String>[],
    this.streams = const <String>[],
    this.sessions = const <String>[],
    this.years = const <int>[],
  });

  final List<String> subjects;
  final List<String> classLevels;
  final List<String> streams;
  final List<String> sessions;
  final List<int> years;
}

/// Throws [AppFailure] on any error; implementations: real API and fake API.
abstract interface class ExamRepository {
  Future<ExamPage> list(ExamFilter filter, {int limit = 20, int skip = 0});

  Future<ExamDetail> detail(String id);

  Future<UnlockRecord> unlock(String id);

  Future<Map<String, AnswerKeyItem>> keys(String id);

  Future<List<UnlockedExam>> myUnlocks();

  /// Distinct filter values derived from the catalogue (no catalogue endpoint).
  Future<CatalogueValues> catalogue();
}
