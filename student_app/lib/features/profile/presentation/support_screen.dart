/// Support page: direct contact channels and a copy fallback, no fake chat.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_context.dart';
import '../../../core/config/constants.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/copy_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (!opened && context.mounted) context.snack(context.l10n.couldNotOpen);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? email = context.auth.user?.email;
    final double gutter = AppSpacing.gutterOf(context);
    return AppPage(
      title: context.l10n.support,
      child: ListView(
        padding: EdgeInsets.fromLTRB(gutter, AppSpacing.sm, gutter, AppSpacing.xl),
        children: <Widget>[
          Text(context.l10n.paymentHelp, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.paymentHelpBody,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if ((email ?? '').isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: context.l10n.accountDetails),
            CopyField(label: context.l10n.email, value: email!, monospace: true),
          ],
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.l10n.supportPhoneLabel),
          CopyField(label: context.l10n.supportPhoneLabel, value: AppInfo.supportPhone, monospace: true),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: context.l10n.callSupport,
            icon: Icons.call_outlined,
            onPressed: () => _open(context, Uri(scheme: 'tel', path: AppInfo.supportPhone)),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: context.l10n.supportWhatsAppLabel),
          CopyField(label: context.l10n.supportWhatsAppLabel, value: AppInfo.supportWhatsApp, monospace: true),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: context.l10n.openWhatsApp,
            icon: Icons.chat_outlined,
            onPressed: () => _open(context, Uri.parse('https://wa.me/${AppInfo.supportWhatsApp}')),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Text(
              context.l10n.deleteAccountHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
