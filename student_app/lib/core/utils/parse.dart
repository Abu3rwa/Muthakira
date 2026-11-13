/// Defensive JSON readers. Every server field is treated as untrusted and
/// nullable; no `dynamic` escapes the data layer.
library;

class Parse {
  const Parse._();

  static Map<String, Object?> map(Object? value) =>
      value is Map ? value.cast<String, Object?>() : <String, Object?>{};

  static List<Object?> list(Object? value) => value is List ? value : <Object?>[];

  static List<Map<String, Object?>> mapList(Object? value) =>
      list(value).map(map).toList(growable: false);

  static String string(Object? value, {String fallback = ''}) {
    if (value is String) return value;
    if (value == null) return fallback;
    return value.toString();
  }

  static String? stringOrNull(Object? value) {
    if (value == null) return null;
    final String text = value is String ? value : value.toString();
    return text.isEmpty ? null : text;
  }

  static int integer(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static int? integerOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double decimal(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static double? decimalOrNull(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static bool boolean(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return fallback;
  }

  static bool? booleanOrNull(Object? value) {
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return null;
  }

  static DateTime? date(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    return null;
  }

  static List<String> stringList(Object? value) =>
      list(value).whereType<String>().toList(growable: false);
}