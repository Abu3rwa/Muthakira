/// In-memory stand-in for the Mothakira API.
///
/// Enable with `--dart-define=USE_FAKE_API=true`. It plugs in at the dio
/// adapter level, so the real repositories, caches, auth interceptor and UI
/// all run unchanged. Nothing here is reachable in release builds because the
/// adapter is only constructed when the `USE_FAKE_API` constant is true.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/errors/error_codes.dart';
import '../core/utils/digits.dart';
import 'fake_fixtures.dart';

part 'fake_backend_ai.dart';
part 'fake_backend_exams.dart';
part 'fake_backend_payments.dart';
part 'fake_backend_practice.dart';

class FakeReply {
  const FakeReply.json(this.status, this.body) : bytes = null, contentType = 'application/json';

  const FakeReply.bytes(this.status, this.bytes, this.contentType) : body = null;

  final int status;
  final Object? body;
  final List<int>? bytes;
  final String contentType;
}

class FakeBackend {
  FakeBackend() : store = FakeStore();

  final FakeStore store;

  FakeReply handle(RequestOptions options) {
    final String method = options.method.toUpperCase();
    final List<String> segments = options.path.split('/').where((String part) => part.isNotEmpty).toList();
    try {
      if (segments.isEmpty) {
        throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      }
      switch (segments.first) {
        case 'auth':
          return _auth(options, method, segments);
        case 'wallet':
          _authorize(options);
          return _wallet(method, segments);
        case 'exams':
          _authorize(options);
          return _exams(options, method, segments);
        case 'practice':
          _authorize(options);
          return _practice(options, method, segments);
        case 'questions':
          _authorize(options);
          return _questions(options, method, segments);
        case 'packages':
          _authorize(options);
          return const FakeReply.json(200, <String, Object?>{'items': FakeStore.packages});
        case 'payments':
          _authorize(options);
          return _payments(options, method, segments);
        case 'ai':
          _authorize(options);
          return _ai(options, method, segments);
        default:
          throw _FakeHttpError(404, ErrorCodes.notFound, 'No route for $method ${options.path}');
      }
    } on _FakeHttpError catch (error) {
      return FakeReply.json(error.status, _error(error.code, error.message));
    }
  }

  FakeReply _auth(RequestOptions options, String method, List<String> segments) {
    final String path = segments.skip(1).join('/');
    if (path == 'me' && method == 'GET') {
      _authorize(options);
      return FakeReply.json(200, <String, Object?>{
        'user': store.userJson(),
        'profile': store.profileJson(),
        'wallet': store.wallet,
      });
    }
    if (method != 'POST') {
      throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    }
    switch (path) {
      case 'student/signup':
        return FakeReply.json(200, _signup(_body(options)));
      case 'login':
        return FakeReply.json(200, _login(_body(options)));
      case 'refresh':
        final String refreshToken = _string(_body(options)['refreshToken']);
        if (!refreshToken.startsWith('fake-refresh-')) {
          throw const _FakeHttpError(401, ErrorCodes.invalidRefreshToken, 'Refresh token is invalid');
        }
        return FakeReply.json(200, <String, Object?>{'tokens': store.issueTokens()});
      case 'password/forgot':
        return const FakeReply.json(200, <String, Object?>{'expires_in': 600});
      case 'password/reset':
        return const FakeReply.json(200, <String, Object?>{'ok': true});
      case 'recovery/reset':
        final String code = _string(_body(options)['recoveryCode']);
        if (code.isEmpty) {
          throw const _FakeHttpError(422, ErrorCodes.invalidRecoveryCode, 'Recovery code is invalid');
        }
        return const FakeReply.json(200, <String, Object?>{'recovery_code': 'MOTH-7K2P-4XQ9'});
      default:
        throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    }
  }

  Map<String, Object?> _signup(Map<String, Object?> body) {
    final String email = _string(body['email']);
    final String password = _string(body['password']);
    final String name = _string(body['name']);
    final String classLevel = _string(body['classLevel']);
    if (!email.contains('@')) {
      throw const _FakeHttpError(422, ErrorCodes.invalidEmail, 'Enter a valid email address');
    }
    if (password.length < 8) {
      throw const _FakeHttpError(422, ErrorCodes.validationError, 'Password must be at least 8 characters');
    }
    if (name.isEmpty || classLevel.isEmpty) {
      throw const _FakeHttpError(422, ErrorCodes.validationError, 'Name and class are required');
    }
    store
      ..email = email
      ..userName = name
      ..classLevel = classLevel
      ..stream = _string(body['stream']).isEmpty ? null : _string(body['stream'])
      ..language = _string(body['language']).isEmpty ? 'ar' : _string(body['language']);
    return <String, Object?>{
      'tokens': store.issueTokens(),
      'user': store.userJson(),
      'profile': store.profileJson(),
      'recovery_code': 'MOTH-4F7K-9Q2C',
    };
  }

  Map<String, Object?> _login(Map<String, Object?> body) {
    final String email = _string(body['email']);
    final String password = _string(body['password']);
    if (!email.contains('@') || password.length < 8) {
      throw const _FakeHttpError(401, ErrorCodes.invalidCredentials, 'Email or password is incorrect');
    }
    store.email = email;
    return <String, Object?>{
      'tokens': store.issueTokens(),
      'user': store.userJson(),
      'profile': store.profileJson(),
    };
  }

