/// Local user data (drift / SQLite): settings, session notes, the initiative
/// tracker and its battle map. Reference data is NOT stored here; it ships as
/// assets.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Encounters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get round => integer().withDefault(const Constant(1))();

  /// Index into the initiative-sorted combatant list: whose turn it is. It
  /// follows that combatant when the order changes; who has already acted
  /// this round is kept beside it (see `AppDatabase._acted`).
  IntColumn get turnIndex => integer().withDefault(const Constant(0))();

  /// Becomes true at the first "next turn". Before that the marker stays on
  /// the top of the order while combatants are added and initiative is rolled.
  BoolColumn get started => boolean().withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  /// Battle-map token size, a factor of the painter's token radius: 0.6
  /// (Küçük), 1.0 (Orta) or 1.5 (Büyük). (schema 6)
  RealColumn get tokenScale => real().withDefault(const Constant(1.0))();

  /// The picture chosen under the battle map: `none` (the drawing alone),
  /// `upload` (the user's own picture, [MapImages]) or `online` (the newest
  /// [MapScenes] picture). A choice whose picture does not exist falls back
  /// to the other picture, then to none (`shownBackground`). (schema 6)
  TextColumn get mapBackground => text().withDefault(const Constant('online'))();
}

class Combatants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get encounterId => integer().references(Encounters, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get initiative => integer().nullable()();
  IntColumn get initBonus => integer().withDefault(const Constant(0))();
  IntColumn get hpCurrent => integer().nullable()();
  IntColumn get hpMax => integer().nullable()();
  IntColumn get ac => integer().nullable()();
  BoolColumn get isPlayer => boolean().withDefault(const Constant(false))();

  /// Comma-separated condition ids (e.g. "prone,poisoned").
  TextColumn get conditions => text().withDefault(const Constant(''))();

  /// Source monster id, when added from the bestiary.
  TextColumn get monsterId => text().nullable()();

  /// Tie-break for equal initiative (lower first).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  /// Token position on the battle map, 0..1 of the map's width and height;
  /// null while the token is not on the map. (schema 2)
  RealColumn get posX => real().nullable()();
  RealColumn get posY => real().nullable()();

  /// A player character's level (1–20) for encounter difficulty; null uses
  /// the party level setting. (schema 4)
  IntColumn get level => integer().nullable()();
}

/// One stroke of an encounter's battle map (schema 2): a pen line, or (schema
/// 5) a stroke of the area brush ("Alan": water, road, forest…), painted under
/// the lines and sent to the online scene as a separate region layer.
class MapStrokes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get encounterId => integer().references(Encounters, #id, onDelete: KeyAction.cascade)();

  /// Points as "x,y x,y …", each coordinate 0..1 of the map's side.
  TextColumn get points => text()();

  /// Index into the map palette (0 ink, 1 water, 2 plants, 3 danger).
  IntColumn get color => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  /// Area brush: the region kind (`RegionKind.index`: 0 water, 1 road,
  /// 2 forest, 3 stone floor, 4 wall, 5 sand); null for a pen line. (schema 5)
  IntColumn get region => integer().nullable()();

  /// Area brush width, 0..1 of the map's side; null for a pen line. (schema 5)
  RealColumn get width => real().nullable()();
}

