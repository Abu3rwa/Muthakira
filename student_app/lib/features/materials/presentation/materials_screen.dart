/// S30: the student's own materials and what has been generated from them.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/states.dart';
import '../domain/material_models.dart';
import '../domain/materials_repository.dart';
import 'material_panels.dart';

class _MaterialsData {
  const _MaterialsData({required this.materials, required this.jobs});

  final List<MaterialItem> materials;
  final Map<String, GenerationJob> jobs;
}

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  late Future<_MaterialsData> _future = _load();

  Future<_MaterialsData> _load() async {
    final MaterialsRepository repository = context.services.materialsRepository;
    final List<MaterialItem> materials = await repository.listMaterials();
    final List<GenerationJob> jobs = await repository.listGenerations();
    final Map<String, GenerationJob> latest = <String, GenerationJob>{};
    for (final GenerationJob job in jobs) {
      final GenerationJob? kept = latest[job.materialId];
      final DateTime? created = job.createdAt;
      if (kept == null || (created != null && (kept.createdAt == null || created.isAfter(kept.createdAt!)))) {
        latest[job.materialId] = job;
      }
    }
    return _MaterialsData(materials: materials, jobs: latest);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _add() async {
    final bool? added = await context.push<bool>(Routes.materialAdd);
    if (added == true && mounted) _reload();
  }

  Future<void> _generate(MaterialItem material) async {
    final String? jobId = await context.push<String>(Routes.generationConfirmOf(material.id), extra: material);
    if (jobId == null || !mounted) return;
    _reload();
    await context.push<void>(Routes.generationOf(jobId));
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myMaterials)),
      body: FutureBuilder<_MaterialsData>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<_MaterialsData> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final Object error = snapshot.error!;
            return ErrorView(
              failure: error is AppFailure ? error : const AppFailure.network(),
              onRetry: _reload,
            );
          }
          final _MaterialsData data = snapshot.data ??
              const _MaterialsData(materials: <MaterialItem>[], jobs: <String, GenerationJob>{});
          final double gutter = AppSpacing.gutterOf(context);
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
              children: <Widget>[
                Text(
                  context.l10n.materialsEntryHint,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: context.l10n.materialAdd,
                  icon: Icons.note_add_outlined,
                  onPressed: _add,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (data.materials.isEmpty)
                  EmptyView(
                    title: context.l10n.materialsEmpty,
                    message: context.l10n.materialsEmptyHint,
                    icon: Icons.library_books_outlined,
                  )
                else
                  for (final MaterialItem material in data.materials)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: MaterialCard(
                        material: material,
                        job: data.jobs[material.id],
                        onGenerate: () => _generate(material),
                        onOpenStatus: (GenerationJob job) =>
                            context.push<void>(Routes.generationOf(job.id)),
                        onOpenSet: (GenerationJob job) =>
                            context.push<void>(Routes.exam(job.examId!)),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
