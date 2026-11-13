/// Values that would otherwise be scattered magic numbers and strings.
library;

class AppInfo {
  const AppInfo._();

  static const String nameAr = 'مذكرة';
  static const String nameEn = 'Mothakira';
  static const String supportPhone = '+249900000000';
  static const String supportWhatsApp = '249900000000';
  static const String bankakPackage = 'com.bankofkhartoum.bankak';
  static const String privacyUrl = 'https://mothakira.sd/privacy';

  /// Sudan has no DST; server timestamps are UTC.
  static const int khartoumUtcOffsetHours = 2;
}

class Limits {
  const Limits._();

  static const Duration requestTimeout = Duration(seconds: 30);

  /// Paid AI calls outlive [requestTimeout]: the server allows up to 60s per
  /// model call (two for generation), so the client must wait longer than the
  /// server works, then recover the stored result instead of guessing failure.
  static const Duration aiGradeTimeout = Duration(seconds: 150);
  static const Duration aiGenerationTimeout = Duration(seconds: 180);
  static const Duration serverWakingAfter = Duration(seconds: 6);
  static const Duration shortAnimation = Duration(milliseconds: 180);
  static const Duration paymentPollStart = Duration(seconds: 30);
  static const Duration paymentPollMax = Duration(minutes: 2);
  static const Duration answerRetryBase = Duration(seconds: 5);

  static const int pageSize = 20;
  static const int ledgerPageSize = 50;
  static const int cataloguePageSize = 100;
  /// Matches the server's answer cap (JSON length ≤ 4000).
  static const int maxAnswerLength = 4000;
  static const int maxReceiptBytes = 8 * 1024 * 1024;
  static const int targetReceiptBytes = 800 * 1024;
  static const int receiptMinLongSide = 1280;
  static const int recentErrorsKept = 50;
  static const int reportReasonMin = 5;

  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.5;
}

class ApiPaths {
  const ApiPaths._();

  static const String signup = '/auth/student/signup';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/password/forgot';
  static const String passwordReset = '/auth/password/reset';
  static const String recoveryReset = '/auth/recovery/reset';
  static const String me = '/auth/me';

  static const String wallet = '/wallet';
  static const String ledger = '/wallet/ledger';

  static const String exams = '/exams';
  static const String unlocks = '/exams/unlocks';
  static String exam(String id) => '/exams/$id';
  static String examKeys(String id) => '/exams/$id/keys';
  static String examUnlock(String id) => '/exams/$id/unlock';

  static const String attempts = '/practice/attempts';
  static String attempt(String id) => '/practice/attempts/$id';
  static String attemptAnswers(String id) => '/practice/attempts/$id/answers';
  static String attemptClose(String id) => '/practice/attempts/$id/close';
  static String attemptNextQuestion(String id) => '/practice/attempts/$id/next-question';
  static String answerAiGrade(String id) => '/practice/answers/$id/ai-grade';
  static String answerSelfMark(String id) => '/practice/answers/$id/self-mark';
  static String reportQuestion(String id) => '/questions/$id/report';

  static const String aiMaterials = '/ai/materials';
  static const String aiMaterialsText = '/ai/materials/text';
  static const String aiGenerations = '/ai/generations';
  static String aiGeneration(String id) => '/ai/generations/$id';

  static const String packages = '/packages';
  static const String receipts = '/payments/receipts';
  static String receiptFile(String id) => '/payments/receipts/$id/file';
  static String receiptStatus(String id) => '/payments/receipts/$id';
  static const String paymentRequests = '/payments/requests';
  static String paymentRequest(String id) => '/payments/requests/$id';
  static String paymentCancel(String id) => '/payments/requests/$id/cancel';
  static String paymentReceipt(String id) => '/payments/requests/$id/receipt';
}

class StorageKeys {
  const StorageKeys._();

  static const String accessToken = 'auth.access_token';
  static const String refreshToken = 'auth.refresh_token';
  static const String cacheKey = 'cache.payload_key';
}

/// Backwards-compatible aliases used by earlier layers.
class AppConstants {
  const AppConstants._();

  static const String supportPhone = AppInfo.supportPhone;
  static const String supportWhatsApp = AppInfo.supportWhatsApp;
  static const String bankakPackage = AppInfo.bankakPackage;
  static const String privacyUrl = AppInfo.privacyUrl;

  static const Duration requestTimeout = Limits.requestTimeout;
  static const Duration serverWakingAfter = Limits.serverWakingAfter;
  static const Duration shortAnimation = Limits.shortAnimation;
  static const Duration feedbackAnimation = Duration(milliseconds: 220);
  static const Duration paymentPollStart = Limits.paymentPollStart;
  static const Duration paymentPollMax = Limits.paymentPollMax;
  static const Duration answerRetryBase = Limits.answerRetryBase;

  static const int pageSize = Limits.pageSize;
  static const int ledgerPageSize = Limits.ledgerPageSize;
  static const int maxAnswerLength = Limits.maxAnswerLength;
  static const int maxReceiptBytes = Limits.maxReceiptBytes;
  static const int targetReceiptBytes = Limits.targetReceiptBytes;
  static const int receiptMinLongSide = Limits.receiptMinLongSide;
  static const int recentErrorsKept = Limits.recentErrorsKept;

  static const List<String> arabicLetters = ['أ', 'ب', 'ج', 'د', 'هـ', 'و', 'ز', 'ح', 'ط', 'ي'];
  static const List<String> englishLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

  static const double minTextScale = Limits.minTextScale;
  static const double maxTextScale = Limits.maxTextScale;
}
