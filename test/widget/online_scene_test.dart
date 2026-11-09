import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';
import 'package:gm_cebi/providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'harness.dart';

/// A 1×1 PNG: what the fake service returns as the picture.
final tinyPng = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

class FakeService {
  final calls = <String>[];
  final bodies = <Map<String, dynamic>>[];
  http.StreamedResponse Function()? nextSubmit;

  http.StreamedResponse _json(Object body, [int status = 200]) =>
      http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(body))), status, headers: {'content-type': 'application/json'});

  Future<http.StreamedResponse> handle(http.BaseRequest r) async {
    final p = r.url.path;
    calls.add('${r.method} $p');
    if (p == '/v1/sessions') {
      return _json({'session': {'id': 's1', 'heartbeatSeconds': 120}, 'capacity': {'state': 'warming', 'etaSeconds': 35}}, 201);
    }
    if (p.endsWith('/heartbeat')) return _json({'session': {'id': 's1', 'heartbeatSeconds': 120}, 'capacity': {'state': 'ready'}});
    if (r.method == 'DELETE') return _json({'closed': true});
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

List<Override> online(FakeService service) => [
      ncConfigProvider.overrideWithValue(const NcConfig(baseUrl: 'http://nc.test', appToken: 'nc_app_test')),
      ncHttpClientProvider.overrideWithValue(MockClient.streaming((r, _) => service.handle(r))),
      sceneRandomProvider.overrideWithValue(Random(1)),
      // Picture.toImage never completes in the fake-async widget test zone;
      // the real export is tested in test/core/map_sketch_test.dart.
      sketchExporterProvider.overrideWith((ref) => () async {
            final strokes = await ref.read(databaseProvider).select(ref.read(databaseProvider).mapStrokes).get();
            return strokes.isEmpty ? null : tinyPng;
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

  final del = FakeService();
  appTest('Settings: delete my data clears pictures and the install id; the switch hides the feature', gmPack: true, overrides: online(del), (tester, db) async {
    db.addScene(assetId: 'asset-1', png: tinyPng, mode: 'map', narrative: 'köprü', seed: 1);
    db.writeSetting('ncInstallId', 'old-install-id');
    db.writeSetting('ncConsent', 'true');
    await settle(tester);
    await tester.tap(find.byTooltip('Ayarlar ve Hakkında'));
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('online-delete')), 300, scrollable: scrollableIn(const Key('settings-list')));
    expect(find.text('Onay verildi'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('online-delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('online-delete')));
    await settle(tester);
    expect(find.text('Veriler silinsin mi?'), findsOneWidget);
    expect(find.textContaining('en geç 7 gün içinde'), findsOneWidget, reason: 'the server side is explained');
    await tester.tap(find.byKey(const Key('online-delete-confirm')));
    await settle(tester);
    expect(find.text('Uygulamadaki çevrimiçi veriler silindi.'), findsOneWidget);
    expect(await pumped(tester, db.select(db.mapScenes).get()), isEmpty);
    final settings = await pumped(tester, db.readSettings());
    expect(settings['ncInstallId'], isNot('old-install-id'));
    expect(settings['ncInstallId'], matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(settings['ncConsent'], 'false');

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
