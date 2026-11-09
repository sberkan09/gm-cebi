import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/errors.dart';
import 'package:gm_cebi/data/neuracraft/models.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/session_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Settings without a database.
class FakeOnlineSettings extends OnlineSettingsNotifier {
  FakeOnlineSettings(this.initial);
  final OnlineSettings initial;

  @override
  Future<OnlineSettings> build() async => initial;

  @override
  Future<void> setConsented(bool v) async => state = AsyncData(state.value!.copyWith(consented: v));

  @override
  Future<void> setEnabled(bool v) async => state = AsyncData(state.value!.copyWith(enabled: v));
}

/// A scripted NeuraCraft server: records every call, answers from [handler].
class FakeServer {
  final calls = <String>[];
  int sessions = 0;
  http.Response Function(http.Request r)? override;

  http.Response handle(http.Request r) {
    calls.add('${r.method} ${r.url.path}');
    final o = override;
    if (o != null) return o(r);
    if (r.method == 'POST' && r.url.path == '/v1/sessions') {
      sessions++;
      return _session('s$sessions', {'state': 'warming', 'etaSeconds': 35}, 201);
    }
    if (r.method == 'POST' && r.url.path.endsWith('/heartbeat')) {
      return _session(r.url.pathSegments[2], {'state': 'ready'});
    }
    if (r.method == 'DELETE') return http.Response(jsonEncode({'closed': true}), 200);
    return http.Response('{}', 404);
  }

  static http.Response _session(String id, Map<String, Object?> capacity, [int status = 200]) => http.Response(
        jsonEncode({
          'session': {'id': id, 'heartbeatSeconds': 120, 'expiresWithoutHeartbeatSeconds': 600, 'endsAt': '2026-11-09T20:00:00Z'},
          'capacity': capacity,
        }),
        status,
        headers: {'content-type': 'application/json'},
      );

  static http.Response error(int status, String code) =>
      http.Response(jsonEncode({'error': {'code': code}}), status, headers: {'content-type': 'application/json'});

  int count(String call) => calls.where((c) => c == call).length;
}

