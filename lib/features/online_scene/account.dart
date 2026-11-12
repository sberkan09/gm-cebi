/// The online scene account: sign-in with an emailed code (neuracraft-cloud
/// #48), tokens in the platform keystore, sign-out and account deletion.
///
/// Sign-out and account deletion are sequences of several awaited steps. They
/// run in [NcAccountActions], which reads everything it needs before the
/// first await and never touches a widget: leaving Settings half-way does not
/// stop them. Its state says which one is running.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/neuracraft/auth.dart';
import '../../data/neuracraft/errors.dart';
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

/// The clock of the sign-in sheet's countdown; overridden in tests.
final ncClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// A sign-in code that was sent: to which address, when another may be asked
/// for, and until when it is valid.
@immutable
class NcCodeRequest {
  const NcCodeRequest({required this.email, required this.resendAt, required this.expiresAt});
  final String email;
  final DateTime resendAt;
  final DateTime expiresAt;
}

/// The last code sent, remembered for this run of the app only (never
/// stored): the sign-in sheet closed and opened again goes on at the code
/// step instead of asking for a second code, which the service refuses
/// within the resend time.
class NcCodeRequestNotifier extends Notifier<NcCodeRequest?> {
  @override
  NcCodeRequest? build() => null;

  /// The request still in force at [now]: null once the code has expired.
  NcCodeRequest? current(DateTime now) {
    final r = state;
    return r != null && now.isBefore(r.expiresAt) ? r : null;
  }

  void _set(NcCodeRequest? request) {
    if (ref.mounted) state = request;
  }

  /// The service said when the next code may be asked for.
  void resendBlockedUntil(DateTime at) {
    final r = state;
    if (r != null) state = NcCodeRequest(email: r.email, resendAt: at, expiresAt: r.expiresAt);
  }

  /// The code was used up or expired on the server.
  void forget() => state = null;
}

final ncCodeRequestProvider = NotifierProvider<NcCodeRequestNotifier, NcCodeRequest?>(NcCodeRequestNotifier.new);

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

  /// Sends a code to [email] and remembers that it was sent
  /// ([ncCodeRequestProvider]), whether or not the sheet that asked is still
  /// open. Throws [NcException] (`auth.invalid_email`,
  /// `auth.code_rate_limited`, `auth.sign_in_unavailable`, offline…).
  Future<NcCodeSent> startEmail(String email) async {
    final address = email.trim();
    final manager = _manager;
    final sent = ref.read(ncCodeRequestProvider.notifier);
    final clock = ref.read(ncClockProvider);
    final answer = await manager.startEmail(address);
    final now = clock();
    sent._set(NcCodeRequest(
        email: address, resendAt: now.add(Duration(seconds: answer.resendAfter)), expiresAt: now.add(Duration(seconds: answer.expiresIn))));
    return answer;
  }

  /// Throws [NcException] (`auth.code_invalid`, `auth.code_expired`…).
  Future<void> verifyEmail(String email, String code) async {
    final manager = _manager;
    final sent = ref.read(ncCodeRequestProvider.notifier);
    try {
      await manager.verifyEmail(email, code);
    } on NcException catch (e) {
      if (e.reaction == NcReaction.codeExpired) sent._set(null);
      rethrow;
    }
    sent._set(null);
    _sync();
  }

  /// Signs out: the tokens are dropped at once, then revoked on the server as
  /// far as possible (see [NcAccountActions.signOut], which also ends the
  /// game's session first).
  Future<void> signOut() async {
    final manager = _manager;
    final sent = ref.read(ncCodeRequestProvider.notifier);
    await manager.signOut();
    sent._set(null);
    _sync();
  }

  /// `DELETE /v1/me` (see [NcAccountActions.deleteAccount]).
  Future<void> deleteAccount() async {
    final client = ref.read(ncClientProvider);
    final sent = ref.read(ncCodeRequestProvider.notifier);
    if (client == null) return;
    await client.deleteMe();
    sent._set(null);
    _sync();
  }
}

final ncAccountProvider = NotifierProvider<NcAccountNotifier, NcAuthState>(NcAccountNotifier.new);

