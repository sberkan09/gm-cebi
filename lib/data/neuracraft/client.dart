/// HTTP client for NeuraCraft Cloud's sketch-to-scene API
/// (neuracraft-cloud docs/partners/gm-cebi.md). The UI never calls HTTP
/// directly; it goes through this class.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

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
const maxReportNoteChars = 500;

class NeuraCraftClient {
  NeuraCraftClient({
    required http.Client httpClient,
    required this.config,
    required this.endUser,
    this.timeout = const Duration(seconds: 20),
    this.pollInterval = const Duration(seconds: 1),
  }) : _http = httpClient;

  final http.Client _http;
  final NcConfig config;

  /// The install id (`X-End-User`), read on every request so a reset takes
  /// effect at once.
  final String Function() endUser;

  /// Per request (a job's whole wait is bounded by the caller).
  final Duration timeout;

  /// Polling period when server-sent events are not available.
  final Duration pollInterval;

  Map<String, String> get _auth => {
        'Authorization': 'Bearer ${config.appToken}',
        'X-End-User': endUser(),
      };

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
  Future<NcJob> submitScene({
    required Uint8List sketchPng,
    required SceneMode mode,
    String? narrative,
    String? prompt,
    String? negative,
    int? seed,
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
    final body = {
      'version': sketchToSceneVersion,
      'params': {
        'mode': mode.name,
        if (text != null && text.isNotEmpty) 'narrative': text,
        if (en != null && en.isNotEmpty) 'prompt': en,
        if (negative != null && negative.isNotEmpty) 'negative': negative,
        'seed': ?seed,
      },
      'inputs': {
        'sketch': {'inline': base64Encode(sketchPng), 'contentType': 'image/png'},
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
    while (true) {
      final job = await getJob(jobId);
      yield NcJobSnapshot(job);
      if (job.state.isFinished) return;
      await Future<void>.delayed(pollInterval);
    }
  }

  Stream<NcJobEvent> _events(String jobId) async* {
    final req = http.Request('GET', config.uri('/v1/jobs/${Uri.encodeComponent(jobId)}/events'))
      ..headers.addAll({..._auth, 'Accept': 'text/event-stream'});
    final http.StreamedResponse res;
    try {
      res = await _http.send(req).timeout(timeout);
    } on Object catch (e) {
      throw NcNetworkException('events: $e');
    }
    if (res.statusCode != 200) {
      final body = await res.stream.bytesToString().catchError((_) => '');
      throw _apiError(res.statusCode, body);
    }
    if (!(res.headers['content-type'] ?? '').contains('text/event-stream')) {
      throw const NcNetworkException('events: not an event stream');
    }
    final data = StringBuffer();
    try {
      await for (final line in res.stream.transform(utf8.decoder).transform(const LineSplitter())) {
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
  /// storage URL; it is followed here by hand so the app token and install
  /// id are only ever sent to NeuraCraft, never to the storage provider.
  Future<Uint8List> downloadAsset(String assetId) async {
    final first = http.Request('GET', config.uri('/v1/assets/${Uri.encodeComponent(assetId)}/content'))
      ..headers.addAll(_auth)
      ..followRedirects = false;
    var res = await _sendStreamed(first);
    if (res.isRedirect || const {301, 302, 303, 307, 308}.contains(res.statusCode)) {
      await res.stream.drain<void>();
      final location = res.headers['location'];
      if (location == null) throw const NcNetworkException('content: redirect without a location');
      final target = config.uri('/').resolve(location);
      res = await _sendStreamed(http.Request('GET', target));
    }
    final bytes = await res.stream.toBytes().timeout(timeout, onTimeout: () => throw const NcNetworkException('content: timeout'));
    if (res.statusCode != 200) throw _apiError(res.statusCode, utf8.decode(bytes, allowMalformed: true));
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

  Future<Map<String, dynamic>> _json(String method, String path, {Object? body}) async {
    final req = http.Request(method, config.uri(path))..headers.addAll({..._auth, 'Accept': 'application/json'});
    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    final res = await _sendStreamed(req);
    final String text;
    try {
      text = await res.stream.bytesToString().timeout(timeout);
    } on Object catch (e) {
      throw NcNetworkException('$method $path: $e');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) throw _apiError(res.statusCode, text);
    if (text.isEmpty) return const {};
    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      throw NcNetworkException('$method $path: not JSON');
    }
  }

  /// `{"error": {"code", "params"}}` → [NcApiException]; anything else
  /// (a proxy page, an empty 502) → [NcNetworkException] for 5xx.
  static NcException _apiError(int status, String body) {
    try {
      final m = jsonDecode(body);
      final err = m is Map<String, dynamic> ? m['error'] : null;
      if (err is Map<String, dynamic> && err['code'] is String) {
        final params = err['params'];
        return NcApiException(status, err['code'] as String, params is Map<String, dynamic> ? params : const {});
      }
    } on FormatException {
      // not JSON
    }
    if (status >= 500) return NcNetworkException('HTTP $status');
    return NcApiException(status, 'http_$status');
  }
}
