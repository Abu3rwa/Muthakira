/// Email + password sign-in.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _showErrors = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _showErrors = true);
    final String? emailError = AuthValidation.email(context.l10n, _email.text);
    final String? passwordError = AuthValidation.password(
      context.l10n,
      _password.text,
    );
    if (emailError != null || passwordError != null) return;
    final bool ok = await context.auth.login(
      email: AuthValidation.normaliseEmail(_email.text),
      password: _password.text,
    );
    // Kept on screen by the controller so the entered values stay and the
    // failure is reported once, next to the form.
    if (!ok) return;
    // Lets Android/Google offer to save the credentials that just worked.
    TextInput.finishAutofillContext();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.auth,
      builder: (BuildContext context, Widget? _) {
        final AppFailure? failure = context.auth.failure;
        return AuthPage(
          showBack: true,
          title: context.l10n.loginTitle,
          subtitle: context.l10n.loginSubtitle,
          footer: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                context.l10n.noAccount,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => context.go(Routes.signup),
                child: Text(context.l10n.signUp),
              ),
            ],
          ),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  label: context.l10n.email,
                  hint: context.l10n.emailHint,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  normaliseDigits: true,
                  textDirection: TextDirection.ltr,
                  errorText: _showErrors
                      ? AuthValidation.email(context.l10n, _email.text)
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: context.l10n.password,
                  hint: context.l10n.passwordHint,
                  controller: _password,
                  obscure: _obscure,
                  autofillHints: const <String>[AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    tooltip: _obscure
                        ? context.l10n.showPassword
                        : context.l10n.hidePassword,
                  ),
                  errorText: _showErrors
                      ? AuthValidation.password(context.l10n, _password.text)
                      : null,
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => context.go(Routes.forgot),
                    child: Text(context.l10n.forgotPassword),
                  ),
                ),
                if (failure != null) ...<Widget>[
                  Text(
                    failureMessage(context.l10n, failure),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                PrimaryButton(
                  label: context.l10n.signIn,
                  isLoading: context.auth.isBusy,
                  onPressed: context.auth.isBusy ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
