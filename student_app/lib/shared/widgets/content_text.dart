/// Paper content keeps its own reading direction regardless of the app
/// locale: an Arabic question inside an English UI reads RTL, and an English
/// question inside an Arabic UI reads LTR.
library;

import 'package:flutter/material.dart';

final RegExp _arabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
final RegExp _latin = RegExp(r'[A-Za-z]');

/// Direction of the first strong character, the same rule as `dir="auto"`.
TextDirection contentDirection(String text) {
  for (final int rune in text.runes) {
    final String char = String.fromCharCode(rune);
    if (_arabic.hasMatch(char)) return TextDirection.rtl;
    if (_latin.hasMatch(char)) return TextDirection.ltr;
  }
  return TextDirection.ltr;
}

/// A [Text] that flips direction with its content instead of the app locale.
class ContentText extends StatelessWidget {
  const ContentText(this.text, {super.key, this.style, this.textAlign, this.maxLines, this.overflow});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: contentDirection(text),
      child: Text(text, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow),
    );
  }
}
