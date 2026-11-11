/// HTTP client for NeuraCraft Cloud's sketch-to-scene API
/// (neuracraft-cloud docs/partners/gm-cebi.md). The UI never calls HTTP
/// directly; it goes through this class.
///
/// Every request carries the signed-in end user's access token
/// (`Authorization: Bearer nc_eu_…`, from [NcTokenManager]). On
/// `401 auth.token_expired` the token is refreshed and the request repeated
/// once.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'auth.dart';
import 'config.dart';
import 'errors.dart';
import 'models.dart';

/// The `sketch_to_scene` preset version this app was written for. Sent with
/// every job so the service maps our parameters if the preset moves on.
const sketchToSceneVersion = 1;

/// Limits of the preset (checked here so a bad request never leaves the app).
const maxNarrativeChars = 500;
const maxPromptChars = 400;
const maxNegativeChars = 300;
const maxSketchBytes = 512 * 1024;

/// The optional region layer (neuracraft-cloud #42): a PNG the size of the
/// sketch, transparent where unpainted.
const maxRegionsBytes = 512 * 1024;

/// `params.ground`: what the service fills the unpainted area with, when a
/// region layer is sent. `grass` is the service's default.
const sceneGrounds = NcSceneFeatures.groundValues;
const maxReportNoteChars = 500;

class NeuraCraftClient {
  NeuraCraftClient({
    required http.Client httpClient,
    required this.config,
    required this.auth,
    this.timeout = const Duration(seconds: 20),
    this.pollInterval = const Duration(seconds: 1),
    this.eventIdleTimeout = const Duration(seconds: 45),
    this.pollRetries = 5,
  }) : _http = httpClient;

  final http.Client _http;
  final NcConfig config;

  /// The sign-in: access token, refresh, and signing out on the server's word.
  final NcTokenManager auth;

  /// Per request (a job's whole wait is bounded by the caller).
  final Duration timeout;

  /// Polling period when server-sent events are not available.
  final Duration pollInterval;

  /// An event stream silent this long is taken as dead (the server pings
  /// every 15 s), and polling takes over.
  final Duration eventIdleTimeout;

  /// Network errors tolerated in a row while polling (backing off from
  /// [pollInterval]) before the wait gives up.
  final int pollRetries;

  // ------------------------------------------------------------ account

  /// The signed-in user and today's quota.
  Future<NcMe> getMe() async => NcMe.fromJson(await _json('GET', '/v1/me'));

  /// Deletes the end user, everything stored for them and all their tokens
  /// (in-app account deletion), then forgets the sign-in here.
  Future<void> deleteMe() async {
    await _json('DELETE', '/v1/me');
    await auth.accountDeleted();
  }

  // ------------------------------------------------------------ sessions

  /// Opens a session (or returns the one already open): the service starts a
  /// GPU on this signal, so call it when a game starts, not when sending.
  Future<NcSession> openSession() async => NcSession.fromJson(await _json('POST', '/v1/sessions'));

  /// Keeps the session open; the answer carries a fresh capacity.
  /// Throws [NcApiException] `session.closed` (410) when it has ended.
  Future<NcSession> heartbeat(String sessionId) async =>
      NcSession.fromJson(await _json('POST', '/v1/sessions/${Uri.encodeComponent(sessionId)}/heartbeat'));

  /// Lets the GPU go sooner (cost).
  Future<void> closeSession(String sessionId) async {
    await _json('DELETE', '/v1/sessions/${Uri.encodeComponent(sessionId)}');
  }

  // ------------------------------------------------------------ jobs

  /// Sends the terrain sketch (a PNG of dark strokes on light, tokens never
  /// included) with a Turkish [narrative] or an English [prompt].
  ///
  /// [regionsPng] is the optional region layer (painted areas in the contract
  /// colours, transparent elsewhere) and [ground] what fills the rest; both
  /// are sent only when given, and only when [sceneFeatures] says the service
  /// takes them (it refuses unknown inputs and parameters).
  Future<NcJob> submitScene({
    required Uint8List sketchPng,
    required SceneMode mode,
    String? narrative,
    String? prompt,
    String? negative,
    int? seed,
    Uint8List? regionsPng,
    String? ground,
  }) async {
    final text = narrative?.trim();
    final en = prompt?.trim();
    if ((text == null || text.isEmpty) == (en == null || en.isEmpty)) {
      throw ArgumentError('give exactly one of narrative or prompt');
    }
    if (text != null && text.length > maxNarrativeChars) throw ArgumentError('narrative is longer than $maxNarrativeChars');
    if (en != null && en.length > maxPromptChars) throw ArgumentError('prompt is longer than $maxPromptChars');
    if (negative != null && negative.length > maxNegativeChars) throw ArgumentError('negative is longer than $maxNegativeChars');
    if (sketchPng.length > maxSketchBytes) throw ArgumentError('sketch is larger than $maxSketchBytes bytes');
    if (regionsPng != null) {
      if (regionsPng.length > maxRegionsBytes) throw ArgumentError('regions is larger than $maxRegionsBytes bytes');
      if (!_isPng(regionsPng)) throw ArgumentError('regions is not a PNG');
    }
    if (ground != null) {
      if (!sceneGrounds.contains(ground)) throw ArgumentError('ground must be one of ${sceneGrounds.join(', ')}');
      if (regionsPng == null) throw ArgumentError('ground is only sent with regions');
    }
    final body = {
      'version': sketchToSceneVersion,
      'params': {
        'mode': mode.name,
        if (text != null && text.isNotEmpty) 'narrative': text,
        if (en != null && en.isNotEmpty) 'prompt': en,
        if (negative != null && negative.isNotEmpty) 'negative': negative,
        'seed': ?seed,
        'ground': ?ground,
      },
      'inputs': {
        'sketch': {'inline': base64Encode(sketchPng), 'contentType': 'image/png'},
        if (regionsPng != null) 'regions': {'inline': base64Encode(regionsPng), 'contentType': 'image/png'},
      },
    };
    final r = await _json('POST', '/v1/presets/sketch_to_scene/jobs', body: body);
    return NcJob.fromJson(r['job'] as Map<String, dynamic>);
  }

