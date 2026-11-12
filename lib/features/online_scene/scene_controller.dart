/// Sends the map's terrain sketch to NeuraCraft Cloud, waits for the picture
/// and keeps it with the encounter (docs/partners/gm-cebi.md, "Flow").
///
/// Retry rules:
/// - `session.closed` → a new session, the request once more;
/// - `limit.concurrent_jobs` / `rate_limited` → wait a few seconds, at most twice;
/// - a job that fails with an unexpected code → once more with a new seed, then
///   give up quietly;
/// - `content.flagged` / `content.unchecked` → tell the user, never charged;
/// - a job that has no picture [SceneController.jobDeadline] after it was
///   accepted → cancelled on the server, the user may try again;
/// - a picture that was made but could not be downloaded → "Yeniden dene"
///   downloads it again (a new job would count against the quota again).
///
/// Sketch: the pen lines. A map with painted areas only is sent as a blank
/// sketch with the region layer, when the service takes the layer.
///
/// Region layer (neuracraft-cloud #42): in map mode, areas painted with the
/// "Alan" brush go as a second PNG (`inputs.regions`) with the chosen
/// `params.ground`, but only when `GET /v1/presets` says the service takes
/// them ([NeuraCraftClient.sceneFeatures]); otherwise the sketch goes alone,
/// exactly as before.
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

  /// "Yeniden dene" makes sense (not when signed out or a quota is used up).
  final bool retryable;

  /// The service failed twice for no reason we can name: say little.
  final bool quiet;
}

/// The terrain sketch of the active encounter as PNG (tokens never included).
typedef SketchExporter = Future<Uint8List?> Function();

/// The pen lines only; null when none are drawn. Painted areas never reach
/// the sketch.
final sketchExporterProvider = Provider<SketchExporter>((ref) => () async {
      final lines = lineStrokesOf(await ref.read(databaseProvider).watchStrokes().first);
      if (lines.isEmpty) return null;
      return renderTerrainPng(lines);
    });

/// A blank sketch (white, the size of the region layer): what goes with the
/// regions when the map has painted areas but no pen line.
final blankSketchExporterProvider = Provider<Future<Uint8List> Function()>((ref) => () => renderTerrainPng(const []));

/// The region layer of the active encounter (areas painted with the "Alan"
/// brush); null when nothing is painted. Throws [RegionsTooLarge].
final regionsExporterProvider = Provider<SketchExporter>((ref) => () async {
      final regions = regionStrokesOf(await ref.read(databaseProvider).watchStrokes().first);
      return renderRegionsPng(regions);
    });

/// Overridden in tests for repeatable seeds.
final sceneRandomProvider = Provider<Random>((ref) => Random.secure());

/// A picture the service made that is not on the device yet.
typedef _Picture = ({String assetId, String? jobId, SceneMode mode, String narrative, int seed, int encounterId});

/// The job ran past [SceneController.jobDeadline].
class _JobDeadlineExceeded implements Exception {
  const _JobDeadlineExceeded();
}

class SceneController extends Notifier<SceneJobState> {
  /// The longest silence between two events of a job. Per event: polling
  /// yields one a second, so on its own this never ends a job that just stays
  /// queued. [jobDeadline] does.
  static const jobTimeout = Duration(minutes: 4);

  /// The whole wait for one job, from accepted to finished (a warm GPU needs
  /// seconds, a cold one about two minutes). After it the job is cancelled.
  static const jobDeadline = Duration(minutes: 4);

  /// Shortened in tests.
  static Duration retrySoonDelay = const Duration(seconds: 3);

  /// Retrying cannot help: signed out, blocked, an outdated build, a used-up
  /// quota, a refused text, a bug.
  static const _notRetryable = {
    NcReaction.authInvalid,
    NcReaction.signInRequired,
    NcReaction.blocked,
    NcReaction.dailyQuota,
    NcReaction.partnerDailyQuota,
    NcReaction.allowanceExhausted,
    NcReaction.bug,
    NcReaction.textRefused,
  };

  StreamSubscription<NcJobEvent>? _watch;

