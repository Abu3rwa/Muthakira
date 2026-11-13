/// Package row with its selected state, and the open-request notice.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';
import '../domain/payment_models.dart';

class PackageRow extends StatelessWidget {
  const PackageRow({super.key, required this.package, required this.selected, required this.onSelect});

  final CreditPackage package;
  final bool selected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String name = package.name.resolve(context.localeController.languageCode);
    final int perCredit = package.credits == 0 ? package.priceSdg : (package.priceSdg / package.credits).round();
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: AppRadii.cardAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelect,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadii.cardAll,
              border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selected ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name.isEmpty ? context.l10n.packageCredits(package.credits) : name,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        context.l10n.packageCredits(package.credits),
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (package.credits > 0)
                        Text(
                          context.l10n.pricePerCredit(context.fmt.sdg(perCredit)),
                          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(context.fmt.sdg(package.priceSdg), style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OpenRequestNotice extends StatelessWidget {
  const OpenRequestNotice({super.key, required this.text, required this.onSeeAll});

  final String text;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: AppRadii.cardAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
          TextButton(onPressed: onSeeAll, child: Text(context.l10n.seeAll)),
        ],
      ),
    );
  }
}
