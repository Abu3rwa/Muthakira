import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../storage/prefs_store.dart';

/// Theme mode, text scale, digit style and data saver, persisted locally.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs)
      : _themeMode = _parseMode(_prefs.themeMode),
        _textScale = _prefs.textScale.clamp(0.85, 1.5),
        _digitStyle = _prefs.digitStyle,
        _dataSaver = _prefs.dataSaver;

  final PrefsStore _prefs;
  ThemeMode _themeMode;
  double _textScale;
  DigitStyle _digitStyle;
  bool _dataSaver;

  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;
  DigitStyle get digitStyle => _digitStyle;
  bool get dataSaver => _dataSaver;

  static ThemeMode _parseMode(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setThemeMode(mode.name);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(0.85, 1.5);
    notifyListeners();
    await _prefs.setTextScale(_textScale);
  }

  Future<void> setDigitStyle(DigitStyle style) async {
    if (style == _digitStyle) return;
    _digitStyle = style;
    notifyListeners();
    await _prefs.setDigitStyle(style);
  }

  Future<void> setDataSaver(bool value) async {
    if (value == _dataSaver) return;
    _dataSaver = value;
    notifyListeners();
    await _prefs.setDataSaver(value);
  }
}
