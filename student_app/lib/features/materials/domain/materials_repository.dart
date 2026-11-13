import 'material_models.dart';

/// Student-owned materials and their generation jobs. All charges are server-side.
abstract interface class MaterialsRepository {
  Future<List<MaterialItem>> listMaterials();

  Future<MaterialItem> addText({
    required String classLevel,
    required String subject,
    required String language,
    required String text,
  });

  Future<MaterialItem> addFile({
    required String classLevel,
    required String subject,
    required String language,
    required List<int> bytes,
    required String fileName,
    required String contentType,
  });

  Future<GenerationJob> createGeneration(String materialId, {int count = generationMinQuestions});

  Future<List<GenerationJob>> listGenerations();

  Future<GenerationJob> generation(String id);
}
