/// Local preferences: appearance, reading, language, digits, data and help.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/config/constants.dart';
import '../../../core/l10n/formatters.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/directional_chevron.dart';
import '../../../shared/widgets/section_header.dart';
import 'settings_samples.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearCache(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.clearCacheConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(context.l10n.clearCacheConfirmBody),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.clearCacheIncludesQueue,
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.clearCache)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final services = context.services;
    final String? userId = services.scope.userId;
    if (userId != null) await services.cache.wipeUser(userId);
    await services.prefs.clearUserData();
    if (context.mounted) context.snack(context.l10n.cacheCleared);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double gutter = AppSpacing.gutterOf(context);
    return AppPage(
      title: context.l10n.settingsTitle,
      child: ListenableBuilder(
        listenable: Listenable.merge(<Listenable>[context.localeController, context.themeController]),
        builder: (BuildContext context, Widget? _) {
          final locale = context.localeController;
          final themeController = context.themeController;
          return ListView(
            padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
            children: <Widget>[
              SectionHeader(title: context.l10n.appearance),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SegmentedButton<ThemeMode>(
                        segments: <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            icon: const Icon(Icons.brightness_auto_outlined),
                            label: Text(context.l10n.themeSystem),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: const Icon(Icons.light_mode_outlined),
                            label: Text(context.l10n.themeLight),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: const Icon(Icons.dark_mode_outlined),
                            label: Text(context.l10n.themeDark),
                          ),
                        ],
                        selected: <ThemeMode>{themeController.themeMode},
                        onSelectionChanged: (Set<ThemeMode> value) => themeController.setThemeMode(value.first),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const ThemeSample(),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.appearanceHint,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.groupReading),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(context.l10n.textSize, style: theme.textTheme.titleSmall),
                          const Spacer(),
                          Text(context.fmt.textScale(themeController.textScale), style: theme.textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const ReadingSample(),
                      Slider(
                        value: themeController.textScale,
                        min: Limits.minTextScale,
                        max: Limits.maxTextScale,
                        divisions: 13,
                        label: context.fmt.textScale(themeController.textScale),
                        onChanged: themeController.setTextScale,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.groupLanguageNumbers),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(context.l10n.appLanguage, style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      SegmentedButton<String>(
                        segments: <ButtonSegment<String>>[
                          ButtonSegment<String>(value: 'ar', label: Text(context.l10n.languageArabic)),
                          ButtonSegment<String>(value: 'en', label: Text(context.l10n.languageEnglish)),
                        ],
                        selected: <String>{locale.languageCode},
                        onSelectionChanged: (Set<String> value) => locale.setLanguage(value.first),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.appLanguageHint,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Divider(height: AppSpacing.lg, color: theme.colorScheme.outlineVariant),
                      Text(context.l10n.digitStyle, style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      SegmentedButton<DigitStyle>(
                        segments: <ButtonSegment<DigitStyle>>[
                          ButtonSegment<DigitStyle>(
                            value: DigitStyle.arabicIndic,
                            label: Text(context.l10n.digitsArabic),
                          ),
                          ButtonSegment<DigitStyle>(
                            value: DigitStyle.western,
                            label: Text(context.l10n.digitsWestern),
                          ),
                        ],
                        selected: <DigitStyle>{themeController.digitStyle},
                        onSelectionChanged: (Set<DigitStyle> value) => themeController.setDigitStyle(value.first),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.digitStyleHint,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.groupData),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: Text(context.l10n.clearCache),
                  subtitle: Text(context.l10n.clearCacheIncludesQueue),
                  onTap: () => _clearCache(context),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.groupHelp),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.support_agent_rounded),
                      title: Text(context.l10n.contactSupport),
                      trailing: const DirectionalChevron(),
                      onTap: () => context.push(Routes.support),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bug_report_outlined),
                      title: Text(context.l10n.diagnosticsTitle),
                      trailing: const DirectionalChevron(),
                      onTap: () => context.push(Routes.diagnostics),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
