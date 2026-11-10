import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/features/npc/npc_generator.dart';
import 'package:gm_cebi/ui/screens/npc_screen.dart';

import 'harness.dart';

Future<void> openNpc(WidgetTester tester) async {
  await openTab(tester, 'Notlar');
  await tester.tap(find.byKey(const Key('open-npc')));
  await settle(tester);
}

Future<void> generate(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('npc-generate')));
  await settle(tester);
}

String valueOf(WidgetTester tester, NpcField f) => tester.widget<Text>(find.byKey(Key('npc-value-${f.name}'))).data!;

Map<NpcField, String> card(WidgetTester tester) => {for (final f in NpcField.values) f: valueOf(tester, f)};

Future<void> scrollTo(WidgetTester tester, Key key, {bool up = false}) async {
  if (find.byKey(key).evaluate().isEmpty) {
    await tester.scrollUntilVisible(find.byKey(key), up ? -200 : 200, scrollable: scrollableIn(const Key('npc-list')));
  }
  await tester.ensureVisible(find.byKey(key));
  await settle(tester);
}

void main() {
  appTest('NPC generator is locked without the GM pack', (tester, db) async {
    await openTab(tester, 'Notlar');
    expect(find.byKey(const Key('open-npc')), findsNothing); // no entry on the locked Notes screen
    Navigator.of(tester.element(find.byType(NavigationBar)))
        .push(MaterialPageRoute<void>(builder: (_) => const NpcScreen()));
    await settle(tester);
    expect(find.text('NPC üretici GM Paketi ile açılır.'), findsOneWidget);
    expect(find.byKey(const Key('npc-generate')), findsNothing);
  });

  appTest('generate shows a full card; re-roll, lock, recent', gmPack: true, random: Random(5), (tester, db) async {
    await openNpc(tester);
    expect(find.text('NPC üret'), findsOneWidget);
    await generate(tester);
    expect(find.byKey(const Key('npc-card')), findsOneWidget);
    final first = card(tester);
    for (final v in first.values) {
      expect(v.trim(), isNotEmpty);
    }
    expect(find.text('Yeniden üret'), findsOneWidget);

    // Tapping one field re-rolls only that field.
    await tester.tap(find.byKey(const Key('npc-field-occupation')));
    await settle(tester);
    final rerolled = card(tester);
    expect(rerolled[NpcField.occupation], isNot(first[NpcField.occupation]));
    for (final f in NpcField.values.where((f) => f != NpcField.occupation)) {
      expect(rerolled[f], first[f], reason: '$f');
    }

    // A locked field survives "Yeniden üret" and ignores taps.
    await tester.tap(find.byKey(const Key('npc-lock-name')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('npc-field-name')));
    await settle(tester);
    expect(valueOf(tester, NpcField.name), first[NpcField.name]);
    await scrollTo(tester, const Key('npc-generate'));
    await generate(tester);
    final regenerated = card(tester);
    expect(regenerated[NpcField.name], first[NpcField.name]);
    expect(NpcField.values.where((f) => regenerated[f] != rerolled[f]), isNotEmpty);

    // The previous NPC is in the recent list.
    await scrollTo(tester, const Key('npc-recent-0'));
    expect(find.text("Son NPC'ler"), findsOneWidget);
  });

  appTest('species filter', gmPack: true, random: Random(2), (tester, db) async {
    await openNpc(tester);
    await tester.tap(find.byKey(const Key('npc-filters')));
    await settle(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ejderdoğan'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('npc-with-hook')));
    await settle(tester);
    await scrollTo(tester, const Key('npc-generate'));
    await generate(tester);
    expect(tester.widget<Text>(find.byKey(const Key('npc-summary'))).data, startsWith('Ejderdoğan · '));
    expect(find.byKey(const Key('npc-value-hook')), findsNothing);
  });

  appTest('save to notes creates a note', gmPack: true, random: Random(8), (tester, db) async {
    await openNpc(tester);
    await generate(tester);
    final name = valueOf(tester, NpcField.name);
    final occupation = valueOf(tester, NpcField.occupation);
    await scrollTo(tester, const Key('npc-save-note'));
    await tester.tap(find.byKey(const Key('npc-save-note')));
    await settle(tester);
    expect(find.text('$name notlara kaydedildi'), findsOneWidget);
    await goBack(tester);
    expect(find.text('NPC: $name'), findsOneWidget);
    expect(find.textContaining('Meslek: $occupation'), findsOneWidget);
  });

  appTest('add to initiative adds a non-player combatant', gmPack: true, random: Random(13), (tester, db) async {
    await openNpc(tester);
    await generate(tester);
    final name = valueOf(tester, NpcField.name);
    await scrollTo(tester, const Key('npc-add-initiative'));
    await tester.tap(find.byKey(const Key('npc-add-initiative')));
    await settle(tester);
    expect(tester.widget<TextField>(find.byKey(const Key('npc-init-name'))).controller!.text, name);
    await tester.enterText(find.byKey(const Key('npc-init-hp')), '12');
    await tester.enterText(find.byKey(const Key('npc-init-ac')), '13');
    await tester.tap(find.byKey(const Key('npc-init-save')));
    await settle(tester);
    expect(find.text('$name inisiyatife eklendi'), findsOneWidget);
    await goBack(tester);
    await openTab(tester, 'İnisiyatif');
    expect(find.text(name), findsOneWidget);
    expect(find.text('CP 12/12'), findsOneWidget);
    expect(find.text('ZS 13'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing); // not a player
  });

  appTest(
    'fits 320 dp at text scale 1.3 with 48 dp targets',
    gmPack: true,
    random: Random(21),
    surface: const Size(320, 640),
    (tester, db) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openNpc(tester);
      await tester.tap(find.byKey(const Key('npc-filters')));
      await settle(tester);
      await scrollTo(tester, const Key('npc-generate'));
      await generate(tester);
      await generate(tester);
      for (final key in ['npc-field-hook', 'npc-save-note', 'npc-recent-0']) {
        await scrollTo(tester, Key(key));
      }
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      await scrollTo(tester, const Key('npc-add-initiative'));
      await tester.tap(find.byKey(const Key('npc-add-initiative')));
      await settle(tester);
      expect(find.byKey(const Key('npc-init-save')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Vazgeç'));
      await settle(tester);
    },
  );
  appTest('filters and locks survive leaving the screen', gmPack: true, random: Random(6), (tester, db) async {
    await openNpc(tester);
    await tester.tap(find.byKey(const Key('npc-filters')));
    await settle(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Goliat'));
    await settle(tester);
    await scrollTo(tester, const Key('npc-generate'));
    await generate(tester);
    final before = card(tester);
    await scrollTo(tester, const Key('npc-lock-occupation'));
    await tester.tap(find.byKey(const Key('npc-lock-occupation')));
    await settle(tester);
    await goBack(tester);
    await tester.tap(find.byKey(const Key('open-npc')));
    await settle(tester);
    expect(card(tester), before);
    expect(tester.widget<IconButton>(find.byKey(const Key('npc-lock-occupation'))).isSelected, isTrue);
    expect(find.textContaining('Goliat · '), findsWidgets); // filter summary and card
    await generate(tester);
    expect(valueOf(tester, NpcField.occupation), before[NpcField.occupation]);
    expect(tester.widget<Text>(find.byKey(const Key('npc-summary'))).data, startsWith('Goliat · '));
  });

  appTest('a locked name disables the species and gender filters', gmPack: true, random: Random(4), (tester, db) async {
    await openNpc(tester);
    await generate(tester);
    await tester.tap(find.byKey(const Key('npc-lock-name')));
    await settle(tester);
    expect(find.text('Ad kilitli: soy ve cinsiyet korunuyor'), findsOneWidget);
    await scrollTo(tester, const Key('npc-filters'));
    await tester.tap(find.byKey(const Key('npc-filters')));
    await settle(tester);
    expect(find.byKey(const Key('npc-name-locked-hint')), findsOneWidget);
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Elf')).onSelected, isNull);
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Kadın')).onSelected, isNull);
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Dostça')).onSelected, isNotNull);
  });

  appTest('everything locked: "Yeniden üret" adds no duplicate', gmPack: true, random: Random(3), (tester, db) async {
    await openNpc(tester);
    await generate(tester);
    for (final f in NpcField.values) {
      await scrollTo(tester, Key('npc-lock-${f.name}'));
      await tester.tap(find.byKey(Key('npc-lock-${f.name}')));
      await settle(tester);
    }
    final before = card(tester);
    await scrollTo(tester, const Key('npc-generate'), up: true);
    await generate(tester);
    expect(find.text('Tüm alanlar kilitli; değişecek bir şey yok.'), findsOneWidget);
    expect(card(tester), before);
    expect(find.byKey(const Key('npc-recent-0')), findsNothing);
  });

  appTest('a double tap on "Nota kaydet" saves one note', gmPack: true, random: Random(9), (tester, db) async {
    await openNpc(tester);
    await generate(tester);
    final name = valueOf(tester, NpcField.name);
    await scrollTo(tester, const Key('npc-save-note'));
    await tester.tap(find.byKey(const Key('npc-save-note')));
    await tester.tap(find.byKey(const Key('npc-save-note')), warnIfMissed: false);
    await settle(tester);
    expect(tester.widget<ButtonStyleButton>(find.byKey(const Key('npc-save-note'))).onPressed, isNull);
    expect(find.text('Notlara kaydedildi'), findsOneWidget);
    // A changed NPC can be saved again.
    await scrollTo(tester, const Key('npc-field-occupation'));
    await tester.tap(find.byKey(const Key('npc-field-occupation')));
    await settle(tester);
    expect(tester.widget<ButtonStyleButton>(find.byKey(const Key('npc-save-note'))).onPressed, isNotNull);
    await goBack(tester);
    expect(find.text('NPC: $name'), findsOneWidget);
  });

  appTest('initiative dialog checks the numbers', gmPack: true, random: Random(13), (tester, db) async {
    await openNpc(tester);
    await generate(tester);
    final name = valueOf(tester, NpcField.name);
    await scrollTo(tester, const Key('npc-add-initiative'));
    await tester.tap(find.byKey(const Key('npc-add-initiative')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('npc-init-hp')), '-');
    await tester.enterText(find.byKey(const Key('npc-init-ac')), '0');
    await tester.enterText(find.byKey(const Key('npc-init-bonus')), '12345678901234567890');
    expect(tester.widget<TextField>(find.byKey(const Key('npc-init-bonus'))).controller!.text, '1234');
    await tester.tap(find.byKey(const Key('npc-init-save')));
    await settle(tester);
    expect(find.text('Geçerli bir sayı yaz'), findsOneWidget);
    expect(find.text('En az 1'), findsOneWidget);
    expect(find.byKey(const Key('npc-init-save')), findsOneWidget); // still open
    await tester.enterText(find.byKey(const Key('npc-init-hp')), '9');
    await tester.enterText(find.byKey(const Key('npc-init-ac')), '');
    await tester.enterText(find.byKey(const Key('npc-init-bonus')), '-1');
    await settle(tester);
    expect(find.text('Geçerli bir sayı yaz'), findsNothing);
    expect(find.text('En az 1'), findsNothing);
    await tester.tap(find.byKey(const Key('npc-init-save')));
    await settle(tester);
    expect(find.text('$name inisiyatife eklendi'), findsOneWidget);
    await goBack(tester);
    await openTab(tester, 'İnisiyatif');
    expect(find.text('CP 9/9'), findsOneWidget);
  });
}
