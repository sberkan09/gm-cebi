/// Sends the map's terrain sketch to NeuraCraft Cloud, waits for the picture
/// and keeps it with the encounter (docs/partners/gm-cebi.md, "Flow").
///
/// Retry rules:
/// - `session.closed` → a new session, the request once more;
/// - `limit.concurrent_jobs` / `rate_limited` → wait a few seconds, at most twice;
/// - a job that fails with an unexpected code → once more with a new seed, then
///   give up quietly;
/// - `content.flagged` / `content.unchecked` → tell the user, never charged.
library;

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/neuracraft/client.dart';
import '../../data/neuracraft/errors.dart';
import '../../data/neuracraft/models.dart';
import '../../db/database.dart';
import '../../providers.dart';
import '../map_sketch.dart';
import 'messages.dart';
import 'online_settings.dart';
import 'session_controller.dart';

enum ScenePhase {
  /// Encoding and sending the sketch.
  sending,

  /// In the queue (a GPU may be starting).
  queued,
  running,
  downloading,
}

@immutable
sealed class SceneJobState {
  const SceneJobState();
}

class SceneIdle extends SceneJobState {
  const SceneIdle();
}

class SceneWorking extends SceneJobState {
  const SceneWorking(this.phase, {this.jobId, this.progress});
  final ScenePhase phase;
  final String? jobId;

  /// 0..1, null when unknown.
  final double? progress;
}

class SceneFailed extends SceneJobState {
  const SceneFailed(this.message, {this.retryable = true, this.quiet = false});
  final String message;

  /// "Yeniden dene" makes sense (not for a dead token or a used-up quota).
  final bool retryable;

  /// The service failed twice for no reason we can name: say little.
  final bool quiet;
}

/// The terrain sketch of the active encounter as PNG (tokens never included).
typedef SketchExporter = Future<Uint8List?> Function();

final sketchExporterProvider = Provider<SketchExporter>((ref) => () async {
      final strokes = await ref.read(databaseProvider).watchStrokes().first;
      if (strokes.isEmpty) return null;
      return renderTerrainPng([for (final s in strokes) SketchStroke(s.offsets, s.color)]);
    });

/// Overridden in tests for repeatable seeds.
final sceneRandomProvider = Provider<Random>((ref) => Random.secure());

class SceneController extends Notifier<SceneJobState> {
  static const jobTimeout = Duration(minutes: 4);
  /// Shortened in tests.
  static Duration retrySoonDelay = const Duration(seconds: 3);

  /// Retrying cannot help: a dead token, a used-up quota, a refused text, a bug.
  static const _notRetryable = {
    NcReaction.authInvalid,
    NcReaction.dailyQuota,
    NcReaction.allowanceExhausted,
    NcReaction.bug,
    NcReaction.textRefused,
  };

  StreamSubscription<NcJobEvent>? _watch;

  /// The wait in progress, finished by [cancel] so [generate] never hangs.
  Completer<NcJob>? _pending;
  String? _jobId;
  int _generation = 0;
  ({SceneMode mode, String narrative})? _last;

  @override
  SceneJobState build() {
    ref.onDispose(() => _watch?.cancel());
    return const SceneIdle();
  }

  bool get busy => state is SceneWorking;

