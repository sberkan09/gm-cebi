/// End-user sign-in for NeuraCraft Cloud (neuracraft-cloud issue #48,
/// docs/partners/gm-cebi.md, "Sign-in"): an emailed 6-digit code gives a
/// short-lived access token (an hour) and a refresh token that changes on
/// every use. Plain Dart, like the rest of this folder.
///
/// - [NcAuthApi]: the four sign-in calls. JSON bodies with the public client
///   id, never an `Authorization` header.
/// - [NcTokenStore]: where the tokens live (the platform keystore in the app,
///   memory in tests and tools).
/// - [NcTokenManager]: the current tokens. Gives [NeuraCraftClient] the access
///   token, refreshes one at a time (a refresh token used twice ends the
///   sign-in), and reports when the server signed the user out.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'errors.dart';

/// One sign-in: what [NcTokenStore] keeps.
class NcTokens {
  const NcTokens({required this.accessToken, required this.refreshToken, required this.accessExpiresAt, required this.endUserId, this.email});

  /// The answer of `verify` and `token`:
  /// `{accessToken, tokenType, expiresIn, refreshToken, endUser: {id}}`.
  factory NcTokens.fromResponse(Map<String, dynamic> m, {required DateTime now, String? email}) {
    final access = m['accessToken'], refresh = m['refreshToken'], user = m['endUser'];
    if (access is! String || refresh is! String || access.isEmpty || refresh.isEmpty) {
      throw const NcNetworkException('auth: no tokens in the answer');
    }
    final expiresIn = (m['expiresIn'] as num?)?.round() ?? 3600;
    return NcTokens(
      accessToken: access,
      refreshToken: refresh,
      accessExpiresAt: now.add(Duration(seconds: expiresIn)),
      endUserId: user is Map<String, dynamic> ? user['id'] as String? ?? '' : '',
      email: email,
    );
  }

  /// Null when [json] is not a stored sign-in (an old or damaged entry).
  static NcTokens? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final access = json['accessToken'], refresh = json['refreshToken'], expires = json['accessExpiresAt'];
    if (access is! String || refresh is! String || expires is! String || refresh.isEmpty) return null;
    final at = DateTime.tryParse(expires);
    if (at == null) return null;
    return NcTokens(
      accessToken: access,
      refreshToken: refresh,
      accessExpiresAt: at,
      endUserId: json['endUserId'] as String? ?? '',
      email: json['email'] as String?,
    );
  }

  /// `nc_eu_…`, sent as `Authorization: Bearer`.
  final String accessToken;

  /// `nc_rt_…`, single use: every refresh returns a new one.
  final String refreshToken;
  final DateTime accessExpiresAt;

  /// `eu_…`, the service's random id for this user.
  final String endUserId;

  /// The address the user typed, kept on the device only, for display.
  final String? email;

  Map<String, Object?> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'accessExpiresAt': accessExpiresAt.toUtc().toIso8601String(),
        'endUserId': endUserId,
        if (email != null) 'email': email,
      };
}

/// Where the tokens are kept between runs.
abstract class NcTokenStore {
  /// Null when signed out. May throw (e.g. a keystore key lost after a device
  /// restore): the manager then starts signed out and clears the store.
  Future<NcTokens?> read();
  Future<void> write(NcTokens tokens);
  Future<void> clear();
}

/// For tests and tools: nothing survives the process.
class MemoryTokenStore implements NcTokenStore {
  MemoryTokenStore([this.tokens]);
  NcTokens? tokens;

  @override
  Future<NcTokens?> read() async => tokens;
  @override
  Future<void> write(NcTokens t) async => tokens = t;
  @override
  Future<void> clear() async => tokens = null;
}

/// The answer of `POST /v1/auth/email/start`.
class NcCodeSent {
  const NcCodeSent({required this.expiresIn, required this.resendAfter});

  /// Seconds the code is valid (600).
  final int expiresIn;

  /// Seconds before another code may be asked for (60).
  final int resendAfter;
}

/// The four sign-in calls: JSON with the client id, no `Authorization`.
class NcAuthApi {
  NcAuthApi({required http.Client httpClient, required this.config, this.timeout = const Duration(seconds: 20), DateTime Function()? clock})
      : _http = httpClient,
        _clock = clock ?? DateTime.now;

  final http.Client _http;
  final NcConfig config;
  final Duration timeout;
  final DateTime Function() _clock;

