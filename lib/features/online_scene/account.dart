/// The online scene account: sign-in with an emailed code (neuracraft-cloud
/// #48), tokens in the platform keystore, sign-out and account deletion.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/neuracraft/auth.dart';
import '../../data/neuracraft/models.dart';
import '../../providers.dart';
import 'online_settings.dart';
import 'scene_controller.dart';
import 'session_controller.dart';

/// Keychain (iOS) / Android Keystore. On iOS the entry stays on this device
/// (not in backups); on Android the secure-storage preferences are excluded
/// from backups (android/app/src/main/res/xml). A restored install that still
/// finds an entry it cannot decrypt starts signed out.
class SecureTokenStore implements NcTokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage(iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device));

  static const key = 'nc.tokens.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<NcTokens?> read() async {
    final v = await _storage.read(key: key);
    if (v == null) return null;
    final t = NcTokens.fromJson(jsonDecode(v));
    if (t == null) throw const FormatException('stored sign-in is damaged');
    return t;
  }

  @override
  Future<void> write(NcTokens tokens) => _storage.write(key: key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: key);
}

/// Overridden in tests with a [MemoryTokenStore].
final ncTokenStoreProvider = Provider<NcTokenStore>((ref) => SecureTokenStore());

/// Null when the build has no NeuraCraft configuration.
final ncTokenManagerProvider = Provider<NcTokenManager?>((ref) {
  final config = ref.watch(ncConfigProvider);
  if (!config.isConfigured) return null;
  final m = NcTokenManager(api: NcAuthApi(httpClient: ref.watch(ncHttpClientProvider), config: config), store: ref.watch(ncTokenStoreProvider));
  ref.onDispose(m.dispose);
  return m;
});

class NcAccountNotifier extends Notifier<NcAuthState> {
  @override
  NcAuthState build() {
    final m = ref.watch(ncTokenManagerProvider);
    if (m == null) return NcAuthState.signedOut;
    final sub = m.states.listen((s) => state = s);
    ref.onDispose(sub.cancel);
    unawaited(m.load());
    return m.state;
  }

  NcTokenManager get _manager => ref.read(ncTokenManagerProvider)!;

  /// Waits for the stored sign-in to be read.
  Future<void> load() async {
    final m = ref.read(ncTokenManagerProvider);
    if (m == null) return;
    await m.load();
    _sync();
  }

  /// The manager's stream delivers on a later microtask; callers that act
  /// right after an await want the new state now.
  void _sync() {
    final m = ref.mounted ? ref.read(ncTokenManagerProvider) : null;
    if (m != null) state = m.state;
  }

  /// Sends a code to [email]. Throws [NcException] (`auth.invalid_email`,
  /// `auth.code_rate_limited`, `auth.sign_in_unavailable`, offline…).
  Future<NcCodeSent> startEmail(String email) => _manager.startEmail(email);

  /// Throws [NcException] (`auth.code_invalid`, `auth.code_expired`…).
  Future<void> verifyEmail(String email, String code) async {
    await _manager.verifyEmail(email, code);
    _sync();
  }

  /// Signs out (see [signOutOnline], which also ends the game's session).
  Future<void> signOut() async {
    await _manager.signOut();
    _sync();
  }

  /// `DELETE /v1/me` (see [deleteOnlineAccount]).
  Future<void> deleteAccount() async {
    final client = ref.read(ncClientProvider);
    if (client == null) return;
    await client.deleteMe();
    _sync();
  }
}

final ncAccountProvider = NotifierProvider<NcAccountNotifier, NcAuthState>(NcAccountNotifier.new);

/// "Çıkış yap": ends the game's session while the token still works, then
/// signs out (the refresh token is revoked as far as possible).
Future<void> signOutOnline(WidgetRef ref) async {
  await ref.read(sceneControllerProvider.notifier).cancel();
  await ref.read(onlineSessionProvider.notifier).closeNow();
  await ref.read(ncAccountProvider.notifier).signOut();
}

/// "Hesabımı sil": `DELETE /v1/me` deletes the account and everything on the
/// server at once; then the pictures kept here go too and consent is asked
/// again. Throws [NcException] when the server could not be reached: the
/// account and the pictures are kept.
Future<void> deleteOnlineAccount(WidgetRef ref) async {
  await ref.read(sceneControllerProvider.notifier).cancel();
  await ref.read(onlineSessionProvider.notifier).closeNow();
  await ref.read(ncAccountProvider.notifier).deleteAccount();
  await ref.read(databaseProvider).deleteAllScenes();
  await ref.read(onlineSettingsProvider.notifier).setConsented(false);
}

/// `GET /v1/me` for Settings ("Bugün: 3/20 harita"). Null when signed out or
/// offline: the line is simply left out.
final ncMeProvider = FutureProvider.autoDispose<NcMe?>((ref) async {
  if (!ref.watch(ncAccountProvider.select((a) => a.signedIn))) return null;
  final client = ref.watch(ncClientProvider);
  if (client == null) return null;
  try {
    return await client.getMe();
  } on Object {
    return null;
  }
});
