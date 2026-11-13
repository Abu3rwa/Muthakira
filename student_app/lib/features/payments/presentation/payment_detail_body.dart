/// The payment detail list: status, summary, instructions, receipt action,
/// cancel and timeline.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/payment_models.dart';
import 'payment_detail_sections.dart';
import 'payment_status_panel.dart';
import 'payment_summary_card.dart';

class PaymentDetailBody extends StatelessWidget {
  const PaymentDetailBody({
    super.key,
    required this.request,
    required this.cancelling,
    required this.onRefresh,
    required this.onSubmit,
    required this.onCancel,
    required this.onOpenBankak,
    required this.onNewRequest,
    required this.onViewReceipt,
  });

  final PaymentRequest request;
  final bool cancelling;
  final VoidCallback onRefresh;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onOpenBankak;
  final VoidCallback onNewRequest;
  final VoidCallback onViewReceipt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool closed = request.status == PaymentStatus.expired ||
        request.status == PaymentStatus.cancelled ||
        request.status == PaymentStatus.unknown;
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterOf(context),
          AppSpacing.sm,
          AppSpacing.gutterOf(context),
          AppSpacing.xl,
        ),
        children: <Widget>[
          PaymentStatusPanel(request: request, onRefresh: onRefresh, onNewRequest: onNewRequest),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.l10n.requestSummaryTitle),
          PaymentSummaryCard(request: request, showInstructions: !closed),
          if (!closed) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: context.l10n.paymentInstructionsTitle),
            TransferInstructionsCard(request: request, onOpenBankak: onOpenBankak),
          ],
          if (request.receipt != null || request.canSubmit) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: context.l10n.receiptLabel),
            if (request.receipt != null)
              Card(
                child: ListTile(
                  leading: Icon(
                    request.receipt!.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
                    color: scheme.primary,
                  ),
                  title: Text(context.l10n.receiptLabel),
                  subtitle: Text(context.fmt.dateTime(request.receipt!.uploadedAt)),
                  trailing: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                  ),
                  onTap: onViewReceipt,
                ),
              )
            else
              const _MissingReceipt(),
            if (request.canSubmit) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: request.status == PaymentStatus.pendingPayment
                    ? context.l10n.submitReceipt
                    : context.l10n.resubmit,
                icon: Icons.upload_file_outlined,
                onPressed: onSubmit,
              ),
            ],
          ],
          if (request.canCancel) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: cancelling ? null : onCancel,
              child: Text(context.l10n.cancelRequest),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.l10n.timeline),
          PaymentTimelineCard(request: request),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.paymentHelpBody,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MissingReceipt extends StatelessWidget {
  const _MissingReceipt();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.cardAll,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.receipt_long_outlined, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.receiptMissing,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