  /// Sends a 6-digit code to [email] (the same answer whether or not the
  /// address signed in before).
  Future<NcCodeSent> startEmail(String email, {String locale = 'tr'}) async {
    final r = await _post('/v1/auth/email/start', {'client_id': config.clientId, 'email': email, 'locale': locale});
    return NcCodeSent(expiresIn: (r['expiresIn'] as num?)?.round() ?? 600, resendAfter: (r['resendAfter'] as num?)?.round() ?? 60);
  }

  Future<NcTokens> verifyEmail(String email, String code) async =>
      NcTokens.fromResponse(await _post('/v1/auth/email/verify', {'client_id': config.clientId, 'email': email, 'code': code}), now: _clock(), email: email);

  /// [refreshToken] is used up by this call, whatever the answer.
  Future<NcTokens> refresh(String refreshToken) async => NcTokens.fromResponse(
      await _post('/v1/auth/token', {'client_id': config.clientId, 'grantType': 'refresh_token', 'refreshToken': refreshToken}),
      now: _clock());

  Future<void> revoke(String refreshToken) async {
    await _post('/v1/auth/revoke', {'client_id': config.clientId, 'refreshToken': refreshToken});
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, Object?> body) async {
    final req = http.Request('POST', config.uri(path))
      ..headers.addAll({'Accept': 'application/json', 'Content-Type': 'application/json'})
      ..body = jsonEncode(body);
    final http.StreamedResponse res;
    final String text;
    try {
      res = await _http.send(req).timeout(timeout);
      text = await res.stream.bytesToString().timeout(timeout);
    } on Object catch (e) {
      throw NcNetworkException('POST $path: $e');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) throw ncErrorFrom(res.statusCode, text);
    if (text.isEmpty) return const {};
    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      throw NcNetworkException('POST $path: not JSON');
    }
  }
}

enum NcAuthStatus {
  /// The store is being read.
  loading,
  signedOut,
  signedIn,

  /// The service blocked this user (`auth.end_user_blocked`): the feature is
  /// off for them until the app restarts.
  blocked,
}

class NcAuthState {
  const NcAuthState(this.status, {this.endUserId, this.email, this.expired = false});

  static const loading = NcAuthState(NcAuthStatus.loading);
  static const signedOut = NcAuthState(NcAuthStatus.signedOut);

  final NcAuthStatus status;
  final String? endUserId;
  final String? email;

  /// Signed out by the server (refresh token used up or revoked), not by the
  /// user: "Oturumun sona erdi, tekrar giriş yap".
  final bool expired;

  bool get signedIn => status == NcAuthStatus.signedIn;

  @override
  bool operator ==(Object other) =>
      other is NcAuthState && other.status == status && other.endUserId == endUserId && other.email == email && other.expired == expired;
  @override
  int get hashCode => Object.hash(status, endUserId, email, expired);
  @override
  String toString() => 'NcAuthState(${status.name}${expired ? ', expired' : ''})';
}

/// Holds the current sign-in and keeps the access token fresh.
class NcTokenManager {
  NcTokenManager({required this.api, required this.store, DateTime Function()? clock, this.refreshMargin = const Duration(seconds: 60)})
      : _clock = clock ?? DateTime.now;

  final NcAuthApi api;
  final NcTokenStore store;
  final DateTime Function() _clock;

  /// An access token this close to its expiry is refreshed before use (the
  /// server's `401 auth.token_expired` is handled too, for clock skew).
  final Duration refreshMargin;

  NcTokens? _tokens;
  Future<void>? _loading;
  Future<NcTokens>? _refreshing;
  NcAuthState _state = NcAuthState.loading;
  final _states = StreamController<NcAuthState>.broadcast();

  NcAuthState get state => _state;

  /// Every change of [state].
  Stream<NcAuthState> get states => _states.stream;

