import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/auth.dart';
import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/errors.dart';
import 'package:gm_cebi/features/online_scene/messages.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'neuracraft_client_test.dart' show clientWith, config, errorResponse, jsonResponse, signedIn, testTokens;

Map<String, Object?> tokenJson(String n) =>
    {'accessToken': 'nc_eu_a$n', 'tokenType': 'Bearer', 'expiresIn': 3600, 'refreshToken': 'nc_rt_r$n', 'endUser': {'id': 'eu_1'}};

/// A store whose read fails, as after a device restore (key gone).
class BrokenStore extends MemoryTokenStore {
  BrokenStore() : super(testTokens());
  int clears = 0;
  @override
  Future<NcTokens?> read() async => throw Exception('Failed to unwrap key');
  @override
  Future<void> clear() async {
    clears++;
    await super.clear();
  }
}

/// A scripted service for the auth flows: `/v1/me` answers 401
/// `auth.token_expired` to any token but [validAccess]; `/v1/auth/token`
/// hands out the next pair (after [refreshDelay], so concurrent callers
/// really overlap) or [refreshAnswer] if set.
class AuthServer {
  final requests = <http.Request>[];
  String validAccess = 'nc_eu_a2';
  int refreshes = 0;
  Duration refreshDelay = const Duration(milliseconds: 20);
  http.Response Function()? refreshAnswer;
  http.Response Function(http.Request r)? other;

  late final client = MockClient((r) async {
    requests.add(r);
    switch (r.url.path) {
      case '/v1/auth/token':
        refreshes++;
        await Future<void>.delayed(refreshDelay);
        final a = refreshAnswer;
        return a != null ? a() : jsonResponse(tokenJson('${refreshes + 1}'));
      case '/v1/auth/revoke':
        return http.Response('', 204);
      case '/v1/me' when r.method == 'GET':
        if (r.headers['Authorization'] != 'Bearer $validAccess') return errorResponse(401, 'auth.token_expired');
        return jsonResponse({
          'endUser': {'id': 'eu_1', 'createdAt': '2026-11-10T08:00:00.000Z'},
          'quota': {'daily': 20, 'used': 3, 'resetsAt': '2026-11-10T21:00:00.000Z'},
        });
      case '/v1/me' when r.method == 'DELETE':
        return http.Response('', 204);
    }
    final o = other;
    return o != null ? o(r) : errorResponse(404, 'not_found');
  });

  Iterable<http.Request> at(String path) => requests.where((r) => r.url.path == path);
}

