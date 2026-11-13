/// Auth entities: the signed-in student, their profile and their token pair.
library;

import '../../../core/utils/parse.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.kind = 'student',
    this.role = 'student',
    this.status = 'active',
    this.language = 'ar',
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, Object?> json) => AppUser(
    id: Parse.string(json['id']),
    name: Parse.string(json['name']),
    phone: Parse.stringOrNull(json['phone']),
    email: Parse.stringOrNull(json['email']),
    kind: Parse.string(json['kind'], fallback: 'student'),
    role: Parse.string(json['role'], fallback: 'student'),
    status: Parse.string(json['status'], fallback: 'active'),
    language: Parse.string(json['language'], fallback: 'ar'),
    createdAt: Parse.date(json['created_at']),
  );

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String kind;
  final String role;
  final String status;
  final String language;
  final DateTime? createdAt;

  bool get isBlocked => status == 'blocked';

  AppUser copyWith({String? name, String? language, String? status}) => AppUser(
    id: id,
    name: name ?? this.name,
    phone: phone,
    email: email,
    kind: kind,
    role: role,
    status: status ?? this.status,
    language: language ?? this.language,
    createdAt: createdAt,
  );
}

class StudentProfile {
  const StudentProfile({this.classLevel, this.stream, this.language = 'ar'});

  factory StudentProfile.fromJson(Map<String, Object?> json) => StudentProfile(
    classLevel: Parse.stringOrNull(json['class_level']),
    stream: Parse.stringOrNull(json['stream']),
    language: Parse.string(json['language'], fallback: 'ar'),
  );

  final String? classLevel;
  final String? stream;
  final String language;
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken, this.expiresIn});

  factory AuthTokens.fromJson(Map<String, Object?> json) => AuthTokens(
    accessToken: Parse.string(json['access_token']),
    refreshToken: Parse.string(json['refresh_token']),
    expiresIn: Parse.integerOrNull(json['expires_in']),
  );

  final String accessToken;
  final String refreshToken;
  final int? expiresIn;
}

/// Result of signup, login or refresh. `recoveryCode` is present only once.
class AuthResult {
  const AuthResult({required this.user, required this.tokens, this.profile, this.recoveryCode});

  final AppUser user;
  final AuthTokens tokens;
  final StudentProfile? profile;
  final String? recoveryCode;
}