/// Turns every DioException into the single AppFailure type, mapping the API
/// error envelope's `code` (never its English message) and 422 field details.
library;

import 'package:dio/dio.dart';

import '../errors/error_codes.dart';
import '../errors/failure.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppFailure) return handler.next(err);
    handler.reject(err.copyWith(error: mapDioException(err)));
  }
}

AppFailure mapDioException(DioException error) {
  if (error.type == DioExceptionType.cancel) return const AppFailure.cancelled();
  final Response<dynamic>? response = error.response;
  if (response == null) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const AppFailure.timeout(),
      _ => const AppFailure.network(),
    };
  }

  final int status = response.statusCode ?? 0;
  final Map<String, dynamic>? envelope = _envelopeOf(response.data);
  final String? requestId = envelope?['request_id'] as String?;

  if (status >= 500) {
    return AppFailure.server(status: status, requestId: requestId);
  }

  final String code = (envelope?['code'] as String?) ?? _codeForStatus(status);
  return AppFailure.api(
    code: code,
    status: status,
    fieldErrors: _fieldErrors(envelope),
    requestId: requestId,
  );
}

Map<String, dynamic>? _envelopeOf(Object? data) {
  if (data is Map && data['error'] is Map) {
    return (data['error'] as Map).cast<String, dynamic>();
  }
  return null;
}

Map<String, String> _fieldErrors(Map<String, dynamic>? envelope) {
  final Object? details = envelope?['details'];
  if (details is! List) return const <String, String>{};
  final Map<String, String> result = <String, String>{};
  for (final Object? item in details) {
    if (item is! Map) continue;
    final Object? path = item['path'];
    final Object? message = item['message'];
    if (path == null || message == null) continue;
    final String key = path is List ? path.join('.') : path.toString();
    result[key] = message.toString();
  }
  return result;
}

String _codeForStatus(int status) => switch (status) {
  401 => ErrorCodes.unauthorized,
  402 => ErrorCodes.insufficientCredits,
  403 => ErrorCodes.forbidden,
  404 => ErrorCodes.notFound,
  409 => ErrorCodes.duplicateValue,
  413 => ErrorCodes.receiptTooLarge,
  422 => ErrorCodes.validationError,
  429 => ErrorCodes.rateLimited,
  _ => ErrorCodes.unknown,
};