/// Keeps a NeuraCraft session open while the battle map is in use, so the
/// service has a GPU warm by the time a sketch is sent
/// (docs/partners/gm-cebi.md, "Flow").
///
/// - The map screen [acquire]s on open and [release]s on close; the session is
///   closed [closeGrace] after the last release, so leaving the map for a
///   moment does not throw the warm GPU away.
/// - Heartbeats run every `heartbeatSeconds` while the app is in the
///   foreground, and stop in the background.
/// - `410 session.closed` on a periodic heartbeat (the session idled out or
///   ran its 8 hours while the map just stood open) → idle. A new session is
///   opened only when the user needs one again: the scene sheet opens, a
///   sketch is sent, the map comes back to the foreground or is opened again.
///   Otherwise an untouched map would keep a GPU warm for as long as it is on
///   screen. (The contract gives the 410 a `reason` but does not list its
///   values, so every 410 on a periodic heartbeat is treated this way.)
/// - `410 session.closed` on a job request, or on the heartbeat sent when the
///   map comes back → a new session, silently.
/// - Nothing is opened before the user's consent and sign-in
///   ([onlineFeatureActiveProvider]).
/// - The server ended the sign-in → idle (the UI asks to sign in again);
///   blocked user or a build the service no longer accepts → disabled.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/neuracraft/client.dart';
import '../../data/neuracraft/errors.dart';
import '../../data/neuracraft/models.dart';
import 'online_settings.dart';

enum SessionPhase {
  /// No session and none wanted (map closed, feature off, no consent or not
  /// signed in), or the session ended on the server while the map stood
  /// untouched and nobody has needed one since.
  idle,
  opening,
  open,

  /// Opening failed; retried after [OnlineSessionController.retryDelay].
  failed,

  /// Off: this build is no longer accepted (`error` [NcReaction.authInvalid],
  /// until an app update) or this user was blocked ([NcReaction.blocked]).
  disabled,
}

@immutable
class OnlineSessionState {
  const OnlineSessionState({this.phase = SessionPhase.idle, this.sessionId, this.capacity, this.error});

  final SessionPhase phase;
  final String? sessionId;

  /// Last capacity the service reported; null before the first answer.
  final NcCapacity? capacity;

  /// Why the last open or heartbeat failed.
  final NcReaction? error;

  OnlineSessionState copyWith({SessionPhase? phase, String? sessionId, bool clearSession = false, NcCapacity? capacity, NcReaction? error, bool clearError = false}) =>
      OnlineSessionState(
        phase: phase ?? this.phase,
        sessionId: clearSession ? null : (sessionId ?? this.sessionId),
        capacity: capacity ?? this.capacity,
        error: clearError ? null : (error ?? this.error),
      );
}

class OnlineSessionController extends Notifier<OnlineSessionState> {
  static const closeGrace = Duration(minutes: 5);
  static const retryDelay = Duration(seconds: 60);

  int _users = 0;
  bool _foreground = true;
  int _heartbeatSeconds = 120;
  Timer? _heartbeat, _closeTimer, _retryTimer;
  Future<void>? _opening;

  /// The last client used, for the best-effort close on dispose (Ref cannot
  /// be read there).
  NeuraCraftClient? _lastClient;

  NeuraCraftClient? get _client => _lastClient = ref.read(ncClientProvider);

  /// Mirror of `state.sessionId` for dispose, where state cannot be read.
  String? _openId;

  @override
  set state(OnlineSessionState value) {
    _openId = value.sessionId;
    super.state = value;
  }

