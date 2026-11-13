/// Typed failures raised by repositories; the UI maps them to localised copy
/// and never shows the server's English message.
library;

enum FailureKind { network, timeout, cancelled, server, api, unknown }

sealed class AppFailure {
  const AppFailure({
    required this.kind,
    this.code = '',
    this.status,
    this.fieldErrors = const <String, String>{},
    this.requestId,
  });

  const factory AppFailure.network() = NetworkFailure;
  const factory AppFailure.timeout() = TimeoutFailure;
  const factory AppFailure.cancelled() = CancelledFailure;
  const factory AppFailure.unknown([String message]) = UnknownFailure;
  factory AppFailure.server({required int status, String? requestId}) =>
      ServerFailure(status: status, requestId: requestId);
  factory AppFailure.api({
    required String code,
    required int status,
    Map<String, String> fieldErrors = const <String, String>{},
    String? requestId,
  }) => ApiFailure(code: code, status: status, fieldErrors: fieldErrors, requestId: requestId);

  final FailureKind kind;
  final String code;
  final int? status;
  final Map<String, String> fieldErrors;
  final String? requestId;

  bool get isOffline => kind == FailureKind.network || kind == FailureKind.timeout;
  bool get isTimeout => kind == FailureKind.timeout;
  bool get isServer => kind == FailureKind.server;
  bool get isBlocked => code == 'ACCOUNT_BLOCKED';
  bool get isAuthExpired => code == 'INVALID_REFRESH_TOKEN' || code == 'UNAUTHORIZED' || code == 'INVALID_TOKEN';

  String? fieldError(String field) {
    final String? direct = fieldErrors[field];
    if (direct != null) return direct;
    for (final MapEntry<String, String> entry in fieldErrors.entries) {
      if (entry.key == field || entry.key.endsWith('.$field')) return entry.value;
    }
    return null;
  }
}

class NetworkFailure extends AppFailure {
  const NetworkFailure() : super(kind: FailureKind.network, code: 'NETWORK_ERROR');
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure() : super(kind: FailureKind.timeout, code: 'NETWORK_ERROR');
}

class CancelledFailure extends AppFailure {
  const CancelledFailure() : super(kind: FailureKind.cancelled);
}

class ServerFailure extends AppFailure {
  const ServerFailure({required super.status, super.requestId})
    : super(kind: FailureKind.server, code: 'INTERNAL_ERROR');
}

class ApiFailure extends AppFailure {
  const ApiFailure({required super.code, required super.status, super.fieldErrors, super.requestId})
    : super(kind: FailureKind.api);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([this.message = '']) : super(kind: FailureKind.unknown, code: 'UNKNOWN_ERROR');

  final String message;
}
