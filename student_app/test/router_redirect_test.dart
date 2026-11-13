import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/app/app_router.dart';
import 'package:student_app/app/app_routes.dart';
import 'package:student_app/features/auth/presentation/auth_controller.dart';

void main() {
  group('splash gate', () {
    test('stays only while the session is unresolved', () {
      expect(AppRouter.resolve(AuthStatus.unknown, Routes.splash), isNull);
    });

    test('leaves splash as soon as the session is known', () {
      expect(AppRouter.resolve(AuthStatus.signedOut, Routes.splash), Routes.welcome);
      expect(AppRouter.resolve(AuthStatus.signedIn, Routes.splash), Routes.home);
      expect(AppRouter.resolve(AuthStatus.blocked, Routes.splash), Routes.blocked);
    });
  });

  group('signed-out routes', () {
    test('keeps onboarding reachable', () {
      expect(AppRouter.resolve(AuthStatus.signedOut, Routes.welcome), isNull);
      expect(AppRouter.resolve(AuthStatus.signedOut, Routes.login), isNull);
      expect(AppRouter.resolve(AuthStatus.signedOut, Routes.signup), isNull);
    });

    test('pushes protected pages to welcome', () {
      expect(AppRouter.resolve(AuthStatus.signedOut, Routes.home), Routes.welcome);
      expect(AppRouter.resolve(AuthStatus.signedOut, Routes.exams), Routes.welcome);
    });
  });

  group('signed-in routes', () {
    test('sends onboarding and unresolved pages home', () {
      expect(AppRouter.resolve(AuthStatus.signedIn, Routes.welcome), Routes.home);
      expect(AppRouter.resolve(AuthStatus.signedIn, Routes.login), Routes.home);
      expect(AppRouter.resolve(AuthStatus.unknown, Routes.home), Routes.splash);
    });

    test('keeps tabs and the recovery gate', () {
      expect(AppRouter.resolve(AuthStatus.signedIn, Routes.home), isNull);
      expect(AppRouter.resolve(AuthStatus.signedIn, Routes.exams), isNull);
      expect(AppRouter.resolve(AuthStatus.signedIn, Routes.recovery), isNull);
    });
  });

  group('blocked account', () {
    test('is pinned to the blocked screen', () {
      expect(AppRouter.resolve(AuthStatus.blocked, Routes.blocked), isNull);
      expect(AppRouter.resolve(AuthStatus.blocked, Routes.login), Routes.blocked);
      expect(AppRouter.resolve(AuthStatus.blocked, Routes.home), Routes.blocked);
    });
  });
}
