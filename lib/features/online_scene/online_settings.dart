/// Settings of the optional online scene feature, kept in the same settings
/// table as the rest: on/off and the first-use consent. The sign-in lives in
/// account.dart (platform keystore).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/neuracraft/client.dart';
import '../../data/neuracraft/config.dart';
import '../../providers.dart';
import 'account.dart';

class OnlineSettings {
  const OnlineSettings({this.enabled = true, this.consented = false, this.authInvalid = false});

  /// The user's switch in Settings. On by default; nothing is sent before
  /// [consented].
  final bool enabled;

  /// The user accepted that the sketch and the description go to the server.
  final bool consented;

  /// The service no longer accepts this build (`auth.client_invalid`,
  /// `auth.end_user_token_required`…): the feature stays off until an app
  /// update. Not persisted: a new build may fix it.
  final bool authInvalid;

  OnlineSettings copyWith({bool? enabled, bool? consented, bool? authInvalid}) => OnlineSettings(
        enabled: enabled ?? this.enabled,
        consented: consented ?? this.consented,
        authInvalid: authInvalid ?? this.authInvalid,
      );
}

class OnlineSettingsNotifier extends AsyncNotifier<OnlineSettings> {
  // `ncInstallId` (the old X-End-User) is no longer read or written.
  static const kEnabled = 'ncEnabled', kConsent = 'ncConsent';

  @override
  Future<OnlineSettings> build() async {
    final m = await ref.read(databaseProvider).readSettings();
    return OnlineSettings(enabled: m[kEnabled] != 'false', consented: m[kConsent] == 'true');
  }

  OnlineSettings get _current => state.value ?? const OnlineSettings();

  Future<void> setEnabled(bool v) async {
    state = AsyncData(_current.copyWith(enabled: v));
    await ref.read(databaseProvider).writeSetting(kEnabled, '$v');
  }

  Future<void> setConsented(bool v) async {
    state = AsyncData(_current.copyWith(consented: v));
    await ref.read(databaseProvider).writeSetting(kConsent, '$v');
  }

  void markAuthInvalid() => state = AsyncData(_current.copyWith(authInvalid: true));
}

final onlineSettingsProvider = AsyncNotifierProvider<OnlineSettingsNotifier, OnlineSettings>(OnlineSettingsNotifier.new);

/// Build-time configuration; overridden in tests.
final ncConfigProvider = Provider<NcConfig>((ref) => NcConfig.fromEnvironment);

final ncHttpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// Null when the build has no NeuraCraft configuration (offline-only build).
final ncClientProvider = Provider<NeuraCraftClient?>((ref) {
  final config = ref.watch(ncConfigProvider);
  final auth = ref.watch(ncTokenManagerProvider);
  if (!config.isConfigured || auth == null) return null;
  return NeuraCraftClient(httpClient: ref.watch(ncHttpClientProvider), config: config, auth: auth);
});

/// The feature is in this build and the user has not turned it off.
final onlineFeatureVisibleProvider = Provider<bool>((ref) {
  if (ref.watch(ncClientProvider) == null) return false;
  final s = ref.watch(onlineSettingsProvider).value;
  return s != null && s.enabled && !s.authInvalid;
});

/// …the user agreed to send sketches and is signed in: sessions may be opened.
final onlineFeatureActiveProvider = Provider<bool>((ref) {
  // Visible first: in an offline-only build neither the settings nor the
  // keystore are even read.
  if (!ref.watch(onlineFeatureVisibleProvider)) return false;
  if (!(ref.watch(onlineSettingsProvider).value?.consented ?? false)) return false;
  return ref.watch(ncAccountProvider).signedIn;
});
