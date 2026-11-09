/// Build-time configuration of the optional online scene feature
/// (NeuraCraft Cloud, docs/online-scene.md).
///
///   flutter run --dart-define=NC_API_URL=http://10.0.2.2:8080 --dart-define=NC_APP_TOKEN=nc_app_…
///
/// Without both values the feature is compiled out of the UI and the app stays
/// fully offline. Never commit a real token.
library;

class NcConfig {
  const NcConfig({required this.baseUrl, required this.appToken});

  /// From `--dart-define`.
  static const fromEnvironment = NcConfig(
    baseUrl: String.fromEnvironment('NC_API_URL'),
    appToken: String.fromEnvironment('NC_APP_TOKEN'),
  );

  /// e.g. `http://localhost:8080` (development) or the production https URL.
  final String baseUrl;

  /// An app token (`nc_app_…`): scopes jobs:submit, jobs:read, assets:read.
  final String appToken;

  bool get isConfigured => baseUrl.isNotEmpty && appToken.isNotEmpty;

  Uri uri(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$base$path');
  }
}
