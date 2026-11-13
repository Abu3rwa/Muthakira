import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:student_app/app/app_routes.dart';
import 'package:student_app/app/app_services.dart';
import 'package:student_app/core/errors/error_codes.dart';
import 'package:student_app/core/l10n/formatters.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/l10n/locale_controller.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/auth/domain/entities.dart';
import 'package:student_app/features/auth/presentation/auth_controller.dart';
import 'package:student_app/features/exams/domain/exam_repository.dart';
import 'package:student_app/features/materials/domain/material_models.dart';
import 'package:student_app/features/materials/domain/materials_repository.dart';
import 'package:student_app/features/materials/presentation/add_material_screen.dart';
import 'package:student_app/features/materials/presentation/generation_confirm_screen.dart';
import 'package:student_app/features/materials/presentation/generation_screen.dart';
import 'package:student_app/features/materials/presentation/materials_screen.dart';
import 'package:student_app/features/wallet/presentation/wallet_controller.dart';
import 'package:student_app/shared/widgets/primary_button.dart';

class _MockServices extends Mock implements AppServices {}

class _MockLocale extends Mock implements LocaleController {}

class _MockMaterials extends Mock implements MaterialsRepository {}

class _MockExams extends Mock implements ExamRepository {}

class _MockWallet extends Mock implements WalletController {}

class _MockAuth extends Mock implements AuthController {}

const MaterialItem _material = MaterialItem(
  id: 'material-1',
  classLevel: '2',
  subject: 'رياضيات',
  language: 'ar',
  kind: MaterialKind.text,
  bytes: 640,
  createdAt: null,
);

GenerationJob _job(GenerationStatus status, {int credits = 2, String? errorCode}) => GenerationJob(
  id: 'job-1',
  materialId: 'material-1',
  classLevel: '2',
  subject: 'رياضيات',
  count: 5,
  status: status,
  creditsCharged: credits,
  createdAt: null,
  examId: status == GenerationStatus.ready ? 'exam-9' : null,
  errorCode: errorCode,
);

