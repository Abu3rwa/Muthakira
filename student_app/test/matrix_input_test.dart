import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/exams/domain/exam_models.dart';
import 'package:student_app/features/practice/presentation/matrix_input.dart';

Question _question(List<String> options) =>
    Question(id: 'm1', path: '1.5', type: 'matrix_input', text: 'أوجد 2A', options: options, marks: 3);

Widget _host(Question question, {Object? initial, required ValueChanged<Object?> onChanged}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('ar'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MatrixInput(question: question, initial: initial, onChanged: onChanged),
      ),
    ),
  );
}

void main() {
  testWidgets('renders rows x columns fields and emits nested rows', (tester) async {
    final List<Object?> answers = <Object?>[];
    await tester.pumpWidget(_host(_question(const <String>['2x2']), onChanged: answers.add));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(4));

    await tester.enterText(find.byType(TextField).at(0), '2');
    await tester.pump();
    final List<dynamic> first = answers.last! as List<dynamic>;
    expect(first.length, 2);
    expect((first[0] as List<dynamic>).first, '2');
    expect((first[0] as List<dynamic>)[1], '');

    await tester.enterText(find.byType(TextField).at(3), '8');
    await tester.pump();
    final List<dynamic> last = answers.last! as List<dynamic>;
    expect((last[1] as List<dynamic>)[1], '8');
    expect((last[0] as List<dynamic>).first, '2');
  });

  testWidgets('accepts Arabic digits and the multiplication sign in the dimensions', (tester) async {
    await tester.pumpWidget(_host(_question(const <String>['٢×٣']), onChanged: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(6));
  });

  testWidgets('restores saved rows from the initial answer', (tester) async {
    await tester.pumpWidget(_host(
      _question(const <String>['2x2']),
      initial: const <List<String>>[
        <String>['2', '4'],
        <String>['6', '8'],
      ],
      onChanged: (_) {},
    ));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('without a usable grid size it shows the honest unavailable notice', (tester) async {
    await tester.pumpWidget(_host(_question(const <String>['2x2||3x3']), onChanged: (_) {}));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(tester.element(find.byType(MatrixInput)));
    expect(find.text(l10n.structureUnavailable), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
