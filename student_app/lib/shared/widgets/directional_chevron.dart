/// A chevron that points toward the reading direction's "forward" side.
library;

import 'package:flutter/material.dart';

class DirectionalChevron extends StatelessWidget {
  const DirectionalChevron({super.key, this.color, this.size = 20});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      size: size,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
