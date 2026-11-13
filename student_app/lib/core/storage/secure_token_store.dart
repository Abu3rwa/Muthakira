/// Keystore-backed storage for the token pair. The access token is cached in
/// memory so request interceptors stay synchronous; every write hits disk.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/constants.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasSession => _accessToken != null && _refreshToken != null;

  Future<void> load() async {
    _accessToken = await _storage.read(key: StorageKeys.accessToken);
    _refreshToken = await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<String?> readAccessToken() async {
    final String? cached = _accessToken;
    if (cached != null) return cached;
    return _accessToken = await _storage.read(key: StorageKeys.accessToken);
  }

  Future<String?> readRefreshToken() async {
    final String? cached = _refreshToken;
    if (cached != null) return cached;
    return _refreshToken = await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> save({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }
}
