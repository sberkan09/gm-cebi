import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  appTest('initiative and notes are locked without the GM pack', (tester, db) async {
    await openTab(tester, 'İnisiyatif');
    expect(find.text('İnisiyatif takibi GM Paketi ile açılır.'), findsOneWidget);
    await openTab(tester, 'Notlar');
    expect(find.text('Oturum notları GM Paketi ile açılır.'), findsOneWidget);
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
    await tester.tap(find.text('Goblin Warrior').first);
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('add-to-initiative')), 400, scrollable: scrollableIn(const Key('detail-list')));
    await tester.tap(find.byKey(const Key('add-to-initiative')));
    await settle(tester);
    expect(find.text('Goblin Warrior inisiyatife eklendi'), findsOneWidget);
    await goBack(tester);
    await openTab(tester, 'İnisiyatif');
    expect(find.text('Goblin Warrior'), findsOneWidget);
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
}
