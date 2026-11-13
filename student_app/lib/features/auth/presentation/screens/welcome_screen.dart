/// First launch: what the app is, then sign up or sign in.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_context.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/screens/system_screens.dart';
import '../../../../shared/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListenableBuilder(
              listenable: context.localeController,
              builder: (BuildContext context, Widget? _) => SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutterOf(context),
                  AppSpacing.md,
                  AppSpacing.gutterOf(context),
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _LanguageChoice(languageCode: context.localeController.languageCode),
                    const SizedBox(height: AppSpacing.lg),
                    const Center(child: AppMark(size: 88)),
                    const SizedBox(height: AppSpacing.lg),
                    Text(context.l10n.appName, style: text.displaySmall, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.tagline,
                      style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(context.l10n.welcomeTitle, style: text.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.welcomeBody,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Point(icon: Icons.quiz_outlined, text: context.l10n.welcomePoint1),
                    _Point(icon: Icons.lock_open_rounded, text: context.l10n.welcomePoint2),
                    _Point(icon: Icons.offline_bolt_outlined, text: context.l10n.welcomePoint3),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: context.l10n.getStarted,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.go(Routes.signup),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          context.l10n.haveAccount,
                          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () => context.go(Routes.login),
                          child: Text(context.l10n.signIn),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          context.l10n.language,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: <ButtonSegment<String>>[
            ButtonSegment<String>(value: 'ar', label: Text(context.l10n.languageArabic)),
            ButtonSegment<String>(value: 'en', label: Text(context.l10n.languageEnglish)),
          ],
          selected: <String>{languageCode},
          onSelectionChanged: (Set<String> value) => context.localeController.setLanguage(value.first),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll<TextStyle?>(Theme.of(context).textTheme.labelMedium),
          ),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(AppRadii.input)),
            child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
