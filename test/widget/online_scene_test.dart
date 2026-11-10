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

  http.StreamedResponse _json(Object body, [int status = 200]) =>
      http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(body))), status, headers: {'content-type': 'application/json'});

  Future<http.StreamedResponse> handle(http.BaseRequest r) async {
    final p = r.url.path;
    calls.add('${r.method} $p');
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