  @override
  OnlineSessionState build() {
    ref.listen<bool>(onlineFeatureActiveProvider, (was, now) {
      // Deferred: this can fire while the widget tree builds (the first read
      // of this provider happens in a widget's initState).
      scheduleMicrotask(() {
        if (!ref.mounted) return;
        if (!ref.read(onlineFeatureActiveProvider)) {
          unawaited(_closeNow());
        } else {
          // Signed in again (another account) after a block.
          if (state.phase == SessionPhase.disabled && state.error == NcReaction.blocked) state = const OnlineSessionState();
          if (_users > 0) _ensureOpen();
        }
      });
    });
    ref.onDispose(() {
      _cancelTimers();
      final id = _openId;
      if (id != null) unawaited(_lastClient?.closeSession(id).catchError((_) {}));
    });
    return const OnlineSessionState();
  }

  bool get _active => ref.read(onlineFeatureActiveProvider);

  /// The map screen is open (counted, so nested screens are fine).
  void acquire() {
    _users++;
    _closeTimer?.cancel();
    _closeTimer = null;
    if (!_active) return;
    if (state.sessionId != null && _users == 1) {
      // Back on the map within the grace period: release() stopped the
      // heartbeats, so restart them (and refresh the capacity now).
      unawaited(_beat(reopen: true));
      _startHeartbeat();
    } else {
      _ensureOpen();
    }
  }

  /// The map screen closed. The session ends [closeGrace] later unless the
  /// map is opened again.
  void release() {
    if (_users > 0) _users--;
    if (_users > 0) return;
    _heartbeat?.cancel();
    _retryTimer?.cancel();
    _closeTimer?.cancel();
    _closeTimer = Timer(closeGrace, () => unawaited(_closeNow()));
  }

  /// From the app lifecycle: heartbeats only in the foreground.
  void setForeground(bool foreground) {
    if (_foreground == foreground) return;
    _foreground = foreground;
    if (!foreground) {
      _heartbeat?.cancel();
      _retryTimer?.cancel();
      return;
    }
    if (_users == 0 || !_active) return;
    if (state.sessionId == null) {
      _ensureOpen();
    } else {
      unawaited(_beat(reopen: true)); // refresh capacity at once; a session that timed out meanwhile is opened again
      _startHeartbeat();
    }
  }

  /// The user needs the session: the scene sheet opens, or a sketch is about
  /// to be sent. Makes sure a session exists so the GPU starts (also after a
  /// heartbeat found it closed and the map went idle).
  /// Never throws; a failed open does not block the job.
  Future<void> ensureOpen() async {
    if (!_active) return;
    await _ensureOpen();
  }

  /// A job request answered `session.closed`: open a new session.
  Future<void> sessionClosed() async {
    _heartbeat?.cancel();
    state = state.copyWith(clearSession: true, phase: SessionPhase.idle);
    // Not from the background: the next resume opens one if the map is still open.
    if (_foreground) await ensureOpen();
  }

  /// The service no longer accepts this build: off until an app update.
  void authRejected() {
    _cancelTimers();
    state = OnlineSessionState(phase: SessionPhase.disabled, error: NcReaction.authInvalid, capacity: state.capacity);
    ref.read(onlineSettingsProvider.notifier).markAuthInvalid();
  }

  /// A request failed with an account reaction: update needed, blocked, or
  /// signed out by the server. Returns whether [r] was one of them.
  bool accountRejected(NcReaction r) {
    switch (r) {
      case NcReaction.authInvalid:
        authRejected();
      case NcReaction.blocked:
        _cancelTimers();
        state = OnlineSessionState(phase: SessionPhase.disabled, error: NcReaction.blocked, capacity: state.capacity);
      case NcReaction.signInRequired:
        // The sign-in is gone, so is the session: idle until signed in again.
        _cancelTimers();
        state = const OnlineSessionState();
      default:
        return false;
    }
    return true;
  }

  /// Ends the session now (game over, feature turned off, signing out). Waits
  /// for the close request, so it goes out while the token still works.
  Future<void> closeNow() => _closeNow();

  Future<void> _ensureOpen() {
    if (state.sessionId != null || state.phase == SessionPhase.disabled) return Future.value();
    return _opening ??= _open().whenComplete(() => _opening = null);
  }

