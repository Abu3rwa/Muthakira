import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/exams/domain/exam_models.dart';
import 'package:student_app/features/practice/presentation/truth_table_input.dart';

Question _question(List<String> variables) =>
    Question(id: 't1', path: '1.6', type: 'truth_table', text: 'أكمل جدول الحقيقة', options: variables, marks: 2);

Widget _host(Question question, {Object? initial, required ValueChanged<Object?> onChanged}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('ar'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TruthTableInput(question: question, initial: initial, onChanged: onChanged),
      ),
    ),
  );
}

void main() {
  test('rows enumerate input bits with the first variable as the top bit', () {
    expect(truthRowBits(2, 0), <String>['0', '0']);
    expect(truthRowBits(2, 1), <String>['0', '1']);
    expect(truthRowBits(2, 2), <String>['1', '0']);
    expect(truthRowBits(2, 3), <String>['1', '1']);
    expect(truthRowBits(3, 5), <String>['1', '0', '1']);
  });

  testWidgets('builds one row per input combination in dense order', (tester) async {
    await tester.pumpWidget(_host(_question(const <String>['A', 'B']), onChanged: (_) {}));
    await tester.pumpAndSettle();

    // 2^2 input rows, each with a pair of output buttons, plus the header.
    expect(find.byType(OutlinedButton), findsNWidgets(8));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('الناتج'), findsOneWidget);
    // Header has no bits, so only the 4 input rows contribute 0/1 cell text.
    expect(find.text('0'), findsNWidgets(8));
    expect(find.text('1'), findsNWidgets(8));
  });

  testWidgets('emits one output value per row and toggles a bit off', (tester) async {
    final List<Object?> answers = <Object?>[];
    await tester.pumpWidget(_host(
      _question(const <String>['A', 'B']),
      initial: const <String>['0', '0', '0', '1'],
      onChanged: answers.add,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, '0').last);
    await tester.pump();
    expect(answers.last, <String?>['0', '0', '0', '0']);

    await tester.tap(find.widgetWithText(OutlinedButton, '0').last);
    await tester.pump();
    expect(answers.last, <String?>['0', '0', '0', null]);
  });

  testWidgets('without input variables it shows the honest unavailable notice', (tester) async {
    await tester.pumpWidget(_host(_question(const <String>[]), onChanged: (_) {}));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(tester.element(find.byType(TruthTableInput)));
    expect(find.text(l10n.structureUnavailable), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
