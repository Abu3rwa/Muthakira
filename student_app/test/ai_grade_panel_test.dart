import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:student_app/app/app_services.dart';
import 'package:student_app/core/errors/error_codes.dart';
import 'package:student_app/core/errors/failure.dart';
import 'package:student_app/core/l10n/formatters.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/l10n/locale_controller.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/practice/domain/practice_models.dart';
import 'package:student_app/features/practice/domain/practice_repository.dart';
import 'package:student_app/features/practice/presentation/ai_grade_panel.dart';
import 'package:student_app/features/wallet/domain/entities.dart';
import 'package:student_app/features/wallet/domain/wallet_repository.dart';
import 'package:student_app/features/wallet/presentation/wallet_controller.dart';
import 'package:student_app/shared/widgets/primary_button.dart';

class _MockServices extends Mock implements AppServices {}

class _MockLocale extends Mock implements LocaleController {}

class _MockPractice extends Mock implements PracticeRepository {}

class _MockWalletRepository extends Mock implements WalletRepository {}

const AnswerRecord _pending = AnswerRecord(
  id: 'answer-1',
  questionId: 'question-1',
  markingStatus: MarkingStatus.pendingAi,
  correct: null,
  awardedMarks: null,
  attemptsCount: 1,
  answeredAt: null,
  markingMethod: 'ai_rubric',
);

const AnswerRecord _markedByAi = AnswerRecord(
  id: 'answer-1',
  questionId: 'question-1',
  markingStatus: MarkingStatus.marked,
  correct: false,
  awardedMarks: 2,
  attemptsCount: 1,
  answeredAt: null,
  markingMethod: 'ai_rubric',
  aiFeedback: 'إجابة قريبة من المطلوب.',
);

/// Mirrors the session screens: the record lives in the parent, so the panel
/// must keep showing paid feedback after the status flips to marked.
class _Host extends StatefulWidget {
  const _Host({required this.initial, required this.totalMarks});

  final AnswerRecord initial;
  final double totalMarks;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late AnswerRecord record = widget.initial;

  void replace(AnswerRecord next) => setState(() => record = next);

  @override
  Widget build(BuildContext context) => AiGradePanel(
    attemptId: 'attempt-1',
    record: record,
    totalMarks: widget.totalMarks,
    onUpdated: (AnswerRecord updated) => setState(() => record = updated),
  );
}

