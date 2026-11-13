/// Locale-aware formatting of numbers, money, marks and Khartoum dates.
/// Money and credits are always whole integers; only marks carry decimals.
library;

import 'package:intl/intl.dart';

import '../config/constants.dart';
import '../utils/bidi.dart';
import '../utils/digits.dart';

enum DigitStyle { arabicIndic, western }

class Formatters {
  const Formatters({this.locale = 'ar', this.digitStyle = DigitStyle.arabicIndic});

  final String locale;
  final DigitStyle digitStyle;

  bool get isArabic => locale == 'ar';

  String _digits(String text) => digitStyle == DigitStyle.arabicIndic
      ? toArabicIndicDigits(text).replaceAll(',', '\u066C')
      : toWesternDigits(text);

  String integer(int value) => _digits(NumberFormat.decimalPattern('en').format(value));

  String decimal(num value, {int maxFraction = 2}) {
    final String pattern = maxFraction > 0 ? '0.${'#' * maxFraction}' : '0';
    return _digits(NumberFormat(pattern, 'en').format(value));
  }

  /// Whole marks render without decimals so "5" never reads as "5.00".
  String marks(num value) =>
      value == value.roundToDouble() ? integer(value.round()) : decimal(value);

  String sdg(int amount) => isolateLtr('${integer(amount)} ${isArabic ? 'جنيه' : 'SDG'}');

  String sdgShort(int amount) => integer(amount);

  String percentage(num value) => '${integer(value.round())}%';

  String textScale(double scale) => '${integer((scale * 100).round())}%';

  /// Sudan has no DST; the server sends UTC and students read UTC+2.
  static DateTime khartoum(DateTime value) =>
      value.toUtc().add(const Duration(hours: AppInfo.khartoumUtcOffsetHours));

  String date(DateTime? value) =>
      value == null ? '—' : _digits(DateFormat.yMMMd(_dateLocale).format(khartoum(value)));

  String dateTime(DateTime? value) => value == null
      ? '—'
      : _digits(DateFormat('d MMM yyyy, HH:mm', _dateLocale).format(khartoum(value)));

  String time(DateTime? value) =>
      value == null ? '—' : _digits(DateFormat.Hm(_dateLocale).format(khartoum(value)));

  /// Days from now until [value]; negative when already past. Display only.
  int daysUntil(DateTime value) => khartoum(value).difference(khartoum(DateTime.now())).inDays;

  String get _dateLocale => isArabic ? 'ar' : 'en_GB';
}