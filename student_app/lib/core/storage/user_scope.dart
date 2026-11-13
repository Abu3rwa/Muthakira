/// The signed-in user id, used to scope every local cache row. Null when signed
/// out, which makes accidental cross-user reads impossible.
library;

class UserScope {
  String? _userId;

  String? get userId => _userId;
  bool get hasUser => _userId != null;

  /// Cache key prefix for anonymous (public) reads such as the exam catalogue.
  String get cacheOwner => _userId ?? 'public';

  void set(String? userId) => _userId = userId;
  void clear() => _userId = null;
}