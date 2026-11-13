part of 'fake_backend.dart';

class FakeMaterial {
  FakeMaterial({
    required this.id,
    required this.classLevel,
    required this.subject,
    required this.language,
    required this.kind,
    required this.bytes,
    this.originalName,
    this.text = '',
  }) : createdAt = DateTime.now();

  final String id;
  final String classLevel;
  final String subject;
  final String language;
  final String kind;
  final int bytes;
  final String? originalName;
  final String text;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'class_level': classLevel,
    'subject': subject,
    'language': language,
    'kind': kind,
    'original_name': originalName,
    'bytes': bytes,
    'created_at': _iso(createdAt),
  };
}

class FakeGenerationJob {
  FakeGenerationJob({
    required this.id,
    required this.material,
    required this.count,
    required this.creditsCharged,
  }) : createdAt = DateTime.now();

  final String id;
  final FakeMaterial material;
  final int count;
  final int creditsCharged;
  final DateTime createdAt;
  String status = 'review';
  String? examId;
  String? errorCode;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'material_id': material.id,
    'class_level': material.classLevel,
    'subject': material.subject,
    'language': material.language,
    'count': count,
    'status': status,
    'credits_charged': creditsCharged,
    'exam_id': examId,
    'error_code': errorCode,
    'created_at': _iso(createdAt),
  };
}

extension _FakeAiRoutes on FakeBackend {
  FakeReply _ai(RequestOptions options, String method, List<String> segments) {
    if (segments.length >= 2 && segments[1] == 'materials') {
      if (segments.length == 2) {
        if (method == 'GET') {
          final List<Map<String, Object?>> items = store.materials.reversed
              .map((FakeMaterial material) => material.toJson())
              .toList(growable: false);
          return FakeReply.json(200, <String, Object?>{'items': items});
        }
        if (method == 'POST') return FakeReply.json(201, _uploadMaterial(options));
        throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      }
      if (segments[2] == 'text' && method == 'POST') {
        return FakeReply.json(201, _textMaterial(_body(options)));
      }
      throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    }
    if (segments.length >= 2 && segments[1] == 'generations') {
      if (segments.length == 2) {
        if (method == 'POST') return FakeReply.json(201, _createJob(_body(options)));
        if (method == 'GET') {
          final List<Map<String, Object?>> items = store.jobs.reversed
              .map((FakeGenerationJob job) => job.toJson())
              .toList(growable: false);
          return FakeReply.json(200, <String, Object?>{'items': items});
        }
        throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      }
      if (segments.length == 3 && method == 'GET') {
        for (final FakeGenerationJob job in store.jobs) {
          if (job.id == segments[2]) return FakeReply.json(200, job.toJson());
        }
        throw const _FakeHttpError(404, ErrorCodes.generationJobNotFound, 'Generation job not found');
      }
    }
    throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
  }

  FakeMaterial _newMaterial({
    required String classLevel,
    required String subject,
    required String language,
    required String kind,
    required int bytes,
    String? originalName,
    String text = '',
  }) {
    final FakeMaterial material = FakeMaterial(
      id: store.nextId('mat'),
      classLevel: classLevel,
      subject: subject,
      language: language,
      kind: kind,
      bytes: bytes,
      originalName: originalName,
      text: text,
    );
    store.materials.add(material);
    return material;
  }

  Map<String, Object?> _textMaterial(Map<String, Object?> body) {
    final String text = _string(body['text']);
    if (text.length < 100) {
      throw const _FakeHttpError(422, ErrorCodes.materialTooShort, 'The material needs at least 100 characters');
    }
    final FakeMaterial material = _newMaterial(
      classLevel: _grade(body['classLevel']),
      subject: _subject(body['subject']),
      language: _language(body['language']),
      kind: 'text',
      bytes: text.length,
      originalName: 'pasted-text',
      text: text,
    );
    return material.toJson();
  }

