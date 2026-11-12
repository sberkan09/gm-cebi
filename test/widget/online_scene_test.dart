import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/auth.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/online_scene/account.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';
import 'package:gm_cebi/providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../features/online_session_test.dart' show signedInTokens;
import 'harness.dart';

/// A 1×1 PNG: what the fake service returns as the picture.
final tinyPng = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

class FakeService {
  final calls = <String>[];
  final bodies = <Map<String, dynamic>>[];
  final authBodies = <String, Map<String, dynamic>>{};
  http.StreamedResponse Function()? nextSubmit;

  /// The answer to `POST /v1/auth/email/start` (default: 202, code sent).
  http.StreamedResponse Function()? startAnswer;

  /// `DELETE /v1/me` fails as if offline.
  bool deleteOffline = false;

  /// The `GET /v1/presets` answer (null: 404, as if the region layer were unknown).
  Map<String, Object?>? presets;

  /// Requests (as `METHOD path`) that wait for this before they answer: a
  /// slow network. Create the completer inside the test body (its zone).
  final hold = <String, Completer<void>>{};

  /// Heartbeats find the session closed (it idled out on the server).
  bool sessionIdledOut = false;

  int count(String call) => calls.where((c) => c == call).length;

  http.StreamedResponse _json(Object body, [int status = 200]) =>
      http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(body))), status, headers: {'content-type': 'application/json'});

  Future<http.StreamedResponse> handle(http.BaseRequest r) async {
    final p = r.url.path;
    calls.add('${r.method} $p');
    await hold['${r.method} $p']?.future;
    if (p.startsWith('/v1/auth/')) {
      expect(r.headers.containsKey('Authorization'), isFalse, reason: 'sign-in calls carry no token');
      authBodies[p] = jsonDecode((r as http.Request).body) as Map<String, dynamic>;
      return switch (p) {
        '/v1/auth/email/start' => startAnswer?.call() ?? _json({'expiresIn': 600, 'resendAfter': 60}, 202),
        '/v1/auth/email/verify' => authBodies[p]!['code'] == '123456'
            ? _json({'accessToken': 'nc_eu_a1', 'tokenType': 'Bearer', 'expiresIn': 3600, 'refreshToken': 'nc_rt_r1', 'endUser': {'id': 'eu_1'}})
            : _json({'error': {'code': 'auth.code_invalid', 'params': {'attemptsLeft': 4}}}, 400),
        '/v1/auth/revoke' => http.StreamedResponse(const Stream.empty(), 204),
        _ => _json({'error': {'code': 'not_found'}}, 404),
      };
    }
    if (r.url.host == 'nc.test') expect(r.headers['Authorization'], 'Bearer nc_eu_a1');
    if (p == '/v1/me') {
      if (r.method == 'DELETE') {
        if (deleteOffline) throw http.ClientException('offline');
        return http.StreamedResponse(const Stream.empty(), 204);
      }
      return _json({'endUser': {'id': 'eu_1', 'createdAt': '2026-11-10T08:00:00.000Z'}, 'quota': {'daily': 20, 'used': 3, 'resetsAt': '2026-11-10T21:00:00.000Z'}});
    }
    if (p == '/v1/sessions') {
      return _json({'session': {'id': 's1', 'heartbeatSeconds': 120}, 'capacity': {'state': 'warming', 'etaSeconds': 35}}, 201);
    }
    if (p.endsWith('/heartbeat') && sessionIdledOut) return _json({'error': {'code': 'session.closed', 'params': {'reason': 'idle'}}}, 410);
    if (p.endsWith('/heartbeat')) return _json({'session': {'id': 's1', 'heartbeatSeconds': 120}, 'capacity': {'state': 'ready'}});
    if (r.method == 'DELETE') return _json({'closed': true});
    if (p == '/v1/presets' && presets != null) return _json(presets!);
    if (p == '/v1/presets/sketch_to_scene/jobs') {
      bodies.add(jsonDecode((r as http.Request).body) as Map<String, dynamic>);
      final n = nextSubmit;
      nextSubmit = null;
      return n?.call() ?? _json({'job': {'id': 'j1', 'state': 'queued', 'outputs': []}}, 201);
    }
    if (p.endsWith('/events')) {
      final done = {'id': 'j1', 'state': 'succeeded', 'outputs': [{'name': 'scene.png', 'assetId': 'asset-1', 'bytes': tinyPng.length}]};
      return http.StreamedResponse(Stream.value(utf8.encode('data: ${jsonEncode({'type': 'job', 'job': done})}\n\n')), 200,
          headers: {'content-type': 'text/event-stream'});
    }
    if (p == '/v1/assets/asset-1/content') return http.StreamedResponse(const Stream.empty(), 302, headers: {'location': 'https://storage.test/x'});
    if (r.url.host == 'storage.test') return http.StreamedResponse(Stream.value(tinyPng), 200);
    if (p.endsWith('/report')) return _json({'report': {}}, 202);
    return _json({'error': {'code': 'not_found'}}, 404);
  }
}

