// Runs GM Cebi's NeuraCraft client against a real NeuraCraft Cloud API
// (development: `docker compose` in neuracraft-cloud, or the API + a worker by hand).
//
//   NC_API_URL=http://127.0.0.1:8080 NC_APP_TOKEN=nc_app_… dart run tool/nc_smoke.dart sketch.png [out.png]
//
// Checks the whole flow the app uses: preset version, session open/heartbeat/
// close, a job from a sketch and a Turkish narrative over server-sent events,
// the download (redirect followed by hand), a report, cancel, and the error
// codes the app reacts to. Exits non-zero on the first failure.
import 'dart:io';
import 'dart:typed_data';

import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/errors.dart';
import 'package:gm_cebi/data/neuracraft/install_id.dart';
import 'package:gm_cebi/data/neuracraft/models.dart';
import 'package:http/http.dart' as http;

void check(bool ok, String what) {
  stdout.writeln('${ok ? 'ok  ' : 'FAIL'} $what');
  if (!ok) exit(1);
}

Future<NcApiException?> apiError(Future<Object?> Function() f) async {
  try {
    await f();
    return null;
  } on NcApiException catch (e) {
    return e;
  }
}

Future<void> main(List<String> args) async {
  final config = NcConfig(baseUrl: Platform.environment['NC_API_URL'] ?? '', appToken: Platform.environment['NC_APP_TOKEN'] ?? '');
  if (!config.isConfigured || args.isEmpty) {
    stderr.writeln('usage: NC_API_URL=… NC_APP_TOKEN=… dart run tool/nc_smoke.dart sketch.png [out.png]');
    exit(2);
  }
  final sketch = Uint8List.fromList(File(args[0]).readAsBytesSync());
  var endUser = newInstallId();
  final http.Client h = http.Client();
  final c = NeuraCraftClient(httpClient: h, config: config, endUser: () => endUser);

  check(await c.supportsSketchToScene(), 'sketch_to_scene v$sketchToSceneVersion is offered');

  final s = await c.openSession();
  check(s.id.isNotEmpty && s.heartbeatSeconds > 0, 'session opened (${s.id}, heartbeat ${s.heartbeatSeconds} s, capacity ${s.capacity.runtimeType})');
  final again = await c.openSession();
  check(again.id == s.id, 'opening again returns the same session');
  final hb = await c.heartbeat(s.id);
  check(hb.id == s.id, 'heartbeat (capacity ${hb.capacity.runtimeType})');

  final sw = Stopwatch()..start();
  final job = await c.submitScene(sketchPng: sketch, mode: SceneMode.map, narrative: 'Nehrin üzerinde ahşap bir köprü, kuzeyde sık bir orman', seed: 1234);
  check(job.state == NcJobState.queued, 'job submitted (${job.id})');
  NcJob? last;
  final kinds = <String>[];
  await for (final e in c.watchJob(job.id).timeout(const Duration(minutes: 5))) {
    kinds.add(switch (e) {
      NcJobSnapshot(:final job) => 'job:${job.state.name}',
      NcJobStateChanged(:final state) => 'state:${state.name}',
      NcJobProgressed(:final progress) => 'progress:${progress.step}/${progress.steps}',
    });
    if (e is NcJobSnapshot) last = e.job;
  }
  stdout.writeln('     events: ${kinds.join(', ')}');
  check(last?.state == NcJobState.succeeded, 'job succeeded in ${sw.elapsed.inMilliseconds} ms');
  final out = last!.outputs.single;
  check(out.name == 'scene.png', 'one output: scene.png (${out.bytes} bytes)');

  final png = await c.downloadAsset(out.assetId);
  final bd = ByteData.sublistView(png);
  check(png.length == out.bytes && bd.getUint32(16) == 512 && bd.getUint32(20) == 512, 'downloaded a 512×512 PNG through the redirect');
  if (args.length > 1) File(args[1]).writeAsBytesSync(png);

  await c.report(out.assetId, ReportReason.other, note: 'duman testi');
  check(true, 'report accepted');
  // The guide says a reported picture is hidden for everyone; the app hides
  // its own copy in any case. Note what the server does today.
  final hidden = await apiError(() => c.downloadAsset(out.assetId));
  stdout.writeln('     after the report the server ${hidden == null ? 'still serves the picture to its owner' : 'answers ${hidden.code}'}');

  final toCancel = await c.submitScene(sketchPng: sketch, mode: SceneMode.atmosphere, prompt: 'a misty forest river', seed: 7);
  await c.cancelJob(toCancel.id);
  final cancelled = await c.watchJob(toCancel.id).last.timeout(const Duration(minutes: 5));
  final cs = (cancelled as NcJobSnapshot).job.state;
  check(cs == NcJobState.cancelled || cs == NcJobState.succeeded, 'cancel accepted (ended ${cs.name})');

  // Errors the app reacts to.
  final missing = await apiError(() => c.getJob('00000000-0000-4000-8000-000000000000'));
  check(missing?.reaction == NcReaction.notFound, 'unknown job → not_found');

  final badUser = endUser;
  endUser = 'bad id with spaces';
  final bad = await apiError(() => c.openSession());
  check(bad?.code == 'partner.end_user_required' && bad?.reaction == NcReaction.bug, 'malformed X-End-User → ${bad?.code}');
  endUser = badUser;

  // NC_SMOKE_PRODUCTION=1: a live service. Skips the two checks that would cost
  // real GPU time or cannot work there: the quota run (up to 10 finished jobs)
  // and the bad-token check (a proxy that injects the real token rewrites it).
  final production = Platform.environment['NC_SMOKE_PRODUCTION'] == '1';
  if (production) {
    stdout.writeln('skip  bad app token, daily quota (NC_SMOKE_PRODUCTION=1)');
  } else {
    final bogus = NeuraCraftClient(httpClient: h, config: NcConfig(baseUrl: config.baseUrl, appToken: 'nc_app_not-a-token'), endUser: () => endUser);
    final auth = await apiError(() => bogus.openSession());
    check(auth?.reaction == NcReaction.authInvalid, 'bad app token → ${auth?.code}');

    NcApiException? quota;
    for (var i = 0; i < 10 && quota == null; i++) {
      quota = await apiError(() async {
        // Cancelled jobs do not count against the quota, and the plan runs one
        // job at a time (limit.concurrent_jobs), so let each one finish.
        final j = await c.submitScene(sketchPng: sketch, mode: SceneMode.map, prompt: 'a bridge', seed: i);
        return c.watchJob(j.id).last.timeout(const Duration(minutes: 5));
      });
    }
    check(quota?.reaction == NcReaction.dailyQuota && quota?.resetsAt != null, 'daily quota → ${quota?.code}, resets ${quota?.resetsAt}');
  }

  await c.closeSession(s.id);
  final closed = await apiError(() => c.heartbeat(s.id));
  check(closed?.reaction == NcReaction.sessionClosed, 'heartbeat after close → ${closed?.code}');

  h.close();
  stdout.writeln('all checks passed');
}
