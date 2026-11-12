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

  test('player levels: set, clear, carried into a new encounter', () async {
    final ayla = await db.addCombatant(name: 'Ayla', isPlayer: true, level: 3);
    final bora = await db.addCombatant(name: 'Bora', isPlayer: true);
    await db.addCombatant(name: 'Goblin', monsterId: 'goblin-warrior');
    var s = await state();
    expect({for (final c in s.combatants) c.name: c.level}, {'Ayla': 3, 'Bora': null, 'Goblin': null});
    await db.setLevel(bora, 7);
    await db.setLevel(ayla, null);
    await db.newEncounter(keepPlayers: true);
    s = await state();
    expect({for (final c in s.combatants) c.name: c.level}, {'Ayla': null, 'Bora': 7});
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

  group('the turn follows the combatant through re-sorting', () {
    late int a, b, c;
    Future<String> turn() async {
      final s = await state();
      return '${s.encounter.round}:${s.current?.name}';
    }

    Future<List<String>> names() async => [for (final x in (await state()).combatants) x.name];

    setUp(() async {
      a = await db.addCombatant(name: 'A', initiative: 20);
      b = await db.addCombatant(name: 'B', initiative: 15);
      c = await db.addCombatant(name: 'C', initiative: 10);
    });

    test('the current combatant drops below one who has not acted: that one still acts this round', () async {
      await db.nextTurn(); // B
      await db.setInitiative(b, 5);
      expect(await names(), ['A', 'C', 'B']);
      expect(await turn(), '1:B', reason: "still B's turn");
      await db.nextTurn();
      expect(await turn(), '1:C', reason: 'C has not acted in round 1');
      await db.nextTurn();
      expect(await turn(), '2:A', reason: 'B is not asked twice');
      await db.nextTurn();
      expect(await turn(), '2:C');
      await db.nextTurn();
      expect(await turn(), '2:B');
      await db.nextTurn();
      expect(await turn(), '3:A');
    });

    test('the current combatant rises above those who have acted: they do not act again', () async {
      await db.nextTurn();
      await db.nextTurn(); // C
      await db.setInitiative(c, 25);
      expect(await names(), ['C', 'A', 'B']);
      expect(await turn(), '1:C');
      await db.nextTurn();
      expect(await turn(), '2:C', reason: 'A and B have acted in round 1');
      await db.nextTurn();
      expect(await turn(), '2:A');
    });

    test('another combatant moves across the marker: not skipped, not asked twice', () async {
      await db.nextTurn(); // B
      await db.setInitiative(c, 18); // has not acted, now above B
      expect(await names(), ['A', 'C', 'B']);
      expect(await turn(), '1:B');
      await db.setInitiative(a, 1); // has acted, now below B
      expect(await names(), ['C', 'B', 'A']);
      expect(await turn(), '1:B');
      await db.nextTurn();
      expect(await turn(), '1:C');
      await db.nextTurn();
      expect(await turn(), '2:C', reason: 'A acted at the top of round 1');
    });

    test('a combatant who joins mid-round above the marker acts this round', () async {
      await db.nextTurn();
      await db.nextTurn(); // C
      await db.addCombatant(name: 'Takviye', initiative: 17);
      expect(await turn(), '1:C');
      await db.nextTurn();
      expect(await turn(), '1:Takviye');
      await db.nextTurn();
      expect(await turn(), '2:A');
    });

    test('"previous" walks back through the turns as they were taken', () async {
      await db.nextTurn(); // B
      await db.setInitiative(b, 5); // A, C, B
      await db.nextTurn(); // C
      await db.previousTurn();
      expect(await turn(), '1:B');
      await db.previousTurn();
      expect(await turn(), '1:A');
      await db.previousTurn();
      expect(await turn(), '1:A', reason: 'nothing before the first turn');
      for (var i = 0; i < 3; i++) {
        await db.nextTurn();
      }
      expect(await turn(), '2:A');
      await db.previousTurn();
      expect(await turn(), '1:B', reason: 'the last in the order closes the round');
      await db.previousTurn();
      expect(await turn(), '1:C');
      await db.nextTurn();
      await db.nextTurn();
      expect(await turn(), '2:A');
    });

    test('the current combatant leaves after a re-sort: the turn goes to the next who has not acted', () async {
      await db.nextTurn(); // B
      await db.setInitiative(b, 5); // A, C, B
      await db.removeCombatant(b);
      expect(await turn(), '1:C');
      await db.removeCombatant(a); // acted; C keeps the turn
      expect(await turn(), '1:C');
      await db.nextTurn();
      expect(await turn(), '2:C');
    });

    test('without a record of the turns taken, everyone above the marker has acted', () async {
      await db.nextTurn(); // B
      await db.writeSetting('initiativeActed', null); // an encounter from before the record was kept
      await db.nextTurn();
      expect(await turn(), '1:C');
      await db.previousTurn();
      await db.previousTurn();
      expect(await turn(), '1:A');
    });

    test('a new encounter starts with nobody having acted', () async {
      await db.nextTurn();
      await db.nextTurn();
      await db.newEncounter(keepPlayers: false);
      await db.addCombatant(name: 'X', initiative: 9);
      await db.addCombatant(name: 'Y', initiative: 3);
      expect(await turn(), '1:X');
      await db.nextTurn();
      expect(await turn(), '1:Y');
      await db.nextTurn();
      expect(await turn(), '2:X');
    });
  });

  group('ties', () {
    late int a, b, c, d;
    Future<List<String>> names() async => [for (final x in (await state()).combatants) x.name];

    setUp(() async {
      a = await db.addCombatant(name: 'A', initiative: 12);
      b = await db.addCombatant(name: 'B', initiative: 12);
      c = await db.addCombatant(name: 'C', initiative: 12);
      d = await db.addCombatant(name: 'D', initiative: 5);
    });

    test('equal initiative: creation order until moved; a move swaps with the neighbour', () async {
      expect(await names(), ['A', 'B', 'C', 'D']);
      await db.moveInTie(c, up: true);
      expect(await names(), ['A', 'C', 'B', 'D']);
      await db.moveInTie(c, up: true);
      expect(await names(), ['C', 'A', 'B', 'D']);
      await db.moveInTie(a, up: false);
      expect(await names(), ['C', 'B', 'A', 'D']);
      await db.moveInTie(c, up: false);
      await db.moveInTie(c, up: false);
      expect(await names(), ['B', 'A', 'C', 'D']);
    });

    test('no move across a different initiative or past the ends', () async {
      final order = (await state()).combatants;
      expect(canMoveInTie(order, a, up: true), isFalse);
      expect(canMoveInTie(order, a, up: false), isTrue);
      expect(canMoveInTie(order, c, up: true), isTrue);
      expect(canMoveInTie(order, c, up: false), isFalse, reason: 'D has another initiative');
      expect(canMoveInTie(order, d, up: true), isFalse);
      expect(canMoveInTie(order, d, up: false), isFalse);
      expect(canMoveInTie(order, 999, up: true), isFalse);
      await db.moveInTie(a, up: true);
      await db.moveInTie(c, up: false);
      await db.moveInTie(d, up: true);
      expect(await names(), ['A', 'B', 'C', 'D']);
    });

    test('combatants without an initiative are not a tie', () async {
      final x = await db.addCombatant(name: 'X');
      final y = await db.addCombatant(name: 'Y');
      final order = (await state()).combatants;
      expect(canMoveInTie(order, x, up: false), isFalse);
      expect(canMoveInTie(order, y, up: true), isFalse);
      await db.moveInTie(x, up: false);
      expect(await names(), ['A', 'B', 'C', 'D', 'X', 'Y']);
    });

    test('a combatant who joins an ordered tie goes to its end; an untouched tie stays in creation order', () async {
      await db.moveInTie(c, up: true); // A, C, B
      await db.setInitiative(d, 12);
      expect(await names(), ['A', 'C', 'B', 'D']);
      await db.setInitiative(c, 5);
      await db.setInitiative(a, 5); // joins C at 5: nobody ordered that tie
      expect(await names(), ['B', 'D', 'A', 'C']);
    });

    test('the turn stays with the same combatant when a tie is re-ordered', () async {
      await db.nextTurn(); // B
      await db.moveInTie(b, up: true); // B, A, C, D
      var s = await state();
      expect(s.current!.name, 'B');
      await db.moveInTie(c, up: true); // B, C, A, D
      await db.nextTurn();
      s = await state();
      expect(s.combatants.map((x) => x.name), ['B', 'C', 'A', 'D']);
      expect(s.current!.name, 'C', reason: 'A has acted');
      await db.nextTurn();
      expect((await state()).current!.name, 'D');
    });

    test('rolled initiative that lands in an ordered tie goes to its end', () async {
      await db.moveInTie(b, up: true); // B, A, C
      await db.addCombatant(name: 'Kurt');
      await db.rollMissingInitiative((bonus) => 12);
      expect(await names(), ['B', 'A', 'C', 'Kurt', 'D']);
    });
  });

  test('edit a combatant: name, max HP, AC and level', () async {
    final id = await db.addCombatant(name: 'Gobiln', hp: 7, ac: 15, initiative: 9);
    final pc = await db.addCombatant(name: 'Ayla', isPlayer: true, hp: 20, level: 3, initiative: 12);
    await db.toggleCondition(id, 'prone');
    await db.updateCombatant(id, name: 'Goblin', hpMax: 12, ac: 13);
    var g = (await state()).combatants.firstWhere((x) => x.id == id);
    expect((g.name, g.hpCurrent, g.hpMax, g.ac), ('Goblin', 12, 12, 13), reason: 'unhurt: stays at full HP');
    expect(g.initiative, 9);
    expect(g.conditionIds, ['prone']);

    await db.changeHp(id, 9); // 3/12
    await db.updateCombatant(id, name: 'Goblin', hpMax: 20, ac: 13);
    g = (await state()).combatants.firstWhere((x) => x.id == id);
    expect((g.hpCurrent, g.hpMax), (3, 20), reason: 'a hurt creature keeps its current HP');
    await db.updateCombatant(id, name: 'Goblin', hpMax: 2, ac: null);
    g = (await state()).combatants.firstWhere((x) => x.id == id);
    expect((g.hpCurrent, g.hpMax, g.ac), (2, 2, null), reason: 'never above the new maximum');
    await db.updateCombatant(id, name: 'Goblin', hpMax: null, ac: null);
    g = (await state()).combatants.firstWhere((x) => x.id == id);
    expect((g.hpCurrent, g.hpMax), (null, null));
    await db.updateCombatant(id, name: 'Goblin', hpMax: 9, ac: null);
    g = (await state()).combatants.firstWhere((x) => x.id == id);
    expect((g.hpCurrent, g.hpMax), (9, 9));

    await db.updateCombatant(pc, name: 'Ayla', hpMax: 20, ac: 16, level: 4);
    final p = (await state()).combatants.firstWhere((x) => x.id == pc);
    expect((p.ac, p.level, p.isPlayer), (16, 4, true));
    await db.updateCombatant(pc, name: 'Ayla', hpMax: 20, ac: 16, level: null);
    expect((await state()).combatants.firstWhere((x) => x.id == pc).level, isNull);
  });

  test('new encounter deletes the old one and its combatants', () async {
    await db.addCombatant(name: 'Goblin', hp: 7);
    await db.newEncounter(keepPlayers: false);
    expect(await db.select(db.encounters).get(), hasLength(1));
    expect(await db.select(db.combatants).get(), isEmpty);
  });
}
