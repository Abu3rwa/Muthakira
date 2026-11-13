/// Inline form rules mirroring the server's Zod schema and phone normaliser.
/// The server re-checks everything; these only save a round trip.
library;

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/digits.dart';

class AuthValidation {
  const AuthValidation._();

  static const int minPassword = 8;
  static const int maxPassword = 128;
  static const int minName = 2;
  static const int maxName = 120;
  static const int maxClassLevel = 80;
  static const int maxEmail = 160;
  static const int minResetCode = 4;
  static const int maxResetCode = 12;
  static const int minRecoveryCode = 4;
  static const int maxRecoveryCode = 40;

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Lowercased, trimmed, Western digits — the same shape the server stores.
  static String normaliseEmail(String raw) => toWesternDigits(raw.trim()).toLowerCase();

  static String? email(AppLocalizations l10n, String raw) {
    final String value = normaliseEmail(raw);
    if (value.isEmpty) return l10n.requiredField;
    if (value.length > maxEmail) return l10n.fieldTooLong(maxEmail);
    return _email.hasMatch(value) ? null : l10n.errorInvalidEmail;
  }

  static String? resetCode(AppLocalizations l10n, String value) {
    final String trimmed = toWesternDigits(value.trim());
    if (trimmed.isEmpty) return l10n.requiredField;
    if (trimmed.length < minResetCode || trimmed.length > maxResetCode) return l10n.errorInvalidResetCode;
    return null;
  }

  static String? password(AppLocalizations l10n, String value) {
    if (value.isEmpty) return l10n.requiredField;
    if (value.length < minPassword) return l10n.fieldPasswordShort;
    if (value.length > maxPassword) return l10n.fieldTooLong(maxPassword);
    return null;
  }

  static String? name(AppLocalizations l10n, String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.requiredField;
    if (trimmed.length < minName) return l10n.fieldTooShort(minName);
    if (trimmed.length > maxName) return l10n.fieldTooLong(maxName);
    return null;
  }

  static String? classLevel(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    if (value.trim().length > maxClassLevel) return l10n.fieldTooLong(maxClassLevel);
    return null;
  }

  static String? recoveryCode(AppLocalizations l10n, String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.requiredField;
    if (trimmed.length < minRecoveryCode) return l10n.fieldTooShort(minRecoveryCode);
    if (trimmed.length > maxRecoveryCode) return l10n.fieldTooLong(maxRecoveryCode);
    return null;
  }

  /// 0 weak, 1 medium, 2 strong. Length plus character variety, nothing clever.
  static int passwordStrength(String value) {
    if (value.length < minPassword) return 0;
    int variety = 0;
    if (value.contains(RegExp(r'[a-z]'))) variety++;
    if (value.contains(RegExp(r'[A-Z]'))) variety++;
    if (value.contains(RegExp(r'\d'))) variety++;
    if (value.contains(RegExp(r'[^A-Za-z0-9]'))) variety++;
    if (value.length >= 12 && variety >= 3) return 2;
    return variety >= 2 ? 1 : 0;
  }
}