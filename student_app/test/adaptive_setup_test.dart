import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:student_app/app/app_routes.dart';
import 'package:student_app/app/app_services.dart';
import 'package:student_app/core/l10n/formatters.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/l10n/locale_controller.dart';
import 'package:student_app/core/storage/prefs_store.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/auth/presentation/auth_controller.dart';
import 'package:student_app/features/exams/domain/exam_models.dart';
import 'package:student_app/features/exams/domain/exam_repository.dart';
import 'package:student_app/features/practice/domain/practice_models.dart';
import 'package:student_app/features/practice/domain/practice_repository.dart';
import 'package:student_app/features/practice/presentation/adaptive_setup_screen.dart';

class _MockServices extends Mock implements AppServices {}

class _MockLocale extends Mock implements LocaleController {}

class _MockExams extends Mock implements ExamRepository {}

class _MockPractice extends Mock implements PracticeRepository {}

class _MockPrefs extends Mock implements PrefsStore {}

class _MockAuth extends Mock implements AuthController {}

ExamSummary _exam(String id, String subject, {bool practice = true}) => ExamSummary(
  id: id,
  examKey: id,
  examYear: 2024,
  session: 'الدور الأول',
  classLevel: 'الثاني الثانوي',
  subject: subject,
  language: 'ar',
  practiceEnabled: practice,
);

void main() {
  setUpAll(() => registerFallbackValue(const ExamFilter()));

  late _MockServices services;
  late _MockExams exams;
  late _MockPractice practice;
  late _MockPrefs prefs;
  late _MockAuth auth;
  late _MockLocale locale;

  setUp(() {
    services = _MockServices();
    exams = _MockExams();
    practice = _MockPractice();
    prefs = _MockPrefs();
    auth = _MockAuth();
    locale = _MockLocale();
    when(() => services.examRepository).thenReturn(exams);
    when(() => services.practiceRepository).thenReturn(practice);
    when(() => services.prefs).thenReturn(prefs);
    when(() => services.auth).thenReturn(auth);
    when(() => services.locale).thenReturn(locale);
    when(() => locale.languageCode).thenReturn('ar');
    when(() => auth.profile).thenReturn(null);
    when(() => prefs.setLastAttempt(any(), any())).thenAnswer((_) async {});
  });

  Future<GoRouter> pumpSetup(WidgetTester tester, List<ExamSummary> papers) async {
    when(() => exams.list(any(), limit: any(named: 'limit'), skip: any(named: 'skip'))).thenAnswer(
      (_) async => ExamPage(items: papers, total: papers.length, limit: 20, skip: 0),
    );
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final GoRouter router = GoRouter(
      initialLocation: Routes.adaptive,
      routes: <RouteBase>[
        GoRoute(path: Routes.adaptive, builder: (_, _) => const AdaptiveSetupScreen()),
        GoRoute(
          path: Routes.adaptiveSession,
          builder: (_, GoRouterState state) => Scaffold(body: Text('SESSION ${state.pathParameters['attemptId']}')),
        ),
        GoRoute(path: Routes.exams, builder: (_, _) => const Scaffold(body: Text('EXAMS'))),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services),
          Provider<Formatters>.value(value: const Formatters()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  AppLocalizations l10nOf(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(AdaptiveSetupScreen)));

  testWidgets('only practice-enabled papers are offered and none of them are priced', (tester) async {
    await pumpSetup(tester, <ExamSummary>[
      _exam('exam-1', 'رياضيات'),
      _exam('exam-2', 'فيزياء'),
      _exam('exam-3', 'كيمياء', practice: false),
    ]);
    final AppLocalizations l10n = l10nOf(tester);

    expect(find.text('رياضيات'), findsNWidgets(2));
    expect(find.text('فيزياء'), findsNWidgets(2));
    expect(find.text('كيمياء'), findsNothing);
    expect(find.text(l10n.adaptiveNoControls), findsOneWidget);
    expect(find.text(l10n.adaptiveFreeNote), findsOneWidget);
    verifyNever(() => practice.start(any()));
  });

  testWidgets('starting adaptive practice uses the server start and resumes by attempt id', (
    tester,
  ) async {
    when(() => practice.start('exam-1')).thenAnswer(
      (_) async => const StartAttemptResult(
        attempt: Attempt(
          id: 'attempt-7',
          examId: 'exam-1',
          status: AttemptStatus.open,
          answersCount: 0,
          correctCount: 0,
          awardedMarks: 0,
          startedAt: null,
          lastActivityAt: null,
        ),
        created: true,
      ),
    );
    final GoRouter router = await pumpSetup(tester, <ExamSummary>[_exam('exam-1', 'رياضيات')]);

    await tester.tap(find.descendant(of: find.byType(Card), matching: find.text('رياضيات')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    verify(() => practice.start('exam-1')).called(1);
    verify(() => prefs.setLastAttempt('exam-1', 'attempt-7')).called(1);
    expect(find.text('SESSION attempt-7'), findsOneWidget);
    expect(router, isNotNull);
  });

  testWidgets('the subject chips filter without hiding the adaptive explanation', (tester) async {
    await pumpSetup(tester, <ExamSummary>[
      _exam('exam-1', 'رياضيات'),
      _exam('exam-2', 'فيزياء'),
    ]);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'فيزياء'));
    await tester.pumpAndSettle();
    expect(find.text('رياضيات'), findsOneWidget);
    expect(find.text(l10n.adaptiveNoControls), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'رياضيات'));
    await tester.pumpAndSettle();
    expect(find.text('فيزياء'), findsOneWidget);
  });

  testWidgets('no practice-enabled paper states the empty case and links to the library', (
    tester,
  ) async {
    await pumpSetup(tester, <ExamSummary>[_exam('exam-3', 'كيمياء', practice: false)]);
    final AppLocalizations l10n = l10nOf(tester);

    expect(find.text(l10n.emptyPractice), findsOneWidget);
    await tester.tap(find.text(l10n.browseExams));
    await tester.pumpAndSettle();
    expect(find.text('EXAMS'), findsOneWidget);
  });
}
