/// Design tokens: every colour, spacing, radius and duration in one place.
///
/// Palette: a contemporary Sudanese study space — warm paper, Nile blue,
/// restrained terracotta and sage. No decorative heritage motifs.
library;

import 'package:flutter/material.dart';

class AppColors {
  /// Nile blue — the single primary action colour.
  static const Color primaryLight = Color(0xFF173F48);
  static const Color primaryDark = Color(0xFF9ECDD2);

  /// Terracotta accent, used sparingly (price emphasis, cover details).
  static const Color accent = Color(0xFF985A3B);
  static const Color tertiaryLight = Color(0xFF356C64);
  static const Color tertiaryDark = Color(0xFFA9C9C0);

  static const Color success = Color(0xFF2F7D5B);
  static const Color warning = Color(0xFF8A6400);
  static const Color error = Color(0xFFB3403A);
  static const Color info = Color(0xFF24606C);

  static const Color successDark = Color(0xFF8FD3B0);
  static const Color warningDark = Color(0xFFF0C86A);
  static const Color errorDark = Color(0xFFF08A8A);
  static const Color infoDark = Color(0xFF9ECDD2);

  /// Warm paper background.
  static const Color surfaceLight = Color(0xFFF7F4ED);
  static const Color surfaceDark = Color(0xFF14262B);

  /// Raised card surface.
  static const Color surfaceContainerLight = Color(0xFFF1EDE4);
  static const Color surfaceContainerDark = Color(0xFF1A2C31);

  static const Color surfaceLowLight = Color(0xFFFBF9F3);
  static const Color surfaceHighLight = Color(0xFFE7E3D9);
  static const Color surfaceLowDark = Color(0xFF20353A);
  static const Color surfaceHighDark = Color(0xFF294046);

  static const Color onSurfaceLight = Color(0xFF203E43);
  static const Color onSurfaceVariantLight = Color(0xFF596967);
  static const Color onSurfaceDark = Color(0xFFE7EEEC);
  static const Color onSurfaceVariantDark = Color(0xFFB1C2BE);

  static const Color outlineLight = Color(0xFF7C8A88);
  static const Color outlineDark = Color(0xFF7A908F);

  static const Color borderLight = Color(0xFFD8DDD4);
  static const Color borderDark = Color(0xFF42585B);

  /// Quiet success surface (sage).
  static const Color sageLight = Color(0xFFEAF0E9);
  static const Color sageDark = Color(0xFF2B4242);

  /// Clay tint behind terracotta accents.
  static const Color clayLight = Color(0xFFF4E3D7);
  static const Color clayDark = Color(0xFF402E22);
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Normal phone gutter. 320dp screens use [gutterOf] for 16.
  static const double screen = 20;
  static const double screenNarrow = 16;
  static const double minTapTarget = 48;

  static double gutterOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= 320 ? screenNarrow : screen;

  static EdgeInsetsGeometry pageGutter(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: gutterOf(context));
}

class AppRadii {
  static const double input = 12;
  static const double button = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius buttonAll = BorderRadius.all(Radius.circular(button));
  static const BorderRadius sheetTop = BorderRadius.vertical(top: Radius.circular(sheet));
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Curve curve = Curves.easeOutCubic;
}

class AppType {
  static const String readingFamily = 'Naskh';
  static const String uiFamily = 'PlexArabic';

  /// Arabic reading text needs generous leading so diacritics are never clipped.
  static const double readingLineHeight = 1.8;
  static const double readingSize = 22;

  /// Long passages may use the compact reading size, never smaller.
  static const double readingSizeLong = 20;
  static const double bodySize = 16;
  static const double secondarySize = 13;
  static const double navLabelSize = 12.5;
}
