import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/models.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';
import 'package:gm_cebi/features/online_scene/session_controller.dart';
import 'package:gm_cebi/providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'online_session_test.dart' show FakeOnlineSettings;

final sketch = Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 7, 7, 7]);
final scenePng = Uint8List.fromList(List.generate(64, (i) => i));

Map<String, Object?> job(String state, {String? error, bool output = false}) => {
      'id': 'job-${state.hashCode}',
      'state': state,
      'progress': null,
      'outputs': output ? [{'name': 'scene.png', 'assetId': 'asset-1', 'kind': 'image', 'bytes': scenePng.length}] : [],
      'error': error == null ? null : {'code': error},
    };

http.StreamedResponse jsonStream(Object body, [int status = 200]) =>
    http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(body))), status, headers: {'content-type': 'application/json'});

http.StreamedResponse err(int status, String code, [Map<String, Object?> params = const {}]) =>
    jsonStream({'error': {'code': code, 'params': params}}, status);

/// A scripted service. [submit] answers job submissions in turn; [finals]
/// are the jobs' final states in turn, sent over SSE.
class Server {
  Server({List<http.StreamedResponse Function()>? submit, List<Map<String, Object?>>? finals})
      : submit = submit ?? [],
        finals = finals ?? [job('succeeded', output: true)];

  final List<http.StreamedResponse Function()> submit;
  final List<Map<String, Object?>> finals;
  final calls = <String>[];
  final bodies = <Map<String, dynamic>>[];
  int sessions = 0;
  bool hangEvents = false;

  /// When set, the submit answer waits for this.
  Completer<void>? holdSubmit;

  /// When set, the events stream is this controller's (the test drives it).
  StreamController<List<int>>? events;

  Future<http.StreamedResponse> handle(http.BaseRequest r) async {
    calls.add('${r.method} ${r.url.path}');
    final p = r.url.path;
    if (p == '/v1/sessions') {
      sessions++;
      return jsonStream({
        'session': {'id': 's$sessions', 'heartbeatSeconds': 120},
        'capacity': {'state': 'ready'},
      }, 201);
    }
    if (p == '/v1/presets/sketch_to_scene/jobs') {
      bodies.add(jsonDecode((r as http.Request).body) as Map<String, dynamic>);
      if (holdSubmit != null) await holdSubmit!.future;
      if (submit.isNotEmpty) return submit.removeAt(0)();
      return jsonStream({'job': job('queued')}, 201);
    }
    if (p.endsWith('/events')) {
      if (this.events != null) return http.StreamedResponse(this.events!.stream, 200, headers: {'content-type': 'text/event-stream'});
      if (hangEvents) {
        return http.StreamedResponse(StreamController<List<int>>().stream, 200, headers: {'content-type': 'text/event-stream'});
      }
      final last = finals.isEmpty ? job('succeeded', output: true) : finals.removeAt(0);
      final events = [
        {'type': 'job', 'job': job('queued')},
        {'type': 'state', 'state': 'running'},
        {'type': 'progress', 'progress': {'step': 2, 'steps': 4, 'op': 'txt2img', 'stage': '', 'fraction': 0.5}},
        {'type': 'job', 'job': last},
      ];
      return http.StreamedResponse(Stream.fromIterable(events.map((e) => utf8.encode('data: ${jsonEncode(e)}\n\n'))), 200,
          headers: {'content-type': 'text/event-stream'});
    }
    if (p.endsWith('/cancel')) return jsonStream({'job': job('cancelled')});
    if (p == '/v1/assets/asset-1/content') {
      return http.StreamedResponse(const Stream.empty(), 302, headers: {'location': 'https://storage.test/blob'});
    }
    if (r.url.host == 'storage.test') return http.StreamedResponse(Stream.value(scenePng), 200);
    if (p.endsWith('/report')) return jsonStream({'report': {}}, 202);
    return err(404, 'not_found');
  }

  int count(String c) => calls.where((x) => x == c).length;
}

