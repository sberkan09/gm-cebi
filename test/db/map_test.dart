import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test('points encode and decode', () {
    const pts = [Offset01(0, 0), Offset01(0.12345, 0.5), Offset01(1, 1)];
    final s = encodePoints(pts);
    expect(s, '0.0000,0.0000 0.1235,0.5000 1.0000,1.0000');
    final back = decodePoints(s);
    expect(back.length, 3);
    expect(back[1].x, closeTo(0.1235, 1e-9));
    expect(decodePoints(''), isEmpty);
  });

  test('strokes: add, undo, delete, clear', () async {
    final a = await db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.2, 0.2)]);
    final b = await db.addStroke(const [Offset01(0.5, 0.5)], color: 1);
    final c = await db.addStroke(const [Offset01(0.7, 0.7), Offset01(0.8, 0.9)], color: 2);
    var list = await db.watchStrokes().first;
    expect(list.map((s) => s.id), [a, b, c]);
    expect(list[1].color, 1);
    expect(list[2].offsets.last, const Offset01(0.8, 0.9));

    await db.undoStroke();
    expect((await db.watchStrokes().first).map((s) => s.id), [a, b]);
    await db.deleteStrokes([a]);
    expect((await db.watchStrokes().first).map((s) => s.id), [b]);
    await db.clearStrokes();
    expect(await db.watchStrokes().first, isEmpty);
    await db.undoStroke(); // nothing left: no error
  });

  test('tokens: place, clamp, remove', () async {
    final id = await db.addCombatant(name: 'Ayla', isPlayer: true, hp: 20);
    var c = (await db.watchEncounterState().first).combatants.single;
    expect(c.mapPosition, isNull);
    await db.setTokenPosition(id, const Offset01(0.25, 0.75));
    c = (await db.watchEncounterState().first).combatants.single;
    expect(c.mapPosition, const Offset01(0.25, 0.75));
    await db.setTokenPosition(id, const Offset01(1.4, -0.2));
    c = (await db.watchEncounterState().first).combatants.single;
    expect(c.mapPosition, const Offset01(1, 0));
    await db.setTokenPosition(id, null);
    c = (await db.watchEncounterState().first).combatants.single;
    expect(c.mapPosition, isNull);
  });

  test('a new encounter starts with an empty map; carried players are off the map', () async {
    final ayla = await db.addCombatant(name: 'Ayla', isPlayer: true, hp: 20);
    final gob = await db.addCombatant(name: 'Goblin', hp: 7);
    await db.setTokenPosition(ayla, const Offset01(0.3, 0.3));
    await db.setTokenPosition(gob, const Offset01(0.6, 0.6));
    await db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.9, 0.9)]);

    await db.newEncounter(keepPlayers: true);
    final s = await db.watchEncounterState().first;
    expect(s.combatants.map((c) => c.name), ['Ayla']);
    expect(s.combatants.single.mapPosition, isNull);
    expect(await db.watchStrokes().first, isEmpty);
    expect(await db.select(db.mapStrokes).get(), isEmpty, reason: 'old strokes are deleted with their encounter');
  });

  test('schema 1 databases are upgraded: columns and table added, data kept', () async {
    final dir = await Directory.systemTemp.createTemp('gmcebi-migration');
    final file = File('${dir.path}/v1.sqlite');
    try {
      // Build a schema-1 file: today's schema minus what schema 2 added.
      final v2 = AppDatabase(NativeDatabase(file));
      await v2.addCombatant(name: 'Goblin', initiative: 12, hp: 7);
      await v2.customStatement('DROP TABLE map_scenes');
      await v2.customStatement('DROP TABLE map_strokes');
      await v2.customStatement('ALTER TABLE combatants DROP COLUMN pos_x');
      await v2.customStatement('ALTER TABLE combatants DROP COLUMN pos_y');
      await v2.customStatement('PRAGMA user_version = 1');
      await v2.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      final s = await upgraded.watchEncounterState().first;
      expect(s.combatants.single.name, 'Goblin');
      expect(s.combatants.single.mapPosition, isNull);
      await upgraded.setTokenPosition(s.combatants.single.id, const Offset01(0.5, 0.5));
      await upgraded.addStroke(const [Offset01(0, 0), Offset01(1, 1)]);
      expect((await upgraded.watchStrokes().first).length, 1);
      final version = await upgraded.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 3);
      await upgraded.addScene(assetId: 'a', png: Uint8List.fromList([1]), mode: 'map', narrative: '', seed: 1);
      expect(await upgraded.watchActiveScene().first, isNotNull);
      await upgraded.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('schema 2 databases get the scenes table', () async {
    final dir = await Directory.systemTemp.createTemp('gmcebi-migration');
    final file = File('${dir.path}/v2.sqlite');
    try {
      final db3 = AppDatabase(NativeDatabase(file));
      await db3.addStroke(const [Offset01(0, 0), Offset01(1, 1)]);
      await db3.customStatement('DROP TABLE map_scenes');
      await db3.customStatement('PRAGMA user_version = 2');
      await db3.close();
      final upgraded = AppDatabase(NativeDatabase(file));
      expect((await upgraded.watchStrokes().first).length, 1, reason: 'the map survives');
      await upgraded.addScene(assetId: 'a', png: Uint8List.fromList([1, 2]), mode: 'atmosphere', narrative: 'köprü', seed: 7);
      expect((await upgraded.watchActiveScene().first)!.seed, 7);
      await upgraded.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('scenes: newest visible one per active encounter; hide, delete all, cascade', () async {
    expect(await db.watchActiveScene().first, isNull);
    final a = await db.addScene(assetId: 'a1', png: Uint8List.fromList([1]), mode: 'map', narrative: 'köprü', seed: 1);
    final b = await db.addScene(assetId: 'a2', png: Uint8List.fromList([2]), mode: 'map', narrative: 'köprü', seed: 2);
    expect((await db.watchActiveScene().first)!.id, b);
    await db.hideScene(b);
    expect((await db.watchActiveScene().first)!.id, a, reason: 'a reported picture is never shown again');
    await db.newEncounter();
    expect(await db.watchActiveScene().first, isNull, reason: 'a new encounter starts without a picture');
    expect(await db.select(db.mapScenes).get(), isEmpty, reason: 'deleted with their encounter');
    await db.addScene(assetId: 'a3', png: Uint8List.fromList([3]), mode: 'atmosphere', narrative: '', seed: 3);
    await db.deleteAllScenes();
    expect(await db.select(db.mapScenes).get(), isEmpty);
  });
}
