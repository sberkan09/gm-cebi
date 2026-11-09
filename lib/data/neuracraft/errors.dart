/// Errors of the NeuraCraft client. The service answers
/// `{"error": {"code": "…", "params": {…}}}`; the app reacts per code
/// (docs/partners/gm-cebi.md, "Errors").
library;

/// What the app should do about a failure. One reaction per service code;
/// the UI turns it into a Turkish message (features/online_scene/messages.dart).
enum NcReaction {
  /// A bug in our request (`preset.params_invalid`, `partner.end_user_required`):
  /// log it, show a generic error.
  bug,

  /// The description was refused (`content.text_refused`).
  textRefused,

  /// The app token is no longer valid: turn the feature off until an update.
  authInvalid,

  /// This install has no allowance left (`allowance.insufficient`).
  allowanceExhausted,

  /// GM Cebi's account is out of credits (`credits.insufficient`).
  serviceOutOfCredits,

  /// The job or picture is gone (`not_found`, e.g. after 7 days).
  notFound,

  /// The session closed (`session.closed`): open a new one and repeat.
  sessionClosed,

  /// Today's maps are used up (`quota.end_user_daily`, with `resetsAt`).
  dailyQuota,

  /// Too many games across GM Cebi (`session.limit`).
  busy,

  /// Wait a few seconds and retry (`limit.concurrent_jobs`, `rate_limited`).
  retrySoon,

  /// No GPU and none starting (`job.no_gpu_worker`).
  noGpu,

  /// The service is being set up (`preset.unavailable`).
  serviceSettingUp,

  /// No answer or not our service: network down, timeout, 5xx without a code.
  offline,

  /// Anything else.
  unknown,
}

sealed class NcException implements Exception {
  const NcException();
  NcReaction get reaction;
}

/// An error answer from the service.
class NcApiException extends NcException {
  const NcApiException(this.status, this.code, [this.params = const {}]);

  final int status;
  final String code;
  final Map<String, Object?> params;

  @override
  NcReaction get reaction => reactionFor(status, code);

  /// `resetsAt` of `quota.end_user_daily`, if given.
  DateTime? get resetsAt => DateTime.tryParse(params['resetsAt']?.toString() ?? '')?.toLocal();

  static NcReaction reactionFor(int status, String code) => switch (code) {
        'preset.params_invalid' || 'partner.end_user_required' || 'request.invalid' => NcReaction.bug,
        'content.text_refused' => NcReaction.textRefused,
        'auth.required' || 'auth.token_revoked' || 'auth.token_expired' || 'auth.scope_missing' => NcReaction.authInvalid,
        'allowance.insufficient' => NcReaction.allowanceExhausted,
        'credits.insufficient' => NcReaction.serviceOutOfCredits,
        'not_found' => NcReaction.notFound,
        'session.closed' => NcReaction.sessionClosed,
        'quota.end_user_daily' => NcReaction.dailyQuota,
        'session.limit' => NcReaction.busy,
        'limit.concurrent_jobs' || 'rate_limited' => NcReaction.retrySoon,
        'job.no_gpu_worker' => NcReaction.noGpu,
        'preset.unavailable' => NcReaction.serviceSettingUp,
        _ => status >= 500 ? NcReaction.offline : NcReaction.unknown,
      };

  @override
  String toString() => 'NcApiException($status $code $params)';
}

/// No usable answer: no network, a timeout, a body that is not the service's.
class NcNetworkException extends NcException {
  const NcNetworkException(this.message);
  final String message;

  @override
  NcReaction get reaction => NcReaction.offline;

  @override
  String toString() => 'NcNetworkException($message)';
}

/// A job that ended `failed` (or `cancelled`), with the service's error code.
class NcJobFailed extends NcException {
  const NcJobFailed(this.code, {this.cancelled = false});

  final String? code;
  final bool cancelled;

  /// The picture failed the content check; nothing was charged.
  bool get flagged => code == 'content.flagged';

  /// The content check could not run; nothing was charged: retry.
  bool get unchecked => code == 'content.unchecked';

  @override
  NcReaction get reaction => NcReaction.unknown;

  @override
  String toString() => 'NcJobFailed($code${cancelled ? ', cancelled' : ''})';
}
