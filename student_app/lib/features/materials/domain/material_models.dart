/// Student materials and the question-generation jobs made from them.
library;

import '../../../core/utils/parse.dart';

/// Source kinds the API currently stores. PDF extraction is not implemented.
enum MaterialKind {
  text,
  image,
  unknown;

  static MaterialKind parse(Object? raw) => switch (raw) {
    'text' => MaterialKind.text,
    'image' => MaterialKind.image,
    _ => MaterialKind.unknown,
  };
}

class MaterialItem {
  const MaterialItem({
    required this.id,
    required this.classLevel,
    required this.subject,
    required this.language,
    required this.kind,
    required this.bytes,
    required this.createdAt,
    this.originalName,
  });

  final String id;

  /// `1`, `2` or `3`: the secondary grade the material was filed under.
  final String classLevel;
  final String subject;
  final String language;
  final MaterialKind kind;
  final int bytes;
  final DateTime? createdAt;
  final String? originalName;

  bool get isPastedText => originalName == null || originalName == 'pasted-text';

  String get displayName {
    if (isPastedText) return subject;
    return originalName!.trim().isEmpty ? subject : originalName!.trim();
  }

  factory MaterialItem.fromJson(Map<String, Object?> json) => MaterialItem(
    id: Parse.string(json['id']),
    classLevel: Parse.string(json['class_level']),
    subject: Parse.string(json['subject']),
    language: Parse.string(json['language'], fallback: 'ar'),
    kind: MaterialKind.parse(json['kind']),
    bytes: Parse.integer(json['bytes']),
    createdAt: Parse.date(json['created_at']),
    originalName: Parse.stringOrNull(json['original_name']),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'class_level': classLevel,
    'subject': subject,
    'language': language,
    'kind': kind.name,
    'bytes': bytes,
    'created_at': createdAt?.toIso8601String(),
    'original_name': originalName,
  };
}

/// Server job states. A new job is created in `review`; there is no
/// server-side `processing` row, so the app only shows that while it waits.
enum GenerationStatus {
  review,
  ready,
  failed,
  rejected,
  unknown;

  static GenerationStatus parse(Object? raw) => switch (raw) {
    'review' => GenerationStatus.review,
    'ready' => GenerationStatus.ready,
    'failed' => GenerationStatus.failed,
    'rejected' => GenerationStatus.rejected,
    _ => GenerationStatus.unknown,
  };
}

class GenerationJob {
  const GenerationJob({
    required this.id,
    required this.materialId,
    required this.classLevel,
    required this.subject,
    required this.count,
    required this.status,
    required this.creditsCharged,
    required this.createdAt,
    this.examId,
    this.errorCode,
  });

  final String id;
  final String materialId;
  final String classLevel;
  final String subject;
  final int count;
  final GenerationStatus status;
  final int creditsCharged;
  final DateTime? createdAt;
  final String? examId;
  final String? errorCode;

  bool get isOpen => status == GenerationStatus.review;
  bool get isReady => status == GenerationStatus.ready && examId != null;

  factory GenerationJob.fromJson(Map<String, Object?> json) => GenerationJob(
    id: Parse.string(json['id']),
    materialId: Parse.string(json['material_id']),
    classLevel: Parse.string(json['class_level']),
    subject: Parse.string(json['subject']),
    count: Parse.integer(json['count']),
    status: GenerationStatus.parse(json['status']),
    creditsCharged: Parse.integer(json['credits_charged']),
    createdAt: Parse.date(json['created_at']),
    examId: Parse.stringOrNull(json['exam_id']),
    errorCode: Parse.stringOrNull(json['error_code']),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'material_id': materialId,
    'class_level': classLevel,
    'subject': subject,
    'count': count,
    'status': status.name,
    'credits_charged': creditsCharged,
    'created_at': createdAt?.toIso8601String(),
    'exam_id': examId,
    'error_code': errorCode,
  };
}

/// The API's supported generation range; the server rejects anything outside.
const int generationMinQuestions = 5;
const int generationMaxQuestions = 10;
const int materialMinChars = 100;