/// A picture made online from an encounter's map sketch (schema 3). Kept
/// here because the service deletes results after 7 days.
class MapScenes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get encounterId => integer().references(Encounters, #id, onDelete: KeyAction.cascade)();

  /// The service's asset id (for reporting).
  TextColumn get assetId => text()();
  BlobColumn get png => blob()();

  /// `map` or `atmosphere`.
  TextColumn get mode => text()();
  TextColumn get narrative => text().withDefault(const Constant(''))();
  IntColumn get seed => integer()();

  /// Reported by the user: never shown again.
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// A picture the user loaded as an encounter's battle map (schema 6): a
/// ready-made map or a photo of a hand-drawn one. At most one per encounter;
/// loading another replaces it. Kept apart from [MapScenes]: it has no
/// server id, is never reported, pruned or sent anywhere, and stays on the
/// device (and in the backups the user makes).
class MapImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get encounterId => integer().unique().references(Encounters, #id, onDelete: KeyAction.cascade)();

  /// The file as picked (PNG, JPEG, WebP, GIF), or a PNG scaled down to
  /// 2048 px on its longer side when the file was too large.
  BlobColumn get bytes => blob()();

  /// Size in pixels as shown (after an EXIF rotation).
  IntColumn get width => integer()();
  IntColumn get height => integer()();

  /// How a non-square picture sits in the square map: `contain` (Sığdır:
  /// all of it, paper around it) or `cover` (Doldur: centre-cropped).
  TextColumn get fit => text().withDefault(const Constant('contain'))();
  DateTimeColumn get createdAt => dateTime()();
}

extension CombatantX on Combatant {
  List<String> get conditionIds => conditions.isEmpty ? const [] : conditions.split(',');
  bool get isDown => hpCurrent != null && hpCurrent! <= 0;
  Offset01? get mapPosition => posX == null || posY == null ? null : Offset01(posX!, posY!);
}

/// A point on the battle map in map units: 0..1 of its side, so the same map
/// looks the same on a phone and on a tablet.
class Offset01 {
  const Offset01(this.x, this.y);
  final double x;
  final double y;

  @override
  bool operator ==(Object other) => other is Offset01 && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
  @override
  String toString() => 'Offset01($x, $y)';
}

/// "x,y x,y …" with 4 decimals (0.1 mm on a 1 m map: plenty).
String encodePoints(List<Offset01> points) =>
    points.map((p) => '${p.x.toStringAsFixed(4)},${p.y.toStringAsFixed(4)}').join(' ');

List<Offset01> decodePoints(String s) {
  if (s.isEmpty) return const [];
  return [
    for (final pair in s.split(' '))
      if (pair.contains(','))
        Offset01(double.parse(pair.substring(0, pair.indexOf(','))), double.parse(pair.substring(pair.indexOf(',') + 1))),
  ];
}

extension MapStrokeX on MapStroke {
  List<Offset01> get offsets => decodePoints(points);

  /// A stroke of the area brush (painted region), not a pen line.
  bool get isRegion => region != null;
}

/// Initiative order: highest initiative first, unrolled at the end, then the
/// manual tie-break and creation order.
List<Combatant> initiativeOrder(Iterable<Combatant> list) {
  final out = [...list];
  out.sort((a, b) {
    final ai = a.initiative, bi = b.initiative;
    if (ai != bi) {
      if (ai == null) return 1;
      if (bi == null) return -1;
      return bi.compareTo(ai);
    }
    final c = a.sortOrder.compareTo(b.sortOrder);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  return out;
}

/// Whether the combatant [id] can swap places with its neighbour above
/// ([up]) or below in [order] (initiative order): only with one that has the
/// same initiative, so only the order within a tie changes. Combatants
/// without an initiative are not a tie: they have no place in the order yet.
bool canMoveInTie(List<Combatant> order, int id, {required bool up}) {
  final i = order.indexWhere((c) => c.id == id);
  final j = up ? i - 1 : i + 1;
  if (i < 0 || j < 0 || j >= order.length) return false;
  return order[i].initiative != null && order[j].initiative == order[i].initiative;
}

class EncounterState {
  const EncounterState(this.encounter, this.combatants);

  final Encounter encounter;

  /// In initiative order.
  final List<Combatant> combatants;

  Combatant? get current =>
      combatants.isEmpty ? null : combatants[encounter.turnIndex.clamp(0, combatants.length - 1)];
}

/// The user's own battle-map picture without its bytes: what the map needs
/// to lay it out ([AppDatabase.watchActiveMapImage]). Equal when nothing
/// shown changed, so turns (which re-run the query) rebuild nothing.
class MapImageInfo {
  const MapImageInfo({required this.id, required this.width, required this.height, required this.fit});
  final int id;
  final int width;
  final int height;

  /// `contain` or `cover` ([MapImages.fit]).
  final String fit;

  @override
  bool operator ==(Object other) => other is MapImageInfo && other.id == id && other.width == width && other.height == height && other.fit == fit;
  @override
  int get hashCode => Object.hash(id, width, height, fit);
}

@DriftDatabase(tables: [Settings, Notes, Encounters, Combatants, MapStrokes, MapScenes, MapImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'gm_cebi'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // One transaction, and every step checks first: drift writes the new
        // user_version only after this callback, so a migration interrupted
        // half way (app killed) must be able to run again on the next start.
        onUpgrade: (m, from, to) => transaction(() async {
          if (from < 2) {
            if (!await _hasColumn('combatants', 'pos_x')) await m.addColumn(combatants, combatants.posX);
            if (!await _hasColumn('combatants', 'pos_y')) await m.addColumn(combatants, combatants.posY);
            await m.createTable(mapStrokes); // CREATE TABLE IF NOT EXISTS
          }
          if (from < 3) await m.createTable(mapScenes); // CREATE TABLE IF NOT EXISTS
          if (from < 4 && !await _hasColumn('combatants', 'level')) await m.addColumn(combatants, combatants.level);
          if (from < 5) {
            // Old strokes keep null: pen lines, as before.
            if (!await _hasColumn('map_strokes', 'region')) await m.addColumn(mapStrokes, mapStrokes.region);
            if (!await _hasColumn('map_strokes', 'width')) await m.addColumn(mapStrokes, mapStrokes.width);
          }
          if (from < 6) {
            // Old encounters: normal tokens, the online picture shown when there is one (as before).
            if (!await _hasColumn('encounters', 'token_scale')) await m.addColumn(encounters, encounters.tokenScale);
            if (!await _hasColumn('encounters', 'map_background')) await m.addColumn(encounters, encounters.mapBackground);
            await m.createTable(mapImages); // CREATE TABLE IF NOT EXISTS
          }
        }),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ------------------------------------------------------------ settings

  Future<Map<String, String>> readSettings() async {
    final rows = await select(settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> writeSetting(String key, String? value) async {
    if (value == null) {
      await (delete(settings)..where((s) => s.key.equals(key))).go();
    } else {
      await into(settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
    }
  }

  // ------------------------------------------------------------ notes

  Stream<List<Note>> watchNotes() => (select(notes)
        ..orderBy([
          (n) => OrderingTerm.desc(n.pinned),
          (n) => OrderingTerm.desc(n.updatedAt),
          (n) => OrderingTerm.desc(n.id),
        ]))
      .watch();

  Future<Note?> getNote(int id) => (select(notes)..where((n) => n.id.equals(id))).getSingleOrNull();

  Future<int> createNote({String title = '', String body = '', DateTime? now}) {
    final t = now ?? DateTime.now();
    return into(notes).insert(NotesCompanion.insert(title: Value(title), body: Value(body), createdAt: t, updatedAt: t));
  }

  Future<void> updateNote(int id, {String? title, String? body, bool? pinned, DateTime? now}) =>
      (update(notes)..where((n) => n.id.equals(id))).write(NotesCompanion(
        title: title == null ? const Value.absent() : Value(title),
        body: body == null ? const Value.absent() : Value(body),
        pinned: pinned == null ? const Value.absent() : Value(pinned),
        updatedAt: Value(now ?? DateTime.now()),
      ));

  Future<void> deleteNote(int id) => (delete(notes)..where((n) => n.id.equals(id))).go();

  // ------------------------------------------------------------ encounters

  /// The active encounter, created on first use.
  Future<Encounter> activeEncounter() async {
    final e = await (select(encounters)
          ..where((e) => e.active.equals(true))
          ..orderBy([(e) => OrderingTerm.desc(e.id)])
          ..limit(1))
        .getSingleOrNull();
    if (e != null) return e;
    final id = await into(encounters).insert(EncountersCompanion.insert(createdAt: DateTime.now()));
    return (select(encounters)..where((e) => e.id.equals(id))).getSingle();
  }

  /// The active encounter with its combatants in initiative order; re-emits on
  /// any change to either table.
  Stream<EncounterState> watchEncounterState() {
    return customSelect(
      'SELECT e.id FROM encounters e WHERE e.active = 1',
      readsFrom: {encounters, combatants},
    ).watch().asyncMap((_) async {
      final e = await activeEncounter();
      final list = await (select(combatants)..where((c) => c.encounterId.equals(e.id))).get();
      return EncounterState(e, initiativeOrder(list));
    });
  }

  Future<int> addCombatant({
    required String name,
    int? initiative,
    int initBonus = 0,
    int? hp,
    int? ac,
    bool isPlayer = false,
    String? monsterId,
    int? level,
  }) =>
      _reordering((e) async => into(combatants).insert(CombatantsCompanion.insert(
            encounterId: e.id,
            name: name,
            initiative: Value(initiative),
            initBonus: Value(initBonus),
            hpCurrent: Value(hp),
            hpMax: Value(hp),
            ac: Value(ac),
            isPlayer: Value(isPlayer),
            monsterId: Value(monsterId),
            level: Value(level),
            sortOrder: Value(await _tieEnd(e.id, initiative)),
            createdAt: DateTime.now(),
          )));

  /// Sets (or, with null, clears) a player's level.
  Future<void> setLevel(int id, int? level) =>
      (update(combatants)..where((c) => c.id.equals(id))).write(CombatantsCompanion(level: Value(level)));

  /// "Düzenle": the name, the HP maximum, the armor class and (players) the
  /// level. Current HP follows the maximum: an unhurt creature stays at full
  /// HP, a hurt one keeps its HP (never above the new maximum); without a
  /// maximum no HP is tracked.
  Future<void> updateCombatant(int id, {required String name, required int? hpMax, required int? ac, int? level}) =>
      transaction(() async {
        final c = await (select(combatants)..where((c) => c.id.equals(id))).getSingleOrNull();
        if (c == null) return;
        final hurt = c.hpCurrent != null && c.hpMax != null && c.hpCurrent! < c.hpMax!;
        final hp = hpMax == null ? null : (hurt && c.hpCurrent! < hpMax ? c.hpCurrent : hpMax);
        await (update(combatants)..where((c) => c.id.equals(id))).write(CombatantsCompanion(
          name: Value(name),
          hpMax: Value(hpMax),
          hpCurrent: Value(hp),
          ac: Value(ac),
          level: Value(c.isPlayer ? level : null),
        ));
      });

  /// Sets (or clears) one combatant's initiative. Only the initiative and the
  /// place within a tie are written. The turn stays with whoever has it.
  Future<void> setInitiative(int id, int? initiative) => _reordering((e) async {
        final c = await (select(combatants)..where((c) => c.id.equals(id))).getSingleOrNull();
        if (c == null || c.initiative == initiative) return;
        await (update(combatants)..where((c) => c.id.equals(id))).write(CombatantsCompanion(
          initiative: Value(initiative),
          sortOrder: Value(await _tieEnd(c.encounterId, initiative)),
        ));
      });

  /// "Yukarı taşı" / "Aşağı taşı": swaps a combatant with its neighbour of the
  /// same initiative (see [canMoveInTie]); otherwise nothing happens.
  Future<void> moveInTie(int id, {required bool up}) => _reordering((e) async {
        final order = await _order(e);
        if (!canMoveInTie(order, id, up: up)) return;
        final i = order.indexWhere((c) => c.id == id);
        final tie = [for (final c in order) if (c.initiative == order[i].initiative) c.id];
        final at = tie.indexOf(id);
        tie[at] = tie[up ? at - 1 : at + 1];
        tie[up ? at - 1 : at + 1] = id;
        await batch((b) {
          for (var k = 0; k < tie.length; k++) {
            b.update(combatants, CombatantsCompanion(sortOrder: Value(k)), where: (x) => x.id.equals(tie[k]));
          }
        });
      });

  Future<void> removeCombatant(int id) => transaction(() async {
        final e = await activeEncounter();
        final before = await _order(e);
        final idx = before.indexWhere((c) => c.id == id);
        if (idx < 0) return;
        final currentIdx = e.turnIndex.clamp(0, before.length - 1);
        final acted = (await _acted(e, before))..remove(id);
        await (delete(combatants)..where((c) => c.id.equals(id))).go();
        final order = [...before]..removeAt(idx);
        if (order.isEmpty) return _setTurn(e, e.round, 0, const []);
        if (idx != currentIdx) {
          // Whoever has the turn keeps it.
          return _setTurn(e, e.round, order.indexWhere((c) => c.id == before[currentIdx].id), acted);
        }
        // The current creature left: the turn passes to the next one who has
        // not acted, or to the top of the next round.
        final next = order.indexWhere((c) => !acted.contains(c.id));
        await (next < 0 ? _setTurn(e, e.started ? e.round + 1 : e.round, 0, const []) : _setTurn(e, e.round, next, acted));
      });

  /// Applies damage (positive) or healing (negative), clamped to 0..max.
  Future<void> changeHp(int id, int damage) async {
    final c = await (select(combatants)..where((c) => c.id.equals(id))).getSingle();
    if (c.hpCurrent == null) return;
    var hp = c.hpCurrent! - damage;
    if (hp < 0) hp = 0;
    if (c.hpMax != null && hp > c.hpMax!) hp = c.hpMax!;
    await (update(combatants)..where((x) => x.id.equals(id))).write(CombatantsCompanion(hpCurrent: Value(hp)));
  }

  Future<void> toggleCondition(int id, String conditionId) async {
    final c = await (select(combatants)..where((c) => c.id.equals(id))).getSingle();
    final ids = [...c.conditionIds];
    ids.contains(conditionId) ? ids.remove(conditionId) : ids.add(conditionId);
    await (update(combatants)..where((x) => x.id.equals(id)))
        .write(CombatantsCompanion(conditions: Value(ids.join(','))));
  }

  /// Rolls initiative (d20 + bonus) for every non-player combatant that has none.
  Future<void> rollMissingInitiative(int Function(int bonus) rollD20) => _reordering((e) async {
        final list = await (select(combatants)
              ..where((c) => c.encounterId.equals(e.id))
              ..orderBy([(c) => OrderingTerm.asc(c.id)]))
            .get();
        for (final c in list) {
          if (c.initiative != null || c.isPlayer) continue;
          final v = rollD20(c.initBonus);
          await (update(combatants)..where((x) => x.id.equals(c.id)))
              .write(CombatantsCompanion(initiative: Value(v), sortOrder: Value(await _tieEnd(e.id, v))));
        }
      });

  /// The turn passes to the first combatant in the order who has not acted
  /// this round; when everyone has, the next round starts at the top.
  Future<void> nextTurn() => transaction(() async {
        final e = await activeEncounter();
        final order = await _order(e);
        if (order.isEmpty) return;
        if (!e.started) {
          await (update(encounters)..where((x) => x.id.equals(e.id))).write(const EncountersCompanion(started: Value(true)));
        }
        final acted = [...await _acted(e, order), order[e.turnIndex.clamp(0, order.length - 1)].id];
        final next = order.indexWhere((c) => !acted.contains(c.id));
        await (next < 0 ? _setTurn(e, e.round + 1, 0, const []) : _setTurn(e, e.round, next, acted));
      });

  /// Back to whoever acted before the current combatant; from the top of a
  /// round, to the last in the order of the round before.
  Future<void> previousTurn() => transaction(() async {
        final e = await activeEncounter();
        final order = await _order(e);
        if (order.isEmpty) return;
        final acted = await _acted(e, order);
        if (acted.isNotEmpty) {
          final previous = acted.removeLast();
          await _setTurn(e, e.round, order.indexWhere((c) => c.id == previous), acted);
        } else if (e.round > 1) {
          await _setTurn(e, e.round - 1, order.length - 1, [for (final c in order.take(order.length - 1)) c.id]);
        }
      });

  /// Deletes the active encounter (and, by cascade, its combatants, its map,
  /// its uploaded picture and its online pictures) and starts an empty one.
  /// Player characters can be carried over with full HP and off the map.
  /// With [keepMap] the drawing (lines and areas, with their ids), the
  /// uploaded picture with its fit, the online picture in use (the newest one
  /// not reported), the token size and the background choice move to the new
  /// encounter; older online pictures are deleted.
  Future<void> newEncounter({bool keepPlayers = true, bool keepMap = false}) async {
    await transaction(() async {
      final e = await activeEncounter();
      final players = keepPlayers
          ? await (select(combatants)..where((c) => c.encounterId.equals(e.id) & c.isPlayer.equals(true))).get()
          : <Combatant>[];
      final id = await into(encounters).insert(EncountersCompanion.insert(
        createdAt: DateTime.now(),
        tokenScale: keepMap ? Value(e.tokenScale) : const Value.absent(),
        mapBackground: keepMap ? Value(e.mapBackground) : const Value.absent(),
      ));
      for (final p in players) {
        await into(combatants).insert(p.toCompanion(false).copyWith(
              id: const Value.absent(),
              encounterId: Value(id),
              initiative: const Value(null),
              conditions: const Value(''),
              hpCurrent: Value(p.hpMax),
              sortOrder: const Value(0),
              posX: const Value(null),
              posY: const Value(null),
            ));
      }
      if (keepMap) {
        await (update(mapStrokes)..where((s) => s.encounterId.equals(e.id))).write(MapStrokesCompanion(encounterId: Value(id)));
        final picture = await (select(mapScenes)
              ..where((s) => s.encounterId.equals(e.id) & s.hidden.equals(false))
              ..orderBy([(s) => OrderingTerm.desc(s.id)])
              ..limit(1))
            .getSingleOrNull();
        if (picture != null) {
          await (update(mapScenes)..where((s) => s.id.equals(picture.id))).write(MapScenesCompanion(encounterId: Value(id)));
        }
        await (update(mapImages)..where((i) => i.encounterId.equals(e.id))).write(MapImagesCompanion(encounterId: Value(id)));
      }
      await (delete(encounters)..where((x) => x.id.equals(e.id))).go();
      await writeSetting(_actedKey, null);
    });
  }

  /// What [newEncounter] deletes, or with `keepMap` carries over, of the
  /// active encounter's map: a drawing (lines or areas), an online picture in
  /// use and the user's uploaded picture.
  Future<({bool drawing, bool picture, bool upload})> activeMapContents() async {
    final e = await activeEncounter();
    final stroke = await (selectOnly(mapStrokes)
          ..addColumns([mapStrokes.id])
          ..where(mapStrokes.encounterId.equals(e.id))
          ..limit(1))
        .get();
    final picture = await (selectOnly(mapScenes)
          ..addColumns([mapScenes.id])
          ..where(mapScenes.encounterId.equals(e.id) & mapScenes.hidden.equals(false))
          ..limit(1))
        .get();
    final upload = await (selectOnly(mapImages)
          ..addColumns([mapImages.id])
          ..where(mapImages.encounterId.equals(e.id)))
        .get();
    return (drawing: stroke.isNotEmpty, picture: picture.isNotEmpty, upload: upload.isNotEmpty);
  }

  // ------------------------------------------------------------ battle map

  /// Strokes of the active encounter's map, oldest first. Watches the stroke
  /// rows themselves, so every added or removed stroke emits.
  Stream<List<MapStroke>> watchStrokes() {
    final q = select(mapStrokes).join([innerJoin(encounters, encounters.id.equalsExp(mapStrokes.encounterId))])
      ..where(encounters.active.equals(true))
      ..orderBy([OrderingTerm.asc(mapStrokes.id)]);
    return q.watch().map((rows) => [for (final r in rows) r.readTable(mapStrokes)]);
  }

  /// A pen line in palette [color], or with [region] (and its [width], 0..1
  /// of the map's side) a stroke of the area brush.
  Future<int> addStroke(List<Offset01> points, {int color = 0, int? region, double? width}) async {
    assert((region == null) == (width == null), 'an area stroke has a kind and a width');
    final e = await activeEncounter();
    return into(mapStrokes).insert(MapStrokesCompanion.insert(
      encounterId: e.id,
      points: encodePoints(points),
      color: Value(color),
      createdAt: DateTime.now(),
      region: Value(region),
      width: Value(width),
    ));
  }

  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.data['name'] == column);
  }

  Future<void> deleteStrokes(Iterable<int> ids) => (delete(mapStrokes)..where((s) => s.id.isIn(ids))).go();

  /// Puts deleted strokes back with their ids (undo of the eraser or "clear").
  Future<void> restoreStrokes(Iterable<MapStroke> rows) =>
      batch((b) => b.insertAll(mapStrokes, rows, mode: InsertMode.insertOrIgnore));

  /// Removes the newest stroke (line or area) of the active map (undo).
  Future<void> undoStroke() async {
    final e = await activeEncounter();
    final last = await (select(mapStrokes)
          ..where((s) => s.encounterId.equals(e.id))
          ..orderBy([(s) => OrderingTerm.desc(s.id)])
          ..limit(1))
        .getSingleOrNull();
    if (last != null) await deleteStrokes([last.id]);
  }

  /// Clears the drawing, lines and areas; tokens stay where they are.
  Future<void> clearStrokes() async {
    final e = await activeEncounter();
    await (delete(mapStrokes)..where((s) => s.encounterId.equals(e.id))).go();
  }

  /// Puts a token on the map (clamped to it) or, with null, takes it off.
  Future<void> setTokenPosition(int combatantId, Offset01? p) =>
      (update(combatants)..where((c) => c.id.equals(combatantId))).write(CombatantsCompanion(
        posX: Value(p?.x.clamp(0.0, 1.0)),
        posY: Value(p?.y.clamp(0.0, 1.0)),
      ));

  /// "Jetonları kaldır": every token of the active encounter off the map, in one write.
  Future<void> clearTokenPositions() async {
    final e = await activeEncounter();
    await (update(combatants)..where((c) => c.encounterId.equals(e.id)))
        .write(const CombatantsCompanion(posX: Value(null), posY: Value(null)));
  }

  /// "Jeton boyutu" of the active encounter's map (see [Encounters.tokenScale]).
  Future<void> setTokenScale(double scale) async {
    final e = await activeEncounter();
    await (update(encounters)..where((x) => x.id.equals(e.id))).write(EncountersCompanion(tokenScale: Value(scale)));
  }

  /// "Arka plan": `none`, `upload` or `online` (see [Encounters.mapBackground]).
  Future<void> setMapBackground(String background) async {
    final e = await activeEncounter();
    await (update(encounters)..where((x) => x.id.equals(e.id))).write(EncountersCompanion(mapBackground: Value(background)));
  }

  // ------------------------------------------------------------ uploaded map picture

  /// The active encounter's uploaded picture, without its bytes. The query
  /// joins encounters, so it re-runs on every turn; compare with `distinct`.
  Stream<MapImageInfo?> watchActiveMapImage() => customSelect(
        'SELECT i.id, i.width, i.height, i.fit FROM map_images i JOIN encounters e ON e.id = i.encounter_id WHERE e.active = 1 '
        'ORDER BY i.id DESC LIMIT 1',
        readsFrom: {mapImages, encounters},
      ).watch().map((rows) => rows.isEmpty
          ? null
          : MapImageInfo(
              id: rows.first.read<int>('id'),
              width: rows.first.read<int>('width'),
              height: rows.first.read<int>('height'),
              fit: rows.first.read<String>('fit')));

  /// The bytes of an uploaded picture; null if it is gone.
  Future<Uint8List?> mapImageBytes(int id) async {
    final row = await (selectOnly(mapImages)
          ..addColumns([mapImages.bytes])
          ..where(mapImages.id.equals(id)))
        .getSingleOrNull();
    return row?.read(mapImages.bytes);
  }

  /// "Harita resmi yükle" / "Resmi değiştir": the active encounter's picture
  /// becomes [bytes] (a new row, so a new id: the decoded image is cached by
  /// id) and is shown. A replaced picture's fit is kept. Returns the new id.
  Future<int> setMapImage(Uint8List bytes, {required int width, required int height}) => transaction(() async {
        final e = await activeEncounter();
        final old = await (select(mapImages)..where((i) => i.encounterId.equals(e.id))).getSingleOrNull();
        await (delete(mapImages)..where((i) => i.encounterId.equals(e.id))).go();
        final id = await into(mapImages).insert(MapImagesCompanion.insert(
          encounterId: e.id,
          bytes: bytes,
          width: width,
          height: height,
          fit: old == null ? const Value.absent() : Value(old.fit),
          createdAt: DateTime.now(),
        ));
        await (update(encounters)..where((x) => x.id.equals(e.id))).write(const EncountersCompanion(mapBackground: Value('upload')));
        return id;
      });

  /// "Resmi kaldır": the drawing and the tokens stay.
  Future<void> removeMapImage() async {
    final e = await activeEncounter();
    await (delete(mapImages)..where((i) => i.encounterId.equals(e.id))).go();
  }

  /// "Sığdır" (`contain`) or "Doldur" (`cover`).
  Future<void> setMapImageFit(String fit) async {
    final e = await activeEncounter();
    await (update(mapImages)..where((i) => i.encounterId.equals(e.id))).write(MapImagesCompanion(fit: Value(fit)));
  }


  // ------------------------------------------------------------ online scenes

  /// The newest picture of the active encounter that is not hidden.
  Stream<MapScene?> watchActiveScene() {
    final q = select(mapScenes).join([innerJoin(encounters, encounters.id.equalsExp(mapScenes.encounterId))])
      ..where(encounters.active.equals(true) & mapScenes.hidden.equals(false))
      ..orderBy([OrderingTerm.desc(mapScenes.id)])
      ..limit(1);
    return q.watch().map((rows) => rows.isEmpty ? null : rows.first.readTable(mapScenes));
  }

  /// Pictures kept per encounter (reported ones included); storing a new one
  /// deletes the older ones.
  static const maxScenesPerEncounter = 5;

  /// Stores a picture with [encounterId] (the encounter the sketch belonged
  /// to; default the active one), makes it that encounter's background and
  /// prunes its older pictures ([maxScenesPerEncounter]). Nothing is stored
  /// if that encounter is gone.
  Future<int?> addScene({required String assetId, required Uint8List png, required String mode, required String narrative, required int seed, int? encounterId}) async {
    final id = encounterId ?? (await activeEncounter()).id;
    final exists = await (select(encounters)..where((e) => e.id.equals(id))).getSingleOrNull();
    if (exists == null) return null;
    return transaction(() async {
      final row = await into(mapScenes).insert(MapScenesCompanion.insert(
        encounterId: id,
        assetId: assetId,
        png: png,
        mode: mode,
        narrative: Value(narrative),
        seed: seed,
        createdAt: DateTime.now(),
      ));
      await (update(encounters)..where((x) => x.id.equals(id))).write(const EncountersCompanion(mapBackground: Value('online')));
      await _pruneScenes(id);
      return row;
    });
  }

  /// Keeps the newest [maxScenesPerEncounter] pictures of [encounterId]. Also
  /// drops the bytes of pictures reported before [hideScene] did so itself.
  Future<void> _pruneScenes(int encounterId) async {
    final keep = await (selectOnly(mapScenes)
          ..addColumns([mapScenes.id])
          ..where(mapScenes.encounterId.equals(encounterId))
          ..orderBy([OrderingTerm.desc(mapScenes.id)])
          ..limit(maxScenesPerEncounter))
        .map((r) => r.read(mapScenes.id)!)
        .get();
    await (delete(mapScenes)..where((s) => s.encounterId.equals(encounterId) & s.id.isNotIn(keep))).go();
    await (update(mapScenes)..where((s) => s.hidden.equals(true) & s.png.length.isBiggerThanValue(0)))
        .write(MapScenesCompanion(png: Value(Uint8List(0))));
  }

  /// After a report: the picture's bytes are deleted at once (they must not
  /// stay on the device or in its backup). The emptied row stays as a marker:
  /// hidden, never shown again.
  Future<void> hideScene(int id) => (update(mapScenes)..where((s) => s.id.equals(id)))
      .write(MapScenesCompanion(hidden: const Value(true), png: Value(Uint8List(0))));

  Future<void> deleteScene(int id) => (delete(mapScenes)..where((s) => s.id.equals(id))).go();

  /// "Delete my data": every online picture of every encounter.
  Future<void> deleteAllScenes() => delete(mapScenes).go();

  Future<List<Combatant>> _order(Encounter e) async =>
      initiativeOrder(await (select(combatants)..where((c) => c.encounterId.equals(e.id))).get());

  /// Settings key for who has had a turn this round: the encounter id, a
  /// colon, then combatant ids in the order the turns were taken ("7:12,15"),
  /// the current combatant not included. Kept beside [Encounters.turnIndex]
  /// (and in the key-value table, so the schema stays as it is) so that a
  /// re-sort (a changed initiative, a newcomer, a re-ordered tie) neither
  /// skips anyone nor asks anyone twice in the round.
  static const _actedKey = 'initiativeActed';

  /// Who has acted this round, in the order the turns were taken; [order] is
  /// the initiative order [Encounters.turnIndex] points into. Without a record
  /// for this encounter (one from before the record was kept) that is everyone
  /// above the marker.
  Future<List<int>> _acted(Encounter e, List<Combatant> order) async {
    if (!e.started || order.isEmpty) return [];
    final turn = e.turnIndex.clamp(0, order.length - 1);
    final row = await (select(settings)..where((s) => s.key.equals(_actedKey))).getSingleOrNull();
    final colon = row?.value.indexOf(':') ?? -1;
    if (row == null || colon < 0 || row.value.substring(0, colon) != '${e.id}') {
      return [for (final c in order.take(turn)) c.id];
    }
    final waiting = {for (final c in order) if (c.id != order[turn].id) c.id};
    return [
      for (final s in row.value.substring(colon + 1).split(','))
        if (int.tryParse(s) case final id? when waiting.remove(id)) id,
    ];
  }

  /// Runs [change], which may re-sort the order, and leaves the turn with the
  /// combatant who had it (before combat starts: on the top of the order).
  /// Who has acted this round does not change, so a combatant who moves
  /// across the marker is neither skipped nor asked twice.
  Future<T> _reordering<T>(Future<T> Function(Encounter e) change) => transaction(() async {
        final e = await activeEncounter();
        final before = await _order(e);
        final current = before.isEmpty ? null : before[e.turnIndex.clamp(0, before.length - 1)].id;
        final acted = await _acted(e, before);
        final result = await change(e);
        if (!e.started) {
          if (e.turnIndex != 0) await _setTurn(e, e.round, 0, const []);
        } else if (current != null) {
          final idx = (await _order(e)).indexWhere((c) => c.id == current);
          if (idx >= 0) await _setTurn(e, e.round, idx, acted);
        }
        return result;
      });

  /// The tie-break for a combatant that gets [initiative]: after the others
  /// with the same initiative once that tie has been ordered by hand
  /// ([moveInTie]); until then 0, which leaves a tie in creation order.
  Future<int> _tieEnd(int encounterId, int? initiative) async {
    final tie = await (select(combatants)
          ..where((c) => c.encounterId.equals(encounterId) & (initiative == null ? c.initiative.isNull() : c.initiative.equals(initiative))))
        .get();
    var last = 0;
    for (final c in tie) {
      if (c.sortOrder > last) last = c.sortOrder;
    }
    return tie.any((c) => c.sortOrder != 0) ? last + 1 : 0;
  }

  Future<void> _setTurn(Encounter e, int round, int turn, List<int> acted) async {
    await (update(encounters)..where((x) => x.id.equals(e.id)))
        .write(EncountersCompanion(round: Value(round), turnIndex: Value(turn)));
    await writeSetting(_actedKey, '${e.id}:${acted.join(',')}');
  }
}
