import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/features/backup/device_files.dart';
import 'package:gm_cebi/ui/screens/notes_screen.dart';

import 'harness.dart';
import 'map_test.dart' show pumped;

void main() {
  appTest('initiative and notes are locked without the GM pack', (tester, db) async {
    await openTab(tester, 'İnisiyatif');
    expect(find.text('İnisiyatif takibi GM Paketi ile açılır.'), findsOneWidget);
    await openTab(tester, 'Notlar');
    expect(find.text('Oturum notları GM Paketi ile açılır.'), findsOneWidget);
    expect(find.byKey(const Key('new-note')), findsNothing);
  });

  appTest('locked notes stay readable, but cannot be created, edited or deleted', (tester, db) async {
    await pumped(tester, db.createNote(title: '3. oturum', body: 'Kurt sürüsü, köprüde pusu.'));
    await openTab(tester, 'Notlar');
    expect(find.text(notesLockedText), findsOneWidget);
    expect(find.text('3. oturum'), findsOneWidget);
    expect(find.text('Kurt sürüsü, köprüde pusu.'), findsOneWidget);
    expect(find.byKey(const Key('new-note')), findsNothing);
    expect(find.byKey(const Key('open-npc')), findsNothing);

    await tester.tap(find.text('3. oturum'));
    await settle(tester);
    expect(find.text(notesLockedText), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('note-title'))).readOnly, isTrue);
    expect(tester.widget<TextField>(find.byKey(const Key('note-body'))).readOnly, isTrue);
    expect(find.byKey(const Key('delete-note')), findsNothing);
    expect(find.byTooltip('Üste sabitle'), findsNothing);
    await tester.enterText(find.byKey(const Key('note-body')), 'değişti');
    await settle(tester);
    await goBack(tester);
    final notes = await pumped(tester, db.select(db.notes).get());
    expect(notes.single.body, 'Kurt sürüsü, köprüde pusu.');
  });

  final files = FakeDeviceFiles();
  appTest('share a note as text', gmPack: true, overrides: [deviceFilesProvider.overrideWithValue(files)], (tester, db) async {
    await pumped(tester, db.createNote(title: '3. oturum ', body: 'Kurt sürüsü.\nKöprüde pusu.\n'));
    await openTab(tester, 'Notlar');
    await tester.tap(find.text('3. oturum'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('note-menu')));
    await settle(tester);
    await tester.tap(find.text('Notu paylaş'));
    await settle(tester);
    expect(files.texts.single, ('3. oturum\n\nKurt sürüsü.\nKöprüde pusu.', '3. oturum'));
    expect(noteShareText('', ' yalnız metin '), 'yalnız metin');
  });

  appTest('initiative: add, order, next turn, damage', gmPack: true, (tester, db) async {
    await openTab(tester, 'İnisiyatif');
    db.addCombatant(name: 'Goblin', initiative: 18, hp: 7, ac: 15); // completes while pumping
    await settle(tester);

    await tester.tap(find.byKey(const Key('add-combatant')));
    await settle(tester);
    await tester.tap(find.text('Oyuncu ya da serbest ekle'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('combatant-name')), 'Ayla');
    await tester.enterText(find.byKey(const Key('combatant-init')), '12');
    await tester.enterText(find.byKey(const Key('combatant-hp')), '24');
    await tester.tap(find.byKey(const Key('combatant-save')));
    await settle(tester);

    expect(find.text('Sıra: Goblin'), findsOneWidget);
    expect(find.text('1. tur'), findsOneWidget);
    await tester.tap(find.byKey(const Key('next-turn')));
    await settle(tester);
    expect(find.text('Sıra: Ayla'), findsOneWidget);
    await tester.tap(find.byKey(const Key('next-turn')));
    await settle(tester);
    expect(find.text('2. tur'), findsOneWidget);

    await tester.tap(find.text('CP 7/7'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('hp-amount')), '5');
    await tester.tap(find.byKey(const Key('hp-damage')));
    await settle(tester);
    expect(find.text('CP 2/7'), findsOneWidget);
  });

  appTest('monster page adds to the initiative tracker', gmPack: true, (tester, db) async {
    await tester.enterText(find.byKey(const Key('search-field')), 'goblin warrior');
    await settle(tester);
    await tester.tap(find.text('Goblin Savaşçısı').first);
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('add-to-initiative')), 400, scrollable: scrollableIn(const Key('detail-list')));
    await tester.tap(find.byKey(const Key('add-to-initiative')));
    await settle(tester);
    expect(find.text('Goblin Savaşçısı inisiyatife eklendi'), findsOneWidget);
    await goBack(tester);
    await openTab(tester, 'İnisiyatif');
    expect(find.text('Goblin Savaşçısı'), findsOneWidget);
  });

  appTest('notes: create, autosave, list, delete', gmPack: true, (tester, db) async {
    await openTab(tester, 'Notlar');
    await tester.tap(find.byKey(const Key('new-note')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('note-title')), '3. oturum – Gölgeli Orman');
    await tester.enterText(find.byKey(const Key('note-body')), 'Kurt sürüsü, köprüde pusu.');
    await settle(tester);
    await goBack(tester);
    expect(find.text('3. oturum – Gölgeli Orman'), findsOneWidget);
    expect(find.text('Kurt sürüsü, köprüde pusu.'), findsOneWidget);

    await tester.tap(find.text('3. oturum – Gölgeli Orman'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('delete-note')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await settle(tester);
    expect(find.text('3. oturum – Gölgeli Orman'), findsNothing);
  });
  appTest('initiative add dialog rejects bad numbers', gmPack: true, (tester, db) async {
    await openTab(tester, 'İnisiyatif');
    await tester.tap(find.byKey(const Key('add-combatant')));
    await settle(tester);
    await tester.tap(find.text('Oyuncu ya da serbest ekle'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('combatant-save')));
    await settle(tester);
    expect(find.text('Ad gerekli'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('combatant-name')), 'Ayla');
    await tester.enterText(find.byKey(const Key('combatant-hp')), '0');
    await tester.enterText(find.byKey(const Key('combatant-ac')), '-');
    await tester.enterText(find.byKey(const Key('combatant-init')), '99999999999999999999');
    await tester.tap(find.byKey(const Key('combatant-save')));
    await settle(tester);
    expect(find.text('Ad gerekli'), findsNothing);
    expect(find.text('En az 1'), findsOneWidget);
    expect(find.text('Geçerli bir sayı yaz'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('combatant-hp')), '20');
    await tester.enterText(find.byKey(const Key('combatant-ac')), '14');
    await tester.tap(find.byKey(const Key('combatant-save')));
    await settle(tester);
    expect(find.text('Ayla'), findsOneWidget);
    expect(find.text('9999'), findsOneWidget); // initiative cut to 4 digits
    expect(find.text('CP 20/20'), findsOneWidget);
    expect(find.text('ZS 14'), findsOneWidget);
  });
}
