/// Creating an account. The recovery code is shown once, on the next screen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_context.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/preset_picker.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../auth_validation.dart';
import 'signup_form_parts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _classLevel;
  String? _stream;
  bool _terms = false;
  bool _obscure = true;
  bool _showErrors = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _showErrors = true);
    final AppLocalizations l10n = context.l10n;
    final String? nameError = AuthValidation.name(l10n, _name.text);
    final String? emailError = AuthValidation.email(l10n, _email.text);
    final String? passwordError = AuthValidation.password(l10n, _password.text);
    final String? levelError = AuthValidation.classLevel(l10n, _classLevel);
    final bool termsError = !_terms;
    if (nameError != null || emailError != null || passwordError != null || levelError != null || termsError) {
      return;
    }
    final bool ok = await context.auth.signup(
      email: AuthValidation.normaliseEmail(_email.text),
      password: _password.text,
      name: _name.text.trim(),
      classLevel: _classLevel!,
      stream: _stream,
      language: context.read<LocaleController>().languageCode,
    );
    if (!ok || !mounted) return;
    final AppFailure? failure = context.auth.failure;
    if (failure != null) {
      context.snack(failureMessage(l10n, failure));
    } else if (context.auth.recoveryCode != null) {
      context.go(Routes.recovery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[context.auth, context.localeController]),
      builder: (BuildContext context, Widget? _) {
        final AppLocalizations l10n = context.l10n;
        final String language = context.localeController.languageCode;
        return AuthPage(
          showBack: true,
          title: l10n.signupTitle,
          subtitle: l10n.signupSubtitle,
          footer: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(l10n.haveAccount, style: Theme.of(context).textTheme.bodyMedium),
              TextButton(onPressed: () => context.go(Routes.login), child: Text(l10n.signIn)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppTextField(
                label: l10n.name,
                hint: l10n.nameHint,
                controller: _name,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.name],
                errorText: _showErrors ? AuthValidation.name(l10n, _name.text) : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.email,
                hint: l10n.emailHint,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                normaliseDigits: true,
                textDirection: TextDirection.ltr,
                errorText: _showErrors ? AuthValidation.email(l10n, _email.text) : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.password,
                hint: l10n.passwordHint,
                controller: _password,
                obscure: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.newPassword],
                helper: l10n.passwordHint,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                ),
                errorText: _showErrors ? AuthValidation.password(l10n, _password.text) : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PresetPicker(
                label: l10n.classLevel,
                hint: l10n.classLevelHint,
                initialValue: _classLevel,
                options: <ChoiceOption>[
                  ChoiceOption(value: 'secondary_1', label: l10n.secondary1),
                  ChoiceOption(value: 'secondary_2', label: l10n.secondary2),
                  ChoiceOption(value: 'secondary_3', label: l10n.secondary3),
                ],
                errorText: _showErrors ? AuthValidation.classLevel(l10n, _classLevel) : null,
                onChanged: (String? value) => setState(() => _classLevel = value),
              ),
              const SizedBox(height: AppSpacing.md),
              PresetPicker(
                label: l10n.stream,
                hint: l10n.streamHint,
                noneLabel: l10n.streamNone,
                initialValue: _stream,
                options: <ChoiceOption>[
                  ChoiceOption(value: 'science', label: l10n.streamScience),
                  ChoiceOption(value: 'literary', label: l10n.streamLiterary),
                ],
                onChanged: (String? value) => setState(() => _stream = value),
              ),
              const SizedBox(height: AppSpacing.md),
              PreferredLanguageField(
                language: language,
                onChanged: (String code) => context.localeController.setLanguage(code),
              ),
              const SizedBox(height: AppSpacing.sm),
              TermsCheckbox(
                value: _terms,
                onChanged: (bool value) => setState(() => _terms = value),
                errorText: _showErrors && !_terms ? l10n.fieldTermsRequired : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: l10n.signUp,
                isLoading: context.auth.isBusy,
                onPressed: context.auth.isBusy ? null : _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