  FakeReply _wallet(String method, List<String> segments) {
    if (segments.length > 1 && segments[1] == 'ledger') {
      if (method != 'GET') {
        throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
      }
      final List<Map<String, Object?>> items = List<Map<String, Object?>>.of(store.ledger)
        ..sort((Map<String, Object?> left, Map<String, Object?> right) =>
            _string(right['created_at']).compareTo(_string(left['created_at'])));
      return FakeReply.json(200, <String, Object?>{'items': items, 'next_cursor': null});
    }
    if (method != 'GET') {
      throw const _FakeHttpError(404, ErrorCodes.notFound, 'No route');
    }
    return FakeReply.json(200, store.wallet);
  }

  void _authorize(RequestOptions options) {
    final Object? header = options.headers['Authorization'];
    if (header is! String || !header.startsWith('Bearer fake-access-')) {
      throw const _FakeHttpError(401, ErrorCodes.unauthorized, 'Sign in to continue');
    }
  }
}

class FakeStore {
  FakeStore() {
    addLedger(type: 'signup_bonus', amount: 4, reason: 'رصيد ترحيبي');
  }

  static const List<Map<String, Object?>> packages = <Map<String, Object?>>[
    <String, Object?>{
      'id': 'pkg_5',
      'name': <String, Object?>{'ar': '٥ نقاط', 'en': '5 credits'},
      'credits': 5,
      'price_sdg': 2500,
    },
    <String, Object?>{
      'id': 'pkg_12',
      'name': <String, Object?>{'ar': '١٢ نقطة', 'en': '12 credits'},
      'credits': 12,
      'price_sdg': 5000,
    },
    <String, Object?>{
      'id': 'pkg_25',
      'name': <String, Object?>{'ar': '٢٥ نقطة', 'en': '25 credits'},
      'credits': 25,
      'price_sdg': 9000,
    },
  ];

  final String userId = 'stu_fake_001';
  String userName = 'طالب تجريبي';
  String email = 'demo@mothakira.sd';
  String classLevel = 'الصف الثالث متوسط';
  String? stream;
  String language = 'ar';
  int balance = 4;
  int reserved = 0;
  int _sequence = 200;
  int _tokenCount = 10;

  final Map<String, FakeExam> exams = buildFakeExams();
  final Map<String, Map<String, Object?>> unlocks = <String, Map<String, Object?>>{};
  final List<Map<String, Object?>> ledger = <Map<String, Object?>>[];
  final Map<String, FakeAttemptState> attempts = <String, FakeAttemptState>{};
  final List<Map<String, Object?>> payments = <Map<String, Object?>>[];
  final Map<String, Map<String, Object?>> receipts = <String, Map<String, Object?>>{};
  final Map<String, List<int>> receiptFiles = <String, List<int>>{};
  final List<FakeMaterial> materials = <FakeMaterial>[];
  final List<FakeGenerationJob> jobs = <FakeGenerationJob>[];

  String nextId(String prefix) => '${prefix}_${_sequence++}';

  Map<String, Object?> get wallet => <String, Object?>{
    'balance': balance,
    'reserved': reserved,
    'available': balance - reserved,
    'next_expiry_at': _iso(DateTime.now().add(const Duration(days: 30))),
  };

  Map<String, Object?> userJson() => <String, Object?>{
    'id': userId,
    'name': userName,
    'email': email,
    'phone': '+249900000000',
    'kind': 'student',
    'role': 'student',
    'status': 'active',
    'language': language,
    'created_at': '2025-11-01T09:00:00.000Z',
  };

  Map<String, Object?> profileJson() => <String, Object?>{
    'class_level': classLevel,
    'stream': stream,
    'language': language,
  };

  Map<String, Object?> issueTokens() {
    _tokenCount += 1;
    return <String, Object?>{
      'access_token': 'fake-access-$_tokenCount',
      'refresh_token': 'fake-refresh-$_tokenCount',
      'expires_in': 900,
    };
  }

  void addLedger({required String type, required int amount, String? lotId, String? paymentId, String? reason}) {
    ledger.add(<String, Object?>{
      'id': nextId('ledger'),
      'entry_type': type,
      'amount': amount,
      'created_at': _iso(DateTime.now()),
      'lot_id': lotId,
      'payment_id': paymentId,
      'reason': reason,
    });
  }
}

class _FakeHttpError implements Exception {
  const _FakeHttpError(this.status, this.code, this.message);

  final int status;
  final String code;
  final String message;
}

Map<String, Object?> _error(String code, String message) => <String, Object?>{
  'error': <String, Object?>{
    'code': code,
    'message': message,
    'details': const <Object?>[],
    'request_id': 'fake-request',
  },
};

Map<String, Object?> _body(RequestOptions options) {
  final Object? data = options.data;
  if (data is Map) return data.cast<String, Object?>();
  return const <String, Object?>{};
}

String _string(Object? value) => value is String ? value.trim() : '';

String _iso(DateTime value) => value.toUtc().toIso8601String();

/// Normalised text for objective marking: Arabic-Indic digits, diacritics,
/// alef/hamza forms and whitespace are all folded before comparison.
String _normalize(Object? value) {
  if (value == null) return '';
  String text = toWesternDigits(value.toString()).trim().toLowerCase();
  text = text.replaceAll(RegExp('[\u064B-\u0652]'), '');
  text = text
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه');
  return text.replaceAll(RegExp(r'\s+'), ' ');
}
