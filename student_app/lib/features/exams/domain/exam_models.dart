import '../../../core/utils/parse.dart';

class Stimulus {
  const Stimulus({
    required this.id,
    required this.kind,
    this.title,
    required this.text,
    this.sortOrder = 0,
  });

  final String id;
  final String kind;
  final String? title;
  final String text;
  final int sortOrder;

  factory Stimulus.fromJson(Map<String, Object?> json) {
    return Stimulus(
      id: Parse.string(json['id']),
      kind: Parse.string(json['kind'], fallback: 'passage'),
      title: Parse.string(json['title']),
      text: Parse.string(json['text']),
      sortOrder: Parse.integer(json['sort_order']),
    );
  }
}

class Question {
  const Question({
    required this.id,
    this.parentId,
    required this.path,
    required this.type,
    this.stimulusId,
    required this.text,
    this.options = const [],
    this.marks = 0,
    this.sortOrder = 0,
    this.difficulty = 3,
    this.access = 'paid',
    this.practiceEligible = false,
    this.keyStatus = 'draft',
    this.markingMethod,
    this.isContainer = false,
    this.childrenCount = 0,
    this.rawKey,
    this.acceptedAlternatives = const [],
    this.explanation,
    this.modelAnswer,
  });

  final String id;
  final String? parentId;
  final String path;
  final String type;
  final String? stimulusId;
  final String text;
  final List<String> options;
  final double marks;
  final int sortOrder;
  final int difficulty;

  /// `trial`, `free` or `paid`.
  final String access;
  final bool practiceEligible;
  final String keyStatus;
  final String? markingMethod;
  final bool isContainer;
  final int childrenCount;

  final Object? rawKey;
  final List<String> acceptedAlternatives;
  final String? explanation;
  final String? modelAnswer;

  bool get hasKey => rawKey != null;

  bool get isObjective => const {
        'mcq',
        'multi_select',
        'true_false',
        'matching_item',
        'fill_blank',
        'table_fill',
        'matrix_input',
        'truth_table',
        'ordering',
        'numeric',
        'math_expression',
      }.contains(type);

  /// Human readable key, used by the feedback panel.
  String? get keyText {
    final Object? key = rawKey;
    return switch (key) {
      null => null,
      final String value => value,
      final bool value => value ? 'true' : 'false',
      final num value => value.toString(),
      final List<Object?> value => value.map((Object? item) => item?.toString() ?? '').join(', '),
      final Map<Object?, Object?> value =>
        value.entries.map((MapEntry<Object?, Object?> entry) => '${entry.key}: ${entry.value}').join('\n'),
      _ => key.toString(),
    };
  }

  String? get keyLetter => rawKey is String ? rawKey as String : null;

  List<String>? get keyLetters =>
      rawKey is List ? (rawKey as List).map((item) => item?.toString() ?? '').toList() : null;

  bool? get keyBool => rawKey is bool ? rawKey as bool : null;

  Map<String, String>? get keyTable {
    final key = rawKey;
    if (key is! Map) return null;
    return key.map((row, value) => MapEntry(row.toString(), value?.toString() ?? ''));
  }

  /// A copy with a different option pool. The API sends a matching bank on the
  /// `matching` container only, so each `matching_item` borrows it to render.
  Question withOptions(List<String> options) => Question(
        id: id,
        parentId: parentId,
        path: path,
        type: type,
        stimulusId: stimulusId,
        text: text,
        options: options,
        marks: marks,
        sortOrder: sortOrder,
        difficulty: difficulty,
        access: access,
        practiceEligible: practiceEligible,
        keyStatus: keyStatus,
        markingMethod: markingMethod,
        isContainer: isContainer,
        childrenCount: childrenCount,
        rawKey: rawKey,
        acceptedAlternatives: acceptedAlternatives,
        explanation: explanation,
        modelAnswer: modelAnswer,
      );

  factory Question.fromJson(Map<String, Object?> json) {
    return Question(
      id: Parse.string(json['id']),
      parentId: Parse.string(json['parent_id']),
      path: Parse.string(json['path']),
      type: Parse.string(json['type'], fallback: 'unknown'),
      stimulusId: Parse.string(json['stimulus_id']),
      text: Parse.string(json['text']),
      options: Parse.stringList(json['options']),
      marks: Parse.decimal(json['marks']),
      sortOrder: Parse.integer(json['sort_order']),
      difficulty: Parse.integer(json['difficulty'], fallback: 3),
      access: Parse.string(json['access'], fallback: 'paid'),
      practiceEligible: Parse.boolean(json['practice_eligible']),
      keyStatus: Parse.string(json['key_status'], fallback: 'draft'),
      markingMethod: Parse.string(json['marking_method']),
      isContainer: Parse.boolean(json['is_container']),
      childrenCount: Parse.integer(json['children_count']),
      rawKey: json['key'],
      acceptedAlternatives: Parse.stringList(json['accepted_alternatives']),
      explanation: Parse.string(json['explanation']),
      modelAnswer: Parse.string(json['model_answer']),
    );
  }
}

