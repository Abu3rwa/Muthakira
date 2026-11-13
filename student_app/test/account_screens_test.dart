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
import 'package:student_app/core/storage/cache_store.dart';
import 'package:student_app/core/storage/prefs_store.dart';
import 'package:student_app/core/storage/user_scope.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/theme/theme_controller.dart';
import 'package:student_app/core/utils/format_code.dart';
import 'package:student_app/features/auth/presentation/auth_controller.dart';
import 'package:student_app/features/auth/presentation/screens/recovery_code_screen.dart';
import 'package:student_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:student_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:student_app/features/profile/presentation/settings_screen.dart';
import 'package:student_app/shared/widgets/primary_button.dart';

class _MockServices extends Mock implements AppServices {}

class _MockLocale extends Mock implements LocaleController {}

class _MockTheme extends Mock implements ThemeController {}

class _MockAuth extends Mock implements AuthController {}

class _MockCache extends Mock implements CacheStore {}

class _MockPrefs extends Mock implements PrefsStore {}

class _MockScope extends Mock implements UserScope {}

void main() {
  late _MockServices services;
  late _MockLocale locale;
  late _MockTheme theme;
  late _MockAuth auth;

  setUp(() {
    services = _MockServices();
    locale = _MockLocale();
    theme = _MockTheme();
    auth = _MockAuth();
    when(() => locale.languageCode).thenReturn('ar');
    when(() => theme.textScale).thenReturn(1);
    when(() => theme.themeMode).thenReturn(ThemeMode.system);
    when(() => theme.digitStyle).thenReturn(DigitStyle.arabicIndic);
    when(() => services.locale).thenReturn(locale);
    when(() => services.theme).thenReturn(theme);
    when(() => services.auth).thenReturn(auth);
    when(() => auth.user).thenReturn(null);
    when(() => locale.setLanguage(any())).thenAnswer((_) async {});
  });

  Widget app(Widget child, {required String path, String language = 'ar'}) {
    final GoRouter router = GoRouter(
      initialLocation: path,
      routes: <RouteBase>[
        GoRoute(path: path, builder: (_, _) => child),
        GoRoute(path: Routes.home, builder: (_, _) => const Scaffold(body: Text('home'))),
      ],
    );
    addTearDown(router.dispose);
    return MultiProvider(
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
    );
  }

  testWidgets('welcome keeps a visible language choice', (WidgetTester tester) async {
    await tester.pumpWidget(app(const WelcomeScreen(), path: Routes.welcome));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    verify(() => locale.setLanguage('en')).called(1);
  });

  testWidgets('recovery code is grouped for reading and acknowledgement gates continue', (
    WidgetTester tester,
  ) async {
    when(() => auth.recoveryCode).thenReturn('ABCDEFGHIJ');
    await tester.pumpWidget(app(const RecoveryCodeScreen(), path: Routes.recovery));
    await tester.pumpAndSettle();
    expect(find.textContaining('ABCDE-FGHIJ'), findsOneWidget);
    final Finder continueButton = find.byType(PrimaryButton);
    expect(tester.widget<PrimaryButton>(continueButton).onPressed, isNull);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(tester.widget<PrimaryButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets('clearing saved data warns about the queue and wipes it', (WidgetTester tester) async {
    final _MockCache cache = _MockCache();
    final _MockPrefs prefs = _MockPrefs();
    final _MockScope scope = _MockScope();
    when(() => services.cache).thenReturn(cache);
    when(() => services.prefs).thenReturn(prefs);
    when(() => services.scope).thenReturn(scope);
    when(() => scope.userId).thenReturn('user-1');
    when(() => cache.wipeUser('user-1')).thenAnswer((_) async {});
    when(() => prefs.clearUserData()).thenAnswer((_) async {});
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('ar'));

    await tester.pumpWidget(app(const SettingsScreen(), path: Routes.settings));
    await tester.pumpAndSettle();
    expect(find.text(l10n.readingSample), findsOneWidget);
    expect(find.text(l10n.dataSaver), findsNothing);

    await tester.scrollUntilVisible(find.text(l10n.clearCache), 250, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text(l10n.clearCache));
    await tester.pumpAndSettle();
    expect(find.text(l10n.clearCacheConfirmBody), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text(l10n.clearCacheIncludesQueue)),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, l10n.clearCache));
    await tester.pumpAndSettle();
    verify(() => cache.wipeUser('user-1')).called(1);
    verify(() => prefs.clearUserData()).called(1);
  });

  for (final String language in <String>['ar', 'en']) {
    testWidgets('signup keeps the preferred language visible at 320px in $language', (
      WidgetTester tester,
    ) async {
      when(() => auth.isBusy).thenReturn(false);
      when(() => auth.failure).thenReturn(null);
      when(() => locale.languageCode).thenReturn(language);
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(const SignupScreen(), path: Routes.signup, language: language));
      await tester.pumpAndSettle();
      final AppLocalizations l10n = lookupAppLocalizations(Locale(language));
      await tester.scrollUntilVisible(
        find.text(l10n.preferredLanguage),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.preferredLanguage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('grouping a code never changes the copied value', () {
    expect(groupCode('ABCDEFGHIJ'), 'ABCDE-FGHIJ');
    expect(groupCode('ABC'), 'ABC');
    expect(groupCode('  ABCDEFGHIJ  '), 'ABCDE-FGHIJ');
  });
}