List<Override> online(FakeService service, {MemoryTokenStore? store}) => [
      ncConfigProvider.overrideWithValue(const NcConfig(baseUrl: 'http://nc.test', clientId: 'nc_client_test')),
      ncHttpClientProvider.overrideWithValue(MockClient.streaming((r, _) => service.handle(r))),
      ncTokenStoreProvider.overrideWithValue(store ?? MemoryTokenStore(signedInTokens())),
      sceneRandomProvider.overrideWithValue(Random(1)),
      // The test's fake clock, so the resend countdown follows pump().
      ncClockProvider.overrideWithValue(() => TestWidgetsFlutterBinding.instance.clock.now()),
      blankSketchExporterProvider.overrideWithValue(() async => tinyPng),
      // Picture.toImage never completes in the fake-async widget test zone;
      // the real export is tested in test/core/map_sketch_test.dart.
      sketchExporterProvider.overrideWith((ref) => () async {
            final strokes = await ref.read(databaseProvider).select(ref.read(databaseProvider).mapStrokes).get();
            return strokes.where((s) => !s.isRegion).isEmpty ? null : tinyPng;
          }),
      regionsExporterProvider.overrideWith((ref) => () async {
            final strokes = await ref.read(databaseProvider).select(ref.read(databaseProvider).mapStrokes).get();
            return strokes.any((s) => s.isRegion) ? tinyPng : null;
          }),
    ];

Future<void> openMapWithSketch(WidgetTester tester, AppDatabase db) async {
  db.addStroke(const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)]);
  await settle(tester);
  await openTab(tester, 'İnisiyatif');
  await tester.tap(find.byKey(const Key('open-map')));
  await settle(tester);
}

