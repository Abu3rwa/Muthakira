/// Auth contract. Implementations: the real API and the fixture-backed fake.
library;

import '../../wallet/domain/entities.dart';
import 'entities.dart';

class SessionSnapshot {
  const SessionSnapshot({required this.user, required this.profile, required this.wallet});

  final AppUser user;
  final StudentProfile profile;
  final WalletSnapshot wallet;
}

abstract interface class AuthRepository {
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
    required String classLevel,
    String? stream,
    required String language,
  });

  Future<AuthResult> login({required String email, required String password});

  /// Emails a reset code when the address has an account. The reply is the
  /// same either way, so this cannot be used to discover registered emails.
  /// Returns how long the code stays valid, in seconds.
  Future<int> forgotPassword({required String email});

  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Offline fallback. Returns the newly issued recovery code, shown once.
  Future<String> recoveryReset({
    required String email,
    required String recoveryCode,
    required String newPassword,
  });

  Future<SessionSnapshot> me();
}