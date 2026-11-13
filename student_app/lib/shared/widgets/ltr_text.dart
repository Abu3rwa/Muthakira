/// Renders a Latin or numeric run left-to-right inside Arabic text.
library;

import 'package:flutter/material.dart';

class LtrText extends StatelessWidget {
  const LtrText(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow});

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        data,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Content text whose direction comes from the paper language, not the UI.
class ContentText extends StatelessWidget {
  const ContentText(
    this.data, {
    super.key,
    required this.language,
    this.style,
    this.textAlign,
    this.selectable = false,
  });

  final String data;
  final String language;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = language == 'en' ? TextDirection.ltr : TextDirection.rtl;
    final TextStyle readingStyle = (style ?? const TextStyle()).copyWith(
      fontFamily: 'Naskh',
      fontSize: 18,
      height: 1.75,
    );
    return Directionality(
      textDirection: direction,
      child: selectable
          ? SelectableText(data, style: readingStyle, textAlign: textAlign)
          : Text(data, style: readingStyle, textAlign: textAlign),
    );
  }
}