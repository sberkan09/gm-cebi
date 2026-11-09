import 'dart:convert';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';
import 'package:gm_cebi/providers.dart';

/// A 1×1 PNG.
final png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

/// What the map paints: the image of the active scene id.
final shownImage = Provider<ui.Image?>((ref) {
  final id = ref.watch(activeSceneIdProvider);
  return id == null ? null : ref.watch(sceneImageProvider(id)).value;
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('turns do not re-decode or free the picture; a new picture replaces it cleanly', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(() async {
      c.dispose();
      await db.close();
    });
    await db.addCombatant(name: 'Ayla', initiative: 15, hp: 10);
    await db.addCombatant(name: 'Kurt', initiative: 10, hp: 10);
    final first = (await db.addScene(assetId: 'a1', png: png, mode: 'map', narrative: '', seed: 1))!;

    final seen = <ui.Image?>[];
    c.listen<ui.Image?>(shownImage, (_, next) => seen.add(next), fireImmediately: true);
    Future<ui.Image> image() async {
      for (var i = 0; i < 200; i++) {
        final v = c.read(shownImage);
        if (v != null) return v;
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      fail('picture never decoded');
    }

    final img1 = await image();
    expect(c.read(activeSceneIdProvider), first);

    // Turns write the encounters table, which the scene query joins.
    for (var i = 0; i < 4; i++) {
      await db.nextTurn();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    expect(identical(c.read(shownImage), img1), isTrue, reason: 'not decoded again');
    expect(img1.debugDisposed, isFalse, reason: 'the painted image was never freed');
    expect(seen.whereType<ui.Image>().toSet(), {img1});

    // A new picture: the map gets the new image; the old one is freed only
    // after nothing shows it, and the map never gets a freed image.
    await db.addScene(assetId: 'a2', png: png, mode: 'map', narrative: '', seed: 2);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final img2 = await image();
    expect(identical(img2, img1), isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(img1.debugDisposed, isTrue, reason: 'the old picture is released');
    expect(img2.debugDisposed, isFalse);
    for (final s in seen.whereType<ui.Image>()) {
      if (identical(s, c.read(shownImage))) expect(s.debugDisposed, isFalse);
    }
  });
}