  /// Makes a picture from the current sketch. [narrative] is the GM's Turkish
  /// description (≤ 500 characters, may be empty: a generic battle-map prompt
  /// is sent then).
  Future<void> generate({required SceneMode mode, required String narrative}) async {
    if (busy) return;
    _last = (mode: mode, narrative: narrative);
    final gen = ++_generation;
    final client = ref.read(ncClientProvider);
    if (client == null) return;
    state = const SceneWorking(ScenePhase.sending);
    // The service counts UTF-16 units (JavaScript length), as Dart's length
    // does; a text field counts characters, so emoji could slip past it.
    if (narrative.trim().length > maxNarrativeChars) {
      state = const SceneFailed('Tarif çok uzun; en çok $maxNarrativeChars karakter olabilir.', retryable: false);
      return;
    }
    try {
      // The picture belongs to the encounter whose sketch is sent, even if a
      // new encounter starts while it is being made.
      final encounterId = (await ref.read(databaseProvider).activeEncounter()).id;
      final png = await ref.read(sketchExporterProvider)();
      if (png == null) {
        state = const SceneFailed('Önce haritaya araziyi çiz.', retryable: false);
        return;
      }
      await ref.read(onlineSessionProvider.notifier).ensureOpen();
      var autoRetried = false;
      while (true) {
        final seed = ref.read(sceneRandomProvider).nextInt(1 << 31);
        final job = await _submit(client, png, mode, narrative, seed);
        if (gen != _generation) {
          // Cancelled while the sketch was on its way: stop the job too, so
          // it neither runs nor counts against the daily quota.
          unawaited(client.cancelJob(job.id).catchError((_) {}));
          return;
        }
        _jobId = job.id;
        state = SceneWorking(ScenePhase.queued, jobId: job.id);
        final done = await _wait(client, job.id, gen);
        if (gen != _generation) return;
        if (done.state == NcJobState.succeeded && done.outputs.isNotEmpty) {
          state = SceneWorking(ScenePhase.downloading, jobId: job.id);
          final out = done.outputs.first;
          final bytes = await client.downloadAsset(out.assetId);
          if (gen != _generation) return;
          await ref.read(databaseProvider).addScene(
              assetId: out.assetId, png: bytes, mode: mode.name, narrative: narrative.trim(), seed: seed, encounterId: encounterId);
          state = const SceneIdle();
          return;
        }
        if (done.state == NcJobState.cancelled) {
          state = const SceneIdle();
          return;
        }
        final failure = NcJobFailed(done.errorCode);
        if (failure.flagged || failure.unchecked) throw failure;
        if (autoRetried) {
          state = SceneFailed(messageFor(failure), quiet: true);
          return;
        }
        autoRetried = true; // a service error: once more with a new seed
      }
    } on NcException catch (e) {
      if (gen != _generation) return;
      if (e.reaction == NcReaction.authInvalid) ref.read(onlineSessionProvider.notifier).authRejected();
      if (e is NcApiException && e.reaction == NcReaction.bug) debugPrint('NeuraCraft rejected the request: ${e.code} ${e.params}');
      state = SceneFailed(messageFor(e), retryable: !_notRetryable.contains(e.reaction));
    } on TimeoutException {
      if (gen != _generation) return;
      unawaited(_cancelOnServer(client));
      state = SceneFailed(messageForReaction(NcReaction.offline));
    } catch (e, st) {
      // Anything else (unexpected JSON, a database error…): never leave the
      // map stuck on "sending".
      debugPrint('scene generation failed: $e\n$st');
      if (gen != _generation) return;
      state = SceneFailed(messageForReaction(NcReaction.bug), retryable: false);
    } finally {
      if (gen == _generation) _jobId = null;
    }
  }

  /// "Yeniden dene": the same mode and description with a new seed.
  Future<void> retry() async {
    final l = _last;
    if (l != null) await generate(mode: l.mode, narrative: l.narrative);
  }

  /// The user gave up waiting.
  Future<void> cancel() async {
    final client = ref.read(ncClientProvider);
    _generation++;
    // Not awaited: cancelling a stream that never closes can wait forever,
    // and the cancel button must not.
    final w = _watch;
    _watch = null;
    if (w != null) unawaited(w.cancel());
    final pending = _pending;
    if (pending != null && !pending.isCompleted) pending.complete(NcJob(id: _jobId ?? '', state: NcJobState.cancelled));
    state = const SceneIdle();
    if (client != null) await _cancelOnServer(client);
  }

  void dismissError() {
    if (state is SceneFailed) state = const SceneIdle();
  }

  Future<void> _cancelOnServer(NeuraCraftClient client) async {
    final id = _jobId;
    _jobId = null;
    if (id != null) await client.cancelJob(id).catchError((_) {});
  }

  Future<NcJob> _submit(NeuraCraftClient client, Uint8List png, SceneMode mode, String narrative, int seed) async {
    var sessionRetried = false;
    var busyRetries = 0;
    final text = narrative.trim();
    while (true) {
      try {
        return await client.submitScene(
          sketchPng: png,
          mode: mode,
          narrative: text.isEmpty ? null : text,
          prompt: text.isEmpty ? 'top-down fantasy battle map, tabletop RPG map, detailed painted texture' : null,
          seed: seed,
        );
      } on NcApiException catch (e) {
        if (e.reaction == NcReaction.sessionClosed && !sessionRetried) {
          sessionRetried = true;
          await ref.read(onlineSessionProvider.notifier).sessionClosed();
          continue;
        }
        if (e.reaction == NcReaction.retrySoon && busyRetries < 2) {
          busyRetries++;
          await Future<void>.delayed(retrySoonDelay);
          continue;
        }
        rethrow;
      }
    }
  }