void main() {
  late _MockServices services;
  late _MockPractice practice;
  late _MockLocale locale;
  late _MockWalletRepository walletRepository;
  late WalletController wallet;

  setUp(() {
    services = _MockServices();
    practice = _MockPractice();
    locale = _MockLocale();
    walletRepository = _MockWalletRepository();
    wallet = WalletController(repository: walletRepository);
    when(() => services.practiceRepository).thenReturn(practice);
    when(() => services.wallet).thenReturn(wallet);
    when(() => services.locale).thenReturn(locale);
    when(() => locale.languageCode).thenReturn('ar');
    when(() => walletRepository.fetchWallet()).thenAnswer((_) async => WalletSnapshot.empty);
  });

  tearDown(() => wallet.dispose());

  Future<void> pumpPanel(
    WidgetTester tester, {
    required AnswerRecord record,
    double totalMarks = 4,
    bool hosted = false,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services),
          Provider<Formatters>.value(value: const Formatters()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: hosted
                  ? _Host(initial: record, totalMarks: totalMarks)
                  : AiGradePanel(
                      key: UniqueKey(),
                      attemptId: 'attempt-1',
                      record: record,
                      totalMarks: totalMarks,
                    ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(AiGradePanel)));

  Future<void> confirmDialog(WidgetTester tester) async {
    final AppLocalizations l10n = l10nOf(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, l10n.aiGradeTitle),
      ),
    );
    // The busy state animates an indeterminate progress bar, so settle by
    // pumping fixed frames instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('AI marking is opt-in: the dialog must be confirmed first', (tester) async {
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenAnswer(
      (_) async => const AiGradeOutcome(awaitingReview: false, creditsCharged: 1, awardedMarks: 2),
    );
    await pumpPanel(tester, record: _pending);
    final AppLocalizations l10n = l10nOf(tester);

    expect(find.text(l10n.aiGradeTitle), findsOneWidget);
    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(l10n.aiGradeUnofficial), findsOneWidget);
    verifyNever(() => practice.aiGrade(any(), any()));

    await tester.tap(find.text(l10n.cancel));
    await tester.pumpAndSettle();
    verifyNever(() => practice.aiGrade(any(), any()));

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);
    verify(() => practice.aiGrade('attempt-1', 'answer-1')).called(1);
  });

  testWidgets('a marked outcome shows server marks, feedback and the charge', (tester) async {
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenAnswer(
      (_) async => const AiGradeOutcome(
        awaitingReview: false,
        creditsCharged: 1,
        awardedMarks: 3,
        correct: false,
        feedback: 'إجابة جيدة لكن ينقصها تعريف المصطلح.',
        missingPoints: <String>['تعريف المصطلح'],
      ),
    );
    await pumpPanel(tester, record: _pending);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);

    expect(find.text('إجابة جيدة لكن ينقصها تعريف المصطلح.'), findsOneWidget);
    expect(find.text(l10n.aiGradeCharged(1)), findsOneWidget);
    expect(
      find.text(l10n.partlyCorrect(const Formatters().marks(3), const Formatters().marks(4))),
      findsOneWidget,
    );
    expect(find.text(l10n.aiGradeMissingPoints), findsOneWidget);
    expect(find.text('• تعريف المصطلح'), findsOneWidget);
  });

  testWidgets('paid feedback survives the parent flipping the record to marked', (tester) async {
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenAnswer(
      (_) async => const AiGradeOutcome(
        awaitingReview: false,
        creditsCharged: 1,
        awardedMarks: 3,
        correct: false,
        feedback: 'إجابة جيدة لكن ينقصها تعريف المصطلح.',
        missingPoints: <String>['تعريف المصطلح'],
      ),
    );
    await pumpPanel(tester, record: _pending, hosted: true);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);

    final _HostState host = tester.state<_HostState>(find.byType(_Host));
    expect(host.record.markingStatus, MarkingStatus.marked);
    expect(host.record.aiMarked, isTrue);
    expect(find.text('إجابة جيدة لكن ينقصها تعريف المصطلح.'), findsOneWidget);
    expect(find.text('• تعريف المصطلح'), findsOneWidget);
    expect(find.text(l10n.aiGradeTitle), findsNothing);

    // A later rebuild from fresh server data must not lose the feedback.
    host.replace(host.record.copyWith());
    await tester.pumpAndSettle();
    expect(find.text('إجابة جيدة لكن ينقصها تعريف المصطلح.'), findsOneWidget);
  });

  testWidgets('a review outcome holds the fee: nothing is charged yet', (tester) async {
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenAnswer(
      (_) async => const AiGradeOutcome(awaitingReview: true, creditsCharged: 0, reviewId: 'review-1'),
    );
    await pumpPanel(tester, record: _pending, hosted: true);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);

    expect(find.text(l10n.aiGradeReviewPending), findsOneWidget);
    expect(find.text(l10n.aiGradeReviewNoCharge), findsOneWidget);
    expect(find.text(l10n.aiGradeCharged(0)), findsNothing);
    expect(find.byType(SecondaryButton), findsNothing);
    final _HostState host = tester.state<_HostState>(find.byType(_Host));
    expect(host.record.markingStatus, MarkingStatus.pendingAi);
    expect(host.record.aiReview?.isPending, isTrue);
  });

  testWidgets('a rejected review explains the refund and offers a free re-submit', (tester) async {
    const AnswerRecord rejected = AnswerRecord(
      id: 'answer-1',
      questionId: 'question-1',
      markingStatus: MarkingStatus.pendingAi,
      correct: null,
      awardedMarks: null,
      attemptsCount: 1,
      answeredAt: null,
      markingMethod: 'ai_rubric',
      aiReview: AiReviewState(status: 'rejected', id: 'review-1'),
    );
    await pumpPanel(tester, record: rejected);
    final AppLocalizations l10n = l10nOf(tester);

    expect(find.text(l10n.aiGradeRejectedTitle), findsOneWidget);
    expect(find.text(l10n.aiGradeRejectedBody), findsOneWidget);
    expect(find.text(l10n.aiGradeTitle), findsOneWidget);
    verifyNever(() => practice.aiGrade(any(), any()));
  });

  testWidgets('an in-flight answer shows progress instead of a second paid button', (tester) async {
    const AnswerRecord inflight = AnswerRecord(
      id: 'answer-1',
      questionId: 'question-1',
      markingStatus: MarkingStatus.pendingAi,
      correct: null,
      awardedMarks: null,
      attemptsCount: 1,
      answeredAt: null,
      markingMethod: 'ai_rubric',
      aiInflight: true,
    );
    await pumpPanel(tester, record: inflight);
    final AppLocalizations l10n = l10nOf(tester);

    expect(find.text(l10n.aiGradeInProgress), findsOneWidget);
    expect(find.byType(SecondaryButton), findsNothing);
    verifyNever(() => practice.aiGrade(any(), any()));
  });

  testWidgets('a replayed result is labelled as recovered and never charged', (tester) async {
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenAnswer(
      (_) async => const AiGradeOutcome(
        awaitingReview: false,
        creditsCharged: 0,
        awardedMarks: 3,
        correct: false,
        feedback: 'نتيجة محفوظة.',
        replayed: true,
      ),
    );
    await pumpPanel(tester, record: _pending);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);

    expect(find.text('نتيجة محفوظة.'), findsOneWidget);
    expect(find.text(l10n.aiGradeRecovered), findsOneWidget);
    expect(find.text(l10n.aiGradeCharged(0)), findsNothing);
  });

  testWidgets('the balance is re-read after every grading attempt', (tester) async {
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenAnswer(
      (_) async => const AiGradeOutcome(awaitingReview: false, creditsCharged: 1, awardedMarks: 2),
    );
    await pumpPanel(tester, record: _pending);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);
    verify(() => walletRepository.fetchWallet()).called(1);

    // A failed attempt must refresh too: the server may have charged or
    // released credits even when the response never arrived.
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenThrow(const AppFailure.timeout());
    await pumpPanel(tester, record: _pending);
    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);
    verify(() => walletRepository.fetchWallet()).called(1);
    expect(find.text(l10n.aiGradeTimeoutHint), findsOneWidget);
  });

  testWidgets('the busy state tells the student marking can take a minute', (tester) async {
    final Completer<AiGradeOutcome> gate = Completer<AiGradeOutcome>();
    when(() => practice.aiGrade('attempt-1', 'answer-1')).thenAnswer((_) => gate.future);
    await pumpPanel(tester, record: _pending);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, l10n.aiGradeTitle),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.aiGradeInProgress), findsOneWidget);
    expect(find.text(l10n.aiGradeInProgressHint), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    gate.complete(const AiGradeOutcome(awaitingReview: false, creditsCharged: 1, awardedMarks: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text(l10n.aiGradeInProgress), findsNothing);
  });

  testWidgets('insufficient credits explain the block and offer the top-up route', (tester) async {
    when(
      () => practice.aiGrade('attempt-1', 'answer-1'),
    ).thenThrow(AppFailure.api(code: ErrorCodes.insufficientCredits, status: 402));
    await pumpPanel(tester, record: _pending);
    final AppLocalizations l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.aiGradeTitle));
    await tester.pumpAndSettle();
    await confirmDialog(tester);

    expect(find.text(l10n.errorInsufficientCredits), findsOneWidget);
    expect(find.text(l10n.addCredit), findsOneWidget);
  });

  testWidgets('an already AI-marked answer shows the stored feedback without a button', (
    tester,
  ) async {
    await pumpPanel(tester, record: _markedByAi);
    final AppLocalizations l10n = l10nOf(tester);

    expect(find.byType(SecondaryButton), findsNothing);
    expect(find.text(l10n.aiGradeTitle), findsNothing);
    expect(find.text('إجابة قريبة من المطلوب.'), findsOneWidget);
    verifyNever(() => practice.aiGrade(any(), any()));
  });
}