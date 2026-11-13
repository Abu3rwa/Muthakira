/// Digit conversion: Arabic-Indic and Persian digits to Western and back.
library;

const String _western = '0123456789';
const String _arabicIndic = '٠١٢٣٤٥٦٧٨٩';
const String _persian = '۰۱۲۳۴۵۶۷۸۹';

/// Converts every Arabic-Indic/Persian digit in [value] to a Western digit.
String toWesternDigits(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final arabic = _arabicIndic.indexOf(char);
    final persian = _persian.indexOf(char);
    if (arabic >= 0) {
      buffer.write(_western[arabic]);
    } else if (persian >= 0) {
      buffer.write(_western[persian]);
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// Renders Western digits as Arabic-Indic; other characters are untouched.
String toArabicIndicDigits(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final index = _western.indexOf(char);
    buffer.write(index >= 0 ? _arabicIndic[index] : char);
  }
  return buffer.toString();
}

/// Strips spaces and thousands separators, then parses a finite number.
double? parseLooseNumber(String value) {
  final cleaned = toWesternDigits(value).replaceAll(RegExp(r'[\s,٬٫]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

/// True when the text contains at least one Arabic letter.
bool containsArabic(String value) => RegExp(r'[؀-ۿ]').hasMatch(value);