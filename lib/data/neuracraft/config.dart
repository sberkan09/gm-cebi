/// Build-time configuration of the optional online scene feature
/// (NeuraCraft Cloud, docs/online-scene.md).
///
///   flutter run --dart-define=NC_API_URL=https://api.neuracraft.app
///
/// Without `NC_API_URL` the feature is compiled out of the UI and the app stays
/// fully offline. The client id is public: it grants nothing on its own, the
/// end user signs in with an emailed code (lib/data/neuracraft/auth.dart). It
/// is built in ([gmCebiClientId]); `--dart-define=NC_CLIENT_ID=…` overrides it
/// (e.g. a local development server).
library;

/// Same as Flutter's kReleaseMode, without importing Flutter (this layer is
/// plain Dart, so tool/nc_smoke.dart runs with `dart run`).
const _releaseMode = bool.fromEnvironment('dart.vm.product');

/// GM Cebi's client id at NeuraCraft Cloud (api.neuracraft.app). Public, not a
/// secret (neuracraft-cloud docs/partners/gm-cebi.md, "Setup").
const gmCebiClientId = 'nc_client_hZnpzu714IuIGtH2S5C26q8S';

class NcConfig {
  const NcConfig({required this.baseUrl, required this.clientId});

  /// From `--dart-define`.
  static const fromEnvironment = NcConfig(
    baseUrl: String.fromEnvironment('NC_API_URL'),
    clientId: String.fromEnvironment('NC_CLIENT_ID', defaultValue: gmCebiClientId),
  );

  /// e.g. `http://localhost:8080` (development) or the production https URL.
  final String baseUrl;

  /// GM Cebi's public client id (`nc_client_…`), sent with the sign-in calls.
  final String clientId;

  /// Release builds only talk https; plain http (a developer's machine) is
  /// for debug and profile builds.
  bool get isConfigured =>
      baseUrl.isNotEmpty && clientId.isNotEmpty && (!_releaseMode || Uri.tryParse(baseUrl)?.scheme == 'https');

  Uri uri(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$base$path');
  }
}