/// What [NcAccountActions] is doing (Settings shows a spinner and turns the
/// account's buttons off meanwhile).
enum NcAccountAction { signingOut, deleting }

/// "Çıkış yap" and "Hesabımı sil": each is several awaited steps (the job, the
/// session, the account, then what is kept on this device). They run here,
/// owned by the app's provider container: everything a step needs is read
/// before the first await, so a sequence goes on to its end whatever happens
/// to the screen whose button started it. (Started from a widget's `ref`,
/// leaving Settings half-way threw and left the user signed in, or the
/// account deleted with its pictures and consent still here.)
///
/// The state is the action in progress, null when idle. (Its own provider:
/// the session and the scene depend on [ncAccountProvider], so that one
/// cannot reach them.)
class NcAccountActions extends Notifier<NcAccountAction?> {
  /// How long each best-effort step (cancelling a job, closing the session)
  /// may hold up the step that matters.
  static Duration bestEffortWait = const Duration(seconds: 8);

  @override
  NcAccountAction? build() => null;

  void _set(NcAccountAction? action) {
    if (ref.mounted) state = action;
  }

  /// "Çıkış yap": ends the game's session while the token still works, then
  /// signs out (the tokens are dropped here, the refresh token is revoked as
  /// far as possible). Never throws.
  Future<void> signOut() async {
    if (state != null || ref.read(ncTokenManagerProvider) == null) return;
    final account = ref.read(ncAccountProvider.notifier);
    final scene = ref.read(sceneControllerProvider.notifier);
    final session = ref.read(onlineSessionProvider.notifier);
    _set(NcAccountAction.signingOut);
    try {
      await _bestEffort(scene.cancel);
      await _bestEffort(session.closeNow);
      await account.signOut();
    } finally {
      _set(null);
    }
  }

  /// "Hesabımı sil": `DELETE /v1/me` deletes the account and everything on
  /// the server at once; then the pictures kept here go too and consent is
  /// asked again. Throws [NcException] when the server could not be reached:
  /// the account and the pictures are kept. Once the server has deleted the
  /// account, every local step runs, even if the one before it fails.
  Future<void> deleteAccount() async {
    if (state != null || ref.read(ncClientProvider) == null) return;
    final account = ref.read(ncAccountProvider.notifier);
    final scene = ref.read(sceneControllerProvider.notifier);
    final session = ref.read(onlineSessionProvider.notifier);
    final settings = ref.read(onlineSettingsProvider.notifier);
    final db = ref.read(databaseProvider);
    _set(NcAccountAction.deleting);
    try {
      await _bestEffort(scene.cancel);
      await _bestEffort(session.closeNow);
      await account.deleteAccount();
      // The account is gone and this device is signed out.
      try {
        await db.deleteAllScenes();
      } finally {
        await settings.setConsented(false);
      }
    } finally {
      _set(null);
    }
  }

  /// "Uygulamadaki çevrimiçi resimleri sil" (signed out: this device only).
  Future<void> deleteLocalPictures() async {
    final scene = ref.read(sceneControllerProvider.notifier);
    final db = ref.read(databaseProvider);
    await _bestEffort(scene.cancel);
    await db.deleteAllScenes();
  }

  /// A step that must not hold up or stop what follows it.
  static Future<void> _bestEffort(Future<void> Function() step) async {
    try {
      await step().timeout(bestEffortWait);
    } on Object {
      // The next step matters more.
    }
  }
}

final ncAccountActionsProvider = NotifierProvider<NcAccountActions, NcAccountAction?>(NcAccountActions.new);

/// `GET /v1/me` for Settings ("Bugün: 3/20 harita"). Null when signed out or
/// offline: the line is simply left out. Not asked for while the feature is
/// switched off or before the user's consent: nothing is sent then.
final ncMeProvider = FutureProvider.autoDispose<NcMe?>((ref) async {
  if (!ref.watch(onlineFeatureActiveProvider)) return null;
  final client = ref.watch(ncClientProvider);
  if (client == null) return null;
  try {
    return await client.getMe();
  } on Object {
    return null;
  }
});
