/// Attaches the access token and refreshes it once for all parallel 401s.
library;

import 'dart:async';

import 'package:dio/dio.dart';

import '../config/constants.dart';
import '../errors/error_codes.dart';
import '../storage/secure_token_store.dart';

typedef SessionExpiredCallback = void Function(String code);

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore tokens,
    required Dio refreshClient,
    required SessionExpiredCallback onSessionExpired,
  }) : _tokens = tokens,
       _refreshClient = refreshClient,
       _onSessionExpired = onSessionExpired;

  static const String retriedFlag = 'retried_after_refresh';
  static const Set<String> _publicPaths = {
    ApiPaths.login,
    ApiPaths.signup,
    ApiPaths.refresh,
    ApiPaths.recoveryReset,
  };

  final TokenStore _tokens;
  final Dio _refreshClient;
  final SessionExpiredCallback _onSessionExpired;

  Dio? _client;
  Future<bool>? _refreshing;

  /// The client used to replay a request after a successful refresh.
  set client(Dio value) => _client = value;

  bool _isPublic(String path) => _publicPaths.any(path.endsWith);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isPublic(options.path)) {
      final token = _tokens.accessToken ?? await _tokens.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final bool unauthorized = err.response?.statusCode == 401;
    final bool retried = err.requestOptions.extra[retriedFlag] == true;
    if (!unauthorized || retried || _isPublic(err.requestOptions.path) || _client == null) {
      return handler.next(err);
    }

    final bool refreshed = await _refreshOnce();
    if (!refreshed) return handler.next(err);

    final RequestOptions options = err.requestOptions;
    options.extra[retriedFlag] = true;
    options.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
    try {
      final Response<dynamic> response = await _client!.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Single flight: concurrent 401s await the same refresh call.
  Future<bool> _refreshOnce() {
    final Future<bool>? inFlight = _refreshing;
    if (inFlight != null) return inFlight;
    final Future<bool> started = _refresh();
    _refreshing = started;
    return started.whenComplete(() => _refreshing = null);
  }

  Future<bool> _refresh() async {
    final String? refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expire(ErrorCodes.invalidRefreshToken);
      return false;
    }
    try {
      final Response<dynamic> response = await _refreshClient.post<dynamic>(
        ApiPaths.refresh,
        data: <String, dynamic>{'refreshToken': refreshToken},
      );
      final Map<String, dynamic> body = (response.data as Map).cast<String, dynamic>();
      final Map<String, dynamic> tokens = (body['tokens'] as Map).cast<String, dynamic>();
      final String? access = tokens['access_token'] as String?;
      final String? rotated = tokens['refresh_token'] as String?;
      if (access == null || rotated == null) {
        await _expire(ErrorCodes.invalidRefreshToken);
        return false;
      }
      await _tokens.save(accessToken: access, refreshToken: rotated);
      return true;
    } on DioException catch (error) {
      await _expire(_codeOf(error));
      return false;
    }
  }

  String _codeOf(DioException error) {
    final Object? data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final String? code = (data['error'] as Map)['code'] as String?;
      if (code != null && code.isNotEmpty) return code;
    }
    return error.response?.statusCode == 403 ? ErrorCodes.accountBlocked : ErrorCodes.invalidRefreshToken;
  }

  Future<void> _expire(String code) async {
    await _tokens.clear();
    _onSessionExpired(code);
  }
}