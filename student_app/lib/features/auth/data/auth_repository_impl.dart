/// Auth against the real API. Tokens are persisted before the result is
/// returned so a session restore can never race the first authenticated call.
library;

import '../../../core/config/constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_token_store.dart';
import '../../../core/utils/digits.dart';
import '../../../core/utils/parse.dart';
import '../../wallet/domain/entities.dart';
import '../domain/auth_repository.dart';
import '../domain/entities.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required ApiClient api, required TokenStore tokens}) : _api = api, _tokens = tokens;

  final ApiClient _api;
  final TokenStore _tokens;

  String _email(String raw) => toWesternDigits(raw.trim()).toLowerCase();

  @override
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
    required String classLevel,
    String? stream,
    required String language,
  }) async {
    final Map<String, dynamic> body = await _api.postJson(
      ApiPaths.signup,
      body: <String, dynamic>{
        'email': _email(email),
        'password': password,
        'name': name.trim(),
        'classLevel': classLevel.trim(),
        'stream': stream == null || stream.trim().isEmpty ? null : stream.trim(),
        'language': language,
      },
    );
    return _persist(body, withRecoveryCode: true);
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    final Map<String, dynamic> body = await _api.postJson(
      ApiPaths.login,
      body: <String, dynamic>{'email': _email(email), 'password': password},
    );
    return _persist(body);
  }

  @override
  Future<int> forgotPassword({required String email}) async {
    final Map<String, dynamic> body = await _api.postJson(
      ApiPaths.forgotPassword,
      body: <String, dynamic>{'email': _email(email)},
    );
    return Parse.integerOrNull(body['expires_in']) ?? 0;
  }

  @override
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _api.postJson(
      ApiPaths.passwordReset,
      body: <String, dynamic>{
        'email': _email(email),
        'code': toWesternDigits(code.trim()),
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<String> recoveryReset({
    required String email,
    required String recoveryCode,
    required String newPassword,
  }) async {
    final Map<String, dynamic> body = await _api.postJson(
      ApiPaths.recoveryReset,
      body: <String, dynamic>{
        'email': _email(email),
        'recoveryCode': recoveryCode.trim().toUpperCase(),
        'newPassword': newPassword,
      },
    );
    return Parse.string(body['recovery_code']);
  }

  @override
  Future<SessionSnapshot> me() async {
    final Map<String, dynamic> body = await _api.getJson(ApiPaths.me);
    return SessionSnapshot(
      user: AppUser.fromJson(Parse.map(body['user'])),
      profile: StudentProfile.fromJson(Parse.map(body['profile'])),
      wallet: WalletSnapshot.fromJson(Parse.map(body['wallet'])),
    );
  }

  Future<AuthResult> _persist(Map<String, dynamic> body, {bool withRecoveryCode = false}) async {    final AuthTokens tokens = AuthTokens.fromJson(Parse.map(body['tokens']));
    await _tokens.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    return AuthResult(
      user: AppUser.fromJson(Parse.map(body['user'])),
      tokens: tokens,
      profile: body['profile'] == null ? null : StudentProfile.fromJson(Parse.map(body['profile'])),
      recoveryCode: withRecoveryCode ? Parse.stringOrNull(body['recovery_code']) : null,
    );
  }
}