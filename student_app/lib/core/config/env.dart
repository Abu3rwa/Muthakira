/// Build-time configuration. Everything here comes from `--dart-define`.
class Env {
  const Env._();

  /// Base URL of the API, including the `/api/v1` prefix.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://muthakira-server.onrender.com/api/v1',
  );

  /// When true the app talks to the in-memory fake API in `lib/dev/`.
  static const bool useFakeApi = bool.fromEnvironment('USE_FAKE_API');

  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  static bool get isReleaseApi => apiBaseUrl.startsWith('https://');
}
