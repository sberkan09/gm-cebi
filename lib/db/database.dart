/// Local user data (drift / SQLite): settings, session notes and the
/// initiative tracker. Reference data is NOT stored here; it ships as assets.
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

  /// Index into the initiative-sorted combatant list.
  IntColumn get turnIndex => integer().withDefault(const Constant(0))();

  /// Becomes true at the first "next turn". Before that the marker stays on
  /// the top of the order while combatants are added and initiative is rolled.
  BoolColumn get started => boolean().withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
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
}

extension CombatantX on Combatant {
  List<String> get conditionIds => conditions.isEmpty ? const [] : conditions.split(',');
  bool get isDown => hpCurrent != null && hpCurrent! <= 0;
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

class EncounterState {
  const EncounterState(this.encounter, this.combatants);

  final Encounter encounter;

  /// In initiative order.
  final List<Combatant> combatants;

  Combatant? get current =>
      combatants.isEmpty ? null : combatants[encounter.turnIndex.clamp(0, combatants.length - 1)];
}

@DriftDatabase(tables: [Settings, Notes, Encounters, Combatants])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'gm_cebi'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
  }) async {
    final e = await activeEncounter();
    final current = await _currentCombatantId(e);
    final id = await into(combatants).insert(CombatantsCompanion.insert(
      encounterId: e.id,
      name: name,
      initiative: Value(initiative),
      initBonus: Value(initBonus),
      hpCurrent: Value(hp),
      hpMax: Value(hp),
      ac: Value(ac),
      isPlayer: Value(isPlayer),
      monsterId: Value(monsterId),
      createdAt: DateTime.now(),
    ));
    await _keepTurnOn(e, current);
    return id;
  }

  Future<void> updateCombatant(Combatant c) async {
    final e = await activeEncounter();
    final current = await _currentCombatantId(e);
    await update(combatants).replace(c);
    await _keepTurnOn(e, current);
  }

  Future<void> removeCombatant(int id) async {
    final e = await activeEncounter();
    final order = await _order(e);
    final idx = order.indexWhere((c) => c.id == id);
    await (delete(combatants)..where((c) => c.id.equals(id))).go();
    if (idx >= 0 && idx < e.turnIndex) {
      await _setTurn(e, e.round, e.turnIndex - 1);
    } else if (e.turnIndex >= order.length - 1) {
      await _setTurn(e, e.round, 0);
    }
  }

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
  Future<void> rollMissingInitiative(int Function(int bonus) rollD20) async {
    final e = await activeEncounter();
    final list = await (select(combatants)..where((c) => c.encounterId.equals(e.id))).get();
    await batch((b) {
      for (final c in list) {
        if (c.initiative == null && !c.isPlayer) {
          b.update(combatants, CombatantsCompanion(initiative: Value(rollD20(c.initBonus))),
              where: (x) => x.id.equals(c.id));
        }
      }
    });
    await _setTurn(e, e.round, 0);
  }

  Future<void> nextTurn() async {
    final e = await activeEncounter();
    final n = (await _order(e)).length;
    if (n == 0) return;
    if (!e.started) {
      await (update(encounters)..where((x) => x.id.equals(e.id))).write(const EncountersCompanion(started: Value(true)));
    }
    final next = e.turnIndex + 1;
    await (next >= n ? _setTurn(e, e.round + 1, 0) : _setTurn(e, e.round, next));
  }

  Future<void> previousTurn() async {
    final e = await activeEncounter();
    final n = (await _order(e)).length;
    if (n == 0) return;
    if (e.turnIndex > 0) {
      await _setTurn(e, e.round, e.turnIndex - 1);
    } else if (e.round > 1) {
      await _setTurn(e, e.round - 1, n - 1);
    }
  }

  /// Ends the active encounter and starts an empty one. Player characters can be kept.
  Future<void> newEncounter({bool keepPlayers = true}) async {
    final e = await activeEncounter();
    final players = keepPlayers
        ? await (select(combatants)..where((c) => c.encounterId.equals(e.id) & c.isPlayer.equals(true))).get()
        : <Combatant>[];
    await transaction(() async {
      await (update(encounters)..where((x) => x.id.equals(e.id))).write(const EncountersCompanion(active: Value(false)));
      final id = await into(encounters).insert(EncountersCompanion.insert(createdAt: DateTime.now()));
      for (final p in players) {
        await into(combatants).insert(p.toCompanion(false).copyWith(
              id: const Value.absent(),
              encounterId: Value(id),
              initiative: const Value(null),
              conditions: const Value(''),
              hpCurrent: Value(p.hpMax),
            ));
      }
    });
  }

  Future<List<Combatant>> _order(Encounter e) async =>
      initiativeOrder(await (select(combatants)..where((c) => c.encounterId.equals(e.id))).get());

  Future<int?> _currentCombatantId(Encounter e) async {
    final o = await _order(e);
    return o.isEmpty ? null : o[e.turnIndex.clamp(0, o.length - 1)].id;
  }

  /// After a re-sort, keeps the turn marker on the same combatant once combat
  /// has started; before that it stays on the first combatant.
  Future<void> _keepTurnOn(Encounter e, int? combatantId) async {
    if (!e.started) {
      if (e.turnIndex != 0) await _setTurn(e, e.round, 0);
      return;
    }
    if (combatantId == null) return;
    final o = await _order(e);
    final idx = o.indexWhere((c) => c.id == combatantId);
    if (idx >= 0 && idx != e.turnIndex) await _setTurn(e, e.round, idx);
  }

  Future<void> _setTurn(Encounter e, int round, int turn) =>
      (update(encounters)..where((x) => x.id.equals(e.id)))
          .write(EncountersCompanion(round: Value(round), turnIndex: Value(turn)));
}
