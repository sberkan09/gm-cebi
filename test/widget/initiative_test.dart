import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';

import 'harness.dart';
import 'map_test.dart' show combatant, pumped, strokesOf;

Future<EncounterState> encounter(WidgetTester tester, AppDatabase db) => pumped(tester, db.watchEncounterState().first);

Future<List<String>> names(WidgetTester tester, AppDatabase db) async =>
    [for (final c in (await encounter(tester, db)).combatants) c.name];

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.ensureVisible(f);
  await settle(tester);
  await tester.tap(f);
  await settle(tester);
}

Future<void> openNewEncounterDialog(WidgetTester tester) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await settle(tester);
  await tester.tap(find.text('Yeni karşılaşma'));
  await settle(tester);
}

String dialogText(WidgetTester tester) => tester
    .widgetList<Text>(find.descendant(of: find.byType(AlertDialog), matching: find.byType(Text)))
    .map((t) => t.data)
    .join('\n');

/// On how many lines a text was laid out.
int lineCount(RenderParagraph p) => p
    .getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: p.text.toPlainText().length))
    .map((b) => b.top)
    .toSet()
    .length;

void main() {
  group('new encounter', () {
    Future<void> fight(WidgetTester tester, AppDatabase db, {bool drawing = true}) async {
      final ayla = await pumped(tester, db.addCombatant(name: 'Ayla', initiative: 17, hp: 24, isPlayer: true));
      await pumped(tester, db.addCombatant(name: 'Goblin', initiative: 12, hp: 7));
      await pumped(tester, db.setTokenPosition(ayla, const Offset01(0.3, 0.3)));
      if (drawing) {
        await pumped(tester, db.addStroke(const [Offset01(0.1, 0.1), Offset01(0.9, 0.9)]));
        await pumped(tester, db.addStroke(const [Offset01(0.2, 0.2), Offset01(0.8, 0.3)], region: 0, width: 0.09));
      }
      await openTab(tester, 'İnisiyatif');
    }

    appTest('the dialog says what is deleted; "Haritayı tut" is ticked and the drawing moves to the new encounter', gmPack: true,
        (tester, db) async {
      await fight(tester, db);
      final before = await strokesOf(tester, db);
      await openNewEncounterDialog(tester);
      final text = dialogText(tester);
      expect(text, contains('silinir'));
      expect(text, contains('jetonların haritadaki yerleri'));
      expect(text, contains('Bu geri alınamaz'));
      expect(text, isNot(contains('kapanır')), reason: 'the old text did not say anything is deleted');
      expect(tester.widget<CheckboxListTile>(find.byKey(const Key('keep-map'))).value, isTrue, reason: 'there is a drawing to lose');
      expect(tester.widget<Text>(find.byKey(const Key('keep-map-effect'))).data, 'Harita çizimi (çizgiler ve alanlar) yeni karşılaşmaya taşınır.');

      await tapKey(tester, 'new-encounter-players');
      expect(find.byType(AlertDialog), findsNothing);
      expect(await names(tester, db), ['Ayla']);
      final after = await strokesOf(tester, db);
      expect(after.map((s) => s.id), before.map((s) => s.id));
      expect(after.map((s) => s.encounterId).toSet(), {(await encounter(tester, db)).encounter.id});
      expect(after[1].isRegion, isTrue);
      expect((await encounter(tester, db)).combatants.single.mapPosition, isNull, reason: 'tokens come off the map');
    });

    appTest('unticked, the dialog says the drawing is deleted, and it is', gmPack: true, (tester, db) async {
      await fight(tester, db);
      await openNewEncounterDialog(tester);
      await tapKey(tester, 'keep-map');
      expect(tester.widget<CheckboxListTile>(find.byKey(const Key('keep-map'))).value, isFalse);
      expect(tester.widget<Text>(find.byKey(const Key('keep-map-effect'))).data, 'Harita çizimi (çizgiler ve alanlar) silinir.');
      await tapKey(tester, 'new-encounter-all');
      expect(await names(tester, db), isEmpty);
      expect(await strokesOf(tester, db), isEmpty);
    });

    appTest('my uploaded map picture is named in the dialog and moves with "Haritayı tut", with its fit and the token size', gmPack: true,
        (tester, db) async {
      await fight(tester, db);
      final picture = await pumped(tester, db.setMapImage(Uint8List.fromList([1, 2, 3]), width: 40, height: 20));
      await pumped(tester, db.setMapImageFit('cover'));
      await pumped(tester, db.setTokenScale(0.6));
      await openNewEncounterDialog(tester);
      expect(tester.widget<Text>(find.byKey(const Key('keep-map-effect'))).data,
          'Harita çizimi (çizgiler ve alanlar) ve yüklediğin harita resmi yeni karşılaşmaya taşınır.');
      await tapKey(tester, 'keep-map');
      expect(tester.widget<Text>(find.byKey(const Key('keep-map-effect'))).data,
          'Harita çizimi (çizgiler ve alanlar) ve yüklediğin harita resmi silinir.');
      await tapKey(tester, 'keep-map');
      await tapKey(tester, 'new-encounter-players');
      final e = (await encounter(tester, db)).encounter;
      final row = await pumped(tester, db.select(db.mapImages).getSingle());
      expect((row.id, row.encounterId, row.fit), (picture, e.id, 'cover'));
      expect(e.tokenScale, 0.6);
    });

    appTest('a picture alone is kept by default, and named alone', gmPack: true, (tester, db) async {
      await fight(tester, db, drawing: false);
      await pumped(tester, db.setMapImage(Uint8List.fromList([1]), width: 1, height: 1));
      await openNewEncounterDialog(tester);
      expect(tester.widget<CheckboxListTile>(find.byKey(const Key('keep-map'))).value, isTrue, reason: 'my own picture is not lost by default');
      expect(tester.widget<Text>(find.byKey(const Key('keep-map-effect'))).data, 'Yüklediğin harita resmi yeni karşılaşmaya taşınır.');
    });

    appTest('without a drawing there is nothing to keep: no checkbox; "Vazgeç" changes nothing', gmPack: true, (tester, db) async {
      await fight(tester, db, drawing: false);
      await openNewEncounterDialog(tester);
      expect(find.byKey(const Key('keep-map')), findsNothing);
      expect(dialogText(tester), contains('silinir'));
      await tester.tap(find.text('Vazgeç'));
      await settle(tester);
      expect(await names(tester, db), ['Ayla', 'Goblin']);
    });

    appTest('the dialog fits a small phone at large text', gmPack: true, surface: const Size(360, 640), (tester, db) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await fight(tester, db);
      await openNewEncounterDialog(tester);
      expect(tester.takeException(), isNull);
      await tapKey(tester, 'new-encounter-players');
      expect(await names(tester, db), ['Ayla']);
      expect(await strokesOf(tester, db), hasLength(2));
    });
  });

  appTest('the card of the current combatant is scrolled into view when the turn changes', gmPack: true, surface: const Size(412, 915),
      (tester, db) async {
    for (var i = 0; i < 12; i++) {
      await pumped(tester, db.addCombatant(name: 'C$i', initiative: 30 - i, hp: 10, ac: 12));
    }
    await openTab(tester, 'İnisiyatif');
    final list = find.byKey(const Key('combatant-list'));
    Future<void> expectCurrentVisible(String name) async {
      final s = await encounter(tester, db);
      expect(s.current!.name, name);
      expect(find.text('Sıra: $name'), findsOneWidget);
      final card = tester.getRect(find.byKey(ValueKey('combatant-${s.current!.id}')));
      final view = tester.getRect(list);
      expect(card.top, greaterThanOrEqualTo(view.top), reason: '$name: the card starts above the list');
      expect(card.bottom, lessThanOrEqualTo(view.bottom), reason: '$name: the card ends below the list');
    }

    for (var i = 1; i <= 11; i++) {
      await tester.tap(find.byKey(const Key('next-turn')));
      await settle(tester);
      await expectCurrentVisible('C$i');
    }
    await tester.tap(find.byKey(const Key('next-turn'))); // round 2: back to the top
    await settle(tester);
    expect(find.text('2. tur'), findsOneWidget);
    await expectCurrentVisible('C0');
    await tester.tap(find.byKey(const Key('prev-turn'))); // and to the bottom again
    await settle(tester);
    await expectCurrentVisible('C11');

    // The current combatant moves in the order: the list follows it.
    final c11 = (await encounter(tester, db)).current!.id;
    await pumped(tester, db.setInitiative(c11, 40));
    await settle(tester);
    await expectCurrentVisible('C11');
  });

  appTest('text that is not a number does not clear the initiative', gmPack: true, (tester, db) async {
    final id = await pumped(tester, db.addCombatant(name: 'Ayla', initiative: 17, isPlayer: true));
    await pumped(tester, db.addCombatant(name: 'Goblin', initiative: 5));
    await openTab(tester, 'İnisiyatif');
    await tester.tap(find.text('17'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('initiative-field')), '1-8');
    await tapKey(tester, 'initiative-save');
    expect(find.text('Geçerli bir sayı yaz'), findsOneWidget, reason: 'the same error as in the add dialog');
    expect(find.byKey(const Key('initiative-field')), findsOneWidget, reason: 'the dialog stays open');
    expect((await combatant(tester, db, id)).initiative, 17);
    expect(await names(tester, db), ['Ayla', 'Goblin']);

    await tester.enterText(find.byKey(const Key('initiative-field')), '-');
    await settle(tester);
    expect(find.text('Geçerli bir sayı yaz'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('initiative-field')), '3');
    await settle(tester);
    expect(find.text('Geçerli bir sayı yaz'), findsNothing);
    await tapKey(tester, 'initiative-save');
    expect((await combatant(tester, db, id)).initiative, 3);
    expect(await names(tester, db), ['Goblin', 'Ayla']);

    // An empty field still means "no initiative".
    await tester.tap(find.text('3'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('initiative-field')), '');
    await tapKey(tester, 'initiative-save');
    expect((await combatant(tester, db, id)).initiative, isNull);
  });

  appTest('changing the initiative of the combatant whose turn it is skips nobody', gmPack: true, (tester, db) async {
    await pumped(tester, db.addCombatant(name: 'A', initiative: 20));
    await pumped(tester, db.addCombatant(name: 'B', initiative: 15));
    await pumped(tester, db.addCombatant(name: 'C', initiative: 10));
    await openTab(tester, 'İnisiyatif');
    await tester.tap(find.byKey(const Key('next-turn')));
    await settle(tester);
    expect(find.text('Sıra: B'), findsOneWidget);
    await tester.tap(find.text('15'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('initiative-field')), '5');
    await tapKey(tester, 'initiative-save');
    expect(await names(tester, db), ['A', 'C', 'B']);
    expect(find.text('Sıra: B'), findsOneWidget);
    await tester.tap(find.byKey(const Key('next-turn')));
    await settle(tester);
    expect(find.text('Sıra: C'), findsOneWidget);
    expect(find.text('1. tur'), findsOneWidget);
    await tester.tap(find.byKey(const Key('next-turn')));
    await settle(tester);
    expect(find.text('Sıra: A'), findsOneWidget);
    expect(find.text('2. tur'), findsOneWidget);
  });

  appTest('a tie is ordered from the combatant sheet; no move without a tie', gmPack: true, (tester, db) async {
    await pumped(tester, db.addCombatant(name: 'Ayla', initiative: 12, isPlayer: true));
    await pumped(tester, db.addCombatant(name: 'Goblin', initiative: 12));
    await pumped(tester, db.addCombatant(name: 'Kurt', initiative: 12));
    await pumped(tester, db.addCombatant(name: 'Ork', initiative: 4));
    await openTab(tester, 'İnisiyatif');

    ListTile tile(String key) => tester.widget<ListTile>(find.byKey(Key(key)));
    await tester.tap(find.text('Kurt'));
    await settle(tester);
    expect(tile('move-up').enabled, isTrue);
    expect(tile('move-down').enabled, isFalse, reason: 'Ork has another initiative');
    await tapKey(tester, 'move-up');
    expect(await names(tester, db), ['Ayla', 'Kurt', 'Goblin', 'Ork']);
    expect(tile('move-down').enabled, isTrue, reason: 'the open sheet follows the new order');
    await tapKey(tester, 'move-up');
    expect(await names(tester, db), ['Kurt', 'Ayla', 'Goblin', 'Ork']);
    expect(tile('move-up').enabled, isFalse, reason: 'first of the tie');
    await tapKey(tester, 'move-up'); // disabled: nothing happens
    await tapKey(tester, 'move-down');
    expect(await names(tester, db), ['Ayla', 'Kurt', 'Goblin', 'Ork']);
    await goBack(tester);
    final rows = [for (final n in ['Ayla', 'Kurt', 'Goblin', 'Ork']) tester.getTopLeft(find.text(n)).dy];
    expect(rows, orderedEquals([...rows]..sort()), reason: 'the list shows the new order');

    await tester.tap(find.text('Ork'));
    await settle(tester);
    expect(find.byKey(const Key('move-up')), findsNothing);
    expect(find.byKey(const Key('move-down')), findsNothing);
  });

  appTest('"Düzenle" changes the name, the HP maximum, the AC and a player\'s level, with the checks of the add dialog', gmPack: true,
      (tester, db) async {
    final gob = await pumped(tester, db.addCombatant(name: 'Gobiln', initiative: 12, hp: 7, ac: 15));
    final ayla = await pumped(tester, db.addCombatant(name: 'Ayla', initiative: 9, hp: 24, ac: 14, isPlayer: true, level: 3));
    await openTab(tester, 'İnisiyatif');

    await tester.tap(find.text('Gobiln'));
    await settle(tester);
    await tapKey(tester, 'edit-combatant');
    expect(tester.widget<TextField>(find.byKey(const Key('edit-name'))).controller!.text, 'Gobiln');
    expect(tester.widget<TextField>(find.byKey(const Key('edit-hp'))).controller!.text, '7');
    expect(tester.widget<TextField>(find.byKey(const Key('edit-ac'))).controller!.text, '15');
    expect(find.byKey(const Key('edit-level-field')), findsNothing, reason: 'not a player');
    await tester.enterText(find.byKey(const Key('edit-name')), '  ');
    await tester.enterText(find.byKey(const Key('edit-hp')), '0');
    await tester.enterText(find.byKey(const Key('edit-ac')), '1-2');
    await tapKey(tester, 'edit-save');
    expect(find.text('Ad gerekli'), findsOneWidget);
    expect(find.text('En az 1'), findsOneWidget);
    expect(find.text('Geçerli bir sayı yaz'), findsOneWidget);
    expect((await combatant(tester, db, gob)).name, 'Gobiln', reason: 'nothing saved yet');
    await tester.enterText(find.byKey(const Key('edit-name')), 'Goblin Reisi');
    await tester.enterText(find.byKey(const Key('edit-hp')), '21');
    await tester.enterText(find.byKey(const Key('edit-ac')), '17');
    await tapKey(tester, 'edit-save');
    var c = await combatant(tester, db, gob);
    expect((c.name, c.hpCurrent, c.hpMax, c.ac, c.initiative), ('Goblin Reisi', 21, 21, 17, 12));
    expect(find.text('Goblin Reisi'), findsWidgets, reason: 'the sheet and the card show the new name');
    await goBack(tester);
    expect(find.text('CP 21/21'), findsOneWidget);
    expect(find.text('ZS 17'), findsOneWidget);

    await tester.tap(find.text('Ayla'));
    await settle(tester);
    await tapKey(tester, 'edit-combatant');
    expect(tester.widget<TextField>(find.byKey(const Key('edit-level-field'))).controller!.text, '3');
    await tester.enterText(find.byKey(const Key('edit-level-field')), '21');
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byKey(const Key('edit-save'))).onPressed, isNull, reason: 'levels are 1–20');
    await tester.enterText(find.byKey(const Key('edit-level-field')), '5');
    await tester.enterText(find.byKey(const Key('edit-hp')), '');
    await tester.enterText(find.byKey(const Key('edit-ac')), '');
    await tapKey(tester, 'edit-save');
    c = await combatant(tester, db, ayla);
    expect((c.name, c.hpCurrent, c.hpMax, c.ac, c.level), ('Ayla', null, null, null, 5), reason: 'HP and AC are optional, as when adding');
    expect(find.text('5. seviye'), findsOneWidget);
  });

  for (final (size, scale) in const [(Size(360, 720), 1.0), (Size(360, 720), 1.3), (Size(360, 720), 1.6), (Size(320, 568), 1.3), (Size(800, 1280), 1.0), (Size(800, 1280), 1.6)]) {
    appTest('"Önceki" stays on one line at text scale $scale on ${size.width.toInt()}x${size.height.toInt()}', gmPack: true, surface: size,
        (tester, db) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumped(tester, db.addCombatant(name: 'Ayla', initiative: 17));
      await pumped(tester, db.addCombatant(name: 'Goblin', initiative: 12));
      await openTab(tester, 'İnisiyatif');
      final bar = tester.getRect(find.byKey(const Key('prev-turn')));
      final label = find.descendant(of: find.byKey(const Key('prev-turn')), matching: find.text('Önceki'));
      if (label.evaluate().isEmpty) {
        // No room for the word: an icon with the word as its tooltip.
        expect(find.byTooltip('Önceki'), findsOneWidget);
        expect(find.descendant(of: find.byKey(const Key('prev-turn')), matching: find.byIcon(Icons.chevron_left)), findsOneWidget);
      } else {
        final p = tester.renderObject<RenderParagraph>(label);
        expect(lineCount(p), 1);
        expect(p.didExceedMaxLines, isFalse);
        expect(tester.getRect(label).width, lessThanOrEqualTo(bar.width));
      }
      final next = find.descendant(of: find.byKey(const Key('next-turn')), matching: find.text('Sonraki'));
      expect(lineCount(tester.renderObject<RenderParagraph>(next)), 1);
      expect(tester.getRect(next).right, lessThanOrEqualTo(tester.getRect(find.byKey(const Key('next-turn'))).right));
      await tester.tap(find.byKey(const Key('next-turn')));
      await settle(tester);
      expect(find.byKey(const Key('current-turn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('prev-turn')));
      await settle(tester);
      expect((await encounter(tester, db)).current!.name, 'Ayla');
    });
  }
}
