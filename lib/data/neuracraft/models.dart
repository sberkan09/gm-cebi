/// NeuraCraft Cloud API shapes used by GM Cebi (neuracraft-cloud
/// docs/partners/gm-cebi.md). Unknown fields are ignored so the service can
/// add fields without breaking shipped apps.
library;

/// Whether a GPU can take a sketch now.
sealed class NcCapacity {
  const NcCapacity();

  factory NcCapacity.fromJson(Object? json) {
    final m = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    return switch (m['state']) {
      'ready' => const NcCapacityReady(),
      'warming' => NcCapacityWarming((m['etaSeconds'] as num?)?.round()),
      _ => NcCapacityUnavailable(m['reason'] as String?),
    };
  }
}

class NcCapacityReady extends NcCapacity {
  const NcCapacityReady();
  @override
  bool operator ==(Object other) => other is NcCapacityReady;
  @override
  int get hashCode => 1;
}

/// A GPU is starting; sketches sent now wait in the queue.
class NcCapacityWarming extends NcCapacity {
  const NcCapacityWarming(this.etaSeconds);
  final int? etaSeconds;
  @override
  bool operator ==(Object other) => other is NcCapacityWarming && other.etaSeconds == etaSeconds;
  @override
  int get hashCode => Object.hash(2, etaSeconds);
}

class NcCapacityUnavailable extends NcCapacity {
  const NcCapacityUnavailable(this.reason);
  final String? reason;
  @override
  bool operator ==(Object other) => other is NcCapacityUnavailable && other.reason == reason;
  @override
  int get hashCode => Object.hash(3, reason);
}

class NcSession {
  const NcSession({required this.id, required this.heartbeatSeconds, required this.capacity, this.endsAt});

  factory NcSession.fromJson(Map<String, dynamic> json) {
    final s = json['session'] as Map<String, dynamic>;
    return NcSession(
      id: s['id'] as String,
      heartbeatSeconds: (s['heartbeatSeconds'] as num?)?.round() ?? 120,
      endsAt: DateTime.tryParse(s['endsAt'] as String? ?? ''),
      capacity: NcCapacity.fromJson(json['capacity']),
    );
  }

  final String id;
  final int heartbeatSeconds;
  final DateTime? endsAt;
  final NcCapacity capacity;
}

enum NcJobState {
  queued,
  leased,
  running,
  succeeded,
  failed,
  cancelled;

  static NcJobState parse(String? s) => values.firstWhere((v) => v.name == s, orElse: () => queued);
  bool get isFinished => this == succeeded || this == failed || this == cancelled;
}

class NcProgress {
  const NcProgress({required this.step, required this.steps, this.fraction});

  factory NcProgress.fromJson(Map<String, dynamic> m) => NcProgress(
        step: (m['step'] as num?)?.round() ?? 0,
        steps: (m['steps'] as num?)?.round() ?? 0,
        fraction: switch ((m['fraction'] as num?)?.toDouble()) { final f? when f >= 0 => f, _ => null },
      );

  final int step;
  final int steps;

  /// 0..1 within the current step, null when unknown.
  final double? fraction;

  /// Overall 0..1, null when unknown.
  double? get overall {
    if (steps <= 0) return null;
    final within = fraction ?? 0;
    return ((step - 1).clamp(0, steps) + within) / steps;
  }
}

class NcOutput {
  const NcOutput({required this.name, required this.assetId, required this.bytes});

  factory NcOutput.fromJson(Map<String, dynamic> m) =>
      NcOutput(name: m['name'] as String? ?? '', assetId: m['assetId'] as String, bytes: (m['bytes'] as num?)?.round() ?? 0);

  final String name;
  final String assetId;
  final int bytes;
}

class NcJob {
  const NcJob({required this.id, required this.state, this.progress, this.outputs = const [], this.errorCode});

  factory NcJob.fromJson(Map<String, dynamic> m) => NcJob(
        id: m['id'] as String,
        state: NcJobState.parse(m['state'] as String?),
        progress: m['progress'] is Map<String, dynamic> ? NcProgress.fromJson(m['progress'] as Map<String, dynamic>) : null,
        outputs: [
          for (final o in (m['outputs'] as List? ?? const []))
            if (o is Map<String, dynamic> && o['assetId'] is String) NcOutput.fromJson(o),
        ],
        errorCode: (m['error'] as Map<String, dynamic>?)?['code'] as String?,
      );

  final String id;
  final NcJobState state;
  final NcProgress? progress;
  final List<NcOutput> outputs;

  /// For a failed job, e.g. `content.flagged`.
  final String? errorCode;