  Future<NcJob> getJob(String jobId) async =>
      NcJob.fromJson((await _json('GET', '/v1/jobs/${Uri.encodeComponent(jobId)}'))['job'] as Map<String, dynamic>);

  Future<void> cancelJob(String jobId) async {
    await _json('POST', '/v1/jobs/${Uri.encodeComponent(jobId)}/cancel');
  }

  /// Follows a job until it finishes: server-sent events, falling back to
  /// polling about once a second when the stream cannot be opened or breaks.
  /// The last event is always an [NcJobSnapshot] with a finished state.
  Stream<NcJobEvent> watchJob(String jobId) async* {
    var finished = false;
    try {
      await for (final e in _events(jobId)) {
        yield e;
        if (e is NcJobSnapshot && e.job.state.isFinished) {
          finished = true;
          return;
        }
      }
    } on NcApiException catch (e) {
      // A real answer from the service (404, 401…): polling would not help.
      if (e.status != 406 && e.status < 500) rethrow;
    } on NcNetworkException {
      // fall back to polling below
    }
    if (finished) return;
    var failures = 0;
    while (true) {
      final NcJob job;
      try {
        job = await getJob(jobId);
        failures = 0;
      } on NcNetworkException {
        // Polling is the fallback for a shaky network: back off and retry.
        if (++failures > pollRetries) rethrow;
        await Future<void>.delayed(pollInterval * (1 << (failures - 1)));
        continue;
      }
      yield NcJobSnapshot(job);
      if (job.state.isFinished) return;
      await Future<void>.delayed(pollInterval);
    }
  }

  Stream<NcJobEvent> _events(String jobId) async* {
    final res = await _sendAuthed(() => http.Request('GET', config.uri('/v1/jobs/${Uri.encodeComponent(jobId)}/events'))
      ..headers['Accept'] = 'text/event-stream');
    if (res.statusCode != 200) {
      final body = await res.stream.bytesToString().catchError((_) => '');
      throw ncErrorFrom(res.statusCode, body);
    }
    if (!(res.headers['content-type'] ?? '').contains('text/event-stream')) {
      throw const NcNetworkException('events: not an event stream');
    }
    final data = StringBuffer();
    try {
      // Pings are lines too, so a live stream is never idle this long.
      final lines = res.stream.transform(utf8.decoder).transform(const LineSplitter()).timeout(eventIdleTimeout);
      await for (final line in lines) {
        if (line.isEmpty) {
          if (data.isNotEmpty) {
            final e = parseEvent(data.toString());
            data.clear();
            if (e != null) yield e;
          }
        } else if (line.startsWith(':')) {
          // ping
        } else if (line.startsWith('data:')) {
          if (data.isNotEmpty) data.write('\n');
          data.write(line.substring(line.startsWith('data: ') ? 6 : 5));
        }
      }
    } on Object catch (e) {
      throw NcNetworkException('events stream: $e');
    }
    if (data.isNotEmpty) {
      final e = parseEvent(data.toString());
      if (e != null) yield e;
    }
    // The stream ended without a final snapshot: let the caller poll.
    throw const NcNetworkException('events stream ended early');
  }

  /// One `data:` payload → an event; unknown or broken payloads are skipped.
  static NcJobEvent? parseEvent(String data) {
    final Object? m;
    try {
      m = jsonDecode(data);
    } on FormatException {
      return null;
    }
    if (m is! Map<String, dynamic>) return null;
    return switch (m['type']) {
      'job' when m['job'] is Map<String, dynamic> => NcJobSnapshot(NcJob.fromJson(m['job'] as Map<String, dynamic>)),
      'state' => NcJobStateChanged(NcJobState.parse(m['state'] as String?)),
      'progress' when m['progress'] is Map<String, dynamic> => NcJobProgressed(NcProgress.fromJson(m['progress'] as Map<String, dynamic>)),
      _ => null,
    };
  }

  // ------------------------------------------------------------ assets

