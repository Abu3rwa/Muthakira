import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/exams/domain/exam_models.dart';
import 'package:student_app/features/practice/presentation/answer_input.dart';
import 'package:student_app/features/practice/presentation/fill_blank_input.dart';
import 'package:student_app/features/practice/presentation/practice_panels.dart';
import 'package:student_app/shared/widgets/content_text.dart';

Widget _app(Locale locale, Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  group('contentDirection', () {
    test('Arabic content reads RTL', () {
      expect(contentDirection('ما عاصمة السودان؟'), TextDirection.rtl);
    });

    test('English content reads LTR', () {
      expect(contentDirection('What is the capital of Sudan?'), TextDirection.ltr);
    });

    test('leading Arabic-Indic digits still read RTL', () {
      expect(contentDirection('٣ / صغ الجملة'), TextDirection.rtl);
    });

    test('neutral leading characters do not flip the direction', () {
      expect(contentDirection('1. ما عاصمة السودان؟'), TextDirection.rtl);
      expect(contentDirection('1. What is the capital?'), TextDirection.ltr);
      expect(contentDirection('«مرحبا»'), TextDirection.rtl);
    });

    test('the first strong character wins in mixed content', () {
      expect(contentDirection('Okonkwo قال ذلك'), TextDirection.ltr);
      expect(contentDirection('قال Okonkwo ذلك'), TextDirection.rtl);
    });

    test('empty and neutral-only text defaults to LTR', () {
      expect(contentDirection(''), TextDirection.ltr);
      expect(contentDirection('123 ... ✓'), TextDirection.ltr);
    });

    test('presentation forms and extended Arabic ranges read RTL', () {
      expect(contentDirection('ﻻ'), TextDirection.rtl);
      expect(contentDirection('ݐ'), TextDirection.rtl);
    });
  });

  group('ContentText', () {
    testWidgets('Arabic paper content stays RTL inside an English UI', (tester) async {
      await tester.pumpWidget(_app(const Locale('en'), const ContentText('اقرأ النص ثم أجب')));
      final Finder dir = find.descendant(of: find.byType(ContentText), matching: find.byType(Directionality));
      expect(tester.widget<Directionality>(dir).textDirection, TextDirection.rtl);
    });

    testWidgets('English paper content stays LTR inside an Arabic UI', (tester) async {
      await tester.pumpWidget(_app(const Locale('ar'), const ContentText('Read the passage then answer')));
      final Finder dir = find.descendant(of: find.byType(ContentText), matching: find.byType(Directionality));
      expect(tester.widget<Directionality>(dir).textDirection, TextDirection.ltr);
    });
  });

  group('content surfaces ignore the app locale', () {
    testWidgets('inline blanks follow the Arabic sentence in an English UI', (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        FillBlankInput(text: 'عنوان القصيدة ......... من العصر .........', initial: null, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      final Finder paragraph = find.byWidgetPredicate((Widget widget) => widget is Text && widget.textSpan != null);
      expect(paragraph, findsOneWidget);
      final Finder dir = find.ancestor(of: paragraph, matching: find.byType(Directionality)).first;
      expect(tester.widget<Directionality>(dir).textDirection, TextDirection.rtl);
      expect(find.descendant(of: paragraph, matching: find.byType(TextField)), findsNWidgets(2));
    });

    testWidgets('section headings and the passage follow their own language', (tester) async {
      await tester.pumpWidget(_app(
        const Locale('en'),
        const QuestionContext(
          sections: <Question>[
            Question(id: 's1', path: '1', type: 'section', text: 'أولاً: الأسئلة الموضوعية', isContainer: true),
          ],
          stimulus: Stimulus(id: 'p1', kind: 'passage', title: 'نص القراءة', text: 'قرأت سلمى ستين صفحة.'),
        ),
      ));
      await tester.pumpAndSettle();

      final Iterable<Directionality> dirs = tester.widgetList<Directionality>(
        find.descendant(of: find.byType(QuestionContext), matching: find.byType(Directionality)),
      );
      expect(dirs.length, 3);
      for (final Directionality dir in dirs) {
        expect(dir.textDirection, TextDirection.rtl);
      }
    });

    testWidgets('Arabic options read RTL in an English UI', (tester) async {
      const Question question = Question(
        id: 'q1',
        path: '1',
        type: 'mcq',
        text: 'اختر الإجابة الصحيحة',
        options: <String>['الخرطوم', 'أم درمان'],
      );
      await tester.pumpWidget(_app(
        const Locale('en'),
        AnswerInput(question: question, letters: const <String>['A', 'B'], initial: null, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      final Iterable<Directionality> dirs = tester.widgetList<Directionality>(
        find.descendant(of: find.byType(ContentText), matching: find.byType(Directionality)),
      );
      expect(dirs.length, 2);
      for (final Directionality dir in dirs) {
        expect(dir.textDirection, TextDirection.rtl);
      }
    });

    testWidgets('English options read LTR in an Arabic UI', (tester) async {
      const Question question = Question(
        id: 'q1',
        path: '1',
        type: 'mcq',
        text: 'Choose the correct answer',
        options: <String>['Khartoum', 'Omdurman'],
      );
      await tester.pumpWidget(_app(
        const Locale('ar'),
        AnswerInput(question: question, letters: const <String>['أ', 'ب'], initial: null, onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      final Iterable<Directionality> dirs = tester.widgetList<Directionality>(
        find.descendant(of: find.byType(ContentText), matching: find.byType(Directionality)),
      );
      expect(dirs.length, 2);
      for (final Directionality dir in dirs) {
        expect(dir.textDirection, TextDirection.ltr);
      }
    });
  });
}