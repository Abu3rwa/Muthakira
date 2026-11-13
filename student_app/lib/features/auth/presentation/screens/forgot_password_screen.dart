/// Password reset: a 6-digit code sent by email, or the recovery code saved
/// at signup when the student has no access to that inbox.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_context.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../auth_validation.dart';
import 'reset_success_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _codeSent = false;
  bool _useRecoveryCode = false;
  bool _obscure = true;
  bool _showErrors = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _showErrors = true);
    if (AuthValidation.email(context.l10n, _email.text) != null) return;
    final String email = AuthValidation.normaliseEmail(_email.text);
    final bool ok = await context.auth.forgotPassword(email: email);
    if (!ok || !mounted) return;
    setState(() => _codeSent = true);
    context.snack(context.l10n.resetCodeSentTo(email));
  }

  Future<void> _resetWithCode() async {
    setState(() => _showErrors = true);
    final String? codeError = AuthValidation.resetCode(context.l10n, _code.text);
    final String? passwordError = AuthValidation.password(context.l10n, _password.text);
    if (codeError != null || passwordError != null) return;
    final bool ok = await context.auth.resetPasswordWithCode(
      email: AuthValidation.normaliseEmail(_email.text),
      code: _code.text.trim(),
      newPassword: _password.text,
    );
    if (!ok || !mounted) return;
    context.auth.clearResetState();
    await showResetSuccessDialog(context, 
      title: context.l10n.resetSuccessTitle,
      body: context.l10n.passwordChangedBody,
    );
    if (!mounted) return;
    context.go(Routes.login);
  }

  Future<void> _resetWithRecoveryCode() async {
    setState(() => _showErrors = true);
    final String? codeError = AuthValidation.recoveryCode(context.l10n, _code.text);
    final String? passwordError = AuthValidation.password(context.l10n, _password.text);
    if (codeError != null || passwordError != null) return;
    final bool ok = await context.auth.recoveryReset(
      email: AuthValidation.normaliseEmail(_email.text),
      recoveryCode: _code.text.trim(),
      newPassword: _password.text,
    );
    if (!ok || !mounted) return;
    final String? newCode = context.auth.recoveryCode;
    await showResetSuccessDialog(context, 
      title: context.l10n.resetSuccessTitle,
      body: context.l10n.resetSuccessBody,
      recoveryCode: newCode,
    );
    if (!mounted) return;
    context.auth.clearRecoveryCode();
    context.go(Routes.login);
  }

  void _switchMode() {
    setState(() {
      _useRecoveryCode = !_useRecoveryCode;
      _showErrors = false;
      _code.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.auth,
      builder: (BuildContext context, Widget? _) {
        final AppFailure? failure = context.auth.failure;
        final bool busy = context.auth.isBusy;
        final bool showCodeFields = _useRecoveryCode || _codeSent;
        final int expirySeconds = context.auth.resetExpiresIn ?? 0;
        final int expiryMinutes = (expirySeconds / 60).ceil();
        return AuthPage(
          showBack: true,
          title: context.l10n.forgotPasswordTitle,
          subtitle: showCodeFields
              ? context.l10n.forgotPasswordCodeBody
              : context.l10n.forgotPasswordBody,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppTextField(
                label: context.l10n.email,
                hint: context.l10n.emailHint,
                controller: _email,
                enabled: !_codeSent,
                keyboardType: TextInputType.emailAddress,
                textInputAction: showCodeFields ? TextInputAction.next : TextInputAction.done,
                autofillHints: const <String>[AutofillHints.email],
                normaliseDigits: true,
                textDirection: TextDirection.ltr,
                onSubmitted: showCodeFields ? null : (_) => _sendCode(),
                errorText: _showErrors ? AuthValidation.email(context.l10n, _email.text) : null,
              ),
              if (!showCodeFields) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: context.l10n.sendResetCode,
                  isLoading: busy,
                  onPressed: busy ? null : _sendCode,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _switchMode,
                  child: Text(context.l10n.useSavedRecoveryCode),
                ),
              ] else ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                if (_codeSent && !_useRecoveryCode) ...<Widget>[
                  Text(
                    context.l10n.resetCodeSentTo(AuthValidation.normaliseEmail(_email.text)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (expiryMinutes > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: Text(
                        context.l10n.resetCodeExpiry(expiryMinutes),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppTextField(
                  label: _useRecoveryCode ? context.l10n.recoveryCode : context.l10n.resetCode,
                  hint: _useRecoveryCode ? null : context.l10n.resetCodeHint,
                  controller: _code,
                  keyboardType: _useRecoveryCode ? TextInputType.text : TextInputType.number,
                  textInputAction: TextInputAction.next,
                  normaliseDigits: true,
                  textDirection: TextDirection.ltr,
                  errorText: _showErrors
                      ? (_useRecoveryCode
                            ? AuthValidation.recoveryCode(context.l10n, _code.text)
                            : AuthValidation.resetCode(context.l10n, _code.text))
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: context.l10n.newPassword,
                  hint: context.l10n.passwordHint,
                  controller: _password,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _useRecoveryCode ? _resetWithRecoveryCode() : _resetWithCode(),
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    tooltip: _obscure ? context.l10n.showPassword : context.l10n.hidePassword,
                  ),
                  errorText: _showErrors ? AuthValidation.password(context.l10n, _password.text) : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: context.l10n.resetPassword,
                  isLoading: busy,
                  onPressed: busy
                      ? null
                      : (_useRecoveryCode ? _resetWithRecoveryCode : _resetWithCode),
                ),
                TextButton(
                  onPressed: busy ? null : _switchMode,
                  child: Text(
                    _useRecoveryCode ? context.l10n.useEmailedCode : context.l10n.useSavedRecoveryCode,
                  ),
                ),
                if (!_useRecoveryCode)
                  TextButton(
                    onPressed: busy ? null : _sendCode,
                    child: Text(context.l10n.resendCode),
                  ),
              ],
              if (failure != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  failureMessage(context.l10n, failure),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
