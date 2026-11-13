import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config/constants.dart';
import '../config/env.dart';
import '../errors/error_codes.dart';
import '../errors/failure.dart';
import '../storage/secure_token_store.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'logging_interceptor.dart';

/// Authenticated HTTP client. Tokens and refresh live in [AuthInterceptor];
/// every failure surfaces as a typed [AppFailure].
class ApiClient {
  ApiClient({
    required TokenStore tokens,
    required SessionExpiredCallback onSessionExpired,
    Dio? dio,
    Dio? refreshDio,
    HttpClientAdapter? adapter,
  }) : _tokens = tokens {
    _dio = dio ?? Dio();
    _dio.options = BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Limits.requestTimeout,
      receiveTimeout: Limits.requestTimeout,
      sendTimeout: const Duration(minutes: 2),
      headers: <String, String>{'Accept': 'application/json'},
      validateStatus: (int? status) => status != null && status < 400,
    );
    final Dio refreshClient = refreshDio ?? Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: <String, String>{'Accept': 'application/json'},
    ));
    if (adapter != null) {
      _dio.httpClientAdapter = adapter;
      refreshClient.httpClientAdapter = adapter;
    }
    final AuthInterceptor auth = AuthInterceptor(
      tokens: tokens,
      refreshClient: refreshClient,
      onSessionExpired: onSessionExpired,
    );
    auth.client = _dio;
    _dio.interceptors.addAll(<Interceptor>[LoggingInterceptor(), auth, ErrorInterceptor()]);
  }

  final TokenStore _tokens;
  late final Dio _dio;

  TokenStore get tokens => _tokens;

  Future<void> restore() => _tokens.load();

  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query, Duration? receiveTimeout}) =>
      _request('GET', path, query: query, receiveTimeout: receiveTimeout);

  Future<Map<String, dynamic>> postJson(String path, {Object? body, Duration? receiveTimeout}) =>
      _request('POST', path, body: body, receiveTimeout: receiveTimeout);

  Future<Map<String, dynamic>> patchJson(String path, {Object? body}) => _request('PATCH', path, body: body);

  Future<Map<String, dynamic>> deleteJson(String path) => _request('DELETE', path);

  Future<Map<String, dynamic>> upload(String path, {required FormData formData}) =>
      _request('POST', path, body: formData);

  Future<Uint8List> getBytes(String path) async {
    try {
      final Response<List<int>> response = await _dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const <int>[]);
    } on DioException catch (error) {
      throw await _failureOf(error);
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Duration? receiveTimeout,
  }) async {
    try {
      final Response<dynamic> response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          contentType: body is FormData ? 'multipart/form-data' : null,
          receiveTimeout: receiveTimeout,
        ),
      );
      final Object? data = response.data;
      if (data is Map) return data.cast<String, dynamic>();
      return const <String, dynamic>{};
    } on DioException catch (error) {
      throw await _failureOf(error);
    }
  }

  Future<AppFailure> _failureOf(DioException error) async {
    final Object? mapped = error.error;
    final AppFailure failure = mapped is AppFailure ? mapped : mapDioException(error);
    if (failure.code == ErrorCodes.accountBlocked) {
      await _tokens.clear();
    }
    return failure;
  }
}
