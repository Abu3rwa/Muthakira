/// Every route in the app, plus the signed-in/signed-out redirect rules.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/screens/blocked_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/legal_screens.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/recovery_code_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/exams/presentation/answer_keys_screen.dart';
import '../features/exams/presentation/exam_detail_screen.dart';
import '../features/exams/presentation/exam_list_screen.dart';
import '../features/exams/presentation/paper_viewer_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/materials/domain/material_models.dart';
import '../features/materials/presentation/add_material_screen.dart';
import '../features/materials/presentation/generation_confirm_screen.dart';
import '../features/materials/presentation/generation_screen.dart';
import '../features/materials/presentation/materials_screen.dart';
import '../features/payments/presentation/packages_screen.dart';
import '../features/payments/presentation/payment_detail_screen.dart';
import '../features/payments/presentation/payments_list_screen.dart';
import '../features/payments/presentation/submit_receipt_screen.dart';
import '../features/practice/presentation/adaptive_session_screen.dart';
import '../features/practice/presentation/adaptive_setup_screen.dart';
import '../features/practice/presentation/practice_hub_screen.dart';
import '../features/practice/presentation/practice_session_screen.dart';
import '../features/practice/presentation/result_screen.dart';
import '../features/profile/presentation/about_screen.dart';
import '../features/profile/presentation/diagnostics_screen.dart';
import '../features/profile/presentation/gallery_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/profile/presentation/support_screen.dart';
import '../features/wallet/presentation/ledger_screen.dart';
import '../features/wallet/presentation/wallet_screen.dart';
import '../shared/screens/system_screens.dart';
import '../shared/widgets/app_shell.dart';
import 'app_routes.dart';
import 'app_services.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter create(AppServices services) {
    return GoRouter(
      initialLocation: Routes.splash,
      refreshListenable: services.auth,
      redirect: (BuildContext context, GoRouterState state) =>
          resolve(services.auth.status, state.matchedLocation),
      routes: <RouteBase>[
        GoRoute(
          path: Routes.splash,
          builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.welcome,
          builder: (BuildContext context, GoRouterState state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.signup,
          builder: (BuildContext context, GoRouterState state) => const SignupScreen(),
        ),
        GoRoute(
          path: Routes.recovery,
          builder: (BuildContext context, GoRouterState state) => const RecoveryCodeScreen(),
        ),
        GoRoute(
          path: Routes.forgot,
          builder: (BuildContext context, GoRouterState state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: Routes.terms,
          builder: (BuildContext context, GoRouterState state) => const TermsScreen(),
        ),
        GoRoute(
          path: Routes.privacy,
          builder: (BuildContext context, GoRouterState state) => const PrivacyScreen(),
        ),
        GoRoute(
          path: Routes.blocked,
          builder: (BuildContext context, GoRouterState state) => const BlockedScreen(),
        ),
        GoRoute(
          path: Routes.maintenance,
          builder: (BuildContext context, GoRouterState state) => const MaintenanceScreen(),
        ),
        GoRoute(
          path: Routes.forceUpdate,
          builder: (BuildContext context, GoRouterState state) => const ForceUpdateScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) =>
              AppShell(shell: shell),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.home,
                  builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.exams,
                  builder: (BuildContext context, GoRouterState state) => const ExamListScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: ':id',
                      builder: (BuildContext context, GoRouterState state) =>
                          ExamDetailScreen(examId: state.pathParameters['id']!),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'paper',
                          builder: (BuildContext context, GoRouterState state) =>
                              PaperViewerScreen(examId: state.pathParameters['id']!),
                        ),
                        GoRoute(
                          path: 'keys',
                          builder: (BuildContext context, GoRouterState state) =>
                              AnswerKeysScreen(examId: state.pathParameters['id']!),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.practice,
                  builder: (BuildContext context, GoRouterState state) => const PracticeHubScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'session/:attemptId',
                      builder: (BuildContext context, GoRouterState state) => PracticeSessionScreen(
                        attemptId: state.pathParameters['attemptId']!,
                        startIndex: int.tryParse(state.uri.queryParameters['question'] ?? '') ?? 0,
                      ),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'result',
                          builder: (BuildContext context, GoRouterState state) =>
                              ResultScreen(attemptId: state.pathParameters['attemptId']!),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'adaptive',
                      builder: (BuildContext context, GoRouterState state) => const AdaptiveSetupScreen(),
                    ),
                    GoRoute(
                      path: 'adaptive/:attemptId',
                      builder: (BuildContext context, GoRouterState state) =>
                          AdaptiveSessionScreen(attemptId: state.pathParameters['attemptId']!),
                    ),
                    GoRoute(
                      path: 'materials',
                      builder: (BuildContext context, GoRouterState state) => const MaterialsScreen(),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'add',
                          builder: (BuildContext context, GoRouterState state) => const AddMaterialScreen(),
                        ),
                        GoRoute(
                          path: 'generations/:id',
                          builder: (BuildContext context, GoRouterState state) =>
                              GenerationScreen(jobId: state.pathParameters['id']!),
                        ),
                        GoRoute(
                          path: ':id/generate',
                          builder: (BuildContext context, GoRouterState state) => GenerationConfirmScreen(
                            materialId: state.pathParameters['id']!,
                            material: state.extra is MaterialItem ? state.extra as MaterialItem? : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.wallet,
                  builder: (BuildContext context, GoRouterState state) => const WalletScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'ledger',
                      builder: (BuildContext context, GoRouterState state) => const LedgerScreen(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: Routes.profile,
                  builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: Routes.settings,
          builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.support,
          builder: (BuildContext context, GoRouterState state) => const SupportScreen(),
        ),
        GoRoute(
          path: Routes.about,
          builder: (BuildContext context, GoRouterState state) => const AboutScreen(),
        ),
        GoRoute(
          path: Routes.diagnostics,
          builder: (BuildContext context, GoRouterState state) => const DiagnosticsScreen(),
        ),
        GoRoute(
          path: Routes.gallery,
          builder: (BuildContext context, GoRouterState state) => const DesignGalleryScreen(),
        ),
        GoRoute(
          path: Routes.packages,
          builder: (BuildContext context, GoRouterState state) => const PackagesScreen(),
        ),
        GoRoute(
          path: Routes.payments,
          builder: (BuildContext context, GoRouterState state) => const PaymentsListScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: ':id',
              builder: (BuildContext context, GoRouterState state) =>
                  PaymentDetailScreen(requestId: state.pathParameters['id']!),
              routes: <RouteBase>[
                GoRoute(
                  path: 'submit',
                  builder: (BuildContext context, GoRouterState state) =>
                      SubmitReceiptScreen(requestId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (BuildContext context, GoRouterState state) => const NotFoundScreen(),
    );
  }

  /// Pure redirect rule, exposed for tests. Splash is a transient gate, never
  /// a destination: leaving it depends only on the resolved session state.
  static String? resolve(AuthStatus status, String path) {
    if (path == Routes.splash) {
      return switch (status) {
        AuthStatus.unknown => null,
        AuthStatus.signedIn => Routes.home,
        AuthStatus.signedOut => Routes.welcome,
        AuthStatus.blocked => Routes.blocked,
      };
    }
    if (status == AuthStatus.unknown) {
      return Routes.splash;
    }
    if (status == AuthStatus.blocked) {
      return path == Routes.blocked ? null : Routes.blocked;
    }
    if (status == AuthStatus.signedOut) {
      return Routes.signedOut.contains(path) ? null : Routes.welcome;
    }
    // Signed in. The recovery-code gate is the only signed-in onboarding step.
    if (path == Routes.recovery) return null;
    return Routes.onboarding.contains(path) ? Routes.home : null;
  }
}
