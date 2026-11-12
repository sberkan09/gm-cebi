import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/auth.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/errors.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/online_scene/account.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/session_controller.dart';
import 'package:gm_cebi/providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'online_session_test.dart' show FakeOnlineSettings, signedInTokens;

const config = NcConfig(baseUrl: 'http://nc.test', clientId: 'nc_client_t');

http.Response j(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

/// A service whose answers can be held back (a slow network) or fail.
class Service {
  final calls = <String>[];

  /// Requests (as `METHOD path`) that wait for this before they answer.
  final hold = <String, Completer<void>>{};

  /// Requests that fail as if offline.
  final offline = <String>{};

  Future<http.Response> handle(http.Request r) async {
    final call = '${r.method} ${r.url.path}';
    calls.add(call);
    await hold[call]?.future;
    if (offline.contains(call)) throw http.ClientException('offline');
    if (call == 'POST /v1/sessions') {
      return j({
        'session': {'id': 's1', 'heartbeatSeconds': 120},
        'capacity': {'state': 'ready'},
      }, 201);
    }
    if (r.method == 'DELETE' && r.url.path.startsWith('/v1/sessions/')) return j({'closed': true});
    if (call == 'DELETE /v1/me') return http.Response('', 204);
    if (call == 'POST /v1/auth/revoke') return http.Response('', 204);
    if (call == 'POST /v1/auth/email/start') return j({'expiresIn': 600, 'resendAfter': 60}, 202);
    return j({'error': {'code': 'not_found'}}, 404);
  }
}

/// A database whose pictures cannot be deleted (a full disk, say).
class StuckPictures extends AppDatabase {
  StuckPictures() : super(NativeDatabase.memory());

  @override
  Future<void> deleteAllScenes() => Future.error(StateError('disk'));
}

void main() {
  late Service service;
  late MemoryTokenStore store;
  late AppDatabase db;

  setUp(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  ProviderContainer make({bool consented = true, DateTime Function()? clock, AppDatabase? database}) {
    service = Service();
    store = MemoryTokenStore(signedInTokens());
    db = database ?? AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      ncConfigProvider.overrideWithValue(config),
      onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(OnlineSettings(consented: consented))),
      ncHttpClientProvider.overrideWithValue(MockClient(service.handle)),
      ncTokenStoreProvider.overrideWithValue(store),
      if (clock != null) ncClockProvider.overrideWithValue(clock),
    ]);
    c.listen(onlineSessionProvider, (_, _) {});
    c.listen(ncAccountProvider, (_, _) {});
    return c;
  }

  /// Signed in, consent given, a session open (the map was just used).
  Future<void> ready(ProviderContainer c) async {
    await c.read(onlineSettingsProvider.future);
    await c.read(ncAccountProvider.notifier).load();
    c.read(onlineSessionProvider.notifier).acquire();
    await pumpEventQueue();
    expect(c.read(onlineSessionProvider).phase, SessionPhase.open);
  }

  test('sign-out: the session is closed while the token still works, then the tokens go; busy meanwhile', () async {
    final c = make();
    await ready(c);
    final busy = <NcAccountAction?>[];
    c.listen(ncAccountActionsProvider, (_, b) => busy.add(b));
    await c.read(ncAccountActionsProvider.notifier).signOut();
    expect(service.calls, ['POST /v1/sessions', 'DELETE /v1/sessions/s1', 'POST /v1/auth/revoke']);
    expect(store.tokens, isNull);
    expect(c.read(ncAccountProvider).signedIn, isFalse);
    expect(busy, [NcAccountAction.signingOut, null]);
    c.dispose();
    await db.close();
  });

  test('sign-out does not wait for ever for a session close that never answers', () {
    fakeAsync((a) {
      final c = make();
      c.read(onlineSettingsProvider);
      c.read(ncAccountProvider);
      a.flushMicrotasks();
      a.elapse(Duration.zero);
      c.read(onlineSessionProvider.notifier).acquire();
      a.flushMicrotasks();
      service.hold['DELETE /v1/sessions/s1'] = Completer<void>();
      unawaited(c.read(ncAccountActionsProvider.notifier).signOut());
      a.elapse(NcAccountActions.bestEffortWait - const Duration(seconds: 1));
      expect(store.tokens, isNotNull);
      expect(c.read(ncAccountActionsProvider), NcAccountAction.signingOut);
      a.elapse(const Duration(seconds: 2));
      expect(store.tokens, isNull, reason: 'signed out all the same');
      expect(service.calls, contains('POST /v1/auth/revoke'));
      expect(c.read(ncAccountActionsProvider), isNull);
      c.dispose();
      db.close();
      a.elapse(const Duration(minutes: 1));
    });
  });

  test('delete account: the server first, then the pictures here and the consent; signed out', () async {
    final c = make();
    await ready(c);
    await db.addScene(assetId: 'a1', png: Uint8List(4), mode: 'map', narrative: '', seed: 1);
    await c.read(ncAccountActionsProvider.notifier).deleteAccount();
    expect(service.calls, ['POST /v1/sessions', 'DELETE /v1/sessions/s1', 'DELETE /v1/me']);
    expect(await db.select(db.mapScenes).get(), isEmpty);
    expect(c.read(onlineSettingsProvider).value!.consented, isFalse);
    expect(store.tokens, isNull);
    expect(c.read(ncAccountProvider).signedIn, isFalse);
    expect(c.read(ncAccountActionsProvider), isNull);
    c.dispose();
    await db.close();
  });

  test('delete account, server unreachable: nothing is deleted here, still signed in, not busy any more', () async {
    final c = make();
    await ready(c);
    await db.addScene(assetId: 'a1', png: Uint8List(4), mode: 'map', narrative: '', seed: 1);
    service.offline.add('DELETE /v1/me');
    await expectLater(c.read(ncAccountActionsProvider.notifier).deleteAccount(), throwsA(isA<NcNetworkException>()));
    expect(await db.select(db.mapScenes).get(), hasLength(1));
    expect(c.read(onlineSettingsProvider).value!.consented, isTrue);
    expect(store.tokens, isNotNull);
    expect(c.read(ncAccountActionsProvider), isNull);
    c.dispose();
    await db.close();
  });

  test('delete account: the consent is withdrawn even when the pictures cannot be deleted', () async {
    final c = make(database: StuckPictures());
    await ready(c);
    await expectLater(c.read(ncAccountActionsProvider.notifier).deleteAccount(), throwsA(isA<StateError>()));
    expect(service.calls, contains('DELETE /v1/me'));
    expect(c.read(onlineSettingsProvider).value!.consented, isFalse, reason: 'the later step ran');
    expect(store.tokens, isNull);
    expect(c.read(ncAccountActionsProvider), isNull);
    c.dispose();
    await db.close();
  });

  test('today\'s quota is not asked for while the feature is off or before consent', () async {
    for (final settings in const [OnlineSettings(enabled: false, consented: true), OnlineSettings(consented: false)]) {
      service = Service();
      final c = ProviderContainer(overrides: [
        ncConfigProvider.overrideWithValue(config),
        onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(settings)),
        ncHttpClientProvider.overrideWithValue(MockClient(service.handle)),
        ncTokenStoreProvider.overrideWithValue(MemoryTokenStore(signedInTokens())),
      ]);
      await c.read(onlineSettingsProvider.future);
      await c.read(ncAccountProvider.notifier).load();
      expect(c.read(ncAccountProvider).signedIn, isTrue);
      expect(await c.read(ncMeProvider.future), isNull);
      expect(service.calls, isEmpty);
      c.dispose();
    }
  });

  test('a code that was sent is remembered for this run: who it went to, when another may be asked for, until it expires', () async {
    var now = DateTime(2026, 11, 12, 20, 0, 0);
    final c = make(clock: () => now);
    await c.read(onlineSettingsProvider.future);
    final requests = c.read(ncCodeRequestProvider.notifier);
    expect(requests.current(now), isNull);
    await c.read(ncAccountProvider.notifier).startEmail(' gm@example.com ');
    final sent = requests.current(now)!;
    expect(sent.email, 'gm@example.com');
    expect(sent.resendAt, now.add(const Duration(seconds: 60)));
    now = now.add(const Duration(minutes: 9, seconds: 59));
    expect(requests.current(now), isNotNull);
    now = now.add(const Duration(seconds: 1));
    expect(requests.current(now), isNull, reason: 'the code has expired');
    c.dispose();
    await db.close();
  });

  testWidgets('sign-out goes on to the end when the screen that started it is left meanwhile', (tester) async {
    final hold = Completer<void>();
    final calls = <String>[];
    final store = MemoryTokenStore(signedInTokens());
    final db = AppDatabase(NativeDatabase.memory());
    final show = ValueNotifier(true);
    late WidgetRef captured;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        ncConfigProvider.overrideWithValue(config),
        onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true))),
        ncTokenStoreProvider.overrideWithValue(store),
        ncHttpClientProvider.overrideWithValue(MockClient((r) async {
          calls.add('${r.method} ${r.url.path}');
          if (r.method == 'POST' && r.url.path == '/v1/sessions') {
            return j({
              'session': {'id': 's1', 'heartbeatSeconds': 120},
              'capacity': {'state': 'ready'},
            }, 201);
          }
          if (r.method == 'DELETE') {
            await hold.future; // a slow network
            return j({'closed': true});
          }
          return http.Response('', 204);
        })),
      ],
      child: MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: show,
          builder: (_, v, _) => v
              ? Consumer(builder: (context, ref, _) {
                  captured = ref;
                  ref.watch(ncAccountProvider);
                  ref.watch(onlineSessionProvider);
                  return TextButton(onPressed: () => ref.read(ncAccountActionsProvider.notifier).signOut(), child: const Text('out'));
                })
              : const SizedBox(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();
    captured.read(onlineSessionProvider.notifier).acquire();
    await tester.pump();
    await tester.pump();
    expect(captured.read(onlineSessionProvider).phase, SessionPhase.open);
    final container = ProviderScope.containerOf(tester.element(find.text('out')));
    await tester.tap(find.text('out'));
    await tester.pump();
    expect(container.read(ncAccountActionsProvider), NcAccountAction.signingOut);
    show.value = false; // the user leaves Settings: the tile is unmounted
    await tester.pump();
    hold.complete();
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(calls, ['POST /v1/sessions', 'DELETE /v1/sessions/s1', 'POST /v1/auth/revoke']);
    expect(store.tokens, isNull, reason: 'the tokens are gone although nobody was watching');
    expect(container.read(ncAccountProvider).signedIn, isFalse);
    expect(container.read(ncAccountActionsProvider), isNull);
    await tester.pumpWidget(const SizedBox());
    final closing = db.close();
    await tester.pump(const Duration(seconds: 1));
    await closing;
  });
}
