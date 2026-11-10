// Runs GM Cebi's NeuraCraft client against a real NeuraCraft Cloud API
// (development: `docker compose` in neuracraft-cloud, or the API + a worker by hand).
//
//   NC_API_URL=http://127.0.0.1:8080 NC_CLIENT_ID=nc_client_… NC_EMAIL=you@example.com \
//     dart run tool/nc_smoke.dart sketch.png [out.png]
//
// Signs in like the app (a code goes to NC_EMAIL; type it in), or with
// NC_REFRESH_TOKEN=nc_rt_… instead of the email. Then checks the whole flow
// the app uses: GET /v1/me, preset version, session open/heartbeat/close, a job
// from a sketch and a Turkish narrative over server-sent events, the download
// (redirect followed by hand), a report, cancel, a refresh (the refresh token
// rotates), and the error codes the app reacts to. Exits non-zero on the
// first failure.
//
// NC_SMOKE_DELETE_ACCOUNT=1 ends with DELETE /v1/me (the account and all its
// data). Otherwise the last refresh token is printed for the next run.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:gm_cebi/data/neuracraft/auth.dart';
import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/errors.dart';
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
  final env = Platform.environment;
  final config = NcConfig(baseUrl: env['NC_API_URL'] ?? '', clientId: env['NC_CLIENT_ID'] ?? '');
  final email = env['NC_EMAIL'] ?? '';
  final refreshToken = env['NC_REFRESH_TOKEN'] ?? '';
  if (!config.isConfigured || args.isEmpty || (email.isEmpty && refreshToken.isEmpty)) {
    stderr.writeln('usage: NC_API_URL=… NC_CLIENT_ID=… (NC_EMAIL=… | NC_REFRESH_TOKEN=…) dart run tool/nc_smoke.dart sketch.png [out.png]');
    exit(2);
  }
  final sketch = Uint8List.fromList(File(args[0]).readAsBytesSync());
  final http.Client h = http.Client();
  final api = NcAuthApi(httpClient: h, config: config);
  final store = MemoryTokenStore();
  final auth = NcTokenManager(api: api, store: store);
  final c = NeuraCraftClient(httpClient: h, config: config, auth: auth);

  // ------------------------------------------------------------ sign-in
  final bad = await apiError(() => api.startEmail('not an email'));
  check(bad?.reaction == NcReaction.invalidEmail || bad?.reaction == NcReaction.signInUnavailable, 'malformed email → ${bad?.code}');
  if (refreshToken.isNotEmpty) {
    await store.write(NcTokens(accessToken: '', refreshToken: refreshToken, accessExpiresAt: DateTime(2000), endUserId: ''));
    await auth.load();
    await auth.accessToken(); // expired: refreshes
    check(auth.state.signedIn, 'signed in with NC_REFRESH_TOKEN');
  } else {
    final sent = await api.startEmail(email);
    check(sent.resendAfter > 0, 'code sent (valid ${sent.expiresIn} s, resend after ${sent.resendAfter} s)');
    final wrong = await apiError(() => api.verifyEmail(email, '000000'));
    if (wrong != null) stdout.writeln('     a wrong code → ${wrong.code} ${wrong.params}');
    stdout.write('code from the email: ');
    final code = stdin.readLineSync(encoding: utf8)?.trim() ?? '';
    await auth.verifyEmail(email, code);
    check(auth.state.signedIn, 'signed in as ${auth.state.endUserId}');
  }
  final me = await c.getMe();
  final signedInAs = store.tokens?.endUserId ?? '';
  check(me.endUserId.isNotEmpty && (signedInAs.isEmpty || me.endUserId == signedInAs),
      'GET /v1/me (${me.endUserId}, today ${me.used}/${me.daily}, resets ${me.resetsAt})');

  // The access token is sent as is; a broken one is a bug the service names.
  final bogus = NcTokenManager(
      api: api, store: MemoryTokenStore(NcTokens(accessToken: 'not-a-token', refreshToken: 'x', accessExpiresAt: DateTime(2100), endUserId: '')));
  final malformed = await apiError(() => NeuraCraftClient(httpClient: h, config: config, auth: bogus).openSession());
  check(malformed?.code == 'auth.required' && malformed?.reaction == NcReaction.authInvalid, 'malformed token → ${malformed?.code}');

  // ------------------------------------------------------------ the flow
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

  // Refresh: the refresh token rotates.
  final before = store.tokens!;
  await auth.refreshAfterExpired(before.accessToken);
  final after = store.tokens!;
  check(after.refreshToken != before.refreshToken && after.accessToken != before.accessToken, 'refresh rotated both tokens');

  // NC_SMOKE_PRODUCTION=1: a live service. Skips the quota run (up to 10
  // finished jobs of real GPU time).
  final production = env['NC_SMOKE_PRODUCTION'] == '1';
  if (production) {
    stdout.writeln('skip  daily quota (NC_SMOKE_PRODUCTION=1)');
  } else {
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

  if (env['NC_SMOKE_DELETE_ACCOUNT'] == '1') {
    final kept = store.tokens!;
    await c.deleteMe();
    check(!auth.state.signedIn && store.tokens == null, 'DELETE /v1/me: account deleted, tokens dropped');
    final gone = await apiError(() => api.refresh(kept.refreshToken));
    check(gone?.reaction == NcReaction.signInRequired, 'refresh after the deletion → ${gone?.code}');
  } else {
    // Last, as it may end the sign-in: the refresh token used before is dead.
    final reused = await apiError(() => api.refresh(before.refreshToken));
    check(reused?.code == 'auth.refresh_invalid', 'the old refresh token again → ${reused?.code}');
    final still = await apiError(() => c.getMe());
    stdout.writeln('     after the reuse, GET /v1/me ${still == null ? 'still works' : '→ ${still.code} (the sign-in ended)'}');
    if (still == null) stdout.writeln('     next run: NC_REFRESH_TOKEN=${store.tokens?.refreshToken}');
  }

  h.close();
  stdout.writeln('all checks passed');
}