  /// Reads the store once; later calls wait for the same read.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    NcTokens? read;
    try {
      read = await store.read();
    } on Object {
      // Undecryptable (a keystore key lost after a device restore) or a
      // broken entry: start signed out.
      read = null;
      await _clearStore();
    }
    // A sign-in that finished meanwhile wins.
    if (_state.status != NcAuthStatus.loading) return;
    _tokens = read;
    _emit(read == null ? NcAuthState.signedOut : _signedIn(read));
  }

  /// The access token for a request; refreshed first when about to expire.
  /// Throws [NcApiException] [NcApiException.signInRequired] when signed out.
  Future<String> accessToken() async {
    await load();
    final t = _tokens;
    if (t == null) throw const NcApiException(401, NcApiException.signInRequired);
    if (!_clock().isBefore(t.accessExpiresAt.subtract(refreshMargin))) return (await _refresh(t)).accessToken;
    return t.accessToken;
  }

  /// A request sent with [stale] answered `401 auth.token_expired`: the
  /// access token to repeat it with. Concurrent callers share one refresh,
  /// and a caller whose token was already replaced gets the new one at once.
  Future<String> refreshAfterExpired(String stale) async {
    await load();
    final t = _tokens;
    if (t == null) throw const NcApiException(401, NcApiException.signInRequired);
    if (t.accessToken != stale) return t.accessToken;
    return (await _refresh(t)).accessToken;
  }

  Future<NcTokens> _refresh(NcTokens t) => _refreshing ??= _doRefresh(t).whenComplete(() => _refreshing = null);

  Future<NcTokens> _doRefresh(NcTokens t) async {
    final NcTokens fresh;
    try {
      fresh = await api.refresh(t.refreshToken);
    } on NcApiException catch (e) {
      if (identical(_tokens, t)) await _react(e);
      rethrow;
    }
    if (!identical(_tokens, t)) {
      // Signed out (or in again) while this was on its way: the new refresh
      // token belongs to nobody.
      unawaited(api.revoke(fresh.refreshToken).then((_) {}, onError: (_) {}));
      final now = _tokens;
      if (now == null) throw const NcApiException(401, NcApiException.signInRequired);
      return now;
    }
    final next = NcTokens(
      accessToken: fresh.accessToken,
      refreshToken: fresh.refreshToken,
      accessExpiresAt: fresh.accessExpiresAt,
      endUserId: fresh.endUserId.isEmpty ? t.endUserId : fresh.endUserId,
      email: t.email,
    );
    _tokens = next;
    await _write(next);
    _emit(_signedIn(next));
    return next;
  }

  /// A request sent with [accessToken] was refused: ends the sign-in when the
  /// server says so (`auth.token_revoked`, `auth.end_user_blocked`). A stale
  /// answer for tokens already replaced changes nothing.
  Future<void> rejected(NcApiException e, {required String accessToken}) async {
    if (_tokens?.accessToken != accessToken) return;
    await _react(e);
  }

  Future<void> _react(NcApiException e) async {
    switch (e.reaction) {
      case NcReaction.signInRequired when e.code != NcApiException.signInRequired:
        await _end(const NcAuthState(NcAuthStatus.signedOut, expired: true));
      case NcReaction.blocked:
        await _end(const NcAuthState(NcAuthStatus.blocked));
      default:
        break;
    }
  }

  /// Sends a code to [email].
  Future<NcCodeSent> startEmail(String email) => api.startEmail(email.trim());

  /// Signs in with the emailed [code].
  Future<void> verifyEmail(String email, String code) async {
    final t = await api.verifyEmail(email.trim(), code.trim());
    _tokens = t;
    _emit(_signedIn(t));
    await _write(t);
  }

  /// The user signed out: the tokens are dropped at once, then revoked on the
  /// server as far as possible.
  Future<void> signOut() async {
    final t = _tokens;
    await _end(NcAuthState.signedOut);
    if (t == null) return;
    try {
      await api.revoke(t.refreshToken);
    } on Object {
      // Best effort: the refresh token expires on its own after 90 days.
    }
  }

  /// `DELETE /v1/me` succeeded: the server dropped every token already.
  Future<void> accountDeleted() => _end(NcAuthState.signedOut);

  void dispose() => _states.close();

  NcAuthState _signedIn(NcTokens t) => NcAuthState(NcAuthStatus.signedIn, endUserId: t.endUserId, email: t.email);

  Future<void> _end(NcAuthState s) async {
    _tokens = null;
    _emit(s);
    await _clearStore();
  }

  void _emit(NcAuthState s) {
    if (s == _state) return;
    _state = s;
    if (!_states.isClosed) _states.add(s);
  }

  Future<void> _write(NcTokens t) async {
    try {
      await store.write(t);
    } on Object {
      // Kept in memory for this run; the next start asks for sign-in again.
    }
  }

  Future<void> _clearStore() async {
    try {
      await store.clear();
    } on Object {
      // nothing more to do
    }
  }
}
