import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/features/auth/presentation/auth_validation.dart';

void main() {
  late AppLocalizations en;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('normaliseEmail', () {
    test('trims, lowercases and converts Arabic-Indic digits', () {
      expect(AuthValidation.normaliseEmail('  Student@Example.COM '), 'student@example.com');
      expect(AuthValidation.normaliseEmail('student١٢@example.com'), 'student12@example.com');
    });
  });

  group('email', () {
    test('rejects empty and malformed addresses', () {
      expect(AuthValidation.email(en, ''), en.requiredField);
      expect(AuthValidation.email(en, 'student'), en.errorInvalidEmail);
      expect(AuthValidation.email(en, 'student@example'), en.errorInvalidEmail);
      expect(AuthValidation.email(en, 'student @example.com'), en.errorInvalidEmail);
    });

    test('accepts a normal address with any casing', () {
      expect(AuthValidation.email(en, '  Student@Example.COM '), isNull);
    });
  });

  group('resetCode', () {
    test('accepts a six-digit mailed code', () {
      expect(AuthValidation.resetCode(en, '123456'), isNull);
      expect(AuthValidation.resetCode(en, '١٢٣٤٥٦'), isNull);
    });

    test('rejects empty, too short and too long codes', () {
      expect(AuthValidation.resetCode(en, ''), en.requiredField);
      expect(AuthValidation.resetCode(en, '123'), en.errorInvalidResetCode);
      expect(AuthValidation.resetCode(en, '1234567890123'), en.errorInvalidResetCode);
    });
  });
}
