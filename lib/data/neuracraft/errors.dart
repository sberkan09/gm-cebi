/// Errors of the NeuraCraft client. The service answers
/// `{"error": {"code": "…", "params": {…}}}`; the app reacts per code
/// (docs/partners/gm-cebi.md, "Errors").
library;

import 'dart:convert';

/// What the app should do about a failure. One reaction per service code;
/// the UI turns it into a Turkish message (features/online_scene/messages.dart).
enum NcReaction {
  /// A bug in our request (`preset.params_invalid`, `partner.end_user_required`):
  /// log it, show a generic error.
  bug,

  /// The description was refused (`content.text_refused`).
  textRefused,

  /// This build cannot talk to the service any more (`auth.client_invalid`,
  /// `auth.end_user_token_required`, `auth.scope_missing`, `auth.required`):
  /// the feature stays off until an app update.
  authInvalid,

  /// Not signed in, or the server ended the sign-in (`auth.refresh_invalid`,
  /// `auth.token_revoked`): back to the sign-in sheet.
  signInRequired,

  /// This end user was blocked (`auth.end_user_blocked`): the feature is off
  /// for them.
  blocked,

  /// The code emails cannot be sent now (`auth.sign_in_unavailable`).
  signInUnavailable,

  /// The address was refused (`auth.invalid_email`).
  invalidEmail,

  /// Wrong code (`auth.code_invalid`, with `attemptsLeft`).
  codeInvalid,

  /// The code expired, was used, or was wrong 5 times (`auth.code_expired`).
  codeExpired,

  /// Too many codes asked for (`auth.code_rate_limited`, with `retryAfter`).
  codeRateLimited,

  /// This user has no allowance left (`allowance.insufficient`).
  allowanceExhausted,

  /// GM Cebi's account is out of credits (`credits.insufficient`).
  serviceOutOfCredits,

  /// The job or picture is gone (`not_found`, e.g. after 7 days).
  notFound,

  /// The session closed (`session.closed`): open a new one and repeat.
  sessionClosed,

  /// Today's maps are used up (`quota.end_user_daily`, with `resetsAt`).
  dailyQuota,

  /// GM Cebi's maps for today are used up across all users (`quota.partner_daily`).
  partnerDailyQuota,

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

  /// Not signed in (raised by the app itself, never by the service).
  static const signInRequired = 'auth.sign_in_required';

  /// `resetsAt` of `quota.end_user_daily` / `quota.partner_daily`, if given.
  DateTime? get resetsAt => DateTime.tryParse(params['resetsAt']?.toString() ?? '')?.toLocal();

  /// `attemptsLeft` of `auth.code_invalid`, if given.
  int? get attemptsLeft => (params['attemptsLeft'] as num?)?.round();

  /// `retryAfter` (seconds) of `auth.code_rate_limited`, if given.
  int? get retryAfter => (params['retryAfter'] as num?)?.round();

  static NcReaction reactionFor(int status, String code) => switch (code) {
        'preset.params_invalid' || 'partner.end_user_required' || 'request.invalid' => NcReaction.bug,
        'content.text_refused' => NcReaction.textRefused,
        'auth.client_invalid' || 'auth.end_user_token_required' || 'auth.scope_missing' || 'auth.required' => NcReaction.authInvalid,
        'auth.refresh_invalid' || 'auth.token_revoked' || signInRequired => NcReaction.signInRequired,
        // Only seen when the request failed again right after a refresh.
        'auth.token_expired' => NcReaction.retrySoon,
        'auth.end_user_blocked' => NcReaction.blocked,
        'auth.sign_in_unavailable' => NcReaction.signInUnavailable,
        'auth.invalid_email' => NcReaction.invalidEmail,
        'auth.code_invalid' => NcReaction.codeInvalid,
        'auth.code_expired' => NcReaction.codeExpired,
        'auth.code_rate_limited' => NcReaction.codeRateLimited,
        'allowance.insufficient' => NcReaction.allowanceExhausted,
        'credits.insufficient' => NcReaction.serviceOutOfCredits,
        'not_found' => NcReaction.notFound,
        'session.closed' => NcReaction.sessionClosed,
        'quota.end_user_daily' => NcReaction.dailyQuota,
        'quota.partner_daily' => NcReaction.partnerDailyQuota,
        'session.limit' => NcReaction.busy,
        'limit.concurrent_jobs' || 'rate_limited' => NcReaction.retrySoon,
        'job.no_gpu_worker' => NcReaction.noGpu,
        'preset.unavailable' => NcReaction.serviceSettingUp,
        _ => status >= 500 ? NcReaction.offline : NcReaction.unknown,
      };

  @override
  String toString() => 'NcApiException($status $code $params)';
}

/// `{"error": {"code", "params"}}` → [NcApiException]; anything else (a proxy
/// page, an empty 502) → [NcNetworkException] for 5xx.
NcException ncErrorFrom(int status, String body) {
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
