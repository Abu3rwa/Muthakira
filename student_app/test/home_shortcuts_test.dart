import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/tokens.dart';
import 'package:student_app/features/home/presentation/home_screen.dart';

void main() {
  Future<List<String>> openShortcuts(
    WidgetTester tester, {
    required String language,
    required double width,
    double textScale = 1,
    bool dark = false,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final calls = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: HomeShortcuts(
                    onPractice: () => calls.add('practice'),
                    onPayments: () => calls.add('payments'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return calls;
  }

  for (final language in <String>['ar', 'en']) {
    for (final width in <double>[320, 360, 390]) {
      for (final scale in <double>[1, 1.5, 2]) {
        testWidgets(
          '$language study shortcuts stay readable and tappable at ${width.toInt()}px, ${scale}x text',
          (tester) async {
            final calls = await openShortcuts(
              tester,
              language: language,
              width: width,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            final context = tester.element(find.byType(HomeShortcuts));
            final l10n = AppLocalizations.of(context);
            final labels = <String>[l10n.practiceTitle, l10n.paymentsTitle];
            expect(
              Directionality.of(context),
              language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            );
            expect(find.byType(OutlinedButton), findsNWidgets(2));
            for (final String label in labels) {
              final Finder button = find.widgetWithText(OutlinedButton, label);
              await tester.ensureVisible(button);
              await tester.pumpAndSettle();
              final Rect buttonRect = tester.getRect(button);
              final Rect textRect = tester.getRect(
                find.descendant(of: button, matching: find.text(label)),
              );
              final Rect iconRect = tester.getRect(
                find.descendant(of: button, matching: find.byType(Icon)).first,
              );
              final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
                find.descendant(
                  of: find.descendant(of: button, matching: find.text(label)),
                  matching: find.byType(RichText),
                ),
              );
              expect(buttonRect.left, greaterThanOrEqualTo(AppSpacing.screen));
              expect(buttonRect.right, lessThanOrEqualTo(width - AppSpacing.screen + 0.01));
              expect(buttonRect.height, greaterThanOrEqualTo(AppSpacing.minTapTarget));
              final Rect inner = buttonRect.inflate(0.5);
              expect(inner.contains(textRect.topLeft), isTrue);
              expect(inner.contains(textRect.bottomRight), isTrue);
              expect(inner.contains(iconRect.topLeft), isTrue);
              expect(inner.contains(iconRect.bottomRight), isTrue);
              expect(paragraph.didExceedMaxLines, isFalse);
              expect(
                tester.widget<Text>(find.text(label)).overflow,
                isNot(TextOverflow.ellipsis),
              );
              expect(
                tester.getSemantics(button),
                matchesSemantics(
                  label: label,
                  textDirection: language == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  isButton: true,
                  hasEnabledState: true,
                  isEnabled: true,
                  isFocusable: true,
                  hasTapAction: true,
                  hasFocusAction: true,
                ),
              );
              await tester.tap(button);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            expect(calls, <String>['practice', 'payments']);
          },
        );
      }
    }

    testWidgets('$language study shortcuts keep their labels in dark mode', (
      tester,
    ) async {
      await openShortcuts(tester, language: language, width: 390, dark: true);
      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(HomeShortcuts));
      final scheme = Theme.of(context).colorScheme;
      final l10n = AppLocalizations.of(context);
      for (final String label in <String>[l10n.practiceTitle, l10n.paymentsTitle]) {
        expect(tester.widget<Text>(find.text(label)).style?.color, scheme.onSurface);
      }
      final sizes = tester
          .widgetList<OutlinedButton>(find.byType(OutlinedButton))
          .map((button) => tester.getSize(find.byWidget(button)))
          .toList();
      expect(sizes[0], sizes[1]);
    });
  }
}
