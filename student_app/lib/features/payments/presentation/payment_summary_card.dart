/// The server summary: package, status, exact amount and copyable codes.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/copy_field.dart';
import '../domain/payment_models.dart';
import 'payment_widgets.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.request, this.showInstructions = true});

  final PaymentRequest request;
  final bool showInstructions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String packageName = request.package.name.resolve(context.localeController.languageCode);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    packageName.isEmpty ? context.l10n.packagesTitle : packageName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                PaymentStatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.expectedAmountLabel,
              style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(context.fmt.sdg(request.expectedAmountSdg), style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            CopyField(label: context.l10n.paymentCode, value: request.paymentCode, emphasise: true, monospace: true),
            const SizedBox(height: AppSpacing.sm),
            CopyField(label: context.l10n.expectedAmountLabel, value: context.fmt.sdg(request.expectedAmountSdg)),
            if (showInstructions) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Icon(Icons.info_outline, size: 18, color: context.semantics.warning),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      context.l10n.exactAmountWarning,
                      style: theme.textTheme.bodySmall?.copyWith(color: context.semantics.warning),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