  NcJob copyWith({NcJobState? state, NcProgress? progress}) =>
      NcJob(id: id, state: state ?? this.state, progress: progress ?? this.progress, outputs: outputs, errorCode: errorCode);
}

/// One server-sent event of `GET /v1/jobs/{id}/events`, or a polled snapshot.
sealed class NcJobEvent {
  const NcJobEvent();
}

class NcJobSnapshot extends NcJobEvent {
  const NcJobSnapshot(this.job);
  final NcJob job;
}

class NcJobStateChanged extends NcJobEvent {
  const NcJobStateChanged(this.state);
  final NcJobState state;
}

class NcJobProgressed extends NcJobEvent {
  const NcJobProgressed(this.progress);
  final NcProgress progress;
}

/// What `sketch_to_scene` takes beyond the sketch, as `GET /v1/presets`
/// advertises it. The listing looks like:
///
/// ```json
/// {"presets": [{"id": "sketch_to_scene", "version": 1, "oldestVersion": 1, "description": "…",
///   "latency": "interactive",
///   "params": {"mode": {"type": "enum", "options": ["map", "atmosphere"], "required": true, "doc": "…"},
///              "ground": {"type": "enum", "options": ["grass", "stone", …], "default": "grass", "doc": "…"}, …},
///   "inputs": [{"name": "sketch", "doc": "…", "contentTypes": ["image/png"], "maxBytes": 524288, "maxSide": 1024},
///              {"name": "regions", …}]}]}
/// ```
///
/// The service refuses inputs and parameters it does not list, so only what
/// is listed by name is sent.
class NcSceneFeatures {
  const NcSceneFeatures({this.regions = false, this.grounds = const []});

  static const none = NcSceneFeatures();

  /// Never throws: an unexpected shape is "not supported".
  factory NcSceneFeatures.fromPresets(Map<String, dynamic> json, {required int minVersion}) {
    final list = json['presets'];
    if (list is! List) return none;
    for (final p in list) {
      if (p is! Map<String, dynamic> || p['id'] != 'sketch_to_scene') continue;
      final v = p['version'];
      if (v is! num || v < minVersion) return none;
      final inputs = p['inputs'];
      final regions = inputs is List && inputs.any((i) => i is Map && i['name'] == 'regions');
      if (!regions) return none;
      final params = p['params'];
      final ground = params is Map ? params['ground'] : null;
      final List<String> grounds;
      if (ground is Map) {
        final options = ground['options'];
        grounds = options is List ? [for (final g in groundValues) if (options.contains(g)) g] : const [...groundValues];
      } else {
        grounds = const [];
      }
      return NcSceneFeatures(regions: true, grounds: grounds);
    }
    return none;
  }

  /// The grounds this app knows (client.dart `sceneGrounds`); `grass` is the
  /// service's default.
  static const groundValues = ['grass', 'stone', 'dirt', 'sand', 'snow'];

  /// The service takes `inputs.regions`.
  final bool regions;

  /// The `params.ground` values it takes (empty: send no ground).
  final List<String> grounds;
}

enum SceneMode {
  /// Keeps the sketch's layout, top-down (~3 s on a warm GPU).
  map,

  /// Prettier and freer (~5 s).
  atmosphere,
}

enum ReportReason { sexual, violenceGore, hate, minorSafety, other }

extension ReportReasonX on ReportReason {
  String get wire => switch (this) {
        ReportReason.sexual => 'sexual',
        ReportReason.violenceGore => 'violence_gore',
        ReportReason.hate => 'hate',
        ReportReason.minorSafety => 'minor_safety',
        ReportReason.other => 'other',
      };
}

/// `GET /v1/me`: the signed-in end user and today's quota.
class NcMe {
  const NcMe({required this.endUserId, this.createdAt, this.daily, this.used, this.resetsAt});

  factory NcMe.fromJson(Map<String, dynamic> m) {
    final user = m['endUser'] is Map<String, dynamic> ? m['endUser'] as Map<String, dynamic> : const <String, dynamic>{};
    final quota = m['quota'] is Map<String, dynamic> ? m['quota'] as Map<String, dynamic> : const <String, dynamic>{};
    return NcMe(
      endUserId: user['id'] as String? ?? '',
      createdAt: DateTime.tryParse(user['createdAt'] as String? ?? ''),
      daily: (quota['daily'] as num?)?.round(),
      used: (quota['used'] as num?)?.round(),
      resetsAt: DateTime.tryParse(quota['resetsAt'] as String? ?? '')?.toLocal(),
    );
  }

  final String endUserId;
  final DateTime? createdAt;

  /// Maps per day for this user, and how many were made today (null when the
  /// service gave none).
  final int? daily;
  final int? used;
  final DateTime? resetsAt;
}