void main() {
  group('sign-in calls', () {
    test('JSON with the client id, never Authorization or X-End-User', () async {
      final seen = <http.Request>[];
      final api = NcAuthApi(
        config: config,
        clock: () => DateTime.utc(2026, 11, 10, 12),
        httpClient: MockClient((r) async {
          seen.add(r);
          return switch (r.url.path) {
            '/v1/auth/email/start' => jsonResponse({'expiresIn': 600, 'resendAfter': 60}, 202),
            '/v1/auth/revoke' => http.Response('', 204),
            _ => jsonResponse(tokenJson('1')),
          };
        }),
      );
      final sent = await api.startEmail('gm@example.com');
      expect((sent.expiresIn, sent.resendAfter), (600, 60));
      final t = await api.verifyEmail('gm@example.com', '123456');
      expect(t.accessToken, 'nc_eu_a1');
      expect(t.refreshToken, 'nc_rt_r1');
      expect(t.endUserId, 'eu_1');
      expect(t.email, 'gm@example.com');
      expect(t.accessExpiresAt, DateTime.utc(2026, 11, 10, 13));
      await api.refresh('nc_rt_r1');
      await api.revoke('nc_rt_r2');

      expect(seen.map((r) => '${r.method} ${r.url.path}'),
          ['POST /v1/auth/email/start', 'POST /v1/auth/email/verify', 'POST /v1/auth/token', 'POST /v1/auth/revoke']);
      for (final r in seen) {
        expect(r.headers.containsKey('Authorization'), isFalse, reason: r.url.path);
        expect(r.headers.containsKey('X-End-User'), isFalse, reason: r.url.path);
        expect(r.headers['Content-Type'], startsWith('application/json'));
      }
      expect(jsonDecode(seen[0].body), {'client_id': 'nc_client_test', 'email': 'gm@example.com', 'locale': 'tr'});
      expect(jsonDecode(seen[1].body), {'client_id': 'nc_client_test', 'email': 'gm@example.com', 'code': '123456'});
      expect(jsonDecode(seen[2].body), {'client_id': 'nc_client_test', 'grantType': 'refresh_token', 'refreshToken': 'nc_rt_r1'});
      expect(jsonDecode(seen[3].body), {'client_id': 'nc_client_test', 'refreshToken': 'nc_rt_r2'});
    });

    test('sign-in errors get their reaction and Turkish message', () async {
      Future<NcApiException> fail(http.Response res) async {
        final api = NcAuthApi(config: config, httpClient: MockClient((r) async => res));
        try {
          await api.startEmail('x');
        } on NcApiException catch (e) {
          return e;
        }
        throw StateError('no error');
      }

      final unavailable = await fail(errorResponse(503, 'auth.sign_in_unavailable'));
      expect(unavailable.reaction, NcReaction.signInUnavailable);
      expect(messageFor(unavailable), contains('Giriş şu an yapılamıyor'));
      final email = await fail(errorResponse(400, 'auth.invalid_email'));
      expect(messageFor(email), 'Bu e-posta adresi geçerli görünmüyor.');
      final wrong = await fail(errorResponse(400, 'auth.code_invalid', {'attemptsLeft': 3}));
      expect(messageFor(wrong), 'Kod yanlış; 3 deneme hakkın kaldı.');
      final expired = await fail(errorResponse(400, 'auth.code_expired'));
      expect(messageFor(expired), contains('Yeni kod iste'));
      final limited = await fail(errorResponse(429, 'auth.code_rate_limited', {'retryAfter': 42}));
      expect(messageFor(limited), 'Çok fazla kod istendi; 42 saniye sonra tekrar dene.');
      final partner = await fail(errorResponse(429, 'quota.partner_daily', {'resetsAt': '2026-11-10T21:00:00.000Z'}));
      expect(messageFor(partner), "GM Cebi'nin bugünkü harita hakkı doldu, yarın tekrar dene.");
    });

    test('tokens survive the store as JSON; a damaged entry is not a sign-in', () {
      final t = testTokens();
      final back = NcTokens.fromJson(jsonDecode(jsonEncode(t.toJson())))!;
      expect((back.accessToken, back.refreshToken, back.endUserId, back.email), (t.accessToken, t.refreshToken, t.endUserId, t.email));
      expect(back.accessExpiresAt.isAtSameMomentAs(t.accessExpiresAt), isTrue);
      expect(NcTokens.fromJson({'accessToken': 'a'}), isNull);
      expect(NcTokens.fromJson('garbage'), isNull);
    });
  });

  group('token manager', () {
    test('concurrent 401 token_expired: exactly one refresh, every request repeated with the new token', () async {
      final server = AuthServer();
      final store = MemoryTokenStore(testTokens());
      final c = clientWith(server.client, auth: signedIn(server.client, store: store));
      final results = await Future.wait([for (var i = 0; i < 5; i++) c.getMe()]);
      expect(results.map((m) => m.used), everyElement(3));
      expect(server.refreshes, 1);
      expect(jsonDecode(server.at('/v1/auth/token').single.body)['refreshToken'], 'nc_rt_r1');
      expect(server.at('/v1/me').where((r) => r.headers['Authorization'] == 'Bearer nc_eu_a2'), hasLength(5));
      expect(store.tokens!.refreshToken, 'nc_rt_r2', reason: 'the rotated refresh token is stored');
      expect(store.tokens!.accessToken, 'nc_eu_a2');
      expect(store.tokens!.email, 'gm@example.com', reason: 'kept across refreshes');

      // A late caller still holding the old token gets the new one, no refresh.
      expect(await c.auth.refreshAfterExpired('nc_eu_a1'), 'nc_eu_a2');
      expect(server.refreshes, 1);
    });

    test('an access token about to expire is refreshed before it is used', () async {
      final server = AuthServer();
      final store = MemoryTokenStore(testTokens(expires: DateTime.now().add(const Duration(seconds: 10))));
      final c = clientWith(server.client, auth: signedIn(server.client, store: store));
      await c.getMe();
      expect(server.refreshes, 1);
      expect(server.at('/v1/me').single.headers['Authorization'], 'Bearer nc_eu_a2');
    });

    test('the request is repeated only once', () async {
      final server = AuthServer()..validAccess = 'never';
      final c = clientWith(server.client);
      await expectLater(c.getMe(), throwsA(isA<NcApiException>().having((e) => e.code, 'code', 'auth.token_expired')));
      expect(server.refreshes, 1);
      expect(server.at('/v1/me'), hasLength(2));
    });

    test('refresh_invalid: signed out by the server, the store cleared', () async {
      final server = AuthServer()..refreshAnswer = () => errorResponse(401, 'auth.refresh_invalid');
      final store = MemoryTokenStore(testTokens());
      final auth = signedIn(server.client, store: store);
      final states = <NcAuthState>[];
      auth.states.listen(states.add);
      final c = clientWith(server.client, auth: auth);
      await expectLater(c.getMe(), throwsA(isA<NcApiException>().having((e) => e.reaction, 'reaction', NcReaction.signInRequired)));
      expect(store.tokens, isNull);
      expect(auth.state.status, NcAuthStatus.signedOut);
      expect(auth.state.expired, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(states.last.expired, isTrue);
      expect(messageForReaction(NcReaction.signInRequired), 'Oturumun sona erdi, tekrar giriş yap.');

      // Nothing more goes out until the user signs in again.
      final before = server.requests.length;
      await expectLater(c.openSession(), throwsA(isA<NcApiException>().having((e) => e.code, 'code', NcApiException.signInRequired)));
      expect(server.requests.length, before);
    });

    test('token_revoked on any request signs out; end_user_blocked blocks', () async {
      final revoked = AuthServer()..other = (r) => errorResponse(401, 'auth.token_revoked');
      final store = MemoryTokenStore(testTokens());
      final c = clientWith(revoked.client, auth: signedIn(revoked.client, store: store));
      await expectLater(c.openSession(), throwsA(isA<NcApiException>()));
      expect(c.auth.state.expired, isTrue);
      expect(store.tokens, isNull);

      final blocked = AuthServer()..other = (r) => errorResponse(403, 'auth.end_user_blocked');
      final b = clientWith(blocked.client);
      await expectLater(b.openSession(), throwsA(isA<NcApiException>().having((e) => e.reaction, 'reaction', NcReaction.blocked)));
      expect(b.auth.state.status, NcAuthStatus.blocked);
    });

    test('a network error while refreshing keeps the sign-in', () async {
      final server = AuthServer()..refreshAnswer = () => throw http.ClientException('offline');
      final store = MemoryTokenStore(testTokens());
      final c = clientWith(server.client, auth: signedIn(server.client, store: store));
      await expectLater(c.getMe(), throwsA(isA<NcNetworkException>()));
      expect(c.auth.state.signedIn, isTrue);
      expect(store.tokens!.refreshToken, 'nc_rt_r1');
    });

    test('an unreadable store (device restore) starts signed out and is cleared', () async {
      final store = BrokenStore();
      final auth = signedIn(AuthServer().client, store: store);
      await auth.load();
      expect(auth.state, NcAuthState.signedOut);
      expect(store.clears, 1);
    });

    test('sign in, then sign out: revoked as far as possible, the store cleared', () async {
      final server = AuthServer()..other = (r) => jsonResponse(tokenJson('1'));
      final store = MemoryTokenStore();
      final auth = NcTokenManager(api: NcAuthApi(httpClient: server.client, config: config), store: store);
      await auth.load();
      expect(auth.state, NcAuthState.signedOut);
      await auth.verifyEmail(' gm@example.com ', '123456');
      expect(auth.state, const NcAuthState(NcAuthStatus.signedIn, endUserId: 'eu_1', email: 'gm@example.com'));
      expect(store.tokens!.refreshToken, 'nc_rt_r1');
      await auth.signOut();
      expect(auth.state, NcAuthState.signedOut, reason: 'not "expired": the user did it');
      expect(store.tokens, isNull);
      expect(jsonDecode(server.at('/v1/auth/revoke').single.body)['refreshToken'], 'nc_rt_r1');

      // Offline: signed out all the same.
      final offline = NcTokenManager(
          api: NcAuthApi(httpClient: MockClient((r) async => throw http.ClientException('offline')), config: config),
          store: MemoryTokenStore(testTokens()));
      await offline.signOut();
      expect(offline.state, NcAuthState.signedOut);
    });
  });

  group('account', () {
    test('GET /v1/me: the user and today\'s quota', () async {
      final server = AuthServer()..validAccess = 'nc_eu_a1';
      final me = await clientWith(server.client).getMe();
      expect(me.endUserId, 'eu_1');
      expect((me.used, me.daily), (3, 20));
      expect(me.resetsAt, DateTime.utc(2026, 11, 10, 21).toLocal());
    });

    test('DELETE /v1/me deletes the account and forgets the sign-in', () async {
      final server = AuthServer();
      final store = MemoryTokenStore(testTokens());
      final c = clientWith(server.client, auth: signedIn(server.client, store: store));
      await c.deleteMe();
      final del = server.requests.single;
      expect('${del.method} ${del.url.path}', 'DELETE /v1/me');
      expect(del.headers['Authorization'], 'Bearer nc_eu_a1');
      expect(store.tokens, isNull);
      expect(c.auth.state, NcAuthState.signedOut);
    });

    test('offline: the account and the sign-in are kept', () async {
      final store = MemoryTokenStore(testTokens());
      final h = MockClient((r) async => throw http.ClientException('offline'));
      final c = clientWith(h, auth: signedIn(h, store: store));
      await expectLater(c.deleteMe(), throwsA(isA<NcNetworkException>()));
      expect(store.tokens, isNotNull);
    });
  });

  group('streams and downloads', () {
    test('the event stream reconnects once after token_expired', () async {
      final auths = <String?>[];
      final server = AuthServer();
      final h = MockClient.streaming((r, body) async {
        if (r.url.path == '/v1/auth/token') {
          server.refreshes++;
          return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(tokenJson('2')))), 200);
        }
        auths.add(r.headers['Authorization']);
        if (r.headers['Authorization'] != 'Bearer nc_eu_a2') {
          return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'error': {'code': 'auth.token_expired'}}))), 401);
        }
        final done = {'id': 'job-1', 'state': 'succeeded', 'outputs': []};
        return http.StreamedResponse(Stream.value(utf8.encode('data: ${jsonEncode({'type': 'job', 'job': done})}\n\n')), 200,
            headers: {'content-type': 'text/event-stream'});
      });
      final events = await clientWith(h).watchJob('job-1').toList();
      expect(events, hasLength(1));
      expect(auths, ['Bearer nc_eu_a1', 'Bearer nc_eu_a2']);
      expect(server.refreshes, 1);
    });

    test('download: token_expired is refreshed; the token never reaches the storage URL', () async {
      final seen = <http.BaseRequest>[];
      final h = MockClient.streaming((r, _) async {
        seen.add(r);
        if (r.url.path == '/v1/auth/token') return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(tokenJson('2')))), 200);
        if (r.url.host == 'nc.test') {
          if (r.headers['Authorization'] != 'Bearer nc_eu_a2') {
            return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'error': {'code': 'auth.token_expired'}}))), 401);
          }
          return http.StreamedResponse(const Stream.empty(), 302, headers: {'location': 'https://storage.example/blob?sig=abc'});
        }
        return http.StreamedResponse(Stream.value([7, 7]), 200);
      });
      expect(await clientWith(h).downloadAsset('a-1'), [7, 7]);
      expect(seen.map((r) => '${r.url.host}${r.url.path}'),
          ['nc.test/v1/assets/a-1/content', 'nc.test/v1/auth/token', 'nc.test/v1/assets/a-1/content', 'storage.example/blob']);
      expect(seen[1].headers.containsKey('Authorization'), isFalse);
      expect(seen.last.headers.containsKey('Authorization'), isFalse);
    });
  });

  test('a client is only as signed in as its manager', () async {
    final h = MockClient((r) async => jsonResponse({}));
    final c = NeuraCraftClient(httpClient: h, config: config, auth: NcTokenManager(api: NcAuthApi(httpClient: h, config: config), store: MemoryTokenStore()));
    await expectLater(c.openSession(), throwsA(isA<NcApiException>().having((e) => e.reaction, 'reaction', NcReaction.signInRequired)));
  });
}
