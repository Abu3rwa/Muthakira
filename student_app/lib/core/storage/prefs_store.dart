import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/formatters.dart';

/// Small, non-secret preferences. Tokens never go here.
class PrefsStore {
  PrefsStore(this._prefs);

  static const _kLocale = 'settings.locale';
  static const _kTheme = 'settings.theme';
  static const _kTextScale = 'settings.text_scale';
  static const _kDigits = 'settings.digits';
  static const _kDataSaver = 'settings.data_saver';
  static const _kOnboarding = 'onboarding.done';
  static const _kTerms = 'onboarding.terms_accepted';
  static const _kLastAttempts = 'practice.last_attempts';

  final SharedPreferences _prefs;

  static Future<PrefsStore> open() async => PrefsStore(await SharedPreferences.getInstance());

  String get locale => _prefs.getString(_kLocale) ?? 'ar';
  Future<void> setLocale(String value) => _prefs.setString(_kLocale, value);

  String get themeMode => _prefs.getString(_kTheme) ?? 'system';
  Future<void> setThemeMode(String value) => _prefs.setString(_kTheme, value);

  double get textScale => _prefs.getDouble(_kTextScale) ?? 1;
  Future<void> setTextScale(double value) => _prefs.setDouble(_kTextScale, value);

  DigitStyle get digitStyle =>
      _prefs.getString(_kDigits) == 'western' ? DigitStyle.western : DigitStyle.arabicIndic;
  Future<void> setDigitStyle(DigitStyle value) =>
      _prefs.setString(_kDigits, value == DigitStyle.western ? 'western' : 'arabic');

  bool get dataSaver => _prefs.getBool(_kDataSaver) ?? true;
  Future<void> setDataSaver(bool value) => _prefs.setBool(_kDataSaver, value);

  bool get onboardingDone => _prefs.getBool(_kOnboarding) ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool(_kOnboarding, true);

  bool get termsAccepted => _prefs.getBool(_kTerms) ?? false;
  Future<void> setTermsAccepted(bool value) => _prefs.setBool(_kTerms, value);

  Map<String, String> get _lastAttempts {
    final raw = _prefs.getString(_kLastAttempts);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
    } on FormatException {
      return const {};
    }
    return const {};
  }

  String? lastAttemptFor(String examId) => _lastAttempts[examId];

  Future<void> setLastAttempt(String examId, String attemptId) async {
    final map = Map<String, String>.from(_lastAttempts)..[examId] = attemptId;
    await _prefs.setString(_kLastAttempts, jsonEncode(map));
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_kLastAttempts);
  }
}
