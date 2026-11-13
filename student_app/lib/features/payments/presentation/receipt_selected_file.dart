/// The locally prepared receipt: file name, type, size, preparation status,
/// preview, and the replace/remove actions.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../domain/payment_models.dart';

class SelectedReceiptFile extends StatelessWidget {
  const SelectedReceiptFile({
    super.key,
    required this.draft,
    required this.preparing,
    required this.compressed,
    required this.onReplace,
    required this.onRemove,
  });

  final ReceiptDraft draft;
  final bool preparing;
  final bool compressed;
  final VoidCallback? onReplace;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isPdf = draft.contentType == 'application/pdf';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined, color: scheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(draft.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${context.l10n.fileTypeLabel}: ${draft.contentType} · '
                            '${context.l10n.fileSizeLabel}: ${_sizeLabel(draft.bytes.lengthInBytes)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _PreparationLine(preparing: preparing, compressed: compressed),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    TextButton(onPressed: onReplace, child: Text(context.l10n.replaceFile)),
                    TextButton(onPressed: onRemove, child: Text(context.l10n.removeFile)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!isPdf) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.input),
            child: Image.memory(draft.bytes, height: 180, fit: BoxFit.contain),
          ),
        ],
      ],
    );
  }
}

class _PreparationLine extends StatelessWidget {
  const _PreparationLine({required this.preparing, required this.compressed});

  final bool preparing;
  final bool compressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    if (preparing) {
      return Row(
        children: <Widget>[
          const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(context.l10n.preparingReceipt, style: theme.textTheme.bodySmall)),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.check_circle_outline, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(context.l10n.receiptReady, style: theme.textTheme.bodySmall),
              if (compressed)
                Text(
                  context.l10n.receiptCompressedHint,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _sizeLabel(int bytes) {
  if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
  return '$bytes B';
}
