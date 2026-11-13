/// Receipt attachment card: three source choices, the attached server file,
/// and the accepted types/size from the real limit.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/config/constants.dart';
import '../../../core/theme/tokens.dart';
import '../domain/payment_models.dart';
import 'receipt_selected_file.dart';

enum ReceiptSource { camera, gallery, file }

class ReceiptPicker extends StatelessWidget {
  const ReceiptPicker({
    super.key,
    required this.draft,
    required this.attached,
    required this.preparing,
    required this.uploaded,
    required this.compressed,
    required this.errorText,
    required this.onPick,
    required this.onReplace,
    required this.onRemove,
    required this.onViewAttached,
  });

  final ReceiptDraft? draft;
  final ReceiptFile? attached;
  final bool preparing;
  final bool uploaded;
  final bool compressed;
  final String? errorText;
  final void Function(ReceiptSource source) onPick;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final VoidCallback onViewAttached;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final ReceiptDraft? local = draft;
    final ReceiptFile? server = attached;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (local != null)
          SelectedReceiptFile(
            draft: local,
            preparing: preparing,
            compressed: compressed,
            onReplace: preparing ? null : onReplace,
            onRemove: preparing ? null : onRemove,
          )
        else if (server != null)
          _AttachedFile(receipt: server, onView: onViewAttached, onReplace: onReplace)
        else
          _SourceChoices(onPick: onPick),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(errorText!, style: theme.textTheme.bodySmall?.copyWith(color: scheme.error)),
          ),
        if (uploaded)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.cloud_done_outlined, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    context.l10n.attachmentKeepNotice,
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.receiptAcceptedTitle,
          style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          context.l10n.receiptAcceptedValue(_sizeLabel(Limits.maxReceiptBytes)),
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(context.l10n.receiptPickHint, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

class _SourceChoices extends StatelessWidget {
  const _SourceChoices({required this.onPick});

  final void Function(ReceiptSource source) onPick;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          _SourceTile(
            icon: Icons.photo_camera_outlined,
            label: context.l10n.takePhoto,
            onTap: () => onPick(ReceiptSource.camera),
          ),
          const Divider(height: 1),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: context.l10n.chooseFromGallery,
            onTap: () => onPick(ReceiptSource.gallery),
          ),
          const Divider(height: 1),
          _SourceTile(
            icon: Icons.picture_as_pdf_outlined,
            label: context.l10n.choosePdf,
            onTap: () => onPick(ReceiptSource.file),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Icon(icon, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachedFile extends StatelessWidget {
  const _AttachedFile({required this.receipt, required this.onView, required this.onReplace});

  final ReceiptFile receipt;
  final VoidCallback onView;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  receipt.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(context.l10n.receiptLabel),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        context.fmt.dateTime(receipt.uploadedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(onPressed: onView, child: Text(context.l10n.viewReceipt)),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextButton(onPressed: onReplace, child: Text(context.l10n.replaceFile)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _sizeLabel(int bytes) {
  if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
  return '$bytes B';
}
