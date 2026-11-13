import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/tokens.dart';
import 'package:student_app/shared/widgets/primary_button.dart';

void main() {
  testWidgets('compact buttons fit an unbounded row and remain tappable', (
    tester,
  ) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Row(
            children: <Widget>[
              const Expanded(child: Text('Package')),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('1,000 SDG'),
                  PrimaryButton(
                    label: 'Buy',
                    expanded: false,
                    onPressed: () => taps++,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final Size size = tester.getSize(find.byType(FilledButton));
    expect(size.width.isFinite, isTrue);
    expect(size.width, lessThan(300));
    expect(size.height, greaterThanOrEqualTo(AppSpacing.minTapTarget));
    expect(
      tester.getSemantics(find.byType(FilledButton)),
      matchesSemantics(
        label: 'Buy',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.text('Buy'));
    expect(taps, 1);
  });

  testWidgets('expanded buttons still fill the available width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: PrimaryButton(label: 'Continue', onPressed: () {}),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(FilledButton)).width, 280);
  });

  testWidgets('compact loading buttons fit a row and cannot submit', (
    tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Row(
            children: <Widget>[
              PrimaryButton(
                label: 'Buy',
                expanded: false,
                isLoading: true,
                onPressed: () => taps++,
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
  });
}
