/// Session state for the whole app: restore, signup, login, reset, logout.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/error_codes.dart';
import '../../../core/errors/failure.dart';
import '../../../core/storage/cache_store.dart';
import '../../../core/storage/prefs_store.dart';
import '../../../core/storage/secure_token_store.dart';
import '../../../core/storage/user_scope.dart';
import '../domain/auth_repository.dart';
import '../domain/entities.dart';

enum AuthStatus { unknown, signedOut, signedIn, blocked }

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
    required TokenStore tokens,
    required PrefsStore prefs,
    required CacheStore cache,
    required UserScope scope,
  }) : _repository = repository,
       _tokens = tokens,
       _prefs = prefs,
       _cache = cache,
       _scope = scope;

  final AuthRepository _repository;
  final TokenStore _tokens;
  final PrefsStore _prefs;
  final CacheStore _cache;
  final UserScope _scope;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  StudentProfile? _profile;
  String? _recoveryCode;
  int? _resetExpiresIn;
  AppFailure? _failure;
  bool _isBusy = false;
  bool _disposed = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  StudentProfile? get profile => _profile;
  String? get recoveryCode => _recoveryCode;
  int? get resetExpiresIn => _resetExpiresIn;
  AppFailure? get failure => _failure;
  bool get isBusy => _isBusy;
  bool get isSignedIn => _status == AuthStatus.signedIn;
  String? get userId => _user?.id;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> restore() async {
    final String? token = await _tokens.readAccessToken().timeout(
      restoreTimeout,
      onTimeout: () => null,
    );
    if (token == null || token.isEmpty) {
      _setStatus(AuthStatus.signedOut);
      return;
    }
    try {
      final SessionSnapshot snapshot = await _repository.me().timeout(restoreTimeout);
      _adopt(snapshot);
    } on TimeoutException {
      // The server may still be waking up; keep the tokens and let the next
      // launch retry instead of trapping the user on the splash forever.
      _setStatus(AuthStatus.signedOut);
    } on AppFailure catch (failure) {
      if (failure.isBlocked) {
        _setStatus(AuthStatus.blocked);
        return;
      }
      await _clearLocalQuietly();
      _setStatus(AuthStatus.signedOut);
    } on Object {
      await _clearLocalQuietly();
      _setStatus(AuthStatus.signedOut);
    } finally {
      if (_status == AuthStatus.unknown) _setStatus(AuthStatus.signedOut);
    }
  }

  /// Startup must never wait on a cold server longer than this.
  static const Duration restoreTimeout = Duration(seconds: 12);

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String classLevel,
    String? stream,
    required String language,
  }) => _run(() async {
    final AuthResult result = await _repository.signup(
      email: email,
      password: password,
      name: name,
      classLevel: classLevel,
      stream: stream,
      language: language,
    );
    _recoveryCode = result.recoveryCode;
    _user = result.user;
    _profile = result.profile ?? StudentProfile(classLevel: classLevel, stream: stream, language: language);
    _scope.set(result.user.id);
    await _prefs.setTermsAccepted(true);
    _setStatus(AuthStatus.signedIn);
  });

  Future<bool> login({required String email, required String password}) => _run(() async {
    final AuthResult result = await _repository.login(email: email, password: password);
    _user = result.user;
    _scope.set(result.user.id);
    _setStatus(AuthStatus.signedIn);
    await _loadProfile();
  });

  /// Sends a reset code. Always succeeds for a well-formed address; the
  /// repository never reveals whether the account exists.
  Future<bool> forgotPassword({required String email}) => _run(() async {
    _resetExpiresIn = await _repository.forgotPassword(email: email);
  });

  Future<bool> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) => _run(() async {
    await _repository.resetPasswordWithCode(email: email, code: code, newPassword: newPassword);
  });

  /// Offline fallback for students who saved the recovery code at signup.
  Future<bool> recoveryReset({
    required String email,
    required String recoveryCode,
    required String newPassword,
  }) => _run(() async {
    _recoveryCode = await _repository.recoveryReset(
      email: email,
      recoveryCode: recoveryCode,
      newPassword: newPassword,
    );
  });

  Future<void> logout() async {
    await _clearLocal();
    _user = null;
    _profile = null;
    _recoveryCode = null;
    _failure = null;
    _setStatus(AuthStatus.signedOut);
  }

  /// Called by the auth interceptor when refresh fails or the account is blocked.
  Future<void> onSessionExpired(String code) async {
    await _clearLocal();
    _user = null;
    _profile = null;
    _setStatus(code == ErrorCodes.accountBlocked ? AuthStatus.blocked : AuthStatus.signedOut);
  }

  void clearRecoveryCode() {
    _recoveryCode = null;
  }

  void clearResetState() {
    _resetExpiresIn = null;
    _failure = null;
    notifyListeners();
  }

  void clearFailure() {
    if (_failure == null) return;
    _failure = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (!isSignedIn) return;
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final SessionSnapshot snapshot = await _repository.me();
      _adopt(snapshot);
    } on AppFailure {
      // The session is already valid; a failed profile read must not sign out.
    }
  }

  void _adopt(SessionSnapshot snapshot) {
    _user = snapshot.user;
    _profile = snapshot.profile;
    _scope.set(snapshot.user.id);
    _setStatus(snapshot.user.isBlocked ? AuthStatus.blocked : AuthStatus.signedIn);
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isBusy = true;
    _failure = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppFailure catch (failure) {
      _failure = failure;
      if (failure.isBlocked) _setStatus(AuthStatus.blocked);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _clearLocal() async {
    final String? ownerId = _scope.userId;
    await _tokens.clear();
    if (ownerId != null) await _cache.wipeUser(ownerId);
    await _prefs.clearUserData();
    _scope.clear();
  }

  /// Cleanup during startup must never block the router from leaving splash.
  Future<void> _clearLocalQuietly() async {
    try {
      await _clearLocal();
    } on Object {
      _scope.clear();
    }
  }

  void _setStatus(AuthStatus next) {
    _status = next;
    notifyListeners();
  }
}