/// Optional fields of the sign-up form, kept apart from the page layout.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_context.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';

class PreferredLanguageField extends StatelessWidget {
  const PreferredLanguageField({super.key, required this.language, required this.onChanged});

  final String language;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.preferredLanguage, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xxs),
        SegmentedButton<String>(
          segments: <ButtonSegment<String>>[
            ButtonSegment<String>(value: 'ar', label: Text(l10n.languageArabic)),
            ButtonSegment<String>(value: 'en', label: Text(l10n.languageEnglish)),
          ],
          selected: <String>{language},
          onSelectionChanged: (Set<String> value) => onChanged(value.first),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.preferredLanguageHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({super.key, required this.value, required this.onChanged, this.errorText});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Checkbox(value: value, onChanged: (bool? next) => onChanged(next ?? false)),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(l10n.termsAccept, style: Theme.of(context).textTheme.bodyMedium),
                  InkWell(
                    onTap: () => context.push(Routes.terms),
                    child: Text(
                      l10n.terms,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
