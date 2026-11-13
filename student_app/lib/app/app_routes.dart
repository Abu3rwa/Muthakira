/// Every route path in one place; nothing else builds a location string.
library;

class Routes {
  const Routes._();

  static const String splash = '/splash';
  static const String language = '/language';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String recovery = '/recovery';
  static const String forgot = '/forgot';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String blocked = '/blocked';
  static const String maintenance = '/maintenance';
  static const String forceUpdate = '/force-update';

  static const String home = '/home';
  static const String exams = '/exams';
  static const String practice = '/practice';
  static const String wallet = '/wallet';
  static const String profile = '/profile';

  static const String examDetail = '/exams/:id';
  static String exam(String id) => '/exams/$id';
  static const String paper = '/exams/:id/paper';
  static String paperOf(String id) => '/exams/$id/paper';
  static const String keys = '/exams/:id/keys';
  static String keysOf(String id) => '/exams/$id/keys';

  static const String session = '/practice/session/:attemptId';
  static String sessionOf(String attemptId) => '/practice/session/$attemptId';
  static const String result = '/practice/session/:attemptId/result';
  static String resultOf(String attemptId) => '/practice/session/$attemptId/result';

  static const String adaptive = '/practice/adaptive';
  static const String adaptiveSession = '/practice/adaptive/:attemptId';
  static String adaptiveSessionOf(String attemptId) => '/practice/adaptive/$attemptId';

  static const String materials = '/practice/materials';
  static const String materialAdd = '/practice/materials/add';
  static const String generationConfirm = '/practice/materials/:id/generate';
  static String generationConfirmOf(String materialId) => '/practice/materials/$materialId/generate';
  static const String generation = '/practice/materials/generations/:id';
  static String generationOf(String jobId) => '/practice/materials/generations/$jobId';

  static const String ledger = '/wallet/ledger';
  static const String packages = '/packages';
  static const String payments = '/payments';
  static const String paymentDetail = '/payments/:id';
  static String payment(String id) => '/payments/$id';
  static const String paymentSubmit = '/payments/:id/submit';
  static String paymentSubmitOf(String id) => '/payments/$id/submit';

  static const String unlocks = '/unlocks';
  static const String settings = '/settings';
  static const String support = '/support';
  static const String about = '/about';
  static const String diagnostics = '/diagnostics';
  static const String gallery = '/gallery';

  /// Reachable without a session.
  static const Set<String> signedOut = <String>{
    splash,
    language,
    welcome,
    login,
    signup,
    forgot,
    terms,
    privacy,
    blocked,
    maintenance,
    forceUpdate,
  };

  /// Only useful before signing in; a signed-in student is sent home.
  static const Set<String> onboarding = <String>{language, welcome, login, signup, forgot};
}