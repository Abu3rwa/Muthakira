/// The status explanation panel with the reason note and the contextual
/// refresh/new-request action.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../domain/payment_models.dart';
import 'payment_widgets.dart';

class PaymentStatusPanel extends StatelessWidget {
  const PaymentStatusPanel({
    super.key,
    required this.request,
    required this.onRefresh,
    required this.onNewRequest,
  });

  final PaymentRequest request;
  final VoidCallback onRefresh;
  final VoidCallback onNewRequest;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final StatusTone tone = statusTone(context, request.status);
    final String? note = (request.rejectReason ?? '').trim().isEmpty ? null : request.rejectReason!.trim();
    final bool showNote = note != null &&
        (request.status == PaymentStatus.rejected || request.status == PaymentStatus.needsInfo);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: tone.background, borderRadius: AppRadii.cardAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(_statusIcon(request.status), color: tone.foreground),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      statusLabel(context, request.status),
                      style: theme.textTheme.titleSmall?.copyWith(color: tone.foreground),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _explanation(context, request.status),
                      style: theme.textTheme.bodySmall?.copyWith(color: tone.foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showNote) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.55),
                borderRadius: AppRadii.inputAll,
                border: BorderDirectional(start: BorderSide(color: tone.foreground, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.rejectReasonLabel,
                    style: theme.textTheme.labelMedium?.copyWith(color: tone.foreground),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(note, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
          if (request.status == PaymentStatus.expired || request.status == PaymentStatus.cancelled) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            TextButton(onPressed: onNewRequest, child: Text(context.l10n.topUpBalance)),
          ],
          if (request.status == PaymentStatus.unknown || request.status.isWaiting) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.refreshStatus),
            ),
          ],
        ],
      ),
    );
  }
}

String _explanation(BuildContext context, PaymentStatus status) => switch (status) {
  PaymentStatus.pendingPayment => context.l10n.paymentStatusExplainPending,
  PaymentStatus.submitted => context.l10n.paymentStatusExplainSubmitted,
  PaymentStatus.underReview => context.l10n.paymentStatusExplainUnderReview,
  PaymentStatus.needsInfo => context.l10n.paymentStatusExplainNeedsInfo,
  PaymentStatus.approved => context.l10n.paymentStatusExplainApproved,
  PaymentStatus.rejected => context.l10n.paymentStatusExplainRejected,
  PaymentStatus.expired => context.l10n.paymentStatusExplainExpired,
  PaymentStatus.cancelled => context.l10n.paymentStatusExplainCancelled,
  PaymentStatus.unknown => context.l10n.paymentStatusExplainUnknown,
};

IconData _statusIcon(PaymentStatus status) => switch (status) {
  PaymentStatus.pendingPayment => Icons.schedule_outlined,
  PaymentStatus.submitted || PaymentStatus.underReview => Icons.hourglass_top_rounded,
  PaymentStatus.needsInfo => Icons.info_outline,
  PaymentStatus.approved => Icons.check_circle_outline,
  PaymentStatus.rejected => Icons.error_outline,
  PaymentStatus.expired => Icons.event_busy_outlined,
  PaymentStatus.cancelled => Icons.block_outlined,
  PaymentStatus.unknown => Icons.help_outline,
};