  /// Downloads a result. The service answers with a redirect to a signed
  /// storage URL; it is followed here by hand so the access token is only
  /// ever sent to NeuraCraft, never to the storage provider.
  Future<Uint8List> downloadAsset(String assetId) async {
    var res = await _sendAuthed(() => http.Request('GET', config.uri('/v1/assets/${Uri.encodeComponent(assetId)}/content'))
      ..followRedirects = false);
    if (res.isRedirect || const {301, 302, 303, 307, 308}.contains(res.statusCode)) {
      await res.stream.drain<void>();
      final location = res.headers['location'];
      if (location == null) throw const NcNetworkException('content: redirect without a location');
      final target = config.uri('/').resolve(location);
      res = await _sendStreamed(http.Request('GET', target));
    }
    final bytes = await res.stream.toBytes().timeout(timeout, onTimeout: () => throw const NcNetworkException('content: timeout'));
    if (res.statusCode != 200) throw ncErrorFrom(res.statusCode, utf8.decode(bytes, allowMalformed: true));
    return bytes;
  }

  /// Reports a picture; the service then hides it for everyone.
  Future<void> report(String assetId, ReportReason reason, {String? note}) async {
    final n = note?.trim();
    if (n != null && n.length > maxReportNoteChars) throw ArgumentError('note is longer than $maxReportNoteChars');
    await _json('POST', '/v1/assets/${Uri.encodeComponent(assetId)}/report', body: {
      'reason': reason.wire,
      if (n != null && n.isNotEmpty) 'note': n,
    });
  }

  /// What the service's `sketch_to_scene` takes beyond the sketch (the region
  /// layer and `ground`), read from `GET /v1/presets` once per client (the
  /// client lives as long as the sign-in and configuration do). The region
  /// layer was agreed in neuracraft-cloud #42 before the server had it, so the
  /// app sends it only once the preset advertises it: an `inputs` entry named
  /// `regions` and, for the ground, a `ground` parameter. Anything unexpected
  /// (an unknown shape, an older preset) means "not supported", which is
  /// cached; a failed request is not cached, so the next call asks again.
  Future<NcSceneFeatures> sceneFeatures() => _features ??= _loadFeatures();
  Future<NcSceneFeatures>? _features;

  Future<NcSceneFeatures> _loadFeatures() async {
    try {
      return NcSceneFeatures.fromPresets(await _json('GET', '/v1/presets'), minVersion: sketchToSceneVersion);
    } on Object {
      _features = null;
      return NcSceneFeatures.none;
    }
  }

  static bool _isPng(Uint8List b) =>
      b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47 && b[4] == 0x0D && b[5] == 0x0A && b[6] == 0x1A && b[7] == 0x0A;

  /// Whether the service offers `sketch_to_scene` at a version this app knows.
  Future<bool> supportsSketchToScene() async {
    final r = await _json('GET', '/v1/presets');
    for (final p in (r['presets'] as List? ?? const [])) {
      if (p is Map<String, dynamic> && p['id'] == 'sketch_to_scene') {
        final v = (p['version'] as num?)?.round() ?? 0;
        return v >= sketchToSceneVersion;
      }
    }
    return false;
  }

  // ------------------------------------------------------------ plumbing

  Future<http.StreamedResponse> _sendStreamed(http.BaseRequest req) async {
    try {
      return await _http.send(req).timeout(timeout);
    } on Object catch (e) {
      throw NcNetworkException('${req.method} ${req.url.path}: $e');
    }
  }

  /// Sends a request built by [build] with the access token. On
  /// `401 auth.token_expired` the token is refreshed (one refresh shared by
  /// all callers) and the request sent once more; on `auth.token_revoked` or
  /// `auth.end_user_blocked` the sign-in ends. Other answers, errors included,
  /// are returned as they are.
  Future<http.StreamedResponse> _sendAuthed(http.BaseRequest Function() build) async {
    var retried = false;
    while (true) {
      final token = await auth.accessToken();
      final req = build()..headers['Authorization'] = 'Bearer $token';
      final res = await _sendStreamed(req);
      if (res.statusCode != 401 && res.statusCode != 403) return res;
      final String text;
      try {
        text = await res.stream.bytesToString().timeout(timeout);
      } on Object catch (e) {
        throw NcNetworkException('${req.method} ${req.url.path}: $e');
      }
      final e = ncErrorFrom(res.statusCode, text);
      if (e is NcApiException) {
        if (e.code == 'auth.token_expired' && !retried) {
          retried = true;
          await auth.refreshAfterExpired(token);
          continue;
        }
        await auth.rejected(e, accessToken: token);
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>> _json(String method, String path, {Object? body}) async {
    final res = await _sendAuthed(() {
      final req = http.Request(method, config.uri(path))..headers['Accept'] = 'application/json';
      if (body != null) {
        req.headers['Content-Type'] = 'application/json';
        req.body = jsonEncode(body);
      }
      return req;
    });
    final String text;
    try {
      text = await res.stream.bytesToString().timeout(timeout);
    } on Object catch (e) {
      throw NcNetworkException('$method $path: $e');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) throw ncErrorFrom(res.statusCode, text);
    if (text.isEmpty) return const {};
    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      throw NcNetworkException('$method $path: not JSON');
    }
  }
}