  /// The wait in progress, finished by [cancel] so [generate] never hangs.
  Completer<NcJob>? _pending;
  String? _jobId;
  int _generation = 0;
  ({SceneMode mode, String narrative, String? ground})? _last;

  /// A finished job's picture whose download failed: [retry] fetches it
  /// again instead of starting (and paying for) a new job.
  _Picture? _undelivered;

  /// The ground of the last request (for "Yeniden dene" from the picture's menu).
  String? get lastGround => _last?.ground;

  @override
  SceneJobState build() {
    ref.onDispose(() => _watch?.cancel());
    return const SceneIdle();
  }

  bool get busy => state is SceneWorking;

  /// Nothing is sent while the feature is switched off or before the user's
  /// consent (the UI does not offer it then; this is the second lock).
  bool get _allowed => ref.read(onlineFeatureVisibleProvider) && (ref.read(onlineSettingsProvider).value?.consented ?? false);

  /// Makes a picture from the current sketch. [narrative] is the GM's Turkish
  /// description (≤ 500 characters, may be empty: a generic battle-map prompt
  /// is sent then). [ground] (`grass`, `stone`…) fills what is not painted;
  /// it goes only with the region layer.
  ///
  /// A map without pen lines but with painted areas goes as a blank sketch
  /// with the region layer, in map mode, when the service takes the layer.
  Future<void> generate({required SceneMode mode, required String narrative, String? ground}) async {
    if (busy || !_allowed) return;
    _last = (mode: mode, narrative: narrative, ground: ground);
    _undelivered = null;
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
      var png = await ref.read(sketchExporterProvider)();
      final regions = png == null || mode == SceneMode.map ? await ref.read(regionsExporterProvider)() : null;
      final ({Uint8List regions, String? ground})? extra;
      if (png != null) {
        await ref.read(onlineSessionProvider.notifier).ensureOpen();
        extra = await _regionLayer(client, mode, ground, regions);
      } else {
        // No pen line. Painted areas alone can go, as the region layer over a
        // blank sketch; asked before a session (a GPU) is opened for nothing.
        final reason = regions == null ? drawFirstMessage : (mode == SceneMode.map ? null : linesNeededForAtmosphereMessage);
        extra = reason == null ? await _regionLayer(client, mode, ground, regions) : null;
        if (extra == null) {
          if (gen == _generation) state = SceneFailed(reason ?? linesNeededMessage, retryable: false);
          return;
        }
        png = await ref.read(blankSketchExporterProvider)();
        await ref.read(onlineSessionProvider.notifier).ensureOpen();
      }
      var autoRetried = false;
      while (true) {
        final seed = ref.read(sceneRandomProvider).nextInt(1 << 31);
        final job = await _submit(client, png, mode, narrative, seed, extra);
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
          await _deliver(
              client,
              (assetId: done.outputs.first.assetId, jobId: job.id, mode: mode, narrative: narrative.trim(), seed: seed, encounterId: encounterId),
              gen);
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
      _failed(e);
    } on RegionsTooLarge {
      if (gen != _generation) return;
      state = const SceneFailed('Boyanan alanlar gönderilemeyecek kadar büyük; birkaçını silip yeniden dene.', retryable: false);
    } on TimeoutException {
      if (gen != _generation) return;
      unawaited(_cancelOnServer(client));
      state = SceneFailed(messageForReaction(NcReaction.offline));
    } on _JobDeadlineExceeded {
      // The service answers but the picture does not come (a job stuck in the
      // queue): stop it there too, and let the user try again.
      if (gen != _generation) return;
      unawaited(_cancelOnServer(client));
      state = SceneFailed(messageForReaction(NcReaction.busy));
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

  /// "Yeniden dene": a picture that was made but not downloaded is fetched
  /// again; otherwise the same mode and description with a new seed.
  Future<void> retry() async {
    if (busy) return;
    final waiting = _undelivered;
    if (waiting != null && await _fetchAgain(waiting)) return;
    final l = _last;
    if (l != null) await generate(mode: l.mode, narrative: l.narrative, ground: l.ground);
  }

  /// Downloads [p] and keeps it with its encounter. A failed download leaves
  /// it in [_undelivered] when trying again can help.
  Future<void> _deliver(NeuraCraftClient client, _Picture p, int gen) async {
    state = SceneWorking(ScenePhase.downloading, jobId: p.jobId);
    final Uint8List bytes;
    try {
      bytes = await client.downloadAsset(p.assetId);
    } on NcException catch (e) {
      if (gen == _generation) _undelivered = e.reaction == NcReaction.notFound || _notRetryable.contains(e.reaction) ? null : p;
      rethrow;
    }
    if (gen != _generation) return;
    _undelivered = null;
    await ref
        .read(databaseProvider)
        .addScene(assetId: p.assetId, png: bytes, mode: p.mode.name, narrative: p.narrative, seed: p.seed, encounterId: p.encounterId);
    state = const SceneIdle();
  }

  /// True when [p] was dealt with (downloaded, or failed again with its
  /// message); false when the service no longer has it: then a new job.
  Future<bool> _fetchAgain(_Picture p) async {
    final client = ref.read(ncClientProvider);
    if (client == null || !_allowed) return true;
    final gen = ++_generation;
    try {
      await _deliver(client, p, gen);
    } on NcException catch (e) {
      if (gen != _generation) return true;
      if (e.reaction == NcReaction.notFound) {
        state = const SceneIdle();
        return false;
      }
      _failed(e);
    } catch (e, st) {
      debugPrint('scene download failed: $e\n$st');
      if (gen == _generation) state = SceneFailed(messageForReaction(NcReaction.bug), retryable: false);
    }
    return true;
  }

  void _failed(NcException e) {
    ref.read(onlineSessionProvider.notifier).accountRejected(e.reaction);
    if (e is NcApiException && e.reaction == NcReaction.bug) debugPrint('NeuraCraft rejected the request: ${e.code} ${e.params}');
    state = SceneFailed(messageFor(e), retryable: !_notRetryable.contains(e.reaction));
  }

  /// The user gave up waiting.
  Future<void> cancel() async {
    final client = ref.read(ncClientProvider);
    _generation++;
    _undelivered = null;
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

  /// The region layer and ground to send, or null: atmosphere mode, nothing
  /// painted, or a service that does not take them yet (then the sketch goes
  /// alone, as before). The ground is sent only if the service lists it.
  Future<({Uint8List regions, String? ground})?> _regionLayer(NeuraCraftClient client, SceneMode mode, String? ground, Uint8List? regions) async {
    if (mode != SceneMode.map || regions == null) return null;
    final features = await client.sceneFeatures();
    if (!features.regions) return null;
    return (regions: regions, ground: features.grounds.contains(ground) ? ground : null);
  }

  Future<NcJob> _submit(NeuraCraftClient client, Uint8List png, SceneMode mode, String narrative, int seed,
      ({Uint8List regions, String? ground})? extra) async {
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
          regionsPng: extra?.regions,
          ground: extra?.ground,
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
    late final StreamSubscription<NcJobEvent> watch;
    final deadline = Timer(jobDeadline, () {
      if (done.isCompleted) return;
      // Not awaited (see [cancel]); stops the polling too.
      unawaited(watch.cancel());
      if (identical(_watch, watch)) _watch = null;
      done.completeError(const _JobDeadlineExceeded());
    });
    _watch = watch = client.watchJob(jobId).timeout(jobTimeout).listen(
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
    return done.future.whenComplete(deadline.cancel);
  }
}

final sceneControllerProvider = NotifierProvider<SceneController, SceneJobState>(SceneController.new);

/// What the service takes beyond the sketch (the region layer, the ground);
/// [NcSceneFeatures.none] offline, signed out or before it answers, and
/// (without asking) while the feature is off or before consent. The client
/// caches the answer, so reopening the sheet does not ask again.
final sceneFeaturesProvider = FutureProvider.autoDispose<NcSceneFeatures>((ref) async {
  if (!ref.watch(onlineFeatureActiveProvider)) return NcSceneFeatures.none;
  final client = ref.watch(ncClientProvider);
  return client == null ? NcSceneFeatures.none : client.sceneFeatures();
});

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
  // A reported picture is an emptied marker row: nothing to show.
  if (row == null || row.hidden || row.png.isEmpty) return null;
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
