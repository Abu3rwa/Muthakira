/// Section header and the small "saved / pending sync" badges.
library;

import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/theme/tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.padding});

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class SavedBadge extends StatelessWidget {
  const SavedBadge({super.key, this.pending = false});

  final bool pending;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SemanticColors colors = context.semantics;
    final Color background = pending ? colors.warningContainer : colors.successContainer;
    final Color foreground = pending ? colors.warning : colors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(pending ? Icons.sync_outlined : Icons.check_circle_outline, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              pending ? l10n.pendingSyncBadge : l10n.savedBadge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({super.key, required this.title, this.icon = Icons.hourglass_empty_rounded});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadii.cardAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: scheme.outline),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '${l10n.comingSoon} · ${l10n.comingSoonHint}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}