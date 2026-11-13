import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:student_app/app/app_routes.dart';
import 'package:student_app/app/app_services.dart';
import 'package:student_app/core/errors/failure.dart';
import 'package:student_app/core/l10n/formatters.dart';
import 'package:student_app/core/l10n/generated/app_localizations.dart';
import 'package:student_app/core/l10n/locale_controller.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/features/payments/domain/payment_models.dart';
import 'package:student_app/features/payments/domain/payment_repository.dart';
import 'package:student_app/features/payments/presentation/packages_screen.dart';
import 'package:student_app/shared/widgets/primary_button.dart';

class _MockServices extends Mock implements AppServices {}

class _MockLocale extends Mock implements LocaleController {}

class _MockPayments extends Mock implements PaymentRepository {}

const _package = CreditPackage(
  id: 'starter',
  name: LocalizedText(ar: 'باقة البداية', en: 'Starter package'),
  credits: 100,
  priceSdg: 1000,
);

void main() {
  late _MockServices services;
  late _MockPayments payments;
  late _MockLocale locale;

  setUp(() {
    services = _MockServices();
    payments = _MockPayments();
    locale = _MockLocale();
    when(() => services.paymentRepository).thenReturn(payments);
    when(() => services.locale).thenReturn(locale);
    when(
      () => payments.packages(),
    ).thenAnswer((_) async => <CreditPackage>[_package]);
    when(
      () => payments.myRequests(),
    ).thenAnswer((_) async => <PaymentRequest>[]);
    when(() => payments.createRequest('starter')).thenAnswer(
      (_) async => PaymentRequest.fromJson({
        'id': 'payment-1',
        'status': 'pending_payment',
        'package': _package.toJson(),
        'base_amount_sdg': 1000,
        'amount_increment': 1,
        'expected_amount_sdg': 1001,
      }),
    );
  });

  Future<GoRouter> openPackages(
    WidgetTester tester, {
    String language = 'ar',
    double width = 360,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => locale.languageCode).thenReturn(language);
    final router = GoRouter(
      initialLocation: Routes.packages,
      routes: <RouteBase>[
        GoRoute(
          path: Routes.packages,
          builder: (_, _) => const PackagesScreen(),
        ),
        GoRoute(
          path: Routes.paymentDetail,
          builder: (_, state) =>
              Scaffold(body: Text('Payment ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services),
          Provider<Formatters>.value(value: Formatters(locale: language)),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  for (final language in <String>['ar', 'en']) {
    for (final width in <double>[320, 360, 390]) {
      testWidgets(
        'packages render and open confirmation in $language at ${width.toInt()}px',
        (tester) async {
          await openPackages(tester, language: language, width: width);
          final error = tester.takeException();
          expect(
            error,
            isNull,
            reason: error is FlutterError ? error.toStringDeep() : null,
          );
          expect(find.text(_package.name.resolve(language)), findsOneWidget);
          final button = find.byType(PrimaryButton);
          expect(button, findsOneWidget);
          expect(tester.widget<PrimaryButton>(button).onPressed, isNull);
          final Rect buttonRect = tester.getRect(button);
          expect(buttonRect.left, greaterThanOrEqualTo(0));
          expect(buttonRect.right, lessThanOrEqualTo(width));
          await tester.tap(find.text(_package.name.resolve(language)));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(tester.widget<PrimaryButton>(button).onPressed, isNotNull);
          verifyNever(() => payments.createRequest(any()));
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(AlertDialog), findsOneWidget);
          verifyNever(() => payments.createRequest(any()));
        },
      );
    }

    testWidgets('confirming a package opens the server payment in $language', (
      tester,
    ) async {
      final router = await openPackages(tester, language: language);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PackagesScreen)),
      );
      await tester.tap(find.text(_package.name.resolve(language)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, l10n.confirmPackage));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      verify(() => payments.createRequest('starter')).called(1);
      expect(
        router.state.uri.path,
        Routes.payment('payment-1'),
      );
      expect(find.text('Payment payment-1'), findsOneWidget);
    });
  }

  testWidgets('cancelling confirmation does not create a payment', (
    tester,
  ) async {
    await openPackages(tester);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(PackagesScreen)),
    );
    await tester.tap(find.text(_package.name.resolve('ar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, l10n.cancel));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    verifyNever(() => payments.createRequest(any()));
  });

  testWidgets('an empty package list shows its explanation', (tester) async {
    when(() => payments.packages()).thenAnswer((_) async => <CreditPackage>[]);
    await openPackages(tester);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(PackagesScreen)),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.noPackages), findsOneWidget);
    expect(find.text(l10n.noPackagesHint), findsOneWidget);
    expect(find.byType(PrimaryButton), findsNothing);
  });

  testWidgets('failed package loading shows retry and recovers', (
    tester,
  ) async {
    when(() => payments.packages()).thenThrow(const AppFailure.network());
    await openPackages(tester);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(PackagesScreen)),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.errorTitle), findsOneWidget);
    expect(find.text(l10n.noPackages), findsNothing);
    when(
      () => payments.packages(),
    ).thenAnswer((_) async => <CreditPackage>[_package]);
    await tester.tap(find.widgetWithText(PrimaryButton, l10n.retry));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(_package.name.ar!), findsOneWidget);
    verify(() => payments.packages()).called(2);
  });
}
