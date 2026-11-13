/// The reset-success dialog, including a replacement recovery code when the
/// server issued one.
library;

import 'package:flutter/material.dart';

import '../../../../app/app_context.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format_code.dart';
import '../../../../shared/widgets/copy_field.dart';

Future<void> showResetSuccessDialog(
  BuildContext context, {
  required String title,
  required String body,
  String? recoveryCode,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(body),
              if (recoveryCode != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                CopyField(
                  label: dialogContext.l10n.recoveryCode,
                  value: recoveryCode,
                  display: groupCode(recoveryCode),
                  emphasise: true,
                  monospace: true,
                ),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.l10n.signIn),
          ),
        ],
      );
    },
  );
}