class ExamSummary {
  const ExamSummary({
    required this.id,
    required this.examKey,
    required this.examYear,
    required this.session,
    required this.classLevel,
    required this.subject,
    required this.language,
    this.stream,
    this.durationMinutes = 0,
    this.totalMarks = 0,
    this.questionCount = 0,
    this.leafQuestionCount = 0,
    this.isFree = false,
    this.unlockCost,
    this.practiceEnabled = true,
    this.status = 'published',
    this.publishedAt,
  });

  final String id;
  final String examKey;
  final int examYear;
  final String session;
  final String classLevel;
  final String subject;
  final String language;
  final String? stream;
  final int durationMinutes;
  final double totalMarks;
  final int questionCount;
  final int leafQuestionCount;
  final bool isFree;
  final int? unlockCost;
  final bool practiceEnabled;
  final String status;
  final DateTime? publishedAt;

  String get title => '$subject — $session $examYear';

  factory ExamSummary.fromJson(Map<String, Object?> json) {
    return ExamSummary(
      id: Parse.string(json['id']),
      examKey: Parse.string(json['exam_key']),
      examYear: Parse.integer(json['exam_year']),
      session: Parse.string(json['session']),
      classLevel: Parse.string(json['class_level']),
      subject: Parse.string(json['subject']),
      language: Parse.string(json['language'], fallback: 'ar'),
      stream: Parse.string(json['stream']),
      durationMinutes: Parse.integer(json['duration_minutes']),
      totalMarks: Parse.decimal(json['total_marks']),
      questionCount: Parse.integer(json['question_count']),
      leafQuestionCount: Parse.integer(json['leaf_question_count']),
      isFree: Parse.boolean(json['is_free']),
      unlockCost: Parse.integerOrNull(json['unlock_cost']),
      practiceEnabled: Parse.boolean(json['practice_enabled'], fallback: true),
      status: Parse.string(json['status'], fallback: 'published'),
      publishedAt: Parse.date(json['published_at']),
    );
  }
}

class ExamDetail {
  const ExamDetail({
    required this.summary,
    this.instructions,
    this.unlocked = false,
    this.unlockCost = 0,
    this.stimuli = const [],
    this.questions = const [],
  });

  final ExamSummary summary;
  final String? instructions;
  final bool unlocked;
  final int unlockCost;
  final List<Stimulus> stimuli;
  final List<Question> questions;

  bool get isFree => summary.isFree;
  bool get canAnswerAll => unlocked || isFree;

  Stimulus? stimulusFor(Question question) {
    if (question.stimulusId == null) return null;
    for (final stimulus in stimuli) {
      if (stimulus.id == question.stimulusId) return stimulus;
    }
    return null;
  }

  factory ExamDetail.fromJson(Map<String, Object?> json) {
    return ExamDetail(
      summary: ExamSummary.fromJson(json),
      instructions: Parse.string(json['instructions']),
      unlocked: Parse.boolean(json['unlocked']),
      unlockCost: Parse.integer(json['unlock_cost']),
      stimuli: Parse.mapList(json['stimuli']).map(Stimulus.fromJson).toList(),
      questions: Parse.mapList(json['questions']).map(Question.fromJson).toList(),
    );
  }
}

class UnlockRecord {
  const UnlockRecord({required this.examId, required this.charged, required this.cost, this.unlockedAt});

  final String examId;
  final bool charged;
  final int cost;
  final DateTime? unlockedAt;

  factory UnlockRecord.fromJson(Map<String, Object?> json) {
    final unlock = Parse.map(json['unlock']);
    return UnlockRecord(
      examId: Parse.string(unlock['exam_id']),
      charged: Parse.boolean(json['charged']),
      cost: Parse.integer(json['cost']),
      unlockedAt: Parse.date(unlock['unlocked_at']),
    );
  }
}

class AnswerKeyItem {
  const AnswerKeyItem({
    required this.id,
    required this.path,
    this.key,
    this.explanation,
    this.criteria = const [],
    this.modelAnswer,
  });

  final String id;
  final String path;
  final Object? key;
  final String? explanation;
  final List<String> criteria;
  final String? modelAnswer;

  factory AnswerKeyItem.fromJson(Map<String, Object?> json) => AnswerKeyItem(
    id: Parse.string(json['id']),
    path: Parse.string(json['path']),
    key: json['key'],
    explanation: Parse.string(json['explanation']),
    criteria: Parse.stringList(json['criteria']),
    modelAnswer: Parse.string(json['model_answer']),
  );
}