  Map<String, Object?> _uploadMaterial(RequestOptions options) {
    final Object? data = options.data;
    if (data is! FormData) {
      throw const _FakeHttpError(400, ErrorCodes.materialFieldInvalid, 'Send the material in a "file" field');
    }
    final Map<String, String> fields = data.fields.fold(<String, String>{}, (
      Map<String, String> into,
      MapEntry<String, String> entry,
    ) {
      into[entry.key] = entry.value;
      return into;
    });
    String? filename;
    int bytes = 0;
    for (final MapEntry<String, MultipartFile> entry in data.files) {
      if (entry.key != 'file') continue;
      filename = entry.value.filename;
      bytes = entry.value.length;
    }
    if (filename == null) {
      throw const _FakeHttpError(400, ErrorCodes.materialRequired, 'Attach a material file');
    }
    final String lowered = filename.toLowerCase();
    if (lowered.endsWith('.pdf')) {
      throw const _FakeHttpError(400, ErrorCodes.materialPdfNotSupported, 'PDF materials are not supported yet');
    }
    final bool isImage = lowered.endsWith('.png') || lowered.endsWith('.jpg') || lowered.endsWith('.jpeg');
    final bool isText = lowered.endsWith('.txt') || lowered.endsWith('.md');
    if (!isImage && !isText) {
      throw const _FakeHttpError(422, ErrorCodes.materialTypeNotAllowed, 'Upload a .txt, .md, PNG or JPEG file');
    }
    final FakeMaterial material = _newMaterial(
      classLevel: _grade(fields['classLevel']),
      subject: _subject(fields['subject']),
      language: _language(fields['language']),
      kind: isImage ? 'image' : 'text',
      bytes: bytes,
      originalName: filename,
      text: isText ? 'x' * 120 : '',
    );
    return material.toJson();
  }

  Map<String, Object?> _createJob(Map<String, Object?> body) {
    final String materialId = _string(body['materialId']);
    FakeMaterial? material;
    for (final FakeMaterial candidate in store.materials) {
      if (candidate.id == materialId) {
        material = candidate;
        break;
      }
    }
    if (material == null) throw const _FakeHttpError(404, ErrorCodes.materialNotFound, 'Material not found');
    final int count = (body['count'] as num?)?.toInt() ?? 5;
    if (count < 5 || count > 10) {
      throw const _FakeHttpError(422, ErrorCodes.validationError, 'Ask for 5 to 10 questions');
    }
    if (store.balance - store.reserved < 1) {
      throw const _FakeHttpError(402, ErrorCodes.insufficientCredits, 'Not enough credits');
    }
    // Server parity: identical recent requests replay the same job, and the
    // fee stays reserved (uncharged) until a human approves the questions.
    for (final FakeGenerationJob existing in store.jobs.reversed) {
      if (existing.material.id == materialId &&
          existing.count == count &&
          existing.status == 'review' &&
          DateTime.now().difference(existing.createdAt) < const Duration(minutes: 5)) {
        return existing.toJson();
      }
    }
    store.reserved += 1;
    final FakeGenerationJob job = FakeGenerationJob(
      id: store.nextId('gen'),
      material: material,
      count: count,
      creditsCharged: 0,
    );
    store.jobs.add(job);
    return job.toJson();
  }

  static String _grade(Object? raw) {
    final String value = _string(raw);
    if (value != '1' && value != '2' && value != '3') {
      throw const _FakeHttpError(422, ErrorCodes.classLevelRequired, 'Choose grade 1, 2 or 3');
    }
    return value;
  }

  static String _subject(Object? raw) {
    final String value = _string(raw);
    if (value.isEmpty) throw const _FakeHttpError(422, ErrorCodes.validationError, 'Subject is required');
    return value;
  }

  static String _language(Object? raw) {
    final String value = _string(raw);
    return value == 'en' ? 'en' : 'ar';
  }
}
