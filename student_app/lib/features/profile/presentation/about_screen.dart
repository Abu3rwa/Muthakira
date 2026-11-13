/// About Mothakira: brand, a short description and the legal entry points.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/config/env.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/screens/system_screens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/directional_chevron.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return AppPage(
      title: context.l10n.aboutApp,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, AppSpacing.xl),
        children: <Widget>[
          const Center(child: AppMark(size: 88)),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.tagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(context.l10n.aboutBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.version(Env.appVersion),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(context.l10n.terms),
                  trailing: const DirectionalChevron(),
                  onTap: () => context.push(Routes.terms),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: Text(context.l10n.privacy),
                  trailing: const DirectionalChevron(),
                  onTap: () => context.push(Routes.privacy),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: Text(context.l10n.contactSupport),
                  trailing: const DirectionalChevron(),
                  onTap: () => context.push(Routes.support),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
