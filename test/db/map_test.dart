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

  test('a new encounter can keep the map: lines, areas and the picture in use; tokens come off', () async {
    final ayla = await db.addCombatant(name: 'Ayla', isPlayer: true, hp: 20);
    final gob = await db.addCombatant(name: 'Goblin', hp: 7);
    await db.setTokenPosition(ayla, const Offset01(0.3, 0.3));
    await db.setTokenPosition(gob, const Offset01(0.6, 0.6));
    final line = await db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.9, 0.9)], color: 2);
    final water = await db.addStroke(const [Offset01(0.2, 0.2), Offset01(0.8, 0.3)], region: 0, width: 0.09);
    await db.addScene(assetId: 'a1', png: Uint8List.fromList([1]), mode: 'map', narrative: 'köprü', seed: 1);
    final reported = await db.addScene(assetId: 'a2', png: Uint8List.fromList([2]), mode: 'map', narrative: 'köprü', seed: 2);
    final inUse = await db.addScene(assetId: 'a3', png: Uint8List.fromList([3]), mode: 'map', narrative: 'köprü', seed: 3);
    final newest = await db.addScene(assetId: 'a4', png: Uint8List.fromList([4]), mode: 'map', narrative: 'köprü', seed: 4);
    await db.hideScene(reported!);
    await db.hideScene(newest!);
    expect((await db.watchActiveScene().first)!.id, inUse);
    final before = await db.activeEncounter();

    await db.newEncounter(keepPlayers: true, keepMap: true);
    final s = await db.watchEncounterState().first;
    expect(s.encounter.id, isNot(before.id));
    expect(await db.select(db.encounters).get(), hasLength(1));
    expect(s.combatants.map((c) => c.name), ['Ayla']);
    expect(s.combatants.single.mapPosition, isNull, reason: 'token positions are reset');
    final strokes = await db.watchStrokes().first;
    expect(strokes.map((x) => x.id), [line, water], reason: 'the same strokes, in the same order');
    expect(strokes[0].color, 2);
    expect(strokes[0].offsets, const [Offset01(0.1, 0.1), Offset01(0.9, 0.9)]);
    expect(strokes[1].region, 0);
    expect(strokes[1].width, closeTo(0.09, 1e-9));
    final scene = await db.watchActiveScene().first;
    expect(scene!.id, inUse);
    expect(scene.png, [3]);
    expect((await db.select(db.mapScenes).get()).map((x) => x.id), [inUse], reason: 'older and reported pictures go with the old encounter');

    // The kept map is the new encounter's map: drawing and undo go on as usual.
    await db.addStroke(const [Offset01(0.5, 0.5), Offset01(0.6, 0.6)]);
    await db.undoStroke();
    expect((await db.watchStrokes().first).map((x) => x.id), [line, water]);

    await db.newEncounter(keepPlayers: false, keepMap: false);
    expect(await db.select(db.mapStrokes).get(), isEmpty);
    expect(await db.select(db.mapScenes).get(), isEmpty);
    expect(await db.watchActiveScene().first, isNull);
  });

  test('keeping the map of an encounter without a drawing or a picture is fine', () async {
    await db.addCombatant(name: 'Goblin', hp: 7);
    await db.newEncounter(keepPlayers: false, keepMap: true);
    expect(await db.watchStrokes().first, isEmpty);
    expect(await db.watchActiveScene().first, isNull);
    expect((await db.watchEncounterState().first).combatants, isEmpty);
  });

  test('schema 1 databases are upgraded: columns and table added, data kept', () async {
    final dir = await Directory.systemTemp.createTemp('gmcebi-migration');
    final file = File('${dir.path}/v1.sqlite');
    try {
      // Build a schema-1 file: today's schema minus what schema 2 added.
      final v2 = AppDatabase(NativeDatabase(file));
      await v2.addCombatant(name: 'Goblin', initiative: 12, hp: 7);
      await v2.customStatement('DROP TABLE map_images');
      await v2.customStatement('DROP TABLE map_scenes');
      await v2.customStatement('DROP TABLE map_strokes');
      await v2.customStatement('ALTER TABLE encounters DROP COLUMN token_scale');
      await v2.customStatement('ALTER TABLE encounters DROP COLUMN map_background');
      await v2.customStatement('ALTER TABLE combatants DROP COLUMN pos_x');
      await v2.customStatement('ALTER TABLE combatants DROP COLUMN pos_y');
      await v2.customStatement('ALTER TABLE combatants DROP COLUMN level');
      await v2.customStatement('PRAGMA user_version = 1');
      await v2.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      final s = await upgraded.watchEncounterState().first;
      expect(s.combatants.single.name, 'Goblin');
      expect(s.combatants.single.mapPosition, isNull);
      expect(s.combatants.single.level, isNull);
      await upgraded.setTokenPosition(s.combatants.single.id, const Offset01(0.5, 0.5));
      await upgraded.addStroke(const [Offset01(0, 0), Offset01(1, 1)]);
      expect((await upgraded.watchStrokes().first).length, 1);
      final version = await upgraded.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 6);
      await upgraded.addScene(assetId: 'a', png: Uint8List.fromList([1]), mode: 'map', narrative: '', seed: 1);
      expect(await upgraded.watchActiveScene().first, isNotNull);
      await upgraded.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('an interrupted schema 1 → 2 upgrade runs again on the next start', () async {
    final dir = await Directory.systemTemp.createTemp('gmcebi-migration');
    final file = File('${dir.path}/half.sqlite');
    try {
      // Schema 1 plus pos_x only: the app was killed after the first step.
      final v2 = AppDatabase(NativeDatabase(file));
      await v2.addCombatant(name: 'Goblin', hp: 7);
      await v2.customStatement('DROP TABLE map_strokes');
      await v2.customStatement('ALTER TABLE combatants DROP COLUMN pos_y');
      await v2.customStatement('PRAGMA user_version = 1');
      await v2.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      final s = await upgraded.watchEncounterState().first;
      expect(s.combatants.single.name, 'Goblin');
      await upgraded.setTokenPosition(s.combatants.single.id, const Offset01(0.2, 0.2));
      await upgraded.addStroke(const [Offset01(0, 0), Offset01(1, 1)]);
      expect((await upgraded.watchStrokes().first).length, 1);
      await upgraded.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('restoreStrokes puts erased strokes back with their ids; clearTokenPositions in one go', () async {
    final a = await db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.2, 0.2)], color: 2);
    final b = await db.addStroke(const [Offset01(0.5, 0.5)]);
    final rows = await db.watchStrokes().first;
    await db.clearStrokes();
    expect(await db.watchStrokes().first, isEmpty);
    await db.restoreStrokes(rows);
    final back = await db.watchStrokes().first;
    expect(back.map((s) => s.id), [a, b]);
    expect(back.first.color, 2);
    await db.restoreStrokes(rows); // twice: nothing duplicated
    expect((await db.watchStrokes().first).length, 2);

    final x = await db.addCombatant(name: 'A');
    final y = await db.addCombatant(name: 'B');
    await db.setTokenPosition(x, const Offset01(0.1, 0.1));
    await db.setTokenPosition(y, const Offset01(0.2, 0.2));
    await db.clearTokenPositions();
    final cs = (await db.watchEncounterState().first).combatants;
    expect(cs.every((c) => c.mapPosition == null), isTrue);
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

  test('schema 3 databases get the level column; data kept', () async {
    final dir = await Directory.systemTemp.createTemp('gmcebi-migration');
    final file = File('${dir.path}/v3.sqlite');
    try {
      final db4 = AppDatabase(NativeDatabase(file));
      await db4.addCombatant(name: 'Ayla', isPlayer: true, hp: 20);
      await db4.customStatement('ALTER TABLE combatants DROP COLUMN level');
      await db4.customStatement('PRAGMA user_version = 3');
      await db4.close();
      final upgraded = AppDatabase(NativeDatabase(file));
      final ayla = (await upgraded.watchEncounterState().first).combatants.single;
      expect(ayla.name, 'Ayla');
      expect(ayla.level, isNull);
      await upgraded.setLevel(ayla.id, 5);
      expect((await upgraded.watchEncounterState().first).combatants.single.level, 5);
      final version = await upgraded.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 6);
      await upgraded.close();

      // Already has the column but still says 3 (killed before user_version was written).
      final again = AppDatabase(NativeDatabase(file));
      await again.customStatement('PRAGMA user_version = 3');
      await again.close();
      final reopened = AppDatabase(NativeDatabase(file));
      expect((await reopened.watchEncounterState().first).combatants.single.level, 5);
      await reopened.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('area strokes: kind and width kept; undo, erase-restore and clear work as for lines', () async {
    final line = await db.addStroke(const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)], color: 1);
    final water = await db.addStroke(const [Offset01(0.2, 0.2), Offset01(0.8, 0.3)], region: 0, width: 0.09);
    final wall = await db.addStroke(const [Offset01(0.5, 0.5)], region: 4, width: 0.025);
    var rows = await db.watchStrokes().first;
    expect(rows.map((s) => s.id), [line, water, wall]);
    expect(rows[0].isRegion, isFalse);
    expect(rows[0].region, isNull);
    expect(rows[0].width, isNull);
    expect(rows[1].isRegion, isTrue);
    expect(rows[1].region, 0);
    expect(rows[1].width, closeTo(0.09, 1e-9));
    expect(rows[2].offsets, const [Offset01(0.5, 0.5)]);

    await db.undoStroke(); // the newest, whatever its layer
    rows = await db.watchStrokes().first;
    expect(rows.map((s) => s.id), [line, water]);
    await db.clearStrokes();
    await db.restoreStrokes(rows);
    rows = await db.watchStrokes().first;
    expect(rows[1].region, 0, reason: 'undo of "clear" brings the area back as an area');
    expect(rows[1].width, closeTo(0.09, 1e-9));

    await db.newEncounter();
    expect(await db.select(db.mapStrokes).get(), isEmpty, reason: 'areas are deleted with their encounter');
  });

  test('schema 4 databases get the area columns; old strokes stay pen lines', () async {
    final dir = await Directory.systemTemp.createTemp('gmcebi-migration');
    final file = File('${dir.path}/v4.sqlite');
    try {
      final db4 = AppDatabase(NativeDatabase(file));
      await db4.addStroke(const [Offset01(0.1, 0.1), Offset01(0.9, 0.9)], color: 2);
      await db4.customStatement('ALTER TABLE map_strokes DROP COLUMN region');
      await db4.customStatement('ALTER TABLE map_strokes DROP COLUMN width');
      await db4.customStatement('DROP TABLE map_images');
      await db4.customStatement('ALTER TABLE encounters DROP COLUMN token_scale');
      await db4.customStatement('ALTER TABLE encounters DROP COLUMN map_background');
      await db4.customStatement('PRAGMA user_version = 4');
      await db4.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      var rows = await upgraded.watchStrokes().first;
      expect(rows.single.color, 2);
      expect(rows.single.isRegion, isFalse);
      expect(rows.single.offsets.last, const Offset01(0.9, 0.9));
      await upgraded.addStroke(const [Offset01(0.3, 0.3), Offset01(0.4, 0.4)], region: 5, width: 0.05);
      rows = await upgraded.watchStrokes().first;
      expect(rows.last.region, 5);
      final version = await upgraded.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 6);
      await upgraded.close();

      // Already has one column but still says 4 (killed half way): runs again.
      final half = AppDatabase(NativeDatabase(file));
      await half.customStatement('ALTER TABLE map_strokes DROP COLUMN width');
      await half.customStatement('PRAGMA user_version = 4');
      await half.close();
      final reopened = AppDatabase(NativeDatabase(file));
      rows = await reopened.watchStrokes().first;
      expect(rows, hasLength(2));
      expect(rows.last.region, 5);
      expect(rows.last.width, isNull, reason: 'the dropped column comes back empty');
      await reopened.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('scenes: newest visible one per active encounter; hide, delete all, cascade', () async {
    expect(await db.watchActiveScene().first, isNull);
    final a = await db.addScene(assetId: 'a1', png: Uint8List.fromList([1]), mode: 'map', narrative: 'köprü', seed: 1);
    final b = await db.addScene(assetId: 'a2', png: Uint8List.fromList([2]), mode: 'map', narrative: 'köprü', seed: 2);
    expect((await db.watchActiveScene().first)!.id, b);
    await db.hideScene(b!);
    expect((await db.watchActiveScene().first)!.id, a, reason: 'a reported picture is never shown again');
    await db.newEncounter();
    expect(await db.watchActiveScene().first, isNull, reason: 'a new encounter starts without a picture');
    expect(await db.select(db.mapScenes).get(), isEmpty, reason: 'deleted with their encounter');
    await db.addScene(assetId: 'a3', png: Uint8List.fromList([3]), mode: 'atmosphere', narrative: '', seed: 3);
    await db.deleteAllScenes();
    expect(await db.select(db.mapScenes).get(), isEmpty);
  });

  test('a reported picture: its bytes are deleted at once, the row stays as a marker and is never shown', () async {
    final keep = await db.addScene(assetId: 'a1', png: Uint8List(1000), mode: 'map', narrative: 'köprü', seed: 1);
    final bad = await db.addScene(assetId: 'a2', png: Uint8List(1000), mode: 'map', narrative: 'köprü', seed: 2);
    await db.hideScene(bad!);
    final row = await (db.select(db.mapScenes)..where((s) => s.id.equals(bad))).getSingle();
    expect(row.hidden, isTrue);
    expect(row.png, isEmpty, reason: 'the reported picture does not stay on the device (or in a backup)');
    expect(row.assetId, 'a2');
    final other = await (db.select(db.mapScenes)..where((s) => s.id.equals(keep!))).getSingle();
    expect(other.png, hasLength(1000), reason: 'other pictures are untouched');
    expect((await db.watchActiveScene().first)!.id, keep);
  });

  test('pictures: at most the latest ${AppDatabase.maxScenesPerEncounter} per encounter are kept', () async {
    final first = await db.activeEncounter();
    final ids = <int>[];
    for (var i = 0; i < AppDatabase.maxScenesPerEncounter + 3; i++) {
      ids.add((await db.addScene(assetId: 'a$i', png: Uint8List(100), mode: 'map', narrative: '', seed: i))!);
    }
    var rows = await db.select(db.mapScenes).get();
    expect(rows.map((r) => r.id), ids.sublist(3), reason: 'the three oldest were deleted');
    expect((await db.watchActiveScene().first)!.id, ids.last);

    // Per encounter: a picture stored for another encounter prunes only that one's.
    await db.customStatement('UPDATE encounters SET active = 0');
    final second = await db.into(db.encounters).insert(EncountersCompanion.insert(createdAt: DateTime.now()));
    await db.addScene(assetId: 'b0', png: Uint8List(100), mode: 'map', narrative: '', seed: 1, encounterId: second);
    rows = await db.select(db.mapScenes).get();
    expect(rows.where((r) => r.encounterId == first.id), hasLength(AppDatabase.maxScenesPerEncounter));
    expect(rows.where((r) => r.encounterId == second), hasLength(1));
  });

  test('a picture reported before its bytes were dropped loses them when the next picture is stored', () async {
    final old = await db.addScene(assetId: 'a1', png: Uint8List(1000), mode: 'map', narrative: '', seed: 1);
    // As an older version of the app left it: hidden, bytes kept.
    await (db.update(db.mapScenes)..where((s) => s.id.equals(old!))).write(const MapScenesCompanion(hidden: Value(true)));
    await db.addScene(assetId: 'a2', png: Uint8List(10), mode: 'map', narrative: '', seed: 2);
    final row = await (db.select(db.mapScenes)..where((s) => s.id.equals(old!))).getSingle();
    expect(row.hidden, isTrue);
    expect(row.png, isEmpty);
  });

  test('schema 5 databases get the picture table and the map settings; old encounters keep their look', () async {
    final dir = await Directory.systemTemp.createTemp('gmcebi-migration');
    final file = File('${dir.path}/v5.sqlite');
    try {
      final db5 = AppDatabase(NativeDatabase(file));
      await db5.addCombatant(name: 'Goblin', hp: 7);
      await db5.addStroke(const [Offset01(0.1, 0.1), Offset01(0.9, 0.9)]);
      await db5.customStatement('DROP TABLE map_images');
      await db5.customStatement('ALTER TABLE encounters DROP COLUMN token_scale');
      await db5.customStatement('ALTER TABLE encounters DROP COLUMN map_background');
      await db5.customStatement('PRAGMA user_version = 5');
      await db5.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      final s = await upgraded.watchEncounterState().first;
      expect(s.combatants.single.name, 'Goblin');
      expect(s.encounter.tokenScale, 1.0);
      expect(s.encounter.mapBackground, 'online', reason: 'an online picture shows when there is one, as before');
      expect((await upgraded.watchStrokes().first), hasLength(1));
      expect(await upgraded.watchActiveMapImage().first, isNull);
      await upgraded.setMapImage(Uint8List.fromList([1, 2, 3]), width: 20, height: 10);
      expect((await upgraded.watchActiveMapImage().first)!.width, 20);
      final version = await upgraded.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 6);
      await upgraded.close();

      // Killed half way: one column there, still says 5. Runs again; the picture stays.
      final half = AppDatabase(NativeDatabase(file));
      await half.customStatement('ALTER TABLE encounters DROP COLUMN map_background');
      await half.customStatement('PRAGMA user_version = 5');
      await half.close();
      final reopened = AppDatabase(NativeDatabase(file));
      expect((await reopened.watchEncounterState().first).encounter.mapBackground, 'online');
      expect((await reopened.watchActiveMapImage().first)!.height, 10);
      await reopened.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('uploaded picture: upload selects it, replace gets a new id and keeps the fit, remove; one per encounter', () async {
    expect(await db.watchActiveMapImage().first, isNull);
    final a = await db.setMapImage(Uint8List.fromList([1, 2, 3]), width: 200, height: 100);
    var info = (await db.watchActiveMapImage().first)!;
    expect((info.id, info.width, info.height, info.fit), (a, 200, 100, 'contain'), reason: 'Sığdır by default');
    expect(await db.mapImageBytes(a), [1, 2, 3]);
    expect((await db.activeEncounter()).mapBackground, 'upload', reason: 'uploading selects the upload');

    await db.setMapImageFit('cover');
    await db.setMapBackground('none');
    final b = await db.setMapImage(Uint8List.fromList([9, 9]), width: 50, height: 80);
    info = (await db.watchActiveMapImage().first)!;
    expect(info.id, isNot(a), reason: 'a new id: the decoded image is cached by id');
    expect((info.width, info.height, info.fit), (50, 80, 'cover'), reason: 'a replaced picture keeps its fit');
    expect(await db.select(db.mapImages).get(), hasLength(1), reason: 'replaced, not added');
    expect(await db.mapImageBytes(a), isNull);
    expect((await db.activeEncounter()).mapBackground, 'upload');

    await db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.2, 0.2)]);
    await db.removeMapImage();
    expect(await db.watchActiveMapImage().first, isNull);
    expect(await db.mapImageBytes(b), isNull);
    expect(await db.watchStrokes().first, hasLength(1), reason: 'the drawing stays');

    await db.setMapImage(Uint8List.fromList([4]), width: 1, height: 1);
    await db.newEncounter();
    expect(await db.watchActiveMapImage().first, isNull, reason: 'deleted with its encounter');
    expect(await db.select(db.mapImages).get(), isEmpty);
  });

  test('a new online picture becomes the background; token size is stored per encounter', () async {
    await db.setMapImage(Uint8List.fromList([1]), width: 1, height: 1);
    expect((await db.activeEncounter()).mapBackground, 'upload');
    await db.addScene(assetId: 'a1', png: Uint8List.fromList([1]), mode: 'map', narrative: '', seed: 1);
    expect((await db.activeEncounter()).mapBackground, 'online');
    await db.setTokenScale(0.6);
    expect((await db.watchEncounterState().first).encounter.tokenScale, 0.6);
    await db.newEncounter();
    expect((await db.activeEncounter()).tokenScale, 1.0, reason: 'a new map starts with normal tokens');
  });

  test('"Haritayı tut" carries the uploaded picture, its fit, the token size and the background', () async {
    await db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.2, 0.2)]);
    final id = await db.setMapImage(Uint8List.fromList([7, 7, 7]), width: 300, height: 150);
    await db.setMapImageFit('cover');
    await db.setTokenScale(1.5);
    expect(await db.activeMapContents(), (drawing: true, picture: false, upload: true));
    final old = await db.activeEncounter();
    await db.newEncounter(keepMap: true);
    final e = await db.activeEncounter();
    expect(e.id, isNot(old.id));
    expect((e.tokenScale, e.mapBackground), (1.5, 'upload'));
    final info = (await db.watchActiveMapImage().first)!;
    expect((info.id, info.width, info.fit), (id, 300, 'cover'));
    expect(await db.mapImageBytes(id), [7, 7, 7]);
    expect(await db.watchStrokes().first, hasLength(1));

    await db.newEncounter();
    expect(await db.activeMapContents(), (drawing: false, picture: false, upload: false));
  });
}
