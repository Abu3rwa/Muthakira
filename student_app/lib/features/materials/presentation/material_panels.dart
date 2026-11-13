/// One material row: identity, source, real generation status and the one
/// action that genuinely works for that status.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/grade_labels.dart';
import '../domain/material_models.dart';

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.material,
    required this.job,
    required this.onGenerate,
    required this.onOpenStatus,
    required this.onOpenSet,
  });

  final MaterialItem material;
  final GenerationJob? job;
  final VoidCallback onGenerate;
  final ValueChanged<GenerationJob> onOpenStatus;
  final ValueChanged<GenerationJob> onOpenSet;

  @override
  Widget build(BuildContext context) {
    final GenerationJob? current = job;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(_kindIcon(material.kind), color: context.scheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    material.displayName,
                    style: context.text.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _StatusChip(status: current?.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${material.subject} · ${gradeLabel(context.l10n, material.classLevel)} · ${_kindLabel(context, material)}',
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.materialCreatedAt(context.fmt.date(material.createdAt)),
              style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
            if (current?.status == GenerationStatus.failed) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                current?.errorCode == 'AI_CONTENT_UNSAFE'
                    ? context.l10n.generationUnsafe
                    : context.l10n.generationFailedBody,
                style: context.text.bodySmall?.copyWith(color: context.scheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _action(context, current),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(BuildContext context, GenerationJob? current) {
    if (current != null && current.isOpen) {
      return TextButton.icon(
        onPressed: () => onOpenStatus(current),
        icon: const Icon(Icons.hourglass_top_rounded, size: 18),
        label: Text(context.l10n.generationStatusTitle),
      );
    }
    if (current != null && current.isReady) {
      return FilledButton.tonalIcon(
        onPressed: () => onOpenSet(current),
        icon: const Icon(Icons.menu_book_rounded, size: 18),
        label: Text(context.l10n.generationOpen),
      );
    }
    return TextButton.icon(
      onPressed: onGenerate,
      icon: const Icon(Icons.auto_awesome_outlined, size: 18),
      label: Text(context.l10n.materialGenerate),
    );
  }

  static IconData _kindIcon(MaterialKind kind) => switch (kind) {
    MaterialKind.image => Icons.image_outlined,
    MaterialKind.text => Icons.article_outlined,
    MaterialKind.unknown => Icons.insert_drive_file_outlined,
  };

  static String _kindLabel(BuildContext context, MaterialItem material) {
    if (material.kind == MaterialKind.image) return context.l10n.materialSourcePhoto;
    if (material.isPastedText) return context.l10n.materialSourcePaste;
    return context.l10n.materialSourceFile;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({this.status});

  final GenerationStatus? status;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semantics;
    final (String label, Color foreground, Color background) = switch (status) {
      null => (context.l10n.materialNoGeneration, context.scheme.onSurfaceVariant, context.scheme.surfaceContainerHigh),
      GenerationStatus.review => (context.l10n.materialStatusReview, colors.warning, colors.warningContainer),
      GenerationStatus.ready => (context.l10n.materialStatusReady, colors.success, colors.successContainer),
      GenerationStatus.failed => (context.l10n.materialStatusFailed, context.scheme.error, context.scheme.errorContainer),
      GenerationStatus.rejected => (context.l10n.materialStatusRejected, context.scheme.error, context.scheme.errorContainer),
      GenerationStatus.unknown => (context.l10n.generationUnknown, context.scheme.onSurfaceVariant, context.scheme.surfaceContainerHigh),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(label, style: context.text.labelSmall?.copyWith(color: foreground)),
    );
  }
}
