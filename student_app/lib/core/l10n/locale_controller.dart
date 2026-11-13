/// UI language, persisted and independent of any paper's content language.
library;

import 'package:flutter/material.dart';

import '../storage/prefs_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) : _locale = _initial(_prefs.locale);

  final PrefsStore _prefs;
  Locale _locale;

  static Locale _initial(String saved) => saved == 'en' ? const Locale('en') : const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  String get languageCode => _locale.languageCode;

  Future<void> setLanguage(String code) async {
    final Locale next = _initial(code);
    if (next == _locale) return;
    _locale = next;
    notifyListeners();
    await _prefs.setLocale(next.languageCode);
  }
}