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

  Future<EncounterState> state() => db.watchEncounterState().first;

  test('settings round trip', () async {
    await db.writeSetting('lang', 'en');
    expect((await db.readSettings())['lang'], 'en');
    await db.writeSetting('lang', null);
    expect(await db.readSettings(), isEmpty);
  });

  test('notes: create, update, pin ordering, delete', () async {
    final t0 = DateTime(2026, 10, 1);
    final a = await db.createNote(title: 'Oturum 1', now: t0);
    final b = await db.createNote(title: 'Oturum 2', now: t0.add(const Duration(days: 7)));
    var list = await db.watchNotes().first;
    expect(list.map((n) => n.id), [b, a]);
    await db.updateNote(a, pinned: true, body: 'Goblin pususu', now: t0.add(const Duration(days: 8)));
    list = await db.watchNotes().first;
    expect(list.first.id, a);
    expect(list.first.body, 'Goblin pususu');
    await db.deleteNote(a);
    expect((await db.watchNotes().first).map((n) => n.id), [b]);
  });

  test('initiative order, turns and rounds', () async {
    await db.addCombatant(name: 'Ayla', initiative: 12, isPlayer: true, hp: 24, ac: 15);
    await db.addCombatant(name: 'Goblin', initiative: 18, hp: 7, ac: 15);
    await db.addCombatant(name: 'Kurt', initiative: 5, hp: 11, ac: 13);
    var s = await state();
    expect(s.combatants.map((c) => c.name), ['Goblin', 'Ayla', 'Kurt']);
    expect(s.current!.name, 'Goblin');
    expect(s.encounter.round, 1);

    await db.nextTurn();
    await db.nextTurn();
    s = await state();
    expect(s.current!.name, 'Kurt');
    await db.nextTurn();
    s = await state();
    expect(s.encounter.round, 2);
    expect(s.current!.name, 'Goblin');
    await db.previousTurn();
    s = await state();
    expect(s.encounter.round, 1);
    expect(s.current!.name, 'Kurt');
  });

  test('adding a combatant keeps the turn on the same creature', () async {
    await db.addCombatant(name: 'A', initiative: 10);
    await db.addCombatant(name: 'B', initiative: 5);
    await db.nextTurn(); // B's turn
    await db.addCombatant(name: 'C', initiative: 20); // sorts before both
    final s = await state();
    expect(s.combatants.map((c) => c.name), ['C', 'A', 'B']);
    expect(s.current!.name, 'B');
  });

  test('removing the current or an earlier combatant fixes the marker', () async {
    final a = await db.addCombatant(name: 'A', initiative: 20);
    await db.addCombatant(name: 'B', initiative: 10);
    await db.addCombatant(name: 'C', initiative: 5);
    await db.nextTurn(); // B
    await db.removeCombatant(a);
    expect((await state()).current!.name, 'B');
  });

  test('HP is clamped and conditions toggle', () async {
    final id = await db.addCombatant(name: 'Goblin', hp: 7);
    await db.changeHp(id, 10);
    var c = (await state()).combatants.single;
    expect(c.hpCurrent, 0);
    expect(c.isDown, isTrue);
    await db.changeHp(id, -100);
    c = (await state()).combatants.single;
    expect(c.hpCurrent, 7);
    await db.toggleCondition(id, 'prone');
    await db.toggleCondition(id, 'poisoned');
    await db.toggleCondition(id, 'prone');
    c = (await state()).combatants.single;
    expect(c.conditionIds, ['poisoned']);
  });

  test('roll missing initiative only for monsters without one', () async {
    await db.addCombatant(name: 'PC', isPlayer: true);
    await db.addCombatant(name: 'Ork', initBonus: 1);
    await db.addCombatant(name: 'Kurt', initiative: 3);
    await db.rollMissingInitiative((bonus) => 10 + bonus);
    final s = await state();
    expect({for (final c in s.combatants) c.name: c.initiative}, {'Ork': 11, 'Kurt': 3, 'PC': null});
    expect(s.combatants.last.name, 'PC'); // unrolled last
  });

  test('new encounter keeps players with full HP', () async {
    final pc = await db.addCombatant(name: 'Ayla', isPlayer: true, hp: 20, initiative: 9);
    await db.addCombatant(name: 'Goblin', hp: 7);
    await db.changeHp(pc, 5);
    await db.nextTurn();
    await db.newEncounter();
    final s = await state();
    expect(s.combatants.map((c) => c.name), ['Ayla']);
    expect(s.combatants.single.hpCurrent, 20);
    expect(s.combatants.single.initiative, isNull);
    expect(s.encounter.round, 1);
    expect(s.encounter.turnIndex, 0);
    expect(s.encounter.started, isFalse);
  });

  test('before combat starts the marker stays on top', () async {
    await db.addCombatant(name: 'A', initiative: 5);
    await db.addCombatant(name: 'B', initiative: 15);
    expect((await state()).current!.name, 'B');
  });

  test('rolling missing initiative mid-combat keeps the turn marker', () async {
    await db.addCombatant(name: 'A', initiative: 20);
    await db.addCombatant(name: 'B', initiative: 10);
    await db.nextTurn(); // B, combat started
    await db.addCombatant(name: 'Takviye', initBonus: 0); // no initiative yet
    await db.rollMissingInitiative((bonus) => 15); // sorts between A and B
    final s = await state();
    expect(s.combatants.map((c) => c.name), ['A', 'Takviye', 'B']);
    expect(s.current!.name, 'B');
  });

  test('removing the current creature when it is last passes the turn to the next round', () async {
    await db.addCombatant(name: 'A', initiative: 20);
    final b = await db.addCombatant(name: 'B', initiative: 10);
    await db.nextTurn(); // B
    await db.removeCombatant(b);
    final s = await state();
    expect(s.current!.name, 'A');
    expect(s.encounter.round, 2);
  });

  test('setInitiative writes only the initiative column', () async {
    final id = await db.addCombatant(name: 'Goblin', hp: 7, initiative: 5);
    await db.changeHp(id, 3);
    await db.setInitiative(id, 12);
    final c = (await state()).combatants.single;
    expect(c.initiative, 12);
    expect(c.hpCurrent, 4);
  });

  test('new encounter deletes the old one and its combatants', () async {
    await db.addCombatant(name: 'Goblin', hp: 7);
    await db.newEncounter(keepPlayers: false);
    expect(await db.select(db.encounters).get(), hasLength(1));
    expect(await db.select(db.combatants).get(), isEmpty);
  });
}
