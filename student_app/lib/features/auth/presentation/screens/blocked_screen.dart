/// Shown when the account is suspended: the only way out is support or sign out.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_context.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/copy_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  Future<void> _contactSupport(BuildContext context) async {
    final Uri uri = Uri(scheme: 'https', host: 'wa.me', path: '/${AppInfo.supportWhatsApp}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      context.snack('${context.l10n.support}: ${AppInfo.supportPhone}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(Icons.block_rounded, size: 64, color: scheme.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.blockedTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.blockedBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CopyField(label: context.l10n.support, value: AppInfo.supportPhone),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: context.l10n.contactSupport,
                    icon: Icons.chat_bubble_outline,
                    onPressed: () => _contactSupport(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: () async {
                      await context.auth.logout();
                      if (context.mounted) context.go(Routes.welcome);
                    },
                    child: Text(context.l10n.logout),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