Future<T> pumped<T>(WidgetTester tester, Future<T> f) async {
  late T value;
  var done = false;
  f.then((v) {
    value = v;
    done = true;
  });
  for (var i = 0; i < 100 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(done, isTrue);
  return value;
}

void main() {
  appTest('offline-only builds show nothing of the online feature', gmPack: true, (tester, db) async {
    await openMapWithSketch(tester, db);
    expect(find.byKey(const Key('scene-open')), findsNothing);
    expect(find.byKey(const Key('capacity-label')), findsNothing);
  });

  appTest('no consent, no request: declining the consent sends nothing', gmPack: true, overrides: online(FakeService()), (tester, db) async {
    await openMapWithSketch(tester, db);
    expect(find.byKey(const Key('scene-open')), findsOneWidget);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    expect(find.text('Çevrimiçi sahne'), findsOneWidget);
    expect(find.textContaining('Anthropic'), findsOneWidget, reason: 'the sub-processor is named in the consent');
    await tester.tap(find.text('Vazgeç'));
    await settle(tester);
    expect(find.byKey(const Key('scene-narrative')), findsNothing);
  });

  final service = FakeService();
  appTest('consent, describe, generate: the picture goes under the tokens', gmPack: true, overrides: online(service), (tester, db) async {
    await openMapWithSketch(tester, db);
    expect(service.calls, isEmpty, reason: 'no session before consent');

    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('consent-accept')));
    await settle(tester);
    expect(service.calls, contains('POST /v1/sessions'), reason: 'consent opens the session: the GPU starts warming');
    expect(find.byKey(const Key('scene-capacity-warning')), findsOneWidget);
    expect(find.byKey(const Key('scene-ground')), findsNothing, reason: 'the service does not take a region layer yet');
    expect(find.byKey(const Key('scene-regions-hint')), findsNothing);
    expect(find.textContaining('nehri, suyu'), findsOneWidget, reason: 'without regions, the description is the only way to say where the water is');

    await tester.tap(find.text('Atmosfer'));
    await tester.enterText(find.byKey(const Key('scene-narrative')), 'Nehrin üzerinde ahşap bir köprü');
    await tester.tap(find.byKey(const Key('scene-generate')));
    await settle(tester);

    final body = service.bodies.single;
    expect(body['params']['mode'], 'atmosphere');
    expect(body['params']['narrative'], 'Nehrin üzerinde ahşap bir köprü');
    final scenes = await pumped(tester, (db.select(db.mapScenes)..orderBy([(s) => OrderingTerm.asc(s.id)])).get());
    expect(scenes.single.png, tinyPng);
    expect(find.byKey(const Key('scene-toggle')), findsOneWidget);
    expect(find.byKey(const Key('capacity-label')), findsOneWidget);

    // Report from the picture's menu: hidden at once, reason sent.
    await tester.tap(find.byKey(const Key('scene-menu')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('scene-report')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('report-violence_gore')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('report-send')));
    await settle(tester);
    expect(service.calls, contains('POST /v1/assets/asset-1/report'));
    expect(find.text('Resim bildirildi ve gizlendi.'), findsOneWidget);
    expect(find.byKey(const Key('scene-toggle')), findsNothing, reason: 'a reported picture is not shown');
  });

  final regionService = FakeService()
    ..presets = {
      'presets': [
        {
          'id': 'sketch_to_scene',
          'version': 1,
          'params': {
            'mode': {'type': 'enum', 'options': ['map', 'atmosphere'], 'required': true},
            'ground': {'type': 'enum', 'options': ['grass', 'stone', 'dirt', 'sand', 'snow'], 'default': 'grass'},
          },
          'inputs': [
            {'name': 'sketch', 'contentTypes': ['image/png']},
            {'name': 'regions', 'contentTypes': ['image/png']},
          ],
        },
      ],
    };
  appTest('a service that takes the region layer: Zemin in map mode; the painted areas and the ground are sent', gmPack: true,
      overrides: online(regionService), (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    db.addStroke(const [Offset01(0.2, 0.2), Offset01(0.8, 0.2)], region: 3, width: 0.09); // stone floor
    db.addStroke(const [Offset01(0.2, 0.3), Offset01(0.8, 0.3)], region: 4, width: 0.05); // wall
    await openMapWithSketch(tester, db);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    expect(find.byKey(const Key('scene-regions-hint')), findsOneWidget);
    expect(find.text('Nehirleri ve yolları Alan fırçasıyla boyarsan resim çok daha doğru olur.'), findsOneWidget);
    expect(find.byKey(const Key('scene-ground')), findsOneWidget);
    for (final label in ['Çimen', 'Taş', 'Toprak', 'Kum', 'Kar']) {
      expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
    }
    expect(tester.widget<ChoiceChip>(find.byKey(const Key('ground-stone'))).selected, isTrue, reason: 'mostly floor and wall: a dungeon');

    await tester.tap(find.text('Atmosfer'));
    await settle(tester);
    expect(find.byKey(const Key('scene-ground')), findsNothing, reason: 'the region layer is for map mode only');
    await tester.tap(find.descendant(of: find.byKey(const Key('scene-mode')), matching: find.text('Harita')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('ground-snow')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('scene-generate')));
    await settle(tester);

    final body = regionService.bodies.single;
    expect(body['params']['mode'], 'map');
    expect(body['params']['ground'], 'snow');
    expect((body['inputs'] as Map).keys, ['sketch', 'regions']);
    expect(body['inputs']['regions']['contentType'], 'image/png');
  });

  final quota = FakeService()
    ..nextSubmit = () => http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'error': {'code': 'quota.end_user_daily', 'params': {'limit': 20, 'resetsAt': DateTime(2026, 11, 10, 0, 0).toUtc().toIso8601String()}}}))),
        429,
        headers: {'content-type': 'application/json'});
  appTest('an error shows its Turkish message; the map goes on', gmPack: true, overrides: online(quota), (tester, db) async {
    await openMapWithSketch(tester, db);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('consent-accept')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('scene-generate')));
    await settle(tester);
    expect(find.text('Bugünkü harita hakkın doldu, 00:00 saatinde yenilenir.'), findsOneWidget);
    expect(find.byKey(const Key('scene-retry')), findsNothing, reason: 'retrying cannot help before the reset');
    await tester.tap(find.byKey(const Key('scene-dismiss')));
    await settle(tester);
    expect(find.byKey(const Key('scene-error')), findsNothing);
    // The offline map still works.
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await tester.dragFrom(canvas.center, const Offset(40, 0));
    await settle(tester);
    expect(await pumped(tester, db.select(db.mapStrokes).get()), hasLength(2));
  });

  final signIn = FakeService();
  final signInStore = MemoryTokenStore();
  appTest('first use: consent, sign in with an emailed code, then the mode sheet', gmPack: true, overrides: online(signIn, store: signInStore),
      (tester, db) async {
    await openMapWithSketch(tester, db);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('consent-accept')));
    await settle(tester);
    expect(signIn.calls, isEmpty, reason: 'consent alone sends nothing: not signed in yet');
    expect(find.byKey(const Key('signin-email')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('signin-email')), 'gm-at-example');
    await tester.tap(find.byKey(const Key('signin-send')));
    await settle(tester);
    expect(find.text('Bu e-posta adresi geçerli görünmüyor.'), findsOneWidget);
    expect(signIn.calls, isEmpty);

    await tester.enterText(find.byKey(const Key('signin-email')), ' gm@example.com ');
    await tester.tap(find.byKey(const Key('signin-send')));
    await settle(tester);
    expect(signIn.authBodies['/v1/auth/email/start'], {'client_id': 'nc_client_test', 'email': 'gm@example.com', 'locale': 'tr'});
    expect(find.textContaining('gm@example.com adresine gönderdik'), findsOneWidget);
    expect(find.text('Yeniden gönder (60 sn)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Yeniden gönder (57 sn)'), findsOneWidget, reason: 'the resend countdown runs');

    await tester.enterText(find.byKey(const Key('signin-code')), '111111');
    await tester.pump();
    await tester.tap(find.byKey(const Key('signin-verify')));
    await settle(tester);
    expect(find.text('Kod yanlış; 4 deneme hakkın kaldı.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('signin-code')), '123456');
    await tester.pump();
    await tester.tap(find.byKey(const Key('signin-verify')));
    await settle(tester);
    expect(signInStore.tokens?.refreshToken, 'nc_rt_r1', reason: 'kept in the (secure) store');
    expect(signInStore.tokens?.email, 'gm@example.com');
    expect(find.byKey(const Key('scene-narrative')), findsOneWidget, reason: 'on to the mode sheet');
    expect(signIn.calls, contains('POST /v1/sessions'), reason: 'signed in: the session opens and the GPU warms');
  });

  final unavailable = FakeService()
    ..startAnswer = () => http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'error': {'code': 'auth.sign_in_unavailable'}}))), 503,
        headers: {'content-type': 'application/json'});
  appTest('sign-in unavailable (503): said inline, nothing else happens', gmPack: true, overrides: online(unavailable, store: MemoryTokenStore()),
      (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    await openMapWithSketch(tester, db);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('signin-email')), 'gm@example.com');
    await tester.tap(find.byKey(const Key('signin-send')));
    await settle(tester);
    expect(find.byKey(const Key('signin-error')), findsOneWidget);
    expect(find.textContaining('Giriş şu an yapılamıyor'), findsOneWidget);
    expect(find.byKey(const Key('signin-email')), findsOneWidget, reason: 'still on the email step');
    expect(unavailable.calls, ['POST /v1/auth/email/start']);
  });

  Future<void> openOnlineSettings(WidgetTester tester, Key key) async {
    await tester.tap(find.byTooltip('Ayarlar ve Hakkında'));
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(key), 300, scrollable: scrollableIn(const Key('settings-list')));
    await tester.ensureVisible(find.byKey(key));
    await settle(tester);
  }

  final out = FakeService();
  final outStore = MemoryTokenStore(signedInTokens());
  appTest("Settings: the account with today's quota; sign out revokes and forgets the tokens", gmPack: true, overrides: online(out, store: outStore),
      (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    await settle(tester);
    await openOnlineSettings(tester, const Key('online-sign-out'));
    expect(find.text('gm@example.com\nBugün: 3/20 harita'), findsOneWidget);
    await tester.tap(find.byKey(const Key('online-sign-out')));
    await settle(tester);
    expect(out.calls, contains('POST /v1/auth/revoke'));
    expect(out.authBodies['/v1/auth/revoke'], {'client_id': 'nc_client_test', 'refreshToken': 'nc_rt_r1'});
    expect(outStore.tokens, isNull);
    expect(find.text('Çıkış yapıldı.'), findsOneWidget);
    expect(find.byKey(const Key('online-sign-in')), findsOneWidget);
    expect(find.byKey(const Key('online-delete-local')), findsOneWidget);
  });

  final gone = FakeService();
  final goneStore = MemoryTokenStore(signedInTokens());
  appTest('Settings: delete my account deletes it on the server, here, and signs out', gmPack: true, overrides: online(gone, store: goneStore),
      (tester, db) async {
    db.addScene(assetId: 'asset-1', png: tinyPng, mode: 'map', narrative: 'köprü', seed: 1);
    db.writeSetting('ncConsent', 'true');
    await settle(tester);
    await openOnlineSettings(tester, const Key('online-delete-account'));
    await tester.tap(find.byKey(const Key('online-delete-account')));
    await settle(tester);
    expect(find.text('Hesabın silinsin mi?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('online-delete-account-confirm')));
    await settle(tester);
    expect(gone.calls, contains('DELETE /v1/me'));
    expect(find.text('Hesabın ve tüm verilerin silindi.'), findsOneWidget);
    expect(goneStore.tokens, isNull);
    expect(await pumped(tester, db.select(db.mapScenes).get()), isEmpty);
    expect((await pumped(tester, db.readSettings()))['ncConsent'], 'false', reason: 'consent is asked again');
    expect(find.byKey(const Key('online-sign-in')), findsOneWidget);
  });

  final offline = FakeService()..deleteOffline = true;
  final offlineStore = MemoryTokenStore(signedInTokens());
  appTest('Settings: offline, the account is not deleted and stays signed in', gmPack: true, overrides: online(offline, store: offlineStore),
      (tester, db) async {
    db.addScene(assetId: 'asset-1', png: tinyPng, mode: 'map', narrative: 'köprü', seed: 1);
    await settle(tester);
    await openOnlineSettings(tester, const Key('online-delete-account'));
    await tester.tap(find.byKey(const Key('online-delete-account')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('online-delete-account-confirm')));
    await settle(tester);
    expect(find.textContaining('hesabın silinmedi'), findsOneWidget);
    expect(offlineStore.tokens, isNotNull);
    expect(await pumped(tester, db.select(db.mapScenes).get()), hasLength(1));
    expect(find.byKey(const Key('online-sign-out')), findsOneWidget);
  });

  final fromSettings = FakeService();
  final fromSettingsStore = MemoryTokenStore();
  appTest('Settings: sign-in asks for the consent first; declined, nothing is sent and no sheet opens', gmPack: true,
      overrides: online(fromSettings, store: fromSettingsStore), (tester, db) async {
    await openOnlineSettings(tester, const Key('online-sign-in'));
    expect(find.text('İlk kullanımda onay istenir'), findsOneWidget);
    await tester.tap(find.byKey(const Key('online-sign-in')));
    await settle(tester);
    expect(find.text('Çevrimiçi sahne'), findsWidgets);
    expect(find.byKey(const Key('consent-accept')), findsOneWidget, reason: 'the same consent as on the map');
    expect(find.byKey(const Key('signin-email')), findsNothing);
    await tester.tap(find.text('Vazgeç'));
    await settle(tester);
    expect(find.byKey(const Key('signin-email')), findsNothing, reason: 'no consent, no sign-in');
    expect((await pumped(tester, db.readSettings()))['ncConsent'], isNot('true'));

    await tester.tap(find.byKey(const Key('online-sign-in')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('consent-accept')));
    await settle(tester);
    expect((await pumped(tester, db.readSettings()))['ncConsent'], 'true');
    expect(find.byKey(const Key('signin-email')), findsOneWidget);
    expect(fromSettings.calls, isEmpty, reason: 'nothing left the device before the address was sent');
    await tester.enterText(find.byKey(const Key('signin-email')), 'gm@example.com');
    await tester.tap(find.byKey(const Key('signin-send')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('signin-code')), '123456');
    await tester.pump();
    await tester.tap(find.byKey(const Key('signin-verify')));
    await settle(tester);
    expect(fromSettingsStore.tokens, isNotNull);
    expect(find.text('gm@example.com\nBugün: 3/20 harita'), findsOneWidget);
    expect(find.text('Onay verildi'), findsOneWidget);
  });

  final quiet = FakeService();
  appTest('Settings: signed in but no consent, or switched off: no request of any kind', gmPack: true,
      overrides: online(quiet, store: MemoryTokenStore(signedInTokens())), (tester, db) async {
    // Signed in by a version that did not ask for the consent in Settings.
    await openOnlineSettings(tester, const Key('online-sign-out'));
    expect(find.byKey(const Key('online-account-details')), findsOneWidget);
    expect(find.text('gm@example.com'), findsOneWidget, reason: 'the address is kept on the device; the quota line is left out');
    expect(quiet.calls, isEmpty, reason: 'no GET /v1/me before consent');

    await goBack(tester);
    db.writeSetting('ncConsent', 'true');
    db.writeSetting('ncEnabled', 'false');
    await settle(tester);
    await openOnlineSettings(tester, const Key('online-sign-out'));
    expect(find.text('gm@example.com'), findsOneWidget);
    expect(quiet.calls, isEmpty, reason: 'no GET /v1/me while the feature is switched off');
  });

  final off = FakeService();
  appTest('Settings, switched off: no sign-in until the feature is on again', gmPack: true, overrides: online(off, store: MemoryTokenStore()),
      (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    db.writeSetting('ncEnabled', 'false');
    await settle(tester);
    await openOnlineSettings(tester, const Key('online-sign-in'));
    expect(tester.widget<ListTile>(find.byKey(const Key('online-sign-in'))).enabled, isFalse);
    expect(find.text('Giriş yapmak için önce "Haritadan resim üret"i aç.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('online-sign-in')));
    await settle(tester);
    expect(find.byKey(const Key('signin-email')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('online-enabled')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('online-enabled')));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('online-sign-in')));
    await settle(tester);
    expect(tester.widget<ListTile>(find.byKey(const Key('online-sign-in'))).enabled, isTrue);
    await tester.tap(find.byKey(const Key('online-sign-in')));
    await settle(tester);
    expect(find.byKey(const Key('signin-email')), findsOneWidget);
    expect(off.calls, isEmpty);
  });

  final slow = FakeService();
  final slowStore = MemoryTokenStore(signedInTokens());
  appTest('Settings: while the account is being deleted, a spinner shows and the buttons are off', gmPack: true,
      overrides: online(slow, store: slowStore), (tester, db) async {
    slow.hold['DELETE /v1/me'] = Completer<void>();
    db.addScene(assetId: 'asset-1', png: tinyPng, mode: 'map', narrative: 'köprü', seed: 1);
    db.writeSetting('ncConsent', 'true');
    await settle(tester);
    await openOnlineSettings(tester, const Key('online-delete-account'));
    expect(find.byKey(const Key('online-account-busy')), findsNothing);
    await tester.tap(find.byKey(const Key('online-delete-account')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('online-delete-account-confirm')));
    // Not settle(): the spinner never settles while the request is on its way.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(slow.calls, contains('DELETE /v1/me'));
    expect(find.descendant(of: find.byKey(const Key('online-delete-account')), matching: find.byKey(const Key('online-account-busy'))), findsOneWidget);
    expect(tester.widget<ListTile>(find.byKey(const Key('online-delete-account'))).enabled, isFalse);
    expect(tester.widget<ListTile>(find.byKey(const Key('online-sign-out'))).enabled, isFalse);
    await tester.tap(find.byKey(const Key('online-sign-out')), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(slow.calls, isNot(contains('POST /v1/auth/revoke')), reason: 'no second action meanwhile');
    expect(slowStore.tokens, isNotNull);

    slow.hold['DELETE /v1/me']!.complete();
    await settle(tester);
    expect(find.byKey(const Key('online-account-busy')), findsNothing);
    expect(find.text('Hesabın ve tüm verilerin silindi.'), findsOneWidget);
    expect(slowStore.tokens, isNull);
    expect(await pumped(tester, db.select(db.mapScenes).get()), isEmpty);
    expect(tester.widget<ListTile>(find.byKey(const Key('online-delete-local'))).enabled, isTrue);
  });

  final held = FakeService();
  appTest('sign-in sheet: it stays while a request is on its way; closed and opened again it goes on at the code step', gmPack: true,
      overrides: online(held, store: MemoryTokenStore()), (tester, db) async {
    held.hold['POST /v1/auth/email/start'] = Completer<void>();
    db.writeSetting('ncConsent', 'true');
    await openMapWithSketch(tester, db);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('signin-email')), 'gm@example.com');
    await tester.tap(find.byKey(const Key('signin-send')));
    Future<void> wait() async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await wait();
    expect(held.count('POST /v1/auth/email/start'), 1);
    final sheet = tester.getRect(find.byKey(const Key('signin-sheet')));
    // The back button, a tap outside, a drag on the handle: the sheet stays.
    await tester.binding.handlePopRoute();
    await wait();
    expect(find.byKey(const Key('signin-email')), findsOneWidget, reason: 'back does not close it while busy');
    await tester.tapAt(const Offset(20, 60));
    await wait();
    expect(find.byKey(const Key('signin-email')), findsOneWidget, reason: 'a tap outside does not close it while busy');
    await tester.dragFrom(sheet.topCenter + const Offset(0, 24), const Offset(0, 500));
    await wait();
    expect(find.byKey(const Key('signin-email')), findsOneWidget, reason: 'dragging does not close it while busy');

    held.hold.remove('POST /v1/auth/email/start')!.complete();
    await settle(tester);
    expect(find.byKey(const Key('signin-code')), findsOneWidget);
    expect(find.text('Yeniden gönder (60 sn)'), findsOneWidget);

    // Idle again: dragging the handle down closes it, as any sheet.
    await tester.dragFrom(tester.getRect(find.byKey(const Key('signin-sheet'))).topCenter + const Offset(0, 24), const Offset(0, 500));
    await settle(tester);
    expect(find.byKey(const Key('signin-sheet')), findsNothing);

    // Opened again 20 seconds later: the code step, the countdown where it is, no second code asked for.
    await tester.pump(const Duration(seconds: 20));
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    expect(find.byKey(const Key('signin-code')), findsOneWidget);
    expect(find.textContaining('gm@example.com adresine gönderdik'), findsOneWidget);
    expect(find.text('Yeniden gönder (40 sn)'), findsOneWidget);
    expect(held.count('POST /v1/auth/email/start'), 1);

    // The same address typed again: back to the code step, still no request.
    await tester.tap(find.byKey(const Key('signin-change-email')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('signin-email')), 'GM@example.com');
    await tester.tap(find.byKey(const Key('signin-send')));
    await settle(tester);
    expect(find.byKey(const Key('signin-code')), findsOneWidget);
    expect(held.count('POST /v1/auth/email/start'), 1);

    // After the resend time a new code can be asked for.
    await tester.pump(const Duration(seconds: 41));
    expect(find.text('Kodu yeniden gönder'), findsOneWidget);
    await tester.tap(find.byKey(const Key('signin-resend')));
    await settle(tester);
    expect(held.count('POST /v1/auth/email/start'), 2);
    expect(find.text('Yeniden gönder (60 sn)'), findsOneWidget);

    // Signed in: nothing is remembered; a tap outside closed the sheet before.
    await tester.enterText(find.byKey(const Key('signin-code')), '123456');
    await tester.pump();
    await tester.tap(find.byKey(const Key('signin-verify')));
    await settle(tester);
    expect(find.byKey(const Key('scene-narrative')), findsOneWidget);
  });

  final expired = FakeService();
  appTest('sign-in sheet: a code that has expired is not offered again', gmPack: true, overrides: online(expired, store: MemoryTokenStore()),
      (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    await openMapWithSketch(tester, db);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('signin-email')), 'gm@example.com');
    await tester.tap(find.byKey(const Key('signin-send')));
    await settle(tester);
    expect(find.byKey(const Key('signin-code')), findsOneWidget);
    await tester.tapAt(const Offset(20, 60)); // a tap outside closes it
    await settle(tester);
    expect(find.byKey(const Key('signin-sheet')), findsNothing);
    await tester.pump(const Duration(minutes: 11));
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    expect(find.byKey(const Key('signin-email')), findsOneWidget, reason: 'ten minutes on, the code is no good: the email step');
  });

  final areasOnly = FakeService()..presets = regionService.presets;
  appTest('painted areas only, a service that takes them: the sheet lets it be sent', gmPack: true, overrides: online(areasOnly),
      (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    db.addStroke(const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)], region: 0, width: 0.09); // a river, no pen line
    await settle(tester);
    await openTab(tester, 'İnisiyatif');
    await tester.tap(find.byKey(const Key('open-map')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    expect(find.byKey(const Key('scene-missing')), findsNothing);
    expect(tester.widget<FilledButton>(find.byKey(const Key('scene-generate'))).onPressed, isNotNull);
    // Atmosphere takes no region layer: lines are needed there.
    await tester.tap(find.text('Atmosfer'));
    await settle(tester);
    expect(find.text('Çizgiyle de çiz: boyanan alanlar yalnızca Harita modunda gönderilir.'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('scene-generate'))).onPressed, isNull);
    await tester.tap(find.descendant(of: find.byKey(const Key('scene-mode')), matching: find.text('Harita')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('scene-generate')));
    await settle(tester);
    final body = areasOnly.bodies.single;
    expect((body['inputs'] as Map).keys, ['sketch', 'regions']);
    expect(body['params']['ground'], 'grass');
    expect(find.byKey(const Key('scene-error')), findsNothing);
    expect(await pumped(tester, db.select(db.mapScenes).get()), hasLength(1));
  });

  final noRegions = FakeService();
  appTest('painted areas only, a service without the region layer: told to draw lines too', gmPack: true, overrides: online(noRegions),
      (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    db.addStroke(const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)], region: 0, width: 0.09);
    await settle(tester);
    await openTab(tester, 'İnisiyatif');
    await tester.tap(find.byKey(const Key('open-map')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    expect(find.text('Çizgiyle de çiz: sunucu henüz alanları desteklemiyor.'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('scene-generate'))).onPressed, isNull);
    expect(noRegions.bodies, isEmpty);
  });

  final idled = FakeService()..sessionIdledOut = true;
  appTest('an untouched map lets the session go; opening the scene sheet asks for one again', gmPack: true, overrides: online(idled),
      (tester, db) async {
    db.writeSetting('ncConsent', 'true');
    await openMapWithSketch(tester, db);
    expect(idled.count('POST /v1/sessions'), 1);
    await tester.pump(const Duration(seconds: 121)); // the heartbeat: 410, idled out
    await settle(tester);
    await tester.pump(const Duration(minutes: 30));
    expect(idled.count('POST /v1/sessions'), 1, reason: 'no new session while nobody asks for a picture');
    expect(find.byKey(const Key('capacity-label')), findsNothing, reason: 'idle and no picture: no status bar');
    await tester.tap(find.byKey(const Key('scene-open')));
    await settle(tester);
    expect(idled.count('POST /v1/sessions'), 2, reason: 'the GPU starts warming while the GM types');
    expect(find.byKey(const Key('scene-narrative')), findsOneWidget);
  });

  final del = FakeService();
  appTest('Settings, signed out: delete the pictures kept here; the switch hides the feature', gmPack: true,
      overrides: online(del, store: MemoryTokenStore()), (tester, db) async {
    db.addScene(assetId: 'asset-1', png: tinyPng, mode: 'map', narrative: 'köprü', seed: 1);
    db.writeSetting('ncConsent', 'true');
    await settle(tester);
    await openOnlineSettings(tester, const Key('online-delete-local'));
    expect(find.text('Onay verildi'), findsOneWidget);
    expect(find.text('Giriş yapılmadı. Dokun ve e-postanla giriş yap.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('online-delete-local')));
    await settle(tester);
    expect(find.text('Resimler silinsin mi?'), findsOneWidget);
    expect(find.textContaining('Hesabımı sil'), findsOneWidget, reason: 'the server side is explained');
    await tester.tap(find.byKey(const Key('online-delete-local-confirm')));
    await settle(tester);
    expect(find.text('Uygulamadaki çevrimiçi resimler silindi.'), findsOneWidget);
    expect(await pumped(tester, db.select(db.mapScenes).get()), isEmpty);

    await tester.ensureVisible(find.byKey(const Key('online-enabled')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('online-enabled')));
    await settle(tester);
    expect((await pumped(tester, db.readSettings()))['ncEnabled'], 'false');
    await goBack(tester);
    await openTab(tester, 'İnisiyatif');
    await tester.tap(find.byKey(const Key('open-map')));
    await settle(tester);
    expect(find.byKey(const Key('scene-open')), findsNothing, reason: 'turned off in Settings');
    expect(del.calls, isEmpty, reason: 'nothing was ever sent in this test');
  });
}