  Future<NcJob> _wait(NeuraCraftClient client, String jobId, int gen) {
    final done = _pending = Completer<NcJob>();
    _watch = client.watchJob(jobId).timeout(jobTimeout).listen(
      (e) {
        if (gen != _generation) return;
        switch (e) {
          case NcJobSnapshot(:final job):
            if (job.state.isFinished) {
              if (!done.isCompleted) done.complete(job);
            } else {
              state = SceneWorking(job.state == NcJobState.queued ? ScenePhase.queued : ScenePhase.running, jobId: jobId, progress: job.progress?.overall);
            }
          case NcJobStateChanged(:final state):
            if (!state.isFinished) this.state = SceneWorking(state == NcJobState.queued ? ScenePhase.queued : ScenePhase.running, jobId: jobId);
          case NcJobProgressed(:final progress):
            state = SceneWorking(ScenePhase.running, jobId: jobId, progress: progress.overall);
        }
      },
      onError: (Object e) {
        if (!done.isCompleted) done.completeError(e);
      },
      onDone: () {
        if (!done.isCompleted) done.completeError(const NcNetworkException('job stream ended'));
      },
      cancelOnError: true,
    );
    return done.future;
  }
}

final sceneControllerProvider = NotifierProvider<SceneController, SceneJobState>(SceneController.new);

/// The picture shown under the active encounter's map, if any. The query
/// joins encounters, so it re-emits on every turn; `distinct` (equality by
/// id) keeps that from rebuilding anything.
final activeSceneProvider = StreamProvider<MapSceneView?>((ref) => ref
    .watch(databaseProvider)
    .watchActiveScene()
    .map((s) => s == null ? null : MapSceneView(id: s.id, assetId: s.assetId, png: s.png, mode: s.mode, narrative: s.narrative))
    .distinct());

/// Id of the picture shown under the map (null: none).
final activeSceneIdProvider = Provider<int?>((ref) => ref.watch(activeSceneProvider.select((s) => s.value?.id)));

/// A scene's picture decoded for painting, per scene id. autoDispose: the
/// image is freed only once nothing watches that id any more, i.e. after
/// the map has moved on to another id (whose entry starts empty), so a freed
/// image is never painted.
final sceneImageProvider = FutureProvider.autoDispose.family<ui.Image?, int>((ref, id) async {
  final row = await (ref.read(databaseProvider).select(ref.read(databaseProvider).mapScenes)..where((s) => s.id.equals(id))).getSingleOrNull();
  if (row == null) return null;
  final codec = await ui.instantiateImageCodec(row.png);
  final image = (await codec.getNextFrame()).image;
  codec.dispose();
  if (!ref.mounted) {
    image.dispose();
    return null;
  }
  ref.onDispose(image.dispose);
  return image;
});

@immutable
class MapSceneView {
  const MapSceneView({required this.id, required this.assetId, required this.png, required this.mode, required this.narrative});
  final int id;
  final String assetId;
  final Uint8List png;
  final String mode;
  final String narrative;

  /// A stored scene never changes; its id identifies it.
  @override
  bool operator ==(Object other) => other is MapSceneView && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

/// Reports a picture: hidden locally at once, sent to the service when
/// possible. Returns null on success, or the message to show.
Future<String?> reportScene(AppDatabase db, NeuraCraftClient? client, MapSceneView scene, ReportReason reason, {String? note}) async {
  await db.hideScene(scene.id);
  if (client == null) return null;
  var n = note?.trim();
  if (n != null && n.length > maxReportNoteChars) n = n.substring(0, maxReportNoteChars);
  try {
    await client.report(scene.assetId, reason, note: n);
    return null;
  } on NcException catch (e) {
    // Hidden here anyway; the server deletes it within 7 days.
    return e.reaction == NcReaction.notFound ? null : 'Resim gizlendi, ama bildirim gönderilemedi.';
  } catch (_) {
    return 'Resim gizlendi, ama bildirim gönderilemedi.';
  }
}
