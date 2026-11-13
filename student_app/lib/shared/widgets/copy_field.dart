/// A read-only value with a large copy button: account numbers, references,
/// payment codes. Numbers always render as an isolated LTR run.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/bidi.dart';

class CopyField extends StatelessWidget {
  const CopyField({
    super.key,
    required this.label,
    required this.value,
    this.display,
    this.emphasise = false,
    this.monospace = false,
  });

  final String label;
  final String value;

  /// Shown instead of [value] when a grouped form is easier to read; the copy
  /// action always uses the raw [value].
  final String? display;
  final bool emphasise;
  final bool monospace;

  Future<void> _copy(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    await HapticFeedback.selectionClick();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.copied), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: emphasise ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: AppRadii.inputAll,
        border: emphasise ? Border.all(color: scheme.primary, width: 2) : null,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: emphasise ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    isolateLtr(display ?? value),
                    style: (emphasise ? theme.textTheme.headlineSmall : theme.textTheme.titleMedium)
                        ?.copyWith(
                          color: emphasise ? scheme.onPrimaryContainer : scheme.onSurface,
                          fontFamily: monospace ? 'monospace' : null,
                          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                          letterSpacing: monospace ? 1.2 : 0,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton.filledTonal(
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_rounded),
            tooltip: l10n.copy,
            iconSize: 22,
            style: IconButton.styleFrom(minimumSize: const Size.square(AppSpacing.minTapTarget)),
          ),
        ],
      ),
    );
  }
}