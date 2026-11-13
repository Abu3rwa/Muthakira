/// Empty, error, offline and "server waking up" states shared by every screen.
library;

import 'package:flutter/material.dart';

import '../../core/errors/error_messages.dart';
import '../../core/errors/failure.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/theme/tokens.dart';
import 'primary_button.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, this.message, this.icon = Icons.inbox_outlined, this.action});

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: scheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...<Widget>[const SizedBox(height: AppSpacing.md), action!],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, required this.onRetry, this.compact = false});

  final AppFailure failure;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String message = failureMessage(l10n, failure);
    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Icon(Icons.error_outline, color: scheme.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    return EmptyView(
      title: l10n.errorTitle,
      message: message,
      icon: failure.isOffline ? Icons.wifi_off_outlined : Icons.error_outline,
      action: PrimaryButton(label: l10n.retry, onPressed: onRetry, icon: Icons.refresh, expanded: false),
    );
  }
}

/// Shown when a request is still running after the cold-start threshold.
class ServerWakingView extends StatelessWidget {
  const ServerWakingView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.serverWaking, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.serverWakingHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.lastUpdated});

  final String? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SemanticColors colors = context.semantics;
    return Container(
      width: double.infinity,
      color: colors.warningContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Icon(Icons.wifi_off_outlined, size: 18, color: colors.warning),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              lastUpdated == null ? l10n.offlineBanner : '${l10n.offlineBanner} ${l10n.lastUpdated(lastUpdated!)}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}