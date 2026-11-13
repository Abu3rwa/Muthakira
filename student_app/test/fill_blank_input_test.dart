import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/exams/domain/exam_models.dart';
import 'package:student_app/features/practice/presentation/answer_input.dart';
import 'package:student_app/features/practice/presentation/fill_blank_input.dart';

Widget _host(String text, {Object? initial, bool enabled = true, required ValueChanged<List<String>> onChanged}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('ar'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FillBlankInput(text: text, initial: initial, enabled: enabled, onChanged: onChanged),
      ),
    ),
  );
}

void main() {
  testWidgets('each marker becomes an inline field inside the sentence', (tester) async {
    await tester.pumpWidget(_host('العاصمة ___ والمدينة ___', onChanged: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    final Finder paragraph = find.byWidgetPredicate((Widget widget) => widget is Text && widget.textSpan != null);
    expect(paragraph, findsOneWidget);
    expect(find.descendant(of: paragraph, matching: find.byType(TextField)), findsNWidgets(2));
  });

  testWidgets('emits the blanks in sentence order, trimmed', (tester) async {
    final List<List<String>> answers = <List<String>>[];
    await tester.pumpWidget(_host('العاصمة ___ والمدينة ___', onChanged: answers.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), ' الخرطوم ');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'أم درمان');
    await tester.pump();

    expect(answers.last, <String>['الخرطوم', 'أم درمان']);
  });

  testWidgets('restores a saved answer into the right blanks', (tester) async {
    await tester.pumpWidget(_host(
      'العاصمة ___ والمدينة ___',
      initial: const <String>['الخرطوم', 'أم درمان'],
      onChanged: (_) {},
    ));
    await tester.pumpAndSettle();

    expect(find.text('الخرطوم'), findsOneWidget);
    expect(find.text('أم درمان'), findsOneWidget);
  });

  testWidgets('a prompt without markers falls back to the text plus one field', (tester) async {
    final List<List<String>> answers = <List<String>>[];
    await tester.pumpWidget(_host('اذكر عاصمة السودان', onChanged: answers.add));
    await tester.pumpAndSettle();

    expect(find.text('اذكر عاصمة السودان'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'الخرطوم');
    await tester.pump();
    expect(answers.last, <String>['الخرطوم']);
  });

  testWidgets('fits a phone-width screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host('قال الشاعر: ___ في ليلة ___ والقمر ___', onChanged: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a submitted answer locks every blank', (tester) async {
    await tester.pumpWidget(_host(
      'العاصمة ___ والمدينة ___',
      initial: const <String>['الخرطوم', 'أم درمان'],
      enabled: false,
      onChanged: (_) {},
    ));
    await tester.pumpAndSettle();

    for (final TextField field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, false);
    }
    expect(find.text('الخرطوم'), findsOneWidget);
  });

  testWidgets('dot blanks from the live Arabic paper render inline', (tester) async {
    final List<List<String>> answers = <List<String>>[];
    await tester.pumpWidget(_host('عنوان القصيدة ......... من العصر .........', onChanged: answers.add));
    await tester.pumpAndSettle();

    final Finder paragraph = find.byWidgetPredicate((Widget widget) => widget is Text && widget.textSpan != null);
    expect(paragraph, findsOneWidget);
    expect(find.descendant(of: paragraph, matching: find.byType(TextField)), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).at(0), 'القدود');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'الأموي');
    await tester.pump();
    expect(answers.last, <String>['القدود', 'الأموي']);
  });

  testWidgets('a single trailing dot blank renders one inline field', (tester) async {
    await tester.pumpWidget(_host('Okonkwo → ........', onChanged: (_) {}));
    await tester.pumpAndSettle();

    final Finder paragraph = find.byWidgetPredicate((Widget widget) => widget is Text && widget.textSpan != null);
    expect(find.descendant(of: paragraph, matching: find.byType(TextField)), findsOneWidget);
  });

  testWidgets('an ellipsis character is a blank too', (tester) async {
    await tester.pumpWidget(_host('الموقع الإعرابي …', onChanged: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('language_analysis answers through the same inline blanks', (tester) async {
    const Question question = Question(
      id: 'la1',
      path: '4.1.2',
      type: 'language_analysis',
      text: 'المشتق : ......... نوعه : .........',
      marks: 2,
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnswerInput(
            question: question,
            letters: const <String>['أ', 'ب'],
            initial: null,
            onChanged: (_) {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final Finder paragraph = find.byWidgetPredicate((Widget widget) => widget is Text && widget.textSpan != null);
    expect(find.descendant(of: paragraph, matching: find.byType(TextField)), findsNWidgets(2));
  });
}