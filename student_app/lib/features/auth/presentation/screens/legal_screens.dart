/// Terms and privacy, reachable before and after sign-up.
library;

import 'package:flutter/material.dart';

import '../../../../app/app_context.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.termsTitle,
      child: const _LegalBody(field: _LegalField.terms),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.privacyTitle,
      child: const _LegalBody(field: _LegalField.privacy),
    );
  }
}

enum _LegalField { terms, privacy }

class _LegalBody extends StatelessWidget {
  const _LegalBody({required this.field});

  final _LegalField field;

  @override
  Widget build(BuildContext context) {
    final String body = field == _LegalField.terms ? context.l10n.termsBody : context.l10n.privacyBody;
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: arabic ? AppType.readingFamily : null,
                  fontSize: AppType.readingSizeLong,
                  height: AppType.readingLineHeight,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppInfo.privacyUrl,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
