import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/backup/backup.dart';

AppDatabase _open() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Every row of every table, as SQL stores it.
Future<Map<String, List<Map<String, Object?>>>> dump(AppDatabase db) async => {
      for (final t in db.allTables)
        t.actualTableName: [
          for (final r in await db.customSelect('SELECT * FROM "${t.actualTableName}" ORDER BY rowid').get()) r.data,
        ],
    };

/// A database with rows in every table and every column set: two encounters
/// (an old one and the active one), a mid-round turn record, pen lines and
/// painted areas, a picture and a reported (emptied) one.
Future<AppDatabase> populated() async {
  final db = _open();
  await db.writeSetting('contentLang', 'en');
  await db.writeSetting('themeMode', 'light');
  await db.writeSetting('partyLevel', '5');
  await db.writeSetting('mapPenMode', 'true');
  await db.writeSetting('ncConsent', 'true');
  await db.writeSetting('ncEnabled', 'false');
  await db.writeSetting('gmPackOverride', 'true');
  await db.writeSetting(lastBackupAtKey, '2026-11-01T10:00:00.000Z');
  await db.createNote(title: 'Oturum 1', body: 'Goblin pususu\nköprüde', now: DateTime(2026, 10, 1, 19, 5));
  final n2 = await db.createNote(title: 'Şehir', body: 'Çarşı', now: DateTime(2026, 10, 8, 20));
  await db.updateNote(n2, pinned: true, now: DateTime(2026, 10, 9));
  // An old encounter, then a new one: ids do not start at 1.
  await db.addCombatant(name: 'Eski');
  await db.newEncounter(keepPlayers: false);
  await db.addCombatant(name: 'Ayla', initiative: 12, isPlayer: true, hp: 24, ac: 15, level: 3);
  final goblin = await db.addCombatant(name: 'Goblin', initiative: 18, initBonus: 2, hp: 7, ac: 15, monsterId: 'goblin-warrior');
  await db.addCombatant(name: 'Kurt', initiative: 5, hp: 11, ac: 13);
  await db.toggleCondition(goblin, 'prone');
  await db.changeHp(goblin, 3);
  await db.setTokenPosition(goblin, const Offset01(0.25, 0.75));
  await db.nextTurn(); // Goblin acted, Ayla's turn
  await db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.2, 0.3)], color: 1);
  await db.addStroke(const [Offset01(0.5, 0.5), Offset01(0.6, 0.6)], region: 2, width: 0.05);
  await db.addScene(assetId: 'a1', png: Uint8List.fromList([137, 80, 78, 71, 0, 255]), mode: 'map', narrative: 'Orman', seed: 42);
  final hidden = await db.addScene(assetId: 'a2', png: Uint8List.fromList([1, 2, 3]), mode: 'atmosphere', narrative: '', seed: 7);
  await db.hideScene(hidden!);
  return db;
}

Future<Map<String, Object?>> exportJson(AppDatabase db) async =>
    jsonDecode(utf8.decode(await exportBackupBytes(db, now: DateTime.utc(2026, 11, 12, 14, 5)))) as Map<String, Object?>;

Future<void> importJson(AppDatabase db, Object json) => restoreBackup(db, parseBackup(db, utf8.encode(jsonEncode(json))));

Future<BackupException> refusal(AppDatabase db, Object? json) async {
  try {
    await restoreBackup(db, parseBackup(db, json is Uint8List ? json : utf8.encode(jsonEncode(json))));
  } on BackupException catch (e) {
    return e;
  }
  fail('not refused');
}

