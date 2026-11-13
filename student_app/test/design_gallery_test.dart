import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/tokens.dart';
import 'package:student_app/features/profile/presentation/gallery_screen.dart';
import 'package:student_app/shared/widgets/primary_button.dart';

/// First redesign gate: the component gallery must render every control
/// without clipping at 320dp, at 1.5× text, in light and dark.
void main() {
  Future<void> openGallery(
    WidgetTester tester, {
    required String language,
    required double width,
    double textScale = 1,
    bool dark = false,
  }) async {
    tester.view.physicalSize = Size(width, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: const DesignGalleryScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  void expectControlsIntact(WidgetTester tester, {required double width, required String language}) {
    expect(tester.takeException(), isNull);
    final BuildContext context = tester.element(find.byType(DesignGalleryScreen));
    expect(
      Directionality.of(context),
      language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
    );
    final double gutter = width <= 320 ? AppSpacing.screenNarrow : AppSpacing.screen;
    for (final Finder button in <Finder>[
      find.byType(FilledButton),
      find.byType(OutlinedButton),
    ]) {
      expect(button, findsWidgets);
      for (final Element element in button.evaluate()) {
        final Rect rect = tester.getRect(find.byWidget(element.widget));
        expect(rect.height, greaterThanOrEqualTo(AppSpacing.minTapTarget));
        expect(rect.left, greaterThanOrEqualTo(gutter - 0.01));
        expect(rect.right, lessThanOrEqualTo(width - gutter + 0.01));
      }
    }
    for (final Finder group in <Finder>[
      find.byType(PrimaryButton),
      find.byType(SecondaryButton),
    ]) {
      for (final Element label in find
          .descendant(of: group, matching: find.byType(Text))
          .evaluate()) {
        expect((label.widget as Text).overflow, isNot(TextOverflow.ellipsis));
      }
    }
    expect(find.text('إرسال'), findsOneWidget);
    expect(find.byType(SecondaryButton), findsOneWidget);
  }

  for (final String language in <String>['ar', 'en']) {
    for (final double width in <double>[320, 390]) {
      for (final double scale in <double>[1, 1.5]) {
        testWidgets(
          '$language gallery is intact at ${width.toInt()}dp, ${scale}x text, light',
          (WidgetTester tester) async {
            await openGallery(tester, language: language, width: width, textScale: scale);
            expectControlsIntact(tester, width: width, language: language);
          },
        );
      }
    }
    testWidgets(
      '$language gallery is intact at 390dp, 1.5x text, dark',
      (WidgetTester tester) async {
        await openGallery(tester, language: language, width: 390, textScale: 1.5, dark: true);
        expectControlsIntact(tester, width: 390, language: language);
        final BuildContext context = tester.element(find.byType(DesignGalleryScreen));
        expect(Theme.of(context).brightness, Brightness.dark);
        expect(AppTheme.dark().scaffoldBackgroundColor, AppColors.surfaceDark);
      },
    );
  }
}
