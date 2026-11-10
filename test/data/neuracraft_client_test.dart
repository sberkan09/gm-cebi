import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/auth.dart';
import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/errors.dart';
import 'package:gm_cebi/data/neuracraft/models.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const config = NcConfig(baseUrl: 'http://nc.test', clientId: 'nc_client_test');

NcTokens testTokens({String access = 'nc_eu_a1', String refresh = 'nc_rt_r1', DateTime? expires}) => NcTokens(
    accessToken: access,
    refreshToken: refresh,
    accessExpiresAt: expires ?? DateTime.now().add(const Duration(hours: 1)),
    endUserId: 'eu_1',
    email: 'gm@example.com');

/// A manager signed in with [testTokens], refreshing through [h].
NcTokenManager signedIn(http.Client h, {NcTokenStore? store}) =>
    NcTokenManager(api: NcAuthApi(httpClient: h, config: config), store: store ?? MemoryTokenStore(testTokens()));

NeuraCraftClient clientWith(http.Client h, {NcTokenManager? auth, Duration timeout = const Duration(seconds: 2)}) => NeuraCraftClient(
      httpClient: h,
      config: config,
      auth: auth ?? signedIn(h),
      pollInterval: const Duration(milliseconds: 1),
      timeout: timeout,
    );

http.Response jsonResponse(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

http.Response errorResponse(int status, String code, [Map<String, Object?> params = const {}]) =>
    jsonResponse({'error': {'code': code, 'params': params}}, status);

Map<String, Object?> sessionJson(Map<String, Object?> capacity) => {
      'session': {
        'id': 'sess-1',
        'heartbeatSeconds': 120,
        'expiresWithoutHeartbeatSeconds': 600,
        'endsAt': '2026-11-09T20:00:00.000Z',
        'idleMinutes': 45,
      },
      'capacity': capacity,
    };

Map<String, Object?> jobJson(String state, {List<Map<String, Object?>> outputs = const [], Map<String, Object?>? error}) => {
      'id': 'job-1',
      'state': state,
      'workflow': {},
      'createdAt': '2026-11-09T10:00:00.000Z',
      'startedAt': null,
      'finishedAt': null,
      'progress': null,
      'outputs': outputs,
      'error': error,
      'workerSeconds': null,
    };

final png = Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 1, 2, 3]);