void main() {
  test('round trip: every table equal, ids kept, turn order still works', () async {
    final source = await populated();
    final json = await exportJson(source);
    expect(json['format'], 'gm-cebi-backup');
    expect(json['version'], 1);
    expect(json['schemaVersion'], source.schemaVersion);
    expect(json['createdAt'], '2026-11-12T14:05:00.000Z');
    final before = await dump(source);

    final target = _open();
    await target.createNote(title: 'Silinecek');
    await target.writeSetting('ncConsent', 'false');
    await importJson(target, json);
    final after = await dump(target);

    expect(after['notes'], before['notes']);
    expect(after['encounters'], before['encounters']);
    expect(after['combatants'], before['combatants']);
    expect(after['map_strokes'], before['map_strokes']);
    // The reported picture (no bytes) is not in the backup.
    expect(after['map_scenes'], [before['map_scenes']!.first]);
    expect(after['map_scenes']!.single['png'], [137, 80, 78, 71, 0, 255]);
    Map<String, Object?> userSettings(List<Map<String, Object?>> rows) =>
        {for (final r in rows) if (!deviceBoundSettings.contains(r['key'])) r['key'] as String: r['value']};
    expect(userSettings(after['settings']!), userSettings(before['settings']!));
    expect(userSettings(after['settings']!), contains('initiativeActed'));
    expect((await target.readSettings())['ncConsent'], 'false'); // this device's

    // Mid-round: Ayla's turn, Goblin has acted; Kurt is next, then round 2.
    var s = await target.watchEncounterState().first;
    expect(s.current!.name, 'Ayla');
    await target.nextTurn();
    s = await target.watchEncounterState().first;
    expect(s.current!.name, 'Kurt');
    await target.nextTurn();
    s = await target.watchEncounterState().first;
    expect((s.encounter.round, s.current!.name), (2, 'Goblin'));
    expect((await target.watchStrokes().first).where((x) => x.isRegion).single.width, 0.05);
    expect((await target.watchActiveScene().first)!.narrative, 'Orman');
    await source.close();
    await target.close();
  });

  test('encodings: ISO-8601 UTC dates, base64 blobs, booleans', () async {
    final db = await populated();
    final tables = (await exportJson(db))['tables'] as Map<String, Object?>;
    final note = (tables['notes'] as List).first as Map<String, Object?>;
    expect(note['created_at'], DateTime(2026, 10, 1, 19, 5).toUtc().toIso8601String());
    expect(note['pinned'], false);
    final scene = (tables['map_scenes'] as List).single as Map<String, Object?>;
    expect(scene['png'], base64Encode([137, 80, 78, 71, 0, 255]));
    expect(scene['hidden'], false);
    await db.close();
  });

  test('device-bound settings are neither exported nor overwritten', () async {
    final db = await populated();
    final json = await exportJson(db);
    final keys = [for (final r in ((json['tables'] as Map)['settings'] as List)) (r as Map)['key']];
    expect(keys, containsAll(['contentLang', 'themeMode', 'partyLevel', 'mapPenMode', 'initiativeActed']));
    for (final k in deviceBoundSettings) {
      expect(keys, isNot(contains(k)));
    }
    // A hand-made file that carries them anyway: ignored.
    ((json['tables'] as Map)['settings'] as List).addAll([
      {'key': 'ncConsent', 'value': 'true'},
      {'key': 'gmPackOverride', 'value': 'true'},
      {'key': lastBackupAtKey, 'value': '2020-01-01T00:00:00.000Z'},
    ]);
    final target = _open();
    await target.writeSetting('ncConsent', 'false');
    await target.writeSetting('gmPackOverride', 'false');
    await target.writeSetting('ncEnabled', 'true');
    await target.writeSetting(lastBackupAtKey, '2026-11-11T09:00:00.000Z');
    await target.writeSetting('themeMode', 'dark');
    await importJson(target, json);
    final m = await target.readSettings();
    expect(m['ncConsent'], 'false');
    expect(m['gmPackOverride'], 'false');
    expect(m['ncEnabled'], 'true');
    expect(m[lastBackupAtKey], '2026-11-11T09:00:00.000Z');
    expect(m['themeMode'], 'light'); // the backup's
    await db.close();
    await target.close();
  });

  // Fails when a table or a column is added: put it in populated() (so the
  // round trip covers it) and here, or exclude the table in
  // backupExcludedTables on purpose.
  test('every table and column is covered by the backup', () async {
    final db = await populated();
    const known = {
      'settings': ['key', 'value'],
      'notes': ['id', 'title', 'body', 'pinned', 'created_at', 'updated_at'],
      'encounters': ['id', 'name', 'round', 'turn_index', 'started', 'active', 'created_at'],
      'combatants': [
        'id', 'encounter_id', 'name', 'initiative', 'init_bonus', 'hp_current', 'hp_max', 'ac', 'is_player', 'conditions', //
        'monster_id', 'sort_order', 'created_at', 'pos_x', 'pos_y', 'level',
      ],
      'map_strokes': ['id', 'encounter_id', 'points', 'color', 'created_at', 'region', 'width'],
      'map_scenes': ['id', 'encounter_id', 'asset_id', 'png', 'mode', 'narrative', 'seed', 'hidden', 'created_at'],
    };
    expect({for (final t in db.allTables) t.actualTableName: [for (final c in t.$columns) c.name]}, known);
    final tables = (await exportJson(db))['tables'] as Map<String, Object?>;
    for (final t in db.allTables) {
      final name = t.actualTableName;
      if (backupExcludedTables.contains(name)) continue;
      expect(tables.keys, contains(name), reason: '$name is neither backed up nor excluded');
      final rows = (tables[name] as List).cast<Map<String, Object?>>();
      expect(rows, isNotEmpty, reason: 'populated() has no $name row');
      for (final c in t.$columns) {
        expect(rows.every((r) => r.containsKey(c.name)), isTrue, reason: '$name.${c.name} is not exported');
        if (c.$nullable) expect(rows.any((r) => r[c.name] != null), isTrue, reason: 'populated() never sets $name.${c.name}');
      }
    }
    await db.close();
  });

  test('an older-schema file imports with defaults', () async {
    // Schema 1: no map tables, no token positions, no player levels; one
    // combatant even without columns that have a default.
    final v1 = {
      'format': 'gm-cebi-backup',
      'version': 1,
      'schemaVersion': 1,
      'createdAt': '2026-09-01T18:00:00.000Z',
      'app': '0.1.0',
      'tables': {
        'settings': [
          {'key': 'partyLevel', 'value': '3'},
        ],
        'notes': [
          {'id': 4, 'title': 'Eski not', 'body': 'Metin', 'pinned': true, 'created_at': '2026-09-01T18:00:00.000Z', 'updated_at': '2026-09-01T18:30:00.000Z'},
        ],
        'encounters': [
          {'id': 2, 'name': '', 'round': 3, 'turn_index': 1, 'started': true, 'active': true, 'created_at': '2026-09-01T18:00:00.000Z'},
        ],
        'combatants': [
          {'id': 5, 'encounter_id': 2, 'name': 'Ork', 'initiative': 15, 'created_at': '2026-09-01T18:00:00.000Z', 'old_column': 'ignored'},
          {
            'id': 6, 'encounter_id': 2, 'name': 'Ayla', 'initiative': 10, 'init_bonus': 1, 'hp_current': 20, 'hp_max': 24, 'ac': 15, //
            'is_player': true, 'conditions': 'prone', 'monster_id': null, 'sort_order': 0, 'created_at': '2026-09-01T18:00:00.000Z',
          },
        ],
      },
    };
    final db = _open();
    await db.addStroke(const [Offset01(0, 0), Offset01(1, 1)]);
    await importJson(db, v1);
    final s = await db.watchEncounterState().first;
    expect(s.encounter.id, 2);
    expect(s.encounter.round, 3);
    expect(s.combatants.map((c) => c.name), ['Ork', 'Ayla']);
    expect(s.current!.name, 'Ayla');
    final ork = s.combatants.first;
    expect((ork.initBonus, ork.isPlayer, ork.conditions, ork.sortOrder, ork.posX, ork.level), (0, false, '', 0, null, null));
    expect(s.combatants.last.level, isNull);
    expect(await db.watchStrokes().first, isEmpty);
    final note = (await db.watchNotes().first).single;
    expect((note.id, note.title, note.pinned), (4, 'Eski not', true));
    expect(note.updatedAt.toUtc(), DateTime.utc(2026, 9, 1, 18, 30));
    expect((await db.readSettings())['partyLevel'], '3');
    await db.close();
  });

  test('refusals: garbage, wrong format, missing tables, newer schema, too large', () async {
    final db = await populated();
    final before = await dump(db);
    final good = await exportJson(db);

    expect((await refusal(db, Uint8List.fromList(utf8.encode('{ yarım')))).message, notABackupMessage);
    expect((await refusal(db, Uint8List.fromList([0xff, 0xfe, 0x00]))).message, notABackupMessage);
    expect((await refusal(db, [1, 2, 3])).message, notABackupMessage);
    expect((await refusal(db, {...good, 'format': 'başka-uygulama'})).message, notABackupMessage);
    expect((await refusal(db, {...good}..remove('tables'))).message, notABackupMessage);
    final missing = {...good, 'tables': {...(good['tables'] as Map)}..remove('notes')};
    expect((await refusal(db, missing)).message, notABackupMessage);
    final badType = jsonDecode(jsonEncode(good)) as Map<String, Object?>;
    (((badType['tables'] as Map)['notes'] as List).first as Map)['created_at'] = 12;
    expect((await refusal(db, badType)).message, notABackupMessage);
    expect((await refusal(db, {...good, 'schemaVersion': db.schemaVersion + 1})).message, newerBackupMessage);
    expect((await refusal(db, {...good, 'version': 2})).message, newerBackupMessage);
    expect((await refusal(db, Uint8List(maxBackupBytes + 1))).message, tooLargeMessage);

    expect(await dump(db), before);
    await db.close();
  });

  test('a row that breaks a constraint mid-file rolls everything back', () async {
    final db = await populated();
    final before = await dump(db);
    final good = await exportJson(db);

    // Two notes with the same id: the second insert fails after the deletes
    // and the first rows went in.
    final dup = jsonDecode(jsonEncode(good)) as Map<String, Object?>;
    final notes = (dup['tables'] as Map)['notes'] as List;
    notes.add({...notes.first as Map, 'title': 'kopya'});
    expect((await refusal(db, dup)).message, restoreFailedMessage);
    expect(await dump(db), before);

    // A combatant of an encounter that is not in the file.
    final dangling = jsonDecode(jsonEncode(good)) as Map<String, Object?>;
    (((dangling['tables'] as Map)['combatants'] as List).last as Map)['encounter_id'] = 999;
    expect((await refusal(db, dangling)).message, restoreFailedMessage);
    expect(await dump(db), before);

    // A required column missing (no default).
    final noName = jsonDecode(jsonEncode(good)) as Map<String, Object?>;
    (((noName['tables'] as Map)['combatants'] as List).first as Map).remove('name');
    expect((await refusal(db, noName)).message, restoreFailedMessage);
    expect(await dump(db), before);
    await db.close();
  });

  test('restore refreshes watching queries', () async {
    final db = _open();
    final source = await populated();
    final json = await exportJson(source);
    final seen = <int>[];
    final sub = db.watchNotes().listen((n) => seen.add(n.length));
    await pumpEventQueue();
    await importJson(db, json);
    await pumpEventQueue();
    expect(seen.last, 2);
    await sub.cancel();
    await db.close();
    await source.close();
  });

  test('backup file name', () {
    expect(backupFileName(DateTime(2026, 1, 5)), 'gm-cebi-yedek-2026-01-05.json');
  });
}