void main() {
  late _MockServices services;
  late _MockMaterials materials;
  late _MockExams exams;
  late _MockWallet wallet;
  late _MockAuth auth;
  late _MockLocale locale;

  setUp(() {
    services = _MockServices();
    materials = _MockMaterials();
    exams = _MockExams();
    wallet = _MockWallet();
    auth = _MockAuth();
    locale = _MockLocale();
    when(() => services.materialsRepository).thenReturn(materials);
    when(() => services.examRepository).thenReturn(exams);
    when(() => services.wallet).thenReturn(wallet);
    when(() => services.auth).thenReturn(auth);
    when(() => services.locale).thenReturn(locale);
    when(() => locale.languageCode).thenReturn('ar');
    when(() => wallet.refresh()).thenAnswer((_) async {});
    when(() => auth.profile).thenReturn(null);
    when(() => exams.catalogue()).thenAnswer((_) async => const CatalogueValues(subjects: <String>['رياضيات']));
  });

  GoRouter buildRouter(String location, WidgetBuilder builder) {
    final GoRouter router = GoRouter(
      initialLocation: location,
      routes: <RouteBase>[
        GoRoute(
          path: Routes.materials,
          builder: (BuildContext context, GoRouterState state) => builder(context),
          routes: <RouteBase>[
            GoRoute(path: 'add', builder: (_, _) => const AddMaterialScreen()),
            GoRoute(
              path: 'generations/:id',
              builder: (_, GoRouterState state) => GenerationScreen(jobId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: ':id/generate',
              builder: (_, GoRouterState state) => GenerationConfirmScreen(
                materialId: state.pathParameters['id']!,
                material: state.extra is MaterialItem ? state.extra as MaterialItem : null,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/exams/:id',
          builder: (_, GoRouterState state) => Scaffold(body: Text('EXAM ${state.pathParameters['id']}')),
        ),
        GoRoute(path: Routes.packages, builder: (_, _) => const Scaffold(body: Text('PACKAGES'))),
      ],
    );
    addTearDown(router.dispose);
    return router;
  }

  Future<GoRouter> pump(WidgetTester tester, GoRouter router) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

  AppLocalizations l10nOf(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(Scaffold).first));

  group('materials list', () {
    testWidgets('shows each material with its newest generation status', (tester) async {
      when(() => materials.listMaterials()).thenAnswer((_) async => <MaterialItem>[_material]);
      when(() => materials.listGenerations()).thenAnswer(
        (_) async => <GenerationJob>[_job(GenerationStatus.review, credits: 1)],
      );
      await pump(tester, buildRouter(Routes.materials, (_) => const MaterialsScreen()));
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.text('رياضيات'), findsWidgets);
      expect(find.text(l10n.materialStatusReview), findsOneWidget);
      expect(find.text(l10n.generationStatusTitle), findsOneWidget);
      expect(find.text(l10n.materialGenerate), findsNothing);
      expect(find.text(l10n.materialsEmpty), findsNothing);
    });

    testWidgets('a material without a job offers generation through the confirm screen', (
      tester,
    ) async {
      when(() => materials.listMaterials()).thenAnswer((_) async => <MaterialItem>[_material]);
      when(() => materials.listGenerations()).thenAnswer((_) async => <GenerationJob>[]);
      await pump(tester, buildRouter(Routes.materials, (_) => const MaterialsScreen()));

      final Finder generate = find.byIcon(Icons.auto_awesome_outlined);
      expect(generate, findsOneWidget);
      await tester.ensureVisible(generate);
      await tester.pumpAndSettle();
      await tester.tap(generate);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(GenerationConfirmScreen), findsOneWidget);
    });

    testWidgets('an empty list explains what to add instead of showing a blank page', (tester) async {
      when(() => materials.listMaterials()).thenAnswer((_) async => <MaterialItem>[]);
      when(() => materials.listGenerations()).thenAnswer((_) async => <GenerationJob>[]);
      await pump(tester, buildRouter(Routes.materials, (_) => const MaterialsScreen()));
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.text(l10n.materialsEmpty), findsOneWidget);
      expect(find.text(l10n.materialAdd), findsOneWidget);
    });
  });

  group('generation confirm', () {
    testWidgets('nothing is charged until the acknowledgement and confirmation', (tester) async {
      when(() => materials.createGeneration('material-1', count: any(named: 'count'))).thenAnswer(
        (_) async => _job(GenerationStatus.review, credits: 1),
      );
      final GoRouter router = await pump(
        tester,
        buildRouter(Routes.materials, (_) => const Scaffold(body: Text('ROOT'))),
      );
      unawaited(router.push(Routes.generationConfirmOf('material-1'), extra: _material));
      await tester.pumpAndSettle();
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.text(l10n.generationPriceServer), findsOneWidget);
      PrimaryButton button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.onPressed, isNull);
      verifyNever(() => materials.createGeneration(any(), count: any(named: 'count')));

      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      final Finder seven = find.widgetWithText(ChoiceChip, const Formatters().integer(7));
      await tester.ensureVisible(seven);
      await tester.pumpAndSettle();
      await tester.tap(seven);
      await tester.pumpAndSettle();
      button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.onPressed, isNotNull);
      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      verify(() => materials.createGeneration('material-1', count: 7)).called(1);
      verify(() => wallet.refresh()).called(1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a missing material fails honestly instead of pricing anything locally', (
      tester,
    ) async {
      when(() => materials.listMaterials()).thenAnswer((_) async => <MaterialItem>[]);
      final GoRouter router = await pump(
        tester,
        buildRouter(Routes.materials, (_) => const Scaffold(body: Text('ROOT'))),
      );
      unawaited(router.push(Routes.generationConfirmOf('material-1')));
      await tester.pumpAndSettle();

      expect(find.text(l10nOf(tester).errorMaterialNotFound), findsOneWidget);
      expect(tester.takeException(), isNull);
      verifyNever(() => materials.createGeneration(any(), count: any(named: 'count')));
    });
  });

  group('generation status', () {
    Future<void> openJob(WidgetTester tester, GenerationJob job) async {
      when(() => materials.generation(job.id)).thenAnswer((_) async => job);
      final GoRouter router = buildRouter(Routes.materials, (_) => const Scaffold(body: Text('ROOT')));
      await pump(tester, router);
      unawaited(router.push(Routes.generationOf(job.id)));
      await tester.pumpAndSettle();
    }

    testWidgets('ready shows the reviewed set, its origin and the charge', (tester) async {
      await openJob(tester, _job(GenerationStatus.ready));
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.text(l10n.generationReadyBody), findsOneWidget);
      expect(find.text(l10n.generationOrigin), findsOneWidget);
      expect(find.text(l10n.generationCharged(2)), findsOneWidget);
      expect(find.text(l10n.generationOpen), findsOneWidget);
    });

    testWidgets('unsafe failures explain the safety check and the refund', (tester) async {
      await openJob(tester, _job(GenerationStatus.failed, errorCode: ErrorCodes.aiContentUnsafe));
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.text(l10n.generationUnsafe), findsOneWidget);
      expect(find.text(l10n.generationNoCharge), findsOneWidget);
      expect(find.text(l10n.generationCharged(2)), findsNothing);
    });

    testWidgets('rejected never claims a numeric charge', (tester) async {
      await openJob(tester, _job(GenerationStatus.rejected));
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.text(l10n.generationRejectedBody), findsOneWidget);
      expect(find.textContaining(l10n.generationCharged(2)), findsNothing);
      expect(find.text(l10n.generationOpen), findsNothing);
    });

    testWidgets('an unknown status refreshes without starting a new request', (tester) async {
      await openJob(tester, _job(GenerationStatus.unknown));
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.text(l10n.generationUnknownBody), findsOneWidget);
      verifyNever(() => materials.createGeneration(any(), count: any(named: 'count')));
    });
  });

  group('add material', () {
    testWidgets('empty input explains both required fields without calling the API', (tester) async {
      final GoRouter router = await pump(
        tester,
        buildRouter(Routes.materials, (_) => const Scaffold(body: Text('ROOT'))),
      );
      unawaited(router.push(Routes.materialAdd));
      await tester.pumpAndSettle();
      final AppLocalizations l10n = l10nOf(tester);

      expect(find.byType(AddMaterialScreen), findsOneWidget);
      expect(find.text(l10n.materialPdfDisabled), findsOneWidget);
      final Finder save = find.byType(PrimaryButton);
      expect(save, findsNothing);
      await tester.scrollUntilVisible(save, 250, scrollable: find.byType(Scrollable).last);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.text(l10n.materialGradeRequired), findsOneWidget);
      expect(find.text(l10n.materialSubjectRequired), findsOneWidget);
      verifyNever(
        () => materials.addText(
          classLevel: any(named: 'classLevel'),
          subject: any(named: 'subject'),
          language: any(named: 'language'),
          text: any(named: 'text'),
        ),
      );
    });

    testWidgets('valid pasted text is sent with the server language and grade', (tester) async {
      when(() => auth.profile).thenReturn(const StudentProfile(classLevel: 'secondary_2'));
      when(
        () => materials.addText(
          classLevel: any(named: 'classLevel'),
          subject: any(named: 'subject'),
          language: any(named: 'language'),
          text: any(named: 'text'),
        ),
      ).thenAnswer((_) async => _material);
      final GoRouter router = await pump(
        tester,
        buildRouter(Routes.materials, (_) => const Scaffold(body: Text('ROOT'))),
      );
      unawaited(router.push(Routes.materialAdd));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'رياضيات');
      await tester.enterText(find.byType(TextField).last, 'م' * 120);
      await tester.pumpAndSettle();
      final Finder save = find.byType(PrimaryButton);
      await tester.scrollUntilVisible(save, 250, scrollable: find.byType(Scrollable).last);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      verify(
        () => materials.addText(
          classLevel: '2',
          subject: 'رياضيات',
          language: 'ar',
          text: 'م' * 120,
        ),
      ).called(1);
      expect(tester.takeException(), isNull);
    });
  });
}
