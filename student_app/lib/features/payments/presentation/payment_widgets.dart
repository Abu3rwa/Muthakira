/// Shared payment presentation bits: the status label and its colour pair.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../domain/payment_models.dart';

String statusLabel(BuildContext context, PaymentStatus status) => switch (status) {
  PaymentStatus.pendingPayment => context.l10n.statusPendingPayment,
  PaymentStatus.submitted => context.l10n.statusSubmitted,
  PaymentStatus.underReview => context.l10n.statusUnderReview,
  PaymentStatus.needsInfo => context.l10n.statusNeedsInfo,
  PaymentStatus.approved => context.l10n.statusApproved,
  PaymentStatus.rejected => context.l10n.statusRejected,
  PaymentStatus.expired => context.l10n.statusExpired,
  PaymentStatus.cancelled => context.l10n.statusCancelled,
  PaymentStatus.unknown => context.l10n.notAvailable,
};

class StatusTone {
  const StatusTone(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

StatusTone statusTone(BuildContext context, PaymentStatus status) {
  final SemanticColors colors = context.semantics;
  final ColorScheme scheme = context.scheme;
  return switch (status) {
    PaymentStatus.approved => StatusTone(colors.success, colors.successContainer),
    PaymentStatus.pendingPayment ||
    PaymentStatus.needsInfo => StatusTone(colors.warning, colors.warningContainer),
    PaymentStatus.submitted ||
    PaymentStatus.underReview => StatusTone(colors.info, colors.infoContainer),
    PaymentStatus.rejected ||
    PaymentStatus.expired => StatusTone(scheme.error, scheme.errorContainer),
    PaymentStatus.cancelled => StatusTone(scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
    PaymentStatus.unknown => StatusTone(scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
  };
}

class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final StatusTone tone = statusTone(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: tone.background, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(
        statusLabel(context, status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: tone.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
