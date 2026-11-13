/// The one-time recovery code. It is never shown again, so the student has to
/// confirm they saved it before continuing.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_context.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/semantic_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_code.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/copy_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class RecoveryCodeScreen extends StatefulWidget {
  const RecoveryCodeScreen({super.key});

  @override
  State<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<RecoveryCodeScreen> {
  bool _saved = false;

  void _finish() {
    context.auth.clearRecoveryCode();
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final String? code = context.auth.recoveryCode;
    final SemanticColors colors = context.semantics;
    if (code == null) {
      return AuthPage(
        title: context.l10n.recoveryCodeTitle,
        child: PrimaryButton(label: context.l10n.continueLabel, onPressed: () => context.go(Routes.home)),
      );
    }
    return AuthPage(
      title: context.l10n.recoveryCodeTitle,
      subtitle: context.l10n.recoveryCodeBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CopyField(
            label: context.l10n.recoveryCode,
            value: code,
            display: groupCode(code),
            emphasise: true,
            monospace: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.warningContainer,
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.warning_amber_rounded, color: colors.warning, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    context.l10n.recoveryCodeWarning,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.warning),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            value: _saved,
            onChanged: (bool? value) => setState(() => _saved = value ?? false),
            title: Text(context.l10n.iSavedIt),
            subtitle: Text(context.l10n.recoverySavedHint),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: context.l10n.continueLabel, onPressed: _saved ? _finish : null),
        ],
      ),
    );
  }
}
