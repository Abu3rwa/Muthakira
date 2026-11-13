/// Materials and generation API. Uploads go through the authenticated client.
library;

import 'package:dio/dio.dart';

import '../../../core/config/constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/parse.dart';
import '../domain/material_models.dart';
import '../domain/materials_repository.dart';

class ApiMaterialsRepository implements MaterialsRepository {
  ApiMaterialsRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<MaterialItem>> listMaterials() async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.aiMaterials);
    return Parse.mapList(json['items']).map(MaterialItem.fromJson).toList(growable: false);
  }

  @override
  Future<MaterialItem> addText({
    required String classLevel,
    required String subject,
    required String language,
    required String text,
  }) async {
    final Map<String, dynamic> json = await _api.postJson(
      ApiPaths.aiMaterialsText,
      body: <String, Object?>{
        'classLevel': classLevel,
        'subject': subject,
        'language': language,
        'text': text,
      },
    );
    return MaterialItem.fromJson(json);
  }

  @override
  Future<MaterialItem> addFile({
    required String classLevel,
    required String subject,
    required String language,
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    final FormData form = FormData.fromMap(<String, Object?>{
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: DioMediaType.parse(contentType),
      ),
      'classLevel': classLevel,
      'subject': subject,
      'language': language,
    });
    final Map<String, dynamic> json = await _api.upload(ApiPaths.aiMaterials, formData: form);
    return MaterialItem.fromJson(json);
  }

  @override
  Future<GenerationJob> createGeneration(String materialId, {int count = generationMinQuestions}) async {
    try {
      final Map<String, dynamic> json = await _api.postJson(
        ApiPaths.aiGenerations,
        body: <String, Object?>{'materialId': materialId, 'count': count},
        receiveTimeout: Limits.aiGenerationTimeout,
      );
      return GenerationJob.fromJson(json);
    } on AppFailure catch (failure) {
      if (!failure.isTimeout) rethrow;
      // The job may exist server-side even though the response was lost; the
      // server also replays identical recent requests, so never re-pay blindly.
      final GenerationJob? existing = await _recentJob(materialId, count);
      if (existing != null) return existing;
      rethrow;
    }
  }

  Future<GenerationJob?> _recentJob(String materialId, int count) async {
    try {
      final List<GenerationJob> jobs = await listGenerations();
      GenerationJob? latest;
      for (final GenerationJob job in jobs) {
        if (job.materialId != materialId || job.count != count) continue;
        if (latest == null ||
            (job.createdAt != null &&
                (latest.createdAt == null || job.createdAt!.isAfter(latest.createdAt!)))) {
          latest = job;
        }
      }
      return latest;
    } on AppFailure {
      return null;
    }
  }

  @override
  Future<List<GenerationJob>> listGenerations() async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.aiGenerations);
    return Parse.mapList(json['items']).map(GenerationJob.fromJson).toList(growable: false);
  }

  @override
  Future<GenerationJob> generation(String id) async {
    final Map<String, dynamic> json = await _api.getJson(ApiPaths.aiGeneration(id));
    return GenerationJob.fromJson(json);
  }
}
