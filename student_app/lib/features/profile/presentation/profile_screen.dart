/// The student's account, settings and the support/legal entry points.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_context.dart';
import '../../../app/app_routes.dart';
import '../../../core/config/env.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/labels.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/directional_chevron.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/domain/entities.dart';
import 'profile_account_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.logoutConfirmTitle),
        content: Text(context.l10n.logoutConfirmBody),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.logout)),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await context.auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: context.l10n.profileTitle,
      showBack: false,
      child: ListenableBuilder(
        listenable: context.auth,
        builder: (BuildContext context, Widget? _) {
          final AppUser? user = context.auth.user;
          final StudentProfile? profile = context.auth.profile;
          final double gutter = AppSpacing.gutterOf(context);
          return ListView(
            padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
            children: <Widget>[
              ProfileAccountCard(
                name: user?.name ?? '',
                email: user?.email,
                phone: user?.phone,
                classLabel: classLabel(context, profile?.classLevel),
                streamLabel: streamLabel(context, profile?.stream),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.settingsTitle),
              Card(
                child: Column(
                  children: <Widget>[
                    _NavTile(
                      icon: Icons.tune_rounded,
                      title: context.l10n.settingsTitle,
                      onTap: () => context.push(Routes.settings),
                    ),
                    const Divider(height: 1),
                    _NavTile(
                      icon: Icons.receipt_long_outlined,
                      title: context.l10n.paymentsTitle,
                      onTap: () => context.push(Routes.payments),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.groupHelp),
              Card(
                child: Column(
                  children: <Widget>[
                    _NavTile(
                      icon: Icons.support_agent_rounded,
                      title: context.l10n.contactSupport,
                      onTap: () => context.push(Routes.support),
                    ),
                    const Divider(height: 1),
                    _NavTile(
                      icon: Icons.bug_report_outlined,
                      title: context.l10n.diagnosticsTitle,
                      onTap: () => context.push(Routes.diagnostics),
                    ),
                    const Divider(height: 1),
                    _NavTile(
                      icon: Icons.person_off_outlined,
                      title: context.l10n.deleteAccount,
                      subtitle: context.l10n.deleteAccountHint,
                      onTap: () => context.push(Routes.support),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: context.l10n.aboutAndLegal),
              Card(
                child: Column(
                  children: <Widget>[
                    _NavTile(
                      icon: Icons.info_outline_rounded,
                      title: context.l10n.aboutApp,
                      onTap: () => context.push(Routes.about),
                    ),
                    const Divider(height: 1),
                    _NavTile(
                      icon: Icons.description_outlined,
                      title: context.l10n.terms,
                      onTap: () => context.push(Routes.terms),
                    ),
                    const Divider(height: 1),
                    _NavTile(
                      icon: Icons.lock_outline_rounded,
                      title: context.l10n.privacy,
                      onTap: () => context.push(Routes.privacy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: ListTile(
                  leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
                  title: Text(context.l10n.logout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  onTap: () => _logout(context),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  context.l10n.version(Env.appVersion),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.title, required this.onTap, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      trailing: const DirectionalChevron(),
      onTap: onTap,
    );
  }
}
