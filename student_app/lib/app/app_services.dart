/// Composition root. Every dependency is built once here and handed to the
/// widget tree through provider; nothing else constructs a repository.
library;

import 'dart:async';

import '../core/config/env.dart';
import '../core/l10n/locale_controller.dart';
import '../core/network/api_client.dart';
import '../core/network/connectivity_controller.dart';
import '../core/storage/app_database.dart';
import '../core/storage/cache_store.dart';
import '../core/storage/prefs_store.dart';
import '../core/storage/secret_box.dart';
import '../core/storage/secure_token_store.dart';
import '../core/storage/user_scope.dart';
import '../core/theme/theme_controller.dart';
import '../dev/fake_api_adapter.dart';
import '../dev/fake_backend.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/exams/data/api_exam_repository.dart';
import '../features/exams/domain/exam_repository.dart';
import '../features/materials/data/api_materials_repository.dart';
import '../features/materials/domain/materials_repository.dart';
import '../features/payments/data/api_payment_repository.dart';
import '../features/payments/domain/payment_repository.dart';
import '../features/practice/data/api_practice_repository.dart';
import '../features/practice/domain/practice_repository.dart';
import '../features/wallet/data/wallet_repository_impl.dart';
import '../features/wallet/domain/wallet_repository.dart';
import '../features/wallet/presentation/wallet_controller.dart';

class AppServices {
  AppServices._({
    required this.prefs,
    required this.tokens,
    required this.database,
    required this.cache,
    required this.scope,
    required this.api,
    required this.connectivity,
    required this.locale,
    required this.theme,
    required this.auth,
    required this.wallet,
    required this.authRepository,
    required this.walletRepository,
    required this.examRepository,
    required this.practiceRepository,
    required this.paymentRepository,
    required this.materialsRepository,
  });

  final PrefsStore prefs;
  final TokenStore tokens;
  final AppDatabase database;
  final CacheStore cache;
  final UserScope scope;
  final ApiClient api;
  final ConnectivityController connectivity;
  final LocaleController locale;
  final ThemeController theme;
  final AuthController auth;
  final WalletController wallet;
  final AuthRepository authRepository;
  final WalletRepository walletRepository;
  final ExamRepository examRepository;
  final PracticeRepository practiceRepository;
  final PaymentRepository paymentRepository;
  final MaterialsRepository materialsRepository;

  static Future<AppServices> create() async {
    final PrefsStore prefs = await PrefsStore.open();
    final TokenStore tokens = TokenStore();
    await tokens.load();

    final AppDatabase database = AppDatabase.open();
    final CacheStore cache = CacheStore(database, SecretBox());
    final UserScope scope = UserScope();

    // The interceptor can fire before the controller exists, so the callback
    // closes over a nullable reference that is filled in below.
    AuthController? sessionOwner;
    final ApiClient api = ApiClient(
      tokens: tokens,
      onSessionExpired: (String code) => unawaited(sessionOwner?.onSessionExpired(code)),
      adapter: Env.useFakeApi ? FakeApiAdapter(FakeBackend()) : null,
    );

    final AuthRepository authRepository = ApiAuthRepository(api: api, tokens: tokens);
    final WalletRepository walletRepository = ApiWalletRepository(api: api, cache: cache, scope: scope);
    final ExamRepository examRepository = ApiExamRepository(api: api, cache: cache, scope: scope);
    final PracticeRepository practiceRepository = ApiPracticeRepository(api, cache, scope);
    final PaymentRepository paymentRepository = ApiPaymentRepository(api, cache, scope);
    final MaterialsRepository materialsRepository = ApiMaterialsRepository(api);

    final AuthController auth = AuthController(
      repository: authRepository,
      tokens: tokens,
      prefs: prefs,
      cache: cache,
      scope: scope,
    );
    sessionOwner = auth;

    final WalletController wallet = WalletController(repository: walletRepository);
    final AppServices services = AppServices._(
      prefs: prefs,
      tokens: tokens,
      database: database,
      cache: cache,
      scope: scope,
      api: api,
      connectivity: ConnectivityController(),
      locale: LocaleController(prefs),
      theme: ThemeController(prefs),
      auth: auth,
      wallet: wallet,
      authRepository: authRepository,
      walletRepository: walletRepository,
      examRepository: examRepository,
      practiceRepository: practiceRepository,
      paymentRepository: paymentRepository,
      materialsRepository: materialsRepository,
    );
    services._watchSession();
    unawaited(auth.restore());
    return services;
  }

  /// The balance is loaded once per sign-in and cleared on sign-out, so no
  /// screen can ever show the previous student's credits.
  void _watchSession() {
    AuthStatus last = auth.status;
    auth.addListener(() {
      final AuthStatus next = auth.status;
      if (next == last) return;
      last = next;
      if (next == AuthStatus.signedIn) {
        unawaited(wallet.load());
      } else {
        wallet.reset();
      }
    });
  }

  bool get usesFakeApi => Env.useFakeApi;

  Future<void> dispose() async {
    connectivity.dispose();
    auth.dispose();
    wallet.dispose();
    locale.dispose();
    theme.dispose();
    await database.close();
  }
}