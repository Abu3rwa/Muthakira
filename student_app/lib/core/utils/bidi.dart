/// Bidirectional text helpers. Arabic UI text must never let a Latin run (a
/// phone number, an amount, a reference) reorder the surrounding sentence.
library;

import 'package:flutter/painting.dart';

import '../config/constants.dart';

const String _lri = '\u2066'; // left-to-right isolate
const String _rli = '\u2067'; // right-to-left isolate
const String _pdi = '\u2069'; // pop directional isolate

/// Wraps a Latin/numeric run so it always reads left-to-right inside Arabic.
String isolateLtr(String value) => value.isEmpty ? value : '$_lri$value$_pdi';

/// Wraps an Arabic run so it stays right-to-left inside an English sentence.
String isolateRtl(String value) => value.isEmpty ? value : '$_rli$value$_pdi';

/// Content direction comes from the paper's language, never the UI language.
TextDirection directionOfLanguage(String language) =>
    language == 'en' ? TextDirection.ltr : TextDirection.rtl;

/// Option letters exactly as the backend marks them: أ ب ج … or A B C …
List<String> optionLettersFor(String language) =>
    language == 'en' ? AppConstants.englishLetters : AppConstants.arabicLetters;

String optionLetterAt(String language, int index) {
  final List<String> letters = optionLettersFor(language);
  if (index < 0 || index >= letters.length) return '';
  return letters[index];
}

/// True when the text is mostly Arabic script, for content that arrives
/// without an explicit language.
bool isMostlyArabic(String text) {
  var arabic = 0;
  var latin = 0;
  for (final int rune in text.runes) {
    if (rune >= 0x0600 && rune <= 0x06FF) arabic += 1;
    if (rune >= 0x0041 && rune <= 0x007A) latin += 1;
  }
  return arabic >= latin;
}