import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/app.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/flags.dart';
import 'package:gm_cebi/providers.dart';

import 'harness.dart';
import 'map_test.dart' show combatant, pumped;

/// Monster ids from the SRD assets (stable whatever language the names are in).
const bugbear = 'bugbear-warrior'; // 200 XP
const goblin = 'goblin-warrior'; // 50 XP

Finder get chip => find.byKey(const Key('difficulty-chip'));

String chipText(WidgetTester tester) => tester
    .widget<Text>(find.descendant(of: chip, matching: find.byType(Text)))
    .data!;

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

Future<void> openSheet(WidgetTester tester) async {
  await tester.tap(chip);
  await settle(tester);
  expect(find.byKey(const Key('difficulty-sheet')), findsOneWidget);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.ensureVisible(f);
  await settle(tester);
  await tester.tap(f);
  await settle(tester);
}

/// Disposes the whole app and starts it again on the same database, the
/// way a closed and reopened app reads everything back from SQLite.
Future<void> restartApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await settle(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        referenceProvider.overrideWith((ref) async => testReference()),
        entitlementsProvider.overrideWithValue(
          const Entitlements(gmPack: true),
        ),
        diceRandomProvider.overrideWithValue(FixedRandom([10])),
      ],
      child: const GmCebiApp(),
    ),
  );
  await settle(tester);
}