void main() {
  test("GM Cebi's public client id is built in; the feature still needs NC_API_URL", () {
    expect(NcConfig.fromEnvironment.clientId, gmCebiClientId);
    expect(gmCebiClientId, startsWith('nc_client_'));
    expect(NcConfig.fromEnvironment.isConfigured, isFalse); // no NC_API_URL in tests: offline build
  });

  group('requests', () {
    test('every request carries the access token, and no X-End-User', () async {
      final seen = <http.BaseRequest>[];
      final c = clientWith(MockClient((r) async {
        seen.add(r);
        return jsonResponse(sessionJson({'state': 'ready'}), 201);
      }));
      await c.openSession();
      expect(seen.single.method, 'POST');
      expect(seen.single.url.toString(), 'http://nc.test/v1/sessions');
      expect(seen.single.headers['Authorization'], 'Bearer nc_eu_a1');
      expect(seen.single.headers.containsKey('X-End-User'), isFalse);
    });

    test('sessions: capacity states and heartbeat', () async {
      final answers = [
        jsonResponse(sessionJson({'state': 'warming', 'etaSeconds': 35}), 201),
        jsonResponse(sessionJson({'state': 'ready'})),
        jsonResponse(sessionJson({'state': 'unavailable', 'reason': 'no_gpu'})),
        jsonResponse({'closed': true}),
      ];
      final paths = <String>[];
      final c = clientWith(MockClient((r) async {
        paths.add('${r.method} ${r.url.path}');
        return answers.removeAt(0);
      }));
      final s = await c.openSession();
      expect(s.id, 'sess-1');
      expect(s.heartbeatSeconds, 120);
      expect(s.capacity, const NcCapacityWarming(35));
      expect((await c.heartbeat('sess-1')).capacity, const NcCapacityReady());
      expect((await c.heartbeat('sess-1')).capacity, const NcCapacityUnavailable('no_gpu'));
      await c.closeSession('sess-1');
      expect(paths, [
        'POST /v1/sessions',
        'POST /v1/sessions/sess-1/heartbeat',
        'POST /v1/sessions/sess-1/heartbeat',
        'DELETE /v1/sessions/sess-1',
      ]);
    });

    test('submitScene sends the preset version, params and the inline PNG', () async {
      late Map<String, dynamic> body;
      final c = clientWith(MockClient((r) async {
        expect(r.url.path, '/v1/presets/sketch_to_scene/jobs');
        expect(r.headers['Content-Type'], startsWith('application/json'));
        body = jsonDecode(r.body) as Map<String, dynamic>;
        return jsonResponse({'job': jobJson('queued')}, 201);
      }));
      final job = await c.submitScene(sketchPng: png, mode: SceneMode.map, narrative: '  Nehrin üzerinde ahşap bir köprü ', seed: 1234);
      expect(job.id, 'job-1');
      expect(job.state, NcJobState.queued);
      expect(body['version'], sketchToSceneVersion);
      expect(body['params'], {'mode': 'map', 'narrative': 'Nehrin üzerinde ahşap bir köprü', 'seed': 1234});
      expect(body['inputs'], {
        'sketch': {'inline': base64Encode(png), 'contentType': 'image/png'},
      });
    });

    test('submitScene refuses bad input before sending anything', () async {
      var sent = 0;
      final c = clientWith(MockClient((r) async {
        sent++;
        return jsonResponse({});
      }));
      Future<void> bad(Future<void> Function() f) => expectLater(f(), throwsArgumentError);
      await bad(() => c.submitScene(sketchPng: png, mode: SceneMode.map));
      await bad(() => c.submitScene(sketchPng: png, mode: SceneMode.map, narrative: 'a', prompt: 'b'));
      await bad(() => c.submitScene(sketchPng: png, mode: SceneMode.map, narrative: 'x' * (maxNarrativeChars + 1)));
      await bad(() => c.submitScene(sketchPng: png, mode: SceneMode.map, prompt: 'x' * (maxPromptChars + 1)));
      await bad(() => c.submitScene(sketchPng: Uint8List(maxSketchBytes + 1), mode: SceneMode.map, narrative: 'köprü'));
      expect(sent, 0);
    });

    test('report sends the wire reason and an optional note', () async {
      late http.Request req;
      final c = clientWith(MockClient((r) async {
        req = r;
        return jsonResponse({'reported': true}, 202);
      }));
      await c.report('asset-9', ReportReason.violenceGore, note: ' kan ');
      expect(req.url.path, '/v1/assets/asset-9/report');
      expect(jsonDecode(req.body), {'reason': 'violence_gore', 'note': 'kan'});
      expect(ReportReason.values.map((r) => r.wire), ['sexual', 'violence_gore', 'hate', 'minor_safety', 'other']);
    });

    test('supportsSketchToScene checks the preset and its version', () async {
      Future<bool> withPresets(List<Object> presets) =>
          clientWith(MockClient((r) async => jsonResponse({'presets': presets}))).supportsSketchToScene();
      expect(await withPresets([{'id': 'sketch_to_scene', 'version': 1}]), isTrue);
      expect(await withPresets([{'id': 'sketch_to_scene', 'version': 2}]), isTrue);
      expect(await withPresets([{'id': 'other', 'version': 1}]), isFalse);
    });
  });

  group('errors', () {
    // docs/partners/gm-cebi.md, "Errors": every code and what the app does.
    const table = <(int, String, NcReaction)>[
      (400, 'preset.params_invalid', NcReaction.bug),
      (400, 'content.text_refused', NcReaction.textRefused),
      (400, 'partner.end_user_required', NcReaction.bug),
      (401, 'auth.required', NcReaction.authInvalid),
      (400, 'auth.client_invalid', NcReaction.authInvalid),
      (401, 'auth.end_user_token_required', NcReaction.authInvalid),
      (403, 'auth.scope_missing', NcReaction.authInvalid),
      (401, 'auth.token_revoked', NcReaction.signInRequired),
      (401, 'auth.refresh_invalid', NcReaction.signInRequired),
      (403, 'auth.end_user_blocked', NcReaction.blocked),
      (503, 'auth.sign_in_unavailable', NcReaction.signInUnavailable),
      (429, 'quota.partner_daily', NcReaction.partnerDailyQuota),
      (402, 'allowance.insufficient', NcReaction.allowanceExhausted),
      (402, 'credits.insufficient', NcReaction.serviceOutOfCredits),
      (404, 'not_found', NcReaction.notFound),
      (410, 'session.closed', NcReaction.sessionClosed),
      (429, 'quota.end_user_daily', NcReaction.dailyQuota),
      (429, 'session.limit', NcReaction.busy),
      (429, 'limit.concurrent_jobs', NcReaction.retrySoon),
      (429, 'rate_limited', NcReaction.retrySoon),
      (503, 'job.no_gpu_worker', NcReaction.noGpu),
      (503, 'preset.unavailable', NcReaction.serviceSettingUp),
    ];

    for (final (status, code, reaction) in table) {
      test('$status $code → $reaction', () async {
        final c = clientWith(MockClient((r) async => errorResponse(status, code, {'field': 'params.mode'})));
        try {
          await c.openSession();
          fail('no exception');
        } on NcApiException catch (e) {
          expect(e.status, status);
          expect(e.code, code);
          expect(e.params['field'], 'params.mode');
          expect(e.reaction, reaction);
        }
      });
    }

    test('quota error exposes resetsAt', () async {
      final c = clientWith(MockClient((r) async =>
          errorResponse(429, 'quota.end_user_daily', {'limit': 20, 'resetsAt': '2026-11-09T21:00:00.000Z'})));
      try {
        await c.openSession();
        fail('no exception');
      } on NcApiException catch (e) {
        expect(e.resetsAt, DateTime.utc(2026, 11, 9, 21).toLocal());
      }
    });

    test('network failures, timeouts and non-service answers become NcNetworkException', () async {
      final down = clientWith(MockClient((r) async => throw http.ClientException('connection refused')));
      await expectLater(down.openSession(), throwsA(isA<NcNetworkException>()));

      final proxy = clientWith(MockClient((r) async => http.Response('<html>Bad gateway</html>', 502)));
      await expectLater(proxy.openSession(), throwsA(isA<NcNetworkException>()));

      final notJson = clientWith(MockClient((r) async => http.Response('hello', 200)));
      await expectLater(notJson.openSession(), throwsA(isA<NcNetworkException>()));

      final slow = clientWith(MockClient((r) => Completer<http.Response>().future), timeout: const Duration(milliseconds: 20));
      await expectLater(slow.openSession(), throwsA(isA<NcNetworkException>()));
    });
  });

  group('waiting for a job', () {
    test('parseEvent understands job, state and progress; skips junk', () {
      final job = NeuraCraftClient.parseEvent(jsonEncode({'type': 'job', 'job': jobJson('queued')}));
      expect((job! as NcJobSnapshot).job.state, NcJobState.queued);
      final st = NeuraCraftClient.parseEvent('{"type":"state","state":"running"}');
      expect((st! as NcJobStateChanged).state, NcJobState.running);
      final pr = NeuraCraftClient.parseEvent(
          '{"type":"progress","progress":{"step":3,"steps":5,"op":"txt2img","stage":"denoise","fraction":0.5}}');
      expect((pr! as NcJobProgressed).progress.overall, closeTo(0.5, 1e-9)); // (2 + 0.5) / 5
      expect(NeuraCraftClient.parseEvent('{"type":"output","output":{}}'), isNull);
      expect(NeuraCraftClient.parseEvent('not json'), isNull);
    });

    test('SSE: events split across chunks, pings ignored, ends with the finished job', () async {
      final events = [
        ': ping\n\n',
        'data: ${jsonEncode({'type': 'job', 'job': jobJson('queued')})}\n\n',
        'data: {"type":"state",', // split mid-line
        '"state":"running"}\n\n: ping\n\n',
        'data: {"type":"progress","progress":{"step":1,"steps":2,"op":"txt2img","stage":"","fraction":-1}}\n\n',
        'data: ${jsonEncode({'type': 'job', 'job': jobJson('succeeded', outputs: [{'name': 'scene.png', 'assetId': 'a-1', 'kind': 'image', 'bytes': 1234}])})}\n\n',
      ];
      late http.BaseRequest seen;
      final c = clientWith(MockClient.streaming((r, _) async {
        seen = r;
        return http.StreamedResponse(Stream.fromIterable(events.map(utf8.encode)), 200,
            headers: {'content-type': 'text/event-stream'});
      }));
      final got = await c.watchJob('job-1').toList();
      expect(seen.url.path, '/v1/jobs/job-1/events');
      expect(seen.headers['Accept'], 'text/event-stream');
      expect(seen.headers['Authorization'], 'Bearer nc_eu_a1');
      expect(got.map((e) => e.runtimeType), [NcJobSnapshot, NcJobStateChanged, NcJobProgressed, NcJobSnapshot]);
      expect((got[2] as NcJobProgressed).progress.fraction, isNull);
      final last = (got.last as NcJobSnapshot).job;
      expect(last.state, NcJobState.succeeded);
      expect(last.outputs.single.assetId, 'a-1');
    });

    test('falls back to polling when the event stream cannot be opened', () async {
      final states = ['queued', 'running', 'succeeded'];
      final c = clientWith(MockClient.streaming((r, _) async {
        if (r.url.path.endsWith('/events')) throw http.ClientException('no SSE through this proxy');
        return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'job': jobJson(states.removeAt(0))}))), 200,
            headers: {'content-type': 'application/json'});
      }));
      final got = await c.watchJob('job-1').toList();
      expect(got.map((e) => (e as NcJobSnapshot).job.state), [NcJobState.queued, NcJobState.running, NcJobState.succeeded]);
    });

    test('falls back to polling when the event stream breaks before the end', () async {
      var polls = 0;
      final c = clientWith(MockClient.streaming((r, _) async {
        if (r.url.path.endsWith('/events')) {
          return http.StreamedResponse(
              Stream.value(utf8.encode('data: ${jsonEncode({'type': 'job', 'job': jobJson('running')})}\n\n')), 200,
              headers: {'content-type': 'text/event-stream'});
        }
        polls++;
        return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'job': jobJson('failed', error: {'code': 'content.flagged'})}))), 200);
      }));
      final got = await c.watchJob('job-1').toList();
      expect(polls, 1);
      final last = (got.last as NcJobSnapshot).job;
      expect(last.state, NcJobState.failed);
      expect(last.errorCode, 'content.flagged');
    });

    test('a service error on the event stream is not hidden by polling', () async {
      final c = clientWith(MockClient.streaming((r, _) async =>
          http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'error': {'code': 'not_found'}}))), 404)));
      await expectLater(c.watchJob('job-1').toList(), throwsA(isA<NcApiException>().having((e) => e.code, 'code', 'not_found')));
    });
  });

  group('flaky networks', () {
    test('a silent event stream (no pings) is taken as dead: polling takes over', () async {
      var polls = 0;
      final h = MockClient.streaming((r, _) async {
        if (r.url.path.endsWith('/events')) {
          return http.StreamedResponse(StreamController<List<int>>().stream, 200, headers: {'content-type': 'text/event-stream'});
        }
        polls++;
        return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'job': jobJson('succeeded')}))), 200);
      });
      final c = NeuraCraftClient(
        httpClient: h,
        config: config,
        auth: signedIn(h),
        pollInterval: const Duration(milliseconds: 1),
        eventIdleTimeout: const Duration(milliseconds: 50),
      );
      final last = await c.watchJob('job-1').last;
      expect((last as NcJobSnapshot).job.state, NcJobState.succeeded);
      expect(polls, 1);
    });

    test('pings keep a slow event stream alive', () async {
      final ctl = StreamController<List<int>>();
      final h = MockClient.streaming((r, _) async => http.StreamedResponse(ctl.stream, 200, headers: {'content-type': 'text/event-stream'}));
      final c = NeuraCraftClient(
        httpClient: h,
        config: config,
        auth: signedIn(h),
        eventIdleTimeout: const Duration(milliseconds: 80),
      );
      final got = c.watchJob('job-1').toList();
      for (var i = 0; i < 4; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        ctl.add(utf8.encode(': ping\n\n'));
      }
      ctl.add(utf8.encode('data: ${jsonEncode({'type': 'job', 'job': jobJson('succeeded')})}\n\n'));
      final events = await got;
      expect((events.single as NcJobSnapshot).job.state, NcJobState.succeeded);
      await ctl.close();
    });

    test('polling rides out a few network errors, then gives up', () async {
      var n = 0;
      final c = clientWith(MockClient.streaming((r, _) async {
        if (r.url.path.endsWith('/events')) throw http.ClientException('no SSE');
        n++;
        if (n <= 3) throw http.ClientException('flaky');
        return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'job': jobJson('succeeded')}))), 200);
      }));
      expect(((await c.watchJob('job-1').last) as NcJobSnapshot).job.state, NcJobState.succeeded);

      final dead = clientWith(MockClient.streaming((r, _) async => throw http.ClientException('offline')));
      await expectLater(dead.watchJob('job-1').toList(), throwsA(isA<NcNetworkException>()));
    });
  });

  group('downloading a result', () {
    test('follows the redirect by hand and never sends the token to storage', () async {
      final seen = <http.BaseRequest>[];
      final c = clientWith(MockClient.streaming((r, _) async {
        seen.add(r);
        if (r.url.host == 'nc.test') {
          expect((r as http.Request).followRedirects, isFalse);
          return http.StreamedResponse(const Stream.empty(), 302, headers: {'location': 'https://storage.example/blob?sig=abc'});
        }
        return http.StreamedResponse(Stream.value([1, 2, 3, 4]), 200, headers: {'content-type': 'image/png'});
      }));
      final bytes = await c.downloadAsset('a-1');
      expect(bytes, [1, 2, 3, 4]);
      expect(seen.map((r) => r.url.toString()), ['http://nc.test/v1/assets/a-1/content', 'https://storage.example/blob?sig=abc']);
      expect(seen[0].headers['Authorization'], 'Bearer nc_eu_a1');
      expect(seen[1].headers.containsKey('Authorization'), isFalse);
      expect(seen[1].headers.containsKey('X-End-User'), isFalse);
    });

    test('relative redirects resolve against the API (development storage)', () async {
      final seen = <String>[];
      final c = clientWith(MockClient.streaming((r, _) async {
        seen.add(r.url.toString());
        if (r.url.path.endsWith('/content')) {
          return http.StreamedResponse(const Stream.empty(), 302, headers: {'location': '/v1/storage/tok123'});
        }
        return http.StreamedResponse(Stream.value([9]), 200);
      }));
      expect(await c.downloadAsset('a-1'), [9]);
      expect(seen.last, 'http://nc.test/v1/storage/tok123');
    });

    test('a missing picture is not_found', () async {
      final c = clientWith(MockClient.streaming((r, _) async =>
          http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'error': {'code': 'not_found'}}))), 404)));
      await expectLater(c.downloadAsset('a-1'), throwsA(isA<NcApiException>().having((e) => e.reaction, 'reaction', NcReaction.notFound)));
    });
  });

  test('config is off unless both values are given', () {
    expect(const NcConfig(baseUrl: '', clientId: 'x').isConfigured, isFalse);
    expect(const NcConfig(baseUrl: 'http://x', clientId: '').isConfigured, isFalse);
    expect(config.isConfigured, isTrue);
    expect(const NcConfig(baseUrl: 'http://x:8080/', clientId: 't').uri('/v1/sessions').toString(), 'http://x:8080/v1/sessions');
    expect(NcConfig.fromEnvironment.isConfigured, isFalse, reason: 'plain test runs have no dart-defines');
  });
}
