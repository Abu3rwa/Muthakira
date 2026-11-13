import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/exams/domain/exam_models.dart';
import 'package:student_app/features/practice/presentation/table_fill_input.dart';

const String _gridText = 'أكمل الجدول:\n| الكلمة | المعنى | النوع |\n| كتاب |  |  |\n| قلم |  |  |';

Question _question(String text) => Question(id: 't1', path: '1.3', type: 'table_fill', text: text, marks: 2);

Widget _host(Question question, {Object? initial, required ValueChanged<Object?> onChanged}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('ar'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TableFillInput(question: question, initial: initial, onChanged: onChanged),
      ),
    ),
  );
}

void main() {
  testWidgets('renders one field per blank cell and emits row.column answers', (tester) async {
    final List<Map<String, String>> answers = <Map<String, String>>[];
    await tester.pumpWidget(_host(
      _question(_gridText),
      onChanged: (Object? v) => answers.add((v! as Map).cast<String, String>()),
    ));
    await tester.pumpAndSettle();

    // Two data rows x two editable columns; the row-label column is static.
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('المعنى'), findsOneWidget);
    expect(find.text('كتاب'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'مقروء');
    await tester.pump();
    expect(answers.last['1.1'], 'مقروء');

    await tester.enterText(find.byType(TextField).at(3), 'اسم');
    await tester.pump();
    expect(answers.last['2.2'], 'اسم');
    expect(answers.last['1.1'], 'مقروء');
  });

  testWidgets('restores saved cells from the initial map', (tester) async {
    await tester.pumpWidget(_host(
      _question(_gridText),
      initial: const <String, String>{'1.2': 'مكتوب'},
      onChanged: (_) {},
    ));
    await tester.pumpAndSettle();

    expect(find.text('مكتوب'), findsOneWidget);
  });

  testWidgets('without a visible grid it shows the honest unavailable notice', (tester) async {
    await tester.pumpWidget(_host(_question('املأ الجدول'), onChanged: (_) {}));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(tester.element(find.byType(TableFillInput)));
    expect(find.text(l10n.structureUnavailable), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
