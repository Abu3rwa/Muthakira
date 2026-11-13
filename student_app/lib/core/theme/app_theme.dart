import 'package:flutter/material.dart';

import 'semantic_colors.dart';
import 'tokens.dart';

/// Material 3 themes built from the design tokens. Both modes share the same
/// type scale so Arabic and English line up.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(_lightScheme, Brightness.light, SemanticColors.light);

  static ThemeData dark() => _build(_darkScheme, Brightness.dark, SemanticColors.dark);

  /// Long-form reading (passages, model answers) uses Naskh with generous
  /// line height so tashkeel is never clipped.
  static TextStyle reading({double scale = 1}) => TextStyle(
    fontFamily: AppType.readingFamily,
    fontSize: AppType.readingSize * scale,
    height: AppType.readingLineHeight,
    fontWeight: FontWeight.w400,
  );

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCEAE6),
    onPrimaryContainer: Color(0xFF0F333A),
    secondary: AppColors.accent,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: AppColors.clayLight,
    onSecondaryContainer: Color(0xFF4A2415),
    tertiary: AppColors.tertiaryLight,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: AppColors.sageLight,
    onTertiaryContainer: Color(0xFF1D3B33),
    error: AppColors.error,
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF7DEDB),
    onErrorContainer: Color(0xFF4A0F0F),
    surface: AppColors.surfaceLight,
    onSurface: AppColors.onSurfaceLight,
    onSurfaceVariant: AppColors.onSurfaceVariantLight,
    surfaceContainerLowest: Color(0xFFFFFEFA),
    surfaceContainerLow: AppColors.surfaceLowLight,
    surfaceContainer: AppColors.surfaceContainerLight,
    surfaceContainerHigh: AppColors.surfaceHighLight,
    surfaceContainerHighest: Color(0xFFDED9CE),
    outline: AppColors.outlineLight,
    outlineVariant: AppColors.borderLight,
    inverseSurface: AppColors.onSurfaceLight,
    onInverseSurface: Color(0xFFF4F1E8),
    inversePrimary: AppColors.primaryDark,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: Color(0xFF032B2A),
    primaryContainer: Color(0xFF22474E),
    onPrimaryContainer: Color(0xFFD3ECEE),
    secondary: Color(0xFFE9AD86),
    onSecondary: Color(0xFF3B1F0E),
    secondaryContainer: AppColors.clayDark,
    onSecondaryContainer: Color(0xFFF7DCC9),
    tertiary: AppColors.tertiaryDark,
    onTertiary: Color(0xFF0C2A25),
    tertiaryContainer: AppColors.sageDark,
    onTertiaryContainer: Color(0xFFCBE4DB),
    error: AppColors.errorDark,
    onError: Color(0xFF3C0A0A),
    errorContainer: Color(0xFF5A1B1B),
    onErrorContainer: Color(0xFFFAD9D9),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    surfaceContainerLowest: Color(0xFF0F1E22),
    surfaceContainerLow: AppColors.surfaceLowDark,
    surfaceContainer: AppColors.surfaceContainerDark,
    surfaceContainerHigh: AppColors.surfaceHighDark,
    surfaceContainerHighest: Color(0xFF334B50),
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.borderDark,
    inverseSurface: AppColors.onSurfaceDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary: AppColors.primaryLight,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData _build(ColorScheme scheme, Brightness brightness, SemanticColors semantics) {
    final TextTheme text = _textTheme(scheme);
    final RoundedRectangleBorder control = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.button),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: AppType.uiFamily,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[semantics],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.screen,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: control,
          textStyle: text.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: control,
          side: BorderSide(color: scheme.outlineVariant),
          foregroundColor: scheme.primary,
          textStyle: text.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, AppSpacing.minTapTarget),
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        helperMaxLines: 3,
        errorMaxLines: 3,
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        helperStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        border: const OutlineInputBorder(borderRadius: AppRadii.inputAll, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputAll,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputAll,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(size: 22, color: selected ? scheme.primary : scheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final bool selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            fontSize: AppType.navLabelSize,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        modalBackgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetTop),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sheet)),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.input)),
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final TextTheme base = ThemeData(brightness: scheme.brightness, fontFamily: AppType.uiFamily).textTheme;
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(fontSize: 30, height: 1.3, fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 26, height: 1.3, fontWeight: FontWeight.w700),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 23, height: 1.35, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontSize: 19, height: 1.35, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontSize: 16.5, height: 1.4, fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontSize: 15, height: 1.4, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: AppType.bodySize, height: 1.55),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 15, height: 1.55),
      bodySmall: base.bodySmall?.copyWith(fontSize: AppType.secondarySize, height: 1.5),
      labelLarge: base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
      labelSmall: base.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}
