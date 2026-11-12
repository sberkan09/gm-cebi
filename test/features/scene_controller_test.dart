import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/auth.dart';
import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/errors.dart';
import 'package:gm_cebi/data/neuracraft/models.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/online_scene/account.dart';
import 'package:gm_cebi/features/online_scene/messages.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';
import 'package:gm_cebi/features/online_scene/session_controller.dart';
import 'package:gm_cebi/providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'online_session_test.dart' show FakeOnlineSettings, signedInTokens;

const config = NcConfig(baseUrl: 'http://nc.test', clientId: 'nc_client_t');

final sketch = Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 7, 7, 7]);
final scenePng = Uint8List.fromList(List.generate(64, (i) => i));
final blankSketch = Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 0, 0, 0]);

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

  /// The `GET /v1/presets` answer (null: 404).
  Map<String, Object?>? presets;

  /// Answers to the picture's download in turn; then the picture.
  final downloads = <http.StreamedResponse Function()>[];

  /// No event stream (a proxy in the way) and a job that stays `queued`.
  bool stuckQueued = false;

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
    if (p == '/v1/presets' && presets != null) return jsonStream(presets!);
    if (p == '/v1/presets/sketch_to_scene/jobs') {
      bodies.add(jsonDecode((r as http.Request).body) as Map<String, dynamic>);
      if (holdSubmit != null) await holdSubmit!.future;
      if (submit.isNotEmpty) return submit.removeAt(0)();
      return jsonStream({'job': job('queued')}, 201);
    }
    if (stuckQueued && p.endsWith('/events')) return err(406, 'not_acceptable');
    if (stuckQueued && p.startsWith('/v1/jobs/') && r.method == 'GET') return jsonStream({'job': job('queued')});
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
      if (downloads.isNotEmpty) return downloads.removeAt(0)();
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
  late MemoryTokenStore store;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SceneController.retrySoonDelay = const Duration(milliseconds: 1);
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<void> make(Server s, {bool withSketch = true, Uint8List? regions}) async {
    server = s;
    c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      ncConfigProvider.overrideWithValue(config),
      onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true))),
      ncTokenStoreProvider.overrideWithValue(store = MemoryTokenStore(signedInTokens())),
      ncHttpClientProvider.overrideWithValue(MockClient.streaming((r, _) => server.handle(r))),
      ncClientProvider.overrideWith((ref) => NeuraCraftClient(
            httpClient: ref.watch(ncHttpClientProvider),
            config: config,
            auth: ref.watch(ncTokenManagerProvider)!,
            pollInterval: const Duration(milliseconds: 1),
          )),
      sketchExporterProvider.overrideWithValue(() async => withSketch ? sketch : null),
      blankSketchExporterProvider.overrideWithValue(() async => blankSketch),
      regionsExporterProvider.overrideWithValue(() async => regions),
      sceneRandomProvider.overrideWithValue(Random(42)),
    ]);
    c.listen(sceneControllerProvider, (_, _) {});
    c.listen(onlineSessionProvider, (_, _) {});
    await c.read(onlineSettingsProvider.future);
    await c.read(ncAccountProvider.notifier).load();
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

  test('the server ends the sign-in on submit: asked to sign in again, the session idle', () async {
    await make(Server(submit: [() => err(401, 'auth.token_revoked')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final f = st() as SceneFailed;
    expect(f.message, 'Oturumun sona erdi, tekrar giriş yap.');
    expect(f.retryable, isFalse);
    expect(c.read(onlineSessionProvider).phase, SessionPhase.idle);
    expect(c.read(ncAccountProvider).expired, isTrue);
    expect(store.tokens, isNull);
    expect(c.read(onlineFeatureVisibleProvider), isTrue);
  });

  test('GM Cebi\'s maps for today are used up: no retry button', () async {
    await make(Server(submit: [() => err(429, 'quota.partner_daily', {'resetsAt': '2026-11-10T21:00:00.000Z'})]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final f = st() as SceneFailed;
    expect(f.message, "GM Cebi'nin bugünkü harita hakkı doldu, yarın tekrar dene.");
    expect(f.retryable, isFalse);
  });

  test('an outdated build turns the feature off until an update', () async {
    await make(Server(submit: [() => err(401, 'auth.end_user_token_required')]));
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
      ncConfigProvider.overrideWithValue(config),
      onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true))),
      ncTokenStoreProvider.overrideWithValue(MemoryTokenStore(signedInTokens())),
      ncHttpClientProvider.overrideWithValue(MockClient((r) async => throw http.ClientException('offline'))),
      sketchExporterProvider.overrideWithValue(() async => sketch),
    ]);
    c.listen(sceneControllerProvider, (_, _) {});
    await c.read(onlineSettingsProvider.future);
    await c.read(ncAccountProvider.notifier).load();
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

  test('a job gets one overall deadline: stuck in the queue on the polling fallback, it is cancelled and can be retried', () {
    fakeAsync((a) {
      final memory = AppDatabase(NativeDatabase.memory());
      server = Server()..stuckQueued = true;
      final box = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(memory),
        ncConfigProvider.overrideWithValue(config),
        onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true))),
        ncTokenStoreProvider.overrideWithValue(MemoryTokenStore(NcTokens(
            accessToken: 'nc_eu_a1', refreshToken: 'nc_rt_r1', accessExpiresAt: DateTime.now().add(const Duration(days: 2)), endUserId: 'eu_1'))),
        ncHttpClientProvider.overrideWithValue(MockClient.streaming((r, _) => server.handle(r))),
        sketchExporterProvider.overrideWithValue(() async => sketch),
        regionsExporterProvider.overrideWithValue(() async => null),
        sceneRandomProvider.overrideWithValue(Random(1)),
      ]);
      c = ProviderContainer(); // for tearDown
      box.listen(sceneControllerProvider, (_, _) {});
      box.listen(onlineSessionProvider, (_, _) {});
      box.read(onlineSettingsProvider);
      box.read(ncAccountProvider);
      a.flushMicrotasks();
      a.elapse(Duration.zero);
      unawaited(box.read(sceneControllerProvider.notifier).generate(mode: SceneMode.map, narrative: 'köprü'));
      a.elapse(SceneController.jobDeadline - const Duration(seconds: 5));
      expect(box.read(sceneControllerProvider), isA<SceneWorking>(), reason: 'still waiting just before the deadline');
      a.elapse(const Duration(seconds: 10));
      final failed = box.read(sceneControllerProvider);
      expect(failed, isA<SceneFailed>(), reason: 'the idle timeout is per event and never fires while polling; the deadline does');
      expect((failed as SceneFailed).message, messageForReaction(NcReaction.busy));
      expect(failed.retryable, isTrue);
      expect(server.calls.where((x) => x.endsWith('/cancel')), hasLength(1), reason: 'the job is cancelled on the server');
      final polls = server.calls.where((x) => x.startsWith('GET /v1/jobs/')).length;
      a.elapse(const Duration(minutes: 30));
      expect(server.calls.where((x) => x.startsWith('GET /v1/jobs/')).length, lessThanOrEqualTo(polls + 1), reason: 'polling stopped');
      expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 1, reason: 'no new job on its own');
      box.dispose();
      memory.close();
      a.elapse(const Duration(seconds: 1));
    });
  });

  test('a failed download after a finished job: "Yeniden dene" fetches the same picture, no second job', () async {
    await make(Server()..downloads.add(() => throw http.ClientException('connection reset')));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    final f = st() as SceneFailed;
    expect(f.message, 'Sunucuya ulaşılamadı. Harita çevrimdışı çalışmaya devam ediyor.');
    expect(f.retryable, isTrue);
    expect(await db.watchActiveScene().first, isNull);

    await ctl().retry();
    expect(st(), isA<SceneIdle>());
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 1, reason: 'the picture was already made (and counted)');
    expect(server.count('GET /v1/assets/asset-1/content'), 2);
    final scene = (await db.watchActiveScene().first)!;
    expect(scene.png, scenePng);
    expect(scene.narrative, 'köprü');
    expect(scene.seed, server.bodies.single['params']['seed']);

    // Nothing is left over: the next retry is a new job.
    await ctl().retry();
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 2);
  });

  test('the picture is gone when its download is retried (404): then a new job', () async {
    await make(Server()
      ..downloads.addAll([() => err(503, 'unavailable'), () => err(404, 'not_found')]));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect(st(), isA<SceneFailed>());
    await ctl().retry();
    expect(st(), isA<SceneIdle>());
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 2);
    expect(await db.watchActiveScene().first, isNotNull);
  });

  test('a new request from the sheet does not fetch an older undelivered picture', () async {
    await make(Server()..downloads.add(() => throw http.ClientException('connection reset')));
    await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
    expect(st(), isA<SceneFailed>());
    await ctl().generate(mode: SceneMode.atmosphere, narrative: 'orman');
    expect(server.count('POST /v1/presets/sketch_to_scene/jobs'), 2);
    expect((await db.watchActiveScene().first)!.narrative, 'orman');
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
    final offline = MockClient((r) async => throw http.ClientException('offline'));
    final failing = NeuraCraftClient(
        httpClient: offline,
        config: config,
        auth: NcTokenManager(api: NcAuthApi(httpClient: offline, config: config), store: MemoryTokenStore(signedInTokens())));
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

  test('nothing is sent while the feature is switched off or before consent', () async {
    for (final settings in const [OnlineSettings(enabled: false, consented: true), OnlineSettings(consented: false)]) {
      server = Server();
      c = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        ncConfigProvider.overrideWithValue(config),
        onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(settings)),
        ncTokenStoreProvider.overrideWithValue(MemoryTokenStore(signedInTokens())),
        ncHttpClientProvider.overrideWithValue(MockClient.streaming((r, _) => server.handle(r))),
        sketchExporterProvider.overrideWithValue(() async => sketch),
        regionsExporterProvider.overrideWithValue(() async => null),
      ]);
      c.listen(sceneControllerProvider, (_, _) {});
      await c.read(onlineSettingsProvider.future);
      await c.read(ncAccountProvider.notifier).load();
      await ctl().generate(mode: SceneMode.map, narrative: 'köprü');
      await ctl().retry();
      expect(st(), isA<SceneIdle>());
      expect(server.calls, isEmpty);
      expect(await c.read(sceneFeaturesProvider.future), same(NcSceneFeatures.none));
      expect(server.calls, isEmpty, reason: 'not even the presets question');
      c.dispose();
    }
    c = ProviderContainer();
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

  group('region layer (neuracraft-cloud #42)', () {
    final regions = Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 5, 5]);
    Map<String, Object?> advertised({bool ground = true}) => {
          'presets': [
            {
              'id': 'sketch_to_scene',
              'version': 1,
              'params': {
                'mode': {'type': 'enum', 'options': ['map', 'atmosphere']},
                if (ground) 'ground': {'type': 'enum', 'options': ['grass', 'stone', 'dirt', 'sand', 'snow'], 'default': 'grass'},
              },
              'inputs': [
                {'name': 'sketch'},
                {'name': 'regions'},
              ],
            },
          ],
        };

    test('advertised: the painted areas and the ground go with the sketch; asked once', () async {
      await make(Server()..presets = advertised(), regions: regions);
      await ctl().generate(mode: SceneMode.map, narrative: 'köprü', ground: 'sand');
      expect(st(), isA<SceneIdle>());
      final body = server.bodies.single;
      expect(body['inputs']['sketch']['inline'], base64Encode(sketch));
      expect(body['inputs']['regions'], {'inline': base64Encode(regions), 'contentType': 'image/png'});
      expect(body['params']['ground'], 'sand');
      expect(server.calls.first, 'POST /v1/sessions');

      await ctl().retry();
      expect(server.bodies.last['params']['ground'], 'sand', reason: 'a retry keeps the ground');
      expect(server.count('GET /v1/presets'), 1, reason: 'the answer is cached');
    });

    test('not advertised (today): the sketch goes alone, exactly as before', () async {
      await make(Server(), regions: regions);
      await ctl().generate(mode: SceneMode.map, narrative: 'köprü', ground: 'sand');
      expect(st(), isA<SceneIdle>());
      final body = server.bodies.single;
      expect((body['inputs'] as Map).keys, ['sketch']);
      expect((body['params'] as Map).containsKey('ground'), isFalse);
    });

    test('regions advertised without a ground: the layer goes, the ground does not', () async {
      await make(Server()..presets = advertised(ground: false), regions: regions);
      await ctl().generate(mode: SceneMode.map, narrative: 'köprü', ground: 'stone');
      final body = server.bodies.single;
      expect((body['inputs'] as Map).keys, ['sketch', 'regions']);
      expect((body['params'] as Map).containsKey('ground'), isFalse);
    });

    test('atmosphere mode and an unpainted map send no region layer (and do not ask)', () async {
      await make(Server()..presets = advertised(), regions: regions);
      await ctl().generate(mode: SceneMode.atmosphere, narrative: 'köprü', ground: 'sand');
      expect((server.bodies.single['inputs'] as Map).keys, ['sketch']);
      expect(server.count('GET /v1/presets'), 0);
    });

    test('painted areas only, a service that takes them: a blank sketch goes with the region layer', () async {
      await make(Server()..presets = advertised(), withSketch: false, regions: regions);
      await ctl().generate(mode: SceneMode.map, narrative: 'nehir', ground: 'grass');
      expect(st(), isA<SceneIdle>());
      final body = server.bodies.single;
      expect(body['inputs']['sketch']['inline'], base64Encode(blankSketch));
      expect(body['inputs']['regions']['inline'], base64Encode(regions));
      expect(body['params']['ground'], 'grass');
      expect(await db.watchActiveScene().first, isNotNull);
    });

    test('painted areas only, a service that does not take them: asked to draw lines too, no session, no job', () async {
      await make(Server(), withSketch: false, regions: regions);
      await ctl().generate(mode: SceneMode.map, narrative: 'nehir');
      final f = st() as SceneFailed;
      expect(f.message, 'Çizgiyle de çiz: sunucu henüz alanları desteklemiyor.');
      expect(f.retryable, isFalse);
      expect(server.calls, ['GET /v1/presets'], reason: 'only the question; no GPU is asked for');
    });

    test('painted areas only in atmosphere mode: asked to draw lines too, nothing is sent', () async {
      await make(Server()..presets = advertised(), withSketch: false, regions: regions);
      await ctl().generate(mode: SceneMode.atmosphere, narrative: 'nehir');
      expect((st() as SceneFailed).message, 'Çizgiyle de çiz: boyanan alanlar yalnızca Harita modunda gönderilir.');
      expect(server.calls, isEmpty);
    });

    test('nothing painted: no region layer, no presets request', () async {
      await make(Server()..presets = advertised());
      await ctl().generate(mode: SceneMode.map, narrative: 'köprü', ground: 'sand');
      expect((server.bodies.single['inputs'] as Map).keys, ['sketch']);
      expect(server.count('GET /v1/presets'), 0);
    });
  });
}
