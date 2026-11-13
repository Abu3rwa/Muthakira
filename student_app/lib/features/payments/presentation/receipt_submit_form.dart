/// The receipt submission form: request summary, attachment, reference and
/// the single submit action.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/payment_models.dart';
import 'payment_widgets.dart';
import 'receipt_extraction.dart';
import 'receipt_picker.dart';

class ReceiptSubmitForm extends StatelessWidget {
  const ReceiptSubmitForm({
    super.key,
    required this.request,
    required this.reference,
    required this.sender,
    required this.draft,
    required this.preparing,
    required this.uploaded,
    required this.compressed,
    required this.busy,
    required this.uploading,
    required this.referenceError,
    required this.receiptError,
    required this.read,
    required this.onPick,
    required this.onReplace,
    required this.onRemove,
    required this.onViewAttached,
    required this.onSubmit,
  });

  final PaymentRequest request;
  final TextEditingController reference;
  final TextEditingController sender;
  final ReceiptDraft? draft;
  final bool preparing;
  final bool uploaded;
  final bool compressed;
  final bool busy;
  final bool uploading;
  final String? referenceError;
  final String? receiptError;
  final ReceiptRead read;
  final void Function(ReceiptSource source) onPick;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final VoidCallback onViewAttached;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutterOf(context),
        AppSpacing.sm,
        AppSpacing.gutterOf(context),
        AppSpacing.xl,
      ),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        request.package.name.resolve(context.localeController.languageCode),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${context.l10n.expectedAmountLabel}: ${context.fmt.sdg(request.expectedAmountSdg)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PaymentStatusChip(status: request.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: context.l10n.receiptLabel),
        ReceiptPicker(
          draft: draft,
          attached: request.receipt,
          preparing: preparing,
          uploaded: uploaded,
          compressed: compressed,
          errorText: receiptError,
          onPick: onPick,
          onReplace: onReplace,
          onRemove: onRemove,
          onViewAttached: onViewAttached,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (read != ReceiptRead.none) ...<Widget>[ReceiptReadNote(read: read), const SizedBox(height: AppSpacing.sm)],
        SectionHeader(title: context.l10n.referenceLabel),
        AppTextField(
          label: context.l10n.referenceLabel,
          controller: reference,
          hint: context.l10n.referenceHint,
          errorText: referenceError,
          keyboardType: TextInputType.text,
          textDirection: TextDirection.ltr,
          maxLength: 64,
          textInputAction: TextInputAction.next,
        ),
        const FieldGap(),
        AppTextField(
          label: '${context.l10n.senderNameLabel} (${context.l10n.optional})',
          controller: sender,
          maxLength: 80,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: uploading ? context.l10n.receiptUploading : context.l10n.submitReceipt,
          icon: Icons.upload_file_outlined,
          isLoading: busy,
          onPressed: busy || preparing || read == ReceiptRead.reading ? null : onSubmit,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.manualReviewNotice,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Tells the student what the server read out of the receipt they just sent.
class ReceiptReadNote extends StatelessWidget {
  const ReceiptReadNote({super.key, required this.read});

  final ReceiptRead read;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool busy = read == ReceiptRead.reading;
    final String text = switch (read) {
      ReceiptRead.reading => context.l10n.receiptReading,
      ReceiptRead.filled => context.l10n.receiptExtracted,
      ReceiptRead.manual => context.l10n.receiptExtractManual,
      ReceiptRead.none => '',
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      children: <Widget>[
        busy
            ? const SizedBox(width: 18, height: 18, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            : Icon(
                read == ReceiptRead.filled ? Icons.auto_awesome_outlined : Icons.edit_outlined,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(text, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}