  Future<void> _open() async {
    final client = _client;
    if (client == null) return;
    _retryTimer?.cancel();
    state = state.copyWith(phase: SessionPhase.opening, clearError: true);
    try {
      final s = await client.openSession();
      if (!ref.mounted) {
        unawaited(client.closeSession(s.id).catchError((_) {}));
        return;
      }
      if (!_active || (_users == 0 && _closeTimer == null)) {
        // Nobody wants it any more (closed while we waited).
        unawaited(client.closeSession(s.id).catchError((_) {}));
        state = state.copyWith(phase: SessionPhase.idle, clearSession: true);
        return;
      }
      _heartbeatSeconds = s.heartbeatSeconds.clamp(10, 600);
      state = OnlineSessionState(phase: SessionPhase.open, sessionId: s.id, capacity: s.capacity);
      _startHeartbeat();
    } on NcException catch (e) {
      if (!ref.mounted || accountRejected(e.reaction)) return;
      _openFailed(e.reaction);
    } catch (e) {
      // Not the service's answer as we know it (a FormatException or a
      // TypeError from its JSON): the same end as any failed open, never a
      // map left on "Bağlanıyor…". Only the error's type is logged.
      debugPrint('opening the online session failed: ${e.runtimeType}');
      if (ref.mounted) _openFailed(NcReaction.unknown);
    }
  }

  /// Failed, with the normal retry [retryDelay] later while the map is open.
  void _openFailed(NcReaction reason) {
    state = state.copyWith(phase: SessionPhase.failed, error: reason, clearSession: true);
    if (_users > 0 && _foreground) {
      _retryTimer = Timer(retryDelay, () {
        if (_users > 0 && _foreground && _active) _ensureOpen();
      });
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    if (!_foreground || _users == 0 || state.sessionId == null) return;
    _heartbeat = Timer.periodic(Duration(seconds: _heartbeatSeconds), (_) => _beat());
  }

  /// One heartbeat. When the session turns out to be closed: with [reopen]
  /// (the map just came back: the user is here) a new one is opened; on a
  /// periodic beat the map goes idle instead (see the library comment).
  Future<void> _beat({bool reopen = false}) async {
    final client = _client;
    final id = state.sessionId;
    if (client == null || id == null) return;
    try {
      final s = await client.heartbeat(id);
      if (ref.mounted && state.sessionId == id) state = state.copyWith(capacity: s.capacity, clearError: true);
    } on NcException catch (e) {
      if (!ref.mounted || state.sessionId != id) return;
      switch (e.reaction) {
        case NcReaction.sessionClosed || NcReaction.notFound:
          if (reopen) {
            await sessionClosed();
          } else {
            _cancelTimers();
            state = const OnlineSessionState();
          }
        case NcReaction.authInvalid || NcReaction.blocked || NcReaction.signInRequired:
          accountRejected(e.reaction);
        default:
          // Network blip: keep the session; the next beat tries again.
          state = state.copyWith(error: e.reaction);
      }
    } catch (e) {
      // An answer that is not the service's (see [_open]): like a blip.
      debugPrint('online session heartbeat failed: ${e.runtimeType}');
      if (ref.mounted && state.sessionId == id) state = state.copyWith(error: NcReaction.unknown);
    }
  }

  Future<void> _closeNow() async {
    _cancelTimers();
    final id = state.sessionId;
    if (state.phase != SessionPhase.disabled && (state.phase != SessionPhase.idle || id != null || state.error != null)) {
      state = const OnlineSessionState();
    }
    if (id != null) await _client?.closeSession(id).catchError((_) {});
  }

  void _cancelTimers() {
    _heartbeat?.cancel();
    _closeTimer?.cancel();
    _retryTimer?.cancel();
    _heartbeat = _closeTimer = _retryTimer = null;
  }
}

final onlineSessionProvider = NotifierProvider<OnlineSessionController, OnlineSessionState>(OnlineSessionController.new);