void main() {
  late FakeServer server;

  ProviderContainer make({bool consented = true, bool enabled = true}) {
    server = FakeServer();
    final c = ProviderContainer(overrides: [
      ncConfigProvider.overrideWithValue(const NcConfig(baseUrl: 'http://nc.test', appToken: 'nc_app_t')),
      onlineSettingsProvider.overrideWith(
          () => FakeOnlineSettings(OnlineSettings(enabled: enabled, consented: consented, installId: 'install-1'))),
      ncClientProvider.overrideWith((ref) => NeuraCraftClient(
            httpClient: MockClient((r) async => server.handle(r)),
            config: ref.watch(ncConfigProvider),
            endUser: () => 'install-1',
          )),
    ]);
    c.listen(onlineSessionProvider, (_, _) {}); // keep it alive like the UI does
    return c;
  }

  OnlineSessionController ctl(ProviderContainer c) => c.read(onlineSessionProvider.notifier);
  OnlineSessionState st(ProviderContainer c) => c.read(onlineSessionProvider);

  void settle(ProviderContainer c, FakeAsync a) {
    c.read(onlineSettingsProvider); // start loading
    a.flushMicrotasks();
    a.elapse(Duration.zero);
  }

  /// Microtasks and zero-delay timers (Riverpod delivers notifications on the
  /// event loop, not as microtasks).
  void tick(FakeAsync a) {
    a.flushMicrotasks();
    a.elapse(Duration.zero);
    a.flushMicrotasks();
  }

  test('nothing is opened without consent; consent opens the session', () {
    fakeAsync((a) {
      final c = make(consented: false);
      settle(c, a);
      ctl(c).acquire();
      tick(a);
      expect(server.calls, isEmpty);
      expect(st(c).phase, SessionPhase.idle);

      c.read(onlineSettingsProvider.notifier).setConsented(true);
      tick(a);
      expect(server.calls, ['POST /v1/sessions']);
      expect(st(c).phase, SessionPhase.open);
      expect(st(c).capacity, const NcCapacityWarming(35));
      c.dispose();
    });
  });

  test('heartbeats every heartbeatSeconds in the foreground, none in the background', () {
    fakeAsync((a) {
      final c = make();
      settle(c, a);
      ctl(c).acquire();
      a.flushMicrotasks();
      expect(st(c).sessionId, 's1');

      a.elapse(const Duration(seconds: 119));
      expect(server.count('POST /v1/sessions/s1/heartbeat'), 0);
      a.elapse(const Duration(seconds: 1));
      expect(server.count('POST /v1/sessions/s1/heartbeat'), 1);
      expect(st(c).capacity, const NcCapacityReady());

      ctl(c).setForeground(false);
      a.elapse(const Duration(minutes: 10));
      expect(server.count('POST /v1/sessions/s1/heartbeat'), 1, reason: 'no heartbeats in the background');

      ctl(c).setForeground(true);
      a.flushMicrotasks();
      expect(server.count('POST /v1/sessions/s1/heartbeat'), 2, reason: 'an immediate beat on resume');
      a.elapse(const Duration(seconds: 120));
      expect(server.count('POST /v1/sessions/s1/heartbeat'), 3);
      c.dispose();
    });
  });

  test('410 session.closed on a heartbeat opens a new session silently', () {
    fakeAsync((a) {
      final c = make();
      settle(c, a);
      ctl(c).acquire();
      a.flushMicrotasks();
      // The next heartbeat finds the session closed; everything else as usual.
      server.override = (r) {
        server.override = null;
        return FakeServer.error(410, 'session.closed');
      };
      a.elapse(const Duration(seconds: 120));
      a.flushMicrotasks();
      expect(server.calls, ['POST /v1/sessions', 'POST /v1/sessions/s1/heartbeat', 'POST /v1/sessions']);
      expect(st(c).sessionId, 's2');
      expect(st(c).phase, SessionPhase.open);
      c.dispose();
    });
  });

  test('closing the map ends the session after the grace period; reopening keeps it', () {
    fakeAsync((a) {
      final c = make();
      settle(c, a);
      ctl(c).acquire();
      a.flushMicrotasks();
      ctl(c).release();
      a.elapse(OnlineSessionController.closeGrace - const Duration(seconds: 1));
      expect(server.count('DELETE /v1/sessions/s1'), 0);
      ctl(c).acquire(); // back to the map within the grace period
      a.elapse(const Duration(minutes: 10));
      expect(server.count('DELETE /v1/sessions/s1'), 0);
      expect(server.count('POST /v1/sessions'), 1, reason: 'the warm session is reused');

      ctl(c).release();
      a.elapse(OnlineSessionController.closeGrace);
      expect(server.count('DELETE /v1/sessions/s1'), 1);
      expect(st(c).phase, SessionPhase.idle);
      c.dispose();
    });
  });

  test('a failed open is retried a minute later; the error is published', () {
    fakeAsync((a) {
      final c = make();
      settle(c, a);
      server.override = (r) => FakeServer.error(503, 'job.no_gpu_worker');
      ctl(c).acquire();
      a.flushMicrotasks();
      expect(st(c).phase, SessionPhase.failed);
      expect(st(c).error, NcReaction.noGpu);
      server.override = null;
      a.elapse(OnlineSessionController.retryDelay);
      a.flushMicrotasks();
      expect(st(c).phase, SessionPhase.open);
      expect(server.count('POST /v1/sessions'), 2);
      c.dispose();
    });
  });

  test('a network error on a heartbeat keeps the session', () {
    fakeAsync((a) {
      final c = make();
      settle(c, a);
      ctl(c).acquire();
      a.flushMicrotasks();
      server.override = (r) => throw http.ClientException('offline');
      a.elapse(const Duration(seconds: 120));
      a.flushMicrotasks();
      expect(st(c).sessionId, 's1');
      expect(st(c).error, NcReaction.offline);
      server.override = null;
      a.elapse(const Duration(seconds: 120));
      expect(st(c).error, isNull);
      c.dispose();
    });
  });

  test('401 turns the feature off until an update', () {
    fakeAsync((a) {
      final c = make();
      settle(c, a);
      server.override = (r) => FakeServer.error(401, 'auth.token_revoked');
      ctl(c).acquire();
      a.flushMicrotasks();
      expect(st(c).phase, SessionPhase.disabled);
      expect(c.read(onlineSettingsProvider).value!.authInvalid, isTrue);
      expect(c.read(onlineFeatureVisibleProvider), isFalse);
      a.elapse(const Duration(minutes: 5));
      expect(server.count('POST /v1/sessions'), 1, reason: 'no retries with a dead token');
      c.dispose();
    });
  });

  test('turning the feature off closes the session at once', () {
    fakeAsync((a) {
      final c = make();
      settle(c, a);
      ctl(c).acquire();
      a.flushMicrotasks();
      c.read(onlineSettingsProvider.notifier).setEnabled(false);
      tick(a);
      expect(server.calls.last, 'DELETE /v1/sessions/s1');
      expect(st(c).phase, SessionPhase.idle);
      c.dispose();
    });
  });

  test('without a NeuraCraft configuration nothing is visible or sent', () {
    fakeAsync((a) {
      final c = ProviderContainer(overrides: [
        ncConfigProvider.overrideWithValue(const NcConfig(baseUrl: '', appToken: '')),
        onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true, installId: 'i'))),
      ]);
      c.read(onlineSettingsProvider);
      a.flushMicrotasks();
      expect(c.read(ncClientProvider), isNull);
      expect(c.read(onlineFeatureVisibleProvider), isFalse);
      c.read(onlineSessionProvider.notifier).acquire();
      a.flushMicrotasks();
      expect(c.read(onlineSessionProvider).phase, SessionPhase.idle);
      c.dispose();
    });
  });
}
