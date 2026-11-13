/// Debug-only request logging. Never logs headers, bodies, tokens or answers.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      options.extra['started_at'] = DateTime.now().millisecondsSinceEpoch;
      debugPrint('--> ${options.method} ${options.path}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) _log(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) _log(err.requestOptions, err.response?.statusCode);
    handler.next(err);
  }

  void _log(RequestOptions options, int? status) {
    final Object? started = options.extra['started_at'];
    final int elapsed = started is int ? DateTime.now().millisecondsSinceEpoch - started : 0;
    debugPrint('<-- $status ${options.method} ${options.path} (${elapsed}ms)');
  }
}