void main() {
  appTest(
    'chip appears after adding a monster; the sheet shows the budgets',
    gmPack: true,
    (tester, db) async {
      await openTab(tester, 'İnisiyatif');
      expect(chip, findsNothing);

      // A combatant added by hand has no XP: still no chip.
      await tester.tap(find.byKey(const Key('add-combatant')));
      await settle(tester);
      await tester.tap(find.text('Oyuncu ya da serbest ekle'));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('combatant-name')), 'Haydut');
      await tester.tap(find.text('Oyuncu karakteri'));
      await settle(tester);
      expect(
        find.byKey(const Key('combatant-level')),
        findsNothing,
        reason: 'level is for players only',
      );
      await tester.tap(find.byKey(const Key('combatant-save')));
      await settle(tester);
      expect(find.text('Haydut'), findsOneWidget);
      expect(chip, findsNothing);

      // Add a Bugbear Warrior from the monster list.
      await tester.tap(find.byKey(const Key('add-combatant')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('add-monster')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('monster-search')),
        'bugbear warrior',
      );
      await settle(tester);
      await tester.tap(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(ListTile),
            )
            .first,
      );
      await settle(tester);
      final rows = await pumped(tester, db.select(db.combatants).get());
      expect(rows.where((c) => c.monsterId == bugbear), hasLength(1));

      // No players yet: the party is 4 characters of level 1 (Low 200).
      expect(chip, findsOneWidget);
      expect(chipText(tester), 'Düşük · 200 / 200 TP');

      await openSheet(tester);
      expect(textOf(tester, 'difficulty-band'), 'Düşük');
      expect(textOf(tester, 'budget-low'), '200 TP');
      expect(textOf(tester, 'budget-moderate'), '300 TP');
      expect(textOf(tester, 'budget-high'), '400 TP');
      expect(find.text('Grup · 4 karakter'), findsOneWidget);
      expect(find.text('TP bilinmiyor'), findsOneWidget);
      expect(find.byKey(const Key('difficulty-unknown-note')), findsOneWidget);
      expect(find.text('Canavarlar · 200 TP'), findsOneWidget);

      // A second bugbear: 400 XP is High, and the open sheet follows.
      await pumped(tester, db.addCombatant(name: 'İkinci', monsterId: bugbear));
      await settle(tester);
      expect(textOf(tester, 'difficulty-band'), 'Yüksek');
      await tapKey(tester, 'party-size-inc');
      await tapKey(tester, 'party-size-inc');
      expect(
        textOf(tester, 'difficulty-band'),
        'Orta',
        reason: '6 × level 1: Moderate 450',
      );
    },
  );

  appTest("changing a player's level changes the category", gmPack: true, (
    tester,
    db,
  ) async {
    await openTab(tester, 'İnisiyatif');
    // Ayla is added through the dialog, with a level.
    await tester.tap(find.byKey(const Key('add-combatant')));
    await settle(tester);
    await tester.tap(find.text('Oyuncu ya da serbest ekle'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('combatant-name')), 'Ayla');
    await tester.enterText(find.byKey(const Key('combatant-level')), '1');
    await tester.tap(find.byKey(const Key('combatant-save')));
    await settle(tester);
    final ayla = (await pumped(tester, db.select(db.combatants).get())).single;
    expect(ayla.level, 1);

    await pumped(
      tester,
      db.addCombatant(name: 'Bugbear A', monsterId: bugbear),
    );
    await pumped(
      tester,
      db.addCombatant(name: 'Bugbear B', monsterId: bugbear),
    );
    await settle(tester);
    // One level-1 character: High is 100, 400 XP is beyond the table.
    expect(chipText(tester), 'Yüksek üstü · 400 / 100 TP');

    await openSheet(tester);
    expect(find.text('Grup · 1 karakter'), findsOneWidget);
    expect(
      find.byKey(Key('party-size-inc')),
      findsNothing,
      reason: 'players are the party',
    );
    await tapKey(tester, 'level-${ayla.id}-inc');
    await tapKey(tester, 'level-${ayla.id}-inc');
    expect(textOf(tester, 'level-${ayla.id}-value'), '3');
    expect(
      textOf(tester, 'difficulty-band'),
      'Yüksek',
      reason: 'level 3: High 400',
    );
    expect((await combatant(tester, db, ayla.id)).level, 3);
    await tapKey(tester, 'level-${ayla.id}-inc');
    await tapKey(tester, 'level-${ayla.id}-inc');
    expect(
      textOf(tester, 'difficulty-band'),
      'Düşük',
      reason: 'level 5: Low 500',
    );
    await goBack(tester);
    expect(chipText(tester), 'Düşük · 400 / 500 TP');

    // The combatant menu edits the level too.
    await tester.tap(find.text('Ayla'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('edit-level')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('level-field')), '6');
    await tester.tap(find.byKey(const Key('level-save')));
    await settle(tester);
    expect((await combatant(tester, db, ayla.id)).level, 6);
    expect(find.text('6. seviye'), findsOneWidget);
    await goBack(tester);
    expect(chipText(tester), 'Düşük · 400 / 600 TP');
  });

  appTest('players without a level use the party level', gmPack: true, (
    tester,
    db,
  ) async {
    await pumped(tester, db.addCombatant(name: 'Ayla', isPlayer: true));
    await pumped(
      tester,
      db.addCombatant(name: 'Bora', isPlayer: true, level: 2),
    );
    await pumped(tester, db.addCombatant(name: 'Goblin', monsterId: goblin));
    await openTab(tester, 'İnisiyatif');
    // Levels 1 + 2: Low 150.
    expect(chipText(tester), 'Düşük altı · 50 / 150 TP');
    await openSheet(tester);
    expect(find.text('grup seviyesi'), findsOneWidget);
    await tapKey(tester, 'party-level-inc');
    await tapKey(tester, 'party-level-inc');
    // Ayla now level 3: Low 150 + 100.
    expect(textOf(tester, 'budget-low'), '250 TP');
    expect(textOf(tester, 'difficulty-band'), 'Düşük altı');
  });

  appTest('party settings and levels survive an app restart', gmPack: true, (
    tester,
    db,
  ) async {
    await pumped(tester, db.addCombatant(name: 'Bugbear', monsterId: bugbear));
    await openTab(tester, 'İnisiyatif');
    await openSheet(tester);
    await tapKey(tester, 'party-size-dec'); // 3
    await tapKey(tester, 'party-level-inc'); // 2
    await tapKey(tester, 'party-level-inc'); // 3
    expect(textOf(tester, 'party-size-value'), '3');
    expect(textOf(tester, 'party-level-value'), '3');
    await goBack(tester);
    final player = await pumped(
      tester,
      db.addCombatant(name: 'Ayla', isPlayer: true, level: 7),
    );
    await settle(tester);

    await restartApp(tester, db);
    await openTab(tester, 'İnisiyatif');
    expect(
      chipText(tester),
      'Düşük altı · 200 / 750 TP',
      reason: 'Ayla at level 7',
    );
    await openSheet(tester);
    expect(textOf(tester, 'level-$player-value'), '7');
    expect(textOf(tester, 'party-level-value'), '3');
    await goBack(tester);

    await tester.tap(find.text('Ayla'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('edit-level')));
    await settle(tester);
    await tester.tap(find.text('Temizle'));
    await settle(tester);
    await goBack(tester);
    await settle(tester);
    // Ayla falls back to the party level (3): Moderate 225.
    expect(chipText(tester), 'Orta · 200 / 225 TP');

    // With no players the saved party size is back too.
    await pumped(tester, db.removeCombatant(player));
    await settle(tester);
    await openSheet(tester);
    expect(textOf(tester, 'party-size-value'), '3');
  });

  appTest(
    'no overflow at 320 dp and text scale 1.3; 48 dp targets',
    gmPack: true,
    surface: const Size(320, 640),
    (tester, db) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumped(
        tester,
        db.addCombatant(
          name: 'Ayla Yıldırımkalkan, Kuzey Ormanlarının Bekçisi',
          isPlayer: true,
          level: 1,
        ),
      );
      for (var i = 0; i < 40; i++) {
        await pumped(
          tester,
          db.addCombatant(
            name: 'Bugbear Savaşçısı ${i + 1}',
            monsterId: bugbear,
          ),
        );
      }
      await pumped(
        tester,
        db.addCombatant(name: 'Adı uzun bir haydut lideri, TP yok'),
      );
      await openTab(tester, 'İnisiyatif');
      final scale = MediaQuery.textScalerOf(tester.element(chip)).scale(10);
      expect(scale, closeTo(13, 0.01));
      expect(chipText(tester), 'Yüksek üstü · 8.000 / 100 TP');
      expect(tester.getSize(chip).height, greaterThanOrEqualTo(48));

      await openSheet(tester);
      for (final key in ['level-1-inc', 'level-1-dec', 'party-level-inc']) {
        final size = tester.getSize(find.byKey(Key(key)));
        expect(size.width, greaterThanOrEqualTo(48), reason: key);
        expect(size.height, greaterThanOrEqualTo(48), reason: key);
      }
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      // Scroll through the whole sheet: any overflow fails the test.
      await tester.scrollUntilVisible(
        find.byKey(const Key('difficulty-unknown-note')),
        300,
        scrollable: scrollableIn(const Key('difficulty-sheet')),
      );
      await settle(tester);
      await goBack(tester);

      // The add dialog with the level field.
      await tester.tap(find.byKey(const Key('add-combatant')));
      await settle(tester);
      await tester.tap(find.text('Oyuncu ya da serbest ekle'));
      await settle(tester);
      expect(find.byKey(const Key('combatant-level')), findsOneWidget);
    },
  );

  appTest('chip semantics', gmPack: true, (tester, db) async {
    final handle = tester.ensureSemantics();
    await pumped(tester, db.addCombatant(name: 'Goblin', monsterId: goblin));
    await openTab(tester, 'İnisiyatif');
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Karşılaşma zorluğu: Düşük altı · 50 / 200 TP'),
      ),
      findsOneWidget,
    );
    final node = tester.getSemantics(chip);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    // The accessibility tap (Switch Access, Voice Access) opens the sheet.
    tester.semantics.tap(
      find.semantics.byLabel(RegExp(r'^Karşılaşma zorluğu: ')),
    );
    await settle(tester);
    expect(find.byKey(const Key('difficulty-sheet')), findsOneWidget);
    handle.dispose();
  });

  appTest(
    'levels outside 1–20 are refused; only "Temizle" clears',
    gmPack: true,
    (tester, db) async {
      await openTab(tester, 'İnisiyatif');
      // Add dialog: an out-of-range level shows an error and blocks "Ekle".
      await tester.tap(find.byKey(const Key('add-combatant')));
      await settle(tester);
      await tester.tap(find.text('Oyuncu ya da serbest ekle'));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('combatant-name')), 'Ayla');
      await tester.enterText(find.byKey(const Key('combatant-level')), '25');
      await settle(tester);
      expect(find.text('1–20 arası bir seviye gir'), findsOneWidget);
      FilledButton button(String key) =>
          tester.widget<FilledButton>(find.byKey(Key(key)));
      expect(button('combatant-save').onPressed, isNull);
      await tester.enterText(find.byKey(const Key('combatant-level')), '0');
      await settle(tester);
      expect(button('combatant-save').onPressed, isNull);
      await tester.enterText(find.byKey(const Key('combatant-level')), '');
      await settle(tester);
      expect(find.text('1–20 arası bir seviye gir'), findsNothing);
      expect(
        button('combatant-save').onPressed,
        isNotNull,
        reason: 'empty is fine',
      );
      await tester.enterText(find.byKey(const Key('combatant-level')), '5');
      await settle(tester);
      await tester.tap(find.byKey(const Key('combatant-save')));
      await settle(tester);
      final ayla = (await pumped(
        tester,
        db.select(db.combatants).get(),
      )).single;
      expect(ayla.level, 5);

      // Edit dialog: 0, 21 and empty cannot be saved; the level stays.
      await tester.tap(find.text('Ayla'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('edit-level')));
      await settle(tester);
      for (final bad in ['0', '21', '99', '']) {
        await tester.enterText(find.byKey(const Key('level-field')), bad);
        await settle(tester);
        expect(button('level-save').onPressed, isNull, reason: bad);
        expect(
          find.text('1–20 arası bir seviye gir'),
          bad.isEmpty ? findsNothing : findsOneWidget,
        );
      }
      await tester.tap(
        find.byKey(const Key('level-save')),
        warnIfMissed: false,
      );
      await settle(tester);
      expect((await combatant(tester, db, ayla.id)).level, 5);
      await tester.enterText(find.byKey(const Key('level-field')), '20');
      await settle(tester);
      await tester.tap(find.byKey(const Key('level-save')));
      await settle(tester);
      expect((await combatant(tester, db, ayla.id)).level, 20);

      await tester.tap(find.byKey(const Key('edit-level')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('level-clear')));
      await settle(tester);
      expect((await combatant(tester, db, ayla.id)).level, isNull);
    },
  );

  appTest('quick taps on a level stepper are not lost', gmPack: true, (
    tester,
    db,
  ) async {
    final ayla = await pumped(
      tester,
      db.addCombatant(name: 'Ayla', isPlayer: true, level: 1),
    );
    await pumped(tester, db.addCombatant(name: 'Goblin', monsterId: goblin));
    await openTab(tester, 'İnisiyatif');
    await openSheet(tester);
    final inc = find.byKey(Key('level-$ayla-inc'));
    // Three taps before the database stream re-emits (no pump in between).
    await tester.tap(inc);
    await tester.tap(inc);
    await tester.tap(inc);
    await settle(tester);
    expect((await combatant(tester, db, ayla)).level, 4);
    expect(textOf(tester, 'level-$ayla-value'), '4');
    final dec = find.byKey(Key('level-$ayla-dec'));
    await tester.tap(dec);
    await tester.tap(dec);
    await settle(tester);
    expect((await combatant(tester, db, ayla)).level, 2);

    // Party settings step from the latest value too.
    await tester.tap(find.byKey(const Key('party-level-inc')));
    await tester.tap(find.byKey(const Key('party-level-inc')));
    await settle(tester);
    expect(textOf(tester, 'party-level-value'), '3');
  });
}
