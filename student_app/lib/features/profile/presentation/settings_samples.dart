/// Small live previews used by the settings sections.
library;

import 'package:flutter/material.dart';

import '../../../app/app_context.dart';
import '../../../core/theme/tokens.dart';

/// A miniature of the active theme: primary colour, header and secondary text.
class ThemeSample extends StatelessWidget {
  const ThemeSample({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.inputAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(AppRadii.input)),
            alignment: Alignment.center,
            child: Icon(Icons.menu_book_rounded, size: 20, color: scheme.onPrimary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.appName,
                  style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurface),
                ),
                Text(
                  context.l10n.tagline,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A sentence with diacritics so the chosen text size can be judged on real
/// Arabic reading, not a short label.
class ReadingSample extends StatelessWidget {
  const ReadingSample({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.readingSample,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
      textAlign: TextAlign.start,
    );
  }
}
