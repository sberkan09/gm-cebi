import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/auth.dart';
import 'package:gm_cebi/data/neuracraft/client.dart';
import 'package:gm_cebi/data/neuracraft/config.dart';
import 'package:gm_cebi/data/neuracraft/models.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/map_sketch.dart';
import 'package:gm_cebi/features/online_scene/account.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';
import 'package:gm_cebi/features/online_scene/session_controller.dart';
import 'package:gm_cebi/providers.dart';
import 'package:http/testing.dart';

import 'online_session_test.dart' show FakeOnlineSettings, signedInTokens;
import 'scene_controller_test.dart' show Server;

/// "Sahneyi canlandır" with the real exporters: the GM's own map picture
/// (`map_images`) must never be in anything sent, only the drawing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = NcConfig(baseUrl: 'http://nc.test', clientId: 'nc_client_t');
  // Recognisable bytes: their text, or any base64 of them, would show up in a body.
  final picture = Uint8List.fromList(utf8.encode('GIZLI-HARITA-RESMI-' * 64));

  test('the uploaded map picture is never in a request body; the sketch is the drawing alone', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    final server = Server()
      ..presets = {
        'presets': [
          {
            'id': 'sketch_to_scene',
            'version': 1,
            'params': {
              'mode': {'type': 'enum', 'options': ['map', 'atmosphere']},
              'ground': {'type': 'enum', 'options': ['grass', 'stone'], 'default': 'grass'},
            },
            'inputs': [
              {'name': 'sketch'},
              {'name': 'regions'},
            ],
          },
        ],
      };
    final sent = <Uint8List>[];
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      ncConfigProvider.overrideWithValue(config),
      onlineSettingsProvider.overrideWith(() => FakeOnlineSettings(const OnlineSettings(consented: true))),
      ncTokenStoreProvider.overrideWithValue(MemoryTokenStore(signedInTokens())),
      ncHttpClientProvider.overrideWithValue(MockClient.streaming((r, body) async {
        sent.add(await body.toBytes());
        return server.handle(r);
      })),
      ncClientProvider.overrideWith((ref) => NeuraCraftClient(
            httpClient: ref.watch(ncHttpClientProvider),
            config: config,
            auth: ref.watch(ncTokenManagerProvider)!,
            pollInterval: const Duration(milliseconds: 1),
          )),
      sceneRandomProvider.overrideWithValue(Random(1)),
      // The real sketch and region exporters: not overridden.
    ]);
    addTearDown(() async {
      c.dispose();
      await db.close();
    });
    c.listen(sceneControllerProvider, (_, _) {});
    c.listen(onlineSessionProvider, (_, _) {});
    await c.read(onlineSettingsProvider.future);
    await c.read(ncAccountProvider.notifier).load();

    await db.setMapImage(picture, width: 1200, height: 600);
    await db.addStroke(const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)]);
    await db.addStroke(const [Offset01(0.2, 0.2), Offset01(0.4, 0.3)], region: RegionKind.water.index, width: 0.05);

    await c.read(sceneControllerProvider.notifier).generate(mode: SceneMode.map, narrative: 'köprü', ground: 'grass');
    expect(c.read(sceneControllerProvider), isA<SceneIdle>());
    expect(server.bodies, hasLength(1));
    expect(sent.where((b) => b.isNotEmpty), isNotEmpty);

    final needles = [
      'GIZLI-HARITA-RESMI',
      for (var k = 0; k < 3; k++) base64Encode(picture.sublist(k)).substring(0, 40),
      for (var k = 0; k < 3; k++) base64Url.encode(picture.sublist(k)).substring(0, 40),
    ];
    for (final b in sent) {
      final text = latin1.decode(b);
      for (final n in needles) {
        expect(text.contains(n), isFalse, reason: 'a request body carries the uploaded picture');
      }
    }

    // What went is exactly the drawing: the pen line as the sketch, the area as the region layer.
    final rows = await db.watchStrokes().first;
    final inputs = server.bodies.single['inputs'] as Map<String, dynamic>;
    expect(base64Decode(inputs['sketch']['inline'] as String), await renderTerrainPng(lineStrokesOf(rows)));
    expect(base64Decode(inputs['regions']['inline'] as String), await renderRegionsPng(regionStrokesOf(rows)));
    expect(inputs.keys.toSet(), {'sketch', 'regions'});
    expect((await db.watchActiveMapImage().first)!.id, isNotNull, reason: 'the picture stays on the device');
  });
}
