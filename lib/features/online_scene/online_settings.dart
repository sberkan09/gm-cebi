/// Settings of the optional online scene feature, kept in the same settings
/// table as the rest: on/off, the first-use consent and the install id.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/neuracraft/client.dart';
import '../../data/neuracraft/config.dart';
import '../../data/neuracraft/install_id.dart';
import '../../providers.dart';

class OnlineSettings {
  const OnlineSettings({this.enabled = true, this.consented = false, this.installId = '', this.authInvalid = false});

  /// The user's switch in Settings. On by default; nothing is sent before
  /// [consented].
  final bool enabled;

  /// The user accepted that the sketch and the description go to the server.
  final bool consented;

  /// Random, made once (`X-End-User`); no personal data.
  final String installId;

  /// The service rejected the app token (401): the feature stays off until
  /// an app update. Not persisted: a new build may carry a new token.
  final bool authInvalid;

  OnlineSettings copyWith({bool? enabled, bool? consented, String? installId, bool? authInvalid}) => OnlineSettings(
        enabled: enabled ?? this.enabled,
        consented: consented ?? this.consented,
        installId: installId ?? this.installId,
        authInvalid: authInvalid ?? this.authInvalid,
      );
}

class OnlineSettingsNotifier extends AsyncNotifier<OnlineSettings> {
  static const kEnabled = 'ncEnabled', kConsent = 'ncConsent', kInstallId = 'ncInstallId';

  @override
  Future<OnlineSettings> build() async {
    final db = ref.read(databaseProvider);
    final m = await db.readSettings();
    var id = m[kInstallId] ?? '';
    if (!installIdPattern.hasMatch(id)) {
      id = newInstallId();
      await db.writeSetting(kInstallId, id);
    }
    return OnlineSettings(enabled: m[kEnabled] != 'false', consented: m[kConsent] == 'true', installId: id);
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

  /// "Delete my data", local part: a fresh install id, so nothing on the
  /// server can be tied to this install any more. Consent is asked again.
  Future<void> resetIdentity() async {
    final id = newInstallId();
    state = AsyncData(_current.copyWith(installId: id, consented: false));
    final db = ref.read(databaseProvider);
    await db.writeSetting(kInstallId, id);
    await db.writeSetting(kConsent, 'false');
  }
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
  if (!config.isConfigured) return null;
  return NeuraCraftClient(
    httpClient: ref.watch(ncHttpClientProvider),
    config: config,
    endUser: () => ref.read(onlineSettingsProvider).value?.installId ?? '',
  );
});

/// The feature is in this build and the user has not turned it off.
final onlineFeatureVisibleProvider = Provider<bool>((ref) {
  if (ref.watch(ncClientProvider) == null) return false;
  final s = ref.watch(onlineSettingsProvider).value;
  return s != null && s.enabled && !s.authInvalid;
});

/// …and the user agreed to send sketches: sessions may be opened.
final onlineFeatureActiveProvider = Provider<bool>((ref) {
  // Visible first: in an offline-only build the settings (and so the install
  // id) are never even loaded.
  if (!ref.watch(onlineFeatureVisibleProvider)) return false;
  return ref.watch(onlineSettingsProvider).value?.consented ?? false;
});