void main() {
  late AppDatabase db;
  late ProviderContainer c;
  late Server server;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SceneController.retrySoonDelay = const Duration(milliseconds: 1);
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<void> make(Server s, {bool withSketch = true}) async {
    server = s;
    c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      ncConfigProvider.overrideWithValue(const NcConfig(baseUrl: 'http://nc.test', appToken: 'nc_app_t')),
      onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true, installId: 'install-1'))),
      ncClientProvider.overrideWith((ref) => NeuraCraftClient(
            httpClient: MockClient.streaming((r, _) => server.handle(r)),
            config: ref.watch(ncConfigProvider),
            endUser: () => 'install-1',
            pollInterval: const Duration(milliseconds: 1),
          )),
      sketchExporterProvider.overrideWithValue(() async => withSketch ? sketch : null),
      sceneRandomProvider.overrideWithValue(Random(42)),
    ]);
    c.listen(sceneControllerProvider, (_, _) {});
    c.listen(onlineSessionProvider, (_, _) {});
    await c.read(onlineSettingsProvider.future);
  }

  SceneController ctl() => c.read(sceneControllerProvider.notifier);
  SceneJobState st() => c.read(sceneControllerProvider);

  test('success: session first, the sketch and narrative sent, the picture kept with the encounter', () async {
    await make(Server());
    final phases = <String>[];
    c.listen(sceneControllerProvider, (_, s) => phases.add(switch (s) {
          SceneWorking(:final phase) => phase.name,
          SceneIdle() => 'idle',
          SceneFailed() => 'failed',
        }));
    await ctl().generate(mode: SceneMode.map, narrative: ' Nehrin üzerinde ahşap bir köprü ');
    expect(st(), isA<SceneIdle>());
    expect(server.calls.first, 'POST /v1/sessions', reason: 'the GPU is asked for before the job');
    final body = server.bodies.single;
    expect(body['params']['mode'], 'map');
    expect(body['params']['narrative'], 'Nehrin üzerinde ahşap bir köprü');
    expect(body['params']['seed'], isA<int>());
    expect(body['inputs']['sketch']['inline'], base64Encode(sketch));
    expect(phases, containsAllInOrder(['sending', 'queued', 'running', 'downloading', 'idle']));
    final scene = await db.watchActiveScene().first;
    expect(scene!.png, scenePng);
    expect(scene.assetId, 'asset-1');
    expect(scene.narrative, 'Nehrin üzerinde ahşap bir köprü');
  });

  test('an empty description sends a generic English prompt instead', () async {
    await make(Server());
    await ctl().generate(mode: SceneMode.atmosphere, narrative: '   ');
    final params = server.bodies.single['params'] as Map<String, dynamic>;
    expect(params.containsKey('narrative'), isFalse);
    expect(params['prompt'], contains('battle map'));
    expect(params['mode'], 'atmosphere');
  });

  test('no terrain drawn yet: nothing is sent', () async {
    await make(Server(), withSketch: false);
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect((st() as SceneFailed).message, 'Önce haritaya araziyi çiz.');
    expect(server.calls, isEmpty);
  });

  test('410 session.closed on submit: a new session and the request once more', () async {
    await make(Server(submit: [() => err(410, 'session.closed')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect(st(), isA<SceneIdle>());
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 2);
    expect(server.sessions, 2);
    expect(await db.watchActiveScene().first, isNotNull);
  });

  test('busy (limit.concurrent_jobs, rate_limited): waits and retries, at most twice', () async {
    await make(Server(submit: [() => err(429, 'limit.concurrent_jobs'), () => err(429, 'rate_limited')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect(st(), isA<SceneIdle>());
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 3);

    await make(Server(submit: [for (var i = 0; i < 3; i++) () => err(429, 'rate_limited')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect((st() as SceneFailed).message, 'Şu an çok yoğun, birkaç saniye sonra tekrar dene.');
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 3);
  });

  test('content.flagged: told to try something else, no automatic retry', () async {
    await make(Server(finals: [job('failed', error: 'content.flagged')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final f = st() as SceneFailed;
    expect(f.message, 'Bu çizim ya da tarif için resim üretilemedi; başka bir çizim ya da tarif dene.');
    expect(f.retryable, isTrue);
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 1);
    expect(await db.watchActiveScene().first, isNull);
  });

  test('content.unchecked: retry message', () async {
    await make(Server(finals: [job('failed', error: 'content.unchecked')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect((st() as SceneFailed).message, 'İçerik kontrolü yapılamadı, tekrar dene.');
  });

  test('any other job failure: once more with a new seed, then a quiet failure', () async {
    await make(Server(finals: [job('failed', error: 'internal'), job('succeeded', output: true)]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect(st(), isA<SceneIdle>());
    final seeds = server.bodies.map((b) => b['params']['seed']).toList();
    expect(seeds, hasLength(2));
    expect(seeds[0], isNot(seeds[1]));

    await make(Server(finals: [job('failed', error: 'internal'), job('failed', error: 'worker.lost')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final f = st() as SceneFailed;
    expect(f.quiet, isTrue);
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 2);
  });

  test('daily quota: when it resets, no retry button', () async {
    final resets = DateTime(2026, 11, 10, 0, 0);
    await make(Server(submit: [() => err(429, 'quota.end_user_daily', {'limit': 20, 'resetsAt': resets.toUtc().toIso8601String()})]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final f = st() as SceneFailed;
    expect(f.message, 'Bugünkü harita hakkın doldu, 00:00 saatinde yenilenir.');
    expect(f.retryable, isFalse);
  });

  test('401 on submit turns the feature off until an update', () async {
    await make(Server(submit: [() => err(401, 'auth.token_expired')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect((st() as SceneFailed).message, 'Çevrimiçi resim için uygulamanın güncellenmesi gerekiyor.');
    expect(c.read(onlineSessionProvider).phase, SessionPhase.disabled);
    expect(c.read(onlineFeatureVisibleProvider), isFalse);
  });

  test('service errors from the table get their Turkish message', () async {
    const cases = {
      'content.text_refused': (400, 'Bu tarif kabul edilmedi, farklı anlatmayı dene.'),
      'allowance.insufficient': (402, 'Bu kullanıcı için hak kalmadı.'),
      'credits.insufficient': (402, 'Çevrimiçi resim geçici olarak kullanılamıyor.'),
      'session.limit': (429, 'Şu an çok yoğun, biraz sonra dene.'),
      'job.no_gpu_worker': (503, 'Çevrimiçi resim şu an kullanılamıyor. Harita çevrimdışı çalışmaya devam ediyor.'),
      'preset.unavailable': (503, 'Servis hazırlanıyor, biraz sonra dene.'),
      'preset.params_invalid': (400, 'Bir hata oluştu, resim üretilemedi.'),
      'partner.end_user_required': (400, 'Bir hata oluştu, resim üretilemedi.'),
    };
    for (final MapEntry(key: code, value: (status, message)) in cases.entries) {
      await make(Server(submit: [() => err(status, code)]));
      await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
      expect((st() as SceneFailed).message, message, reason: code);
      c.dispose();
      c = ProviderContainer(); // replaced by the next make(); keeps tearDown happy
    }
  });

  test('no network: the offline message; the map goes on', () async {
    server = Server();
    c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      ncConfigProvider.overrideWithValue(const NcConfig(baseUrl: 'http://nc.test', appToken: 'nc_app_t')),
      onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true, installId: 'install-1'))),
      ncClientProvider.overrideWith((ref) => NeuraCraftClient(
            httpClient: MockClient((r) async => throw http.ClientException('offline')),
            config: ref.watch(ncConfigProvider),
            endUser: () => 'install-1',
          )),
      sketchExporterProvider.overrideWithValue(() async => sketch),
    ]);
    c.listen(sceneControllerProvider, (_, _) {});
    await c.read(onlineSettingsProvider.future);
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect((st() as SceneFailed).message, 'Sunucuya ulaşılamadı. Harita çevrimdışı çalışmaya devam ediyor.');
  });

  test('cancel stops waiting and cancels the job on the server', () async {
    await make(Server()..hangEvents = true);
    final running = ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    while (st() is! SceneWorking || (st() as SceneWorking).jobId == null) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    await ctl().cancel();
    await running;
    expect(st(), isA<SceneIdle>());
    expect(server.calls.where((x) => x.endsWith('/cancel')), hasLength(1));
    expect(await db.watchActiveScene().first, isNull);
  });

  test('report: hidden locally at once, sent to the service; hidden even when sending fails', () async {
    await make(Server());
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final row = (await db.watchActiveScene().first)!;
    final scene = MapSceneView(id: row.id, assetId: row.assetId, png: row.png, mode: row.mode, narrative: row.narrative);
    expect(await reportScene(db, c.read(ncClientProvider), scene, ReportReason.hate, note: 'x'), isNull);
    expect(server.count('POST /v1/assets/asset-1/report'), 1);
    expect(await db.watchActiveScene().first, isNull);

    final id = await db.addScene(assetId: 'asset-2', png: scenePng, mode: 'map', narrative: '', seed: 1);
    final failing = NeuraCraftClient(
        httpClient: MockClient((r) async => throw http.ClientException('offline')),
        config: const NcConfig(baseUrl: 'http://nc.test', appToken: 't'),
        endUser: () => 'i');
    final view = MapSceneView(id: id!, assetId: 'asset-2', png: scenePng, mode: 'map', narrative: '');
    expect(await reportScene(db, failing, view, ReportReason.other), 'Resim gizlendi, ama bildirim gönderilemedi.');
    expect(await db.watchActiveScene().first, isNull);
  });

  test('cancel while the sketch is on its way also cancels the job on the server', () async {
    await make(Server()..holdSubmit = Completer<void>());
    final running = ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    while (server.bodies.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    await ctl().cancel(); // still "sending": no job id yet
    server.holdSubmit!.complete();
    await running;
    for (var i = 0; i < 20 && !server.calls.any((x) => x.endsWith('/cancel')); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(server.calls.where((x) => x.endsWith('/cancel')), hasLength(1), reason: 'the job must not run or count against the quota');
    expect(st(), isA<SceneIdle>());
  });

  test('an unexpected answer never leaves the map stuck on "sending"', () async {
    await make(Server(submit: [() => jsonStream({'unexpected': true}, 201)]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final f = st() as SceneFailed;
    expect(f.message, 'Bir hata oluştu, resim üretilemedi.');
  });

  test('a description over 500 UTF-16 units (emoji) is refused before sending', () async {
    await make(Server());
    await ctl().generate(mode: SceneMode.map, narrative: '🌲' * 300); // 300 characters, 600 units
    expect((st() as SceneFailed).message, contains('en çok 500'));
    expect(server.calls, isEmpty);
  });

  test('content.text_refused offers no retry (the same text would be refused again)', () async {
    await make(Server(submit: [() => err(400, 'content.text_refused', {'field': 'narrative'})]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect((st() as SceneFailed).retryable, isFalse);
  });

  test('a picture finishing after a new encounter started is not given to the new encounter', () async {
    await make(Server()..events = StreamController<List<int>>());
    final running = ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    while (st() is! SceneWorking || (st() as SceneWorking).phase != ScenePhase.queued) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    await db.newEncounter(); // the GM starts the next fight meanwhile
    final done = {'id': 'j', 'state': 'succeeded', 'outputs': [{'name': 'scene.png', 'assetId': 'asset-1', 'bytes': 64}]};
    server.events!.add(utf8.encode('data: ${jsonEncode({'type': 'job', 'job': done})}\n\n'));
    await server.events!.close();
    await running;
    expect(await db.watchActiveScene().first, isNull, reason: 'the new encounter has no picture');
    expect(await db.select(db.mapScenes).get(), isEmpty, reason: 'the old encounter is gone, so nothing is kept');
  });
}
