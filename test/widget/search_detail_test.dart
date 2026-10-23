import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  appTest('search in Turkish, open the condition, flip to English with one tap', (tester, db) async {
    expect(find.text('Durumlar'), findsOneWidget); // browse grid when the box is empty

    await tester.enterText(find.byKey(const Key('search-field')), 'kör');
    await settle(tester);
    expect(find.textContaining('sonuç ·'), findsOneWidget);
    await tester.tap(find.text('Kör').first);
    await settle(tester);

    expect(find.byKey(const Key('detail-title')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('detail-title'))).data, 'Kör');
    expect(find.textContaining('Göremez', findRichText: true), findsWidgets);

    await tester.tap(find.text('EN'));
    await settle(tester);
    expect(tester.widget<Text>(find.byKey(const Key('detail-title'))).data, 'Blinded');
    expect(find.textContaining('Can’t See', findRichText: true), findsWidgets);
  });

  appTest('English query finds the Turkish spell; spell card labels follow the language', (tester, db) async {
    await tester.enterText(find.byKey(const Key('search-field')), 'fireball');
    await settle(tester);
    await tester.tap(find.text('Ateş Topu').first);
    await settle(tester);
    expect(find.textContaining('3. Seviye Oluşturma'), findsOneWidget);
    expect(find.textContaining('Yapma Süresi', findRichText: true), findsOneWidget);
    await tester.tap(find.text('EN'));
    await settle(tester);
    expect(find.textContaining('Level 3 Evocation'), findsOneWidget);
    expect(find.textContaining('Casting Time', findRichText: true), findsOneWidget);
  });

  appTest('untranslated monster shows the English stat block with a note', (tester, db) async {
    await tester.enterText(find.byKey(const Key('search-field')), 'aboleth');
    await settle(tester);
    await tester.tap(find.text('Aboleth').first);
    await settle(tester);
    expect(find.byKey(const Key('untranslated-banner')), findsOneWidget);
    expect(find.byKey(const Key('ability-table')), findsOneWidget);
    expect(find.text('Legendary Actions'), findsOneWidget);
    // GM pack locked: no "add to initiative".
    expect(find.byKey(const Key('add-to-initiative')), findsNothing);
  });

  appTest('no results message', (tester, db) async {
    await tester.enterText(find.byKey(const Key('search-field')), 'qqqzzz');
    await settle(tester);
    expect(find.text('Sonuç yok'), findsOneWidget);
  });

  appTest('browse a dataset in Turkish alphabetical order', (tester, db) async {
    await tester.tap(find.text('Durumlar'));
    await settle(tester);
    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => (t.title as Text).data!)
        .toList();
    expect(titles.first, 'Bilinçsiz');
    expect(titles.indexOf('Sağır') < titles.indexOf('Sersemlemiş'), isTrue);
  });

  appTest('settings show the verbatim SRD attribution', (tester, db) async {
    await tester.tap(find.byTooltip('Ayarlar ve Hakkında'));
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('attribution')), 300, scrollable: scrollableIn(const Key('settings-list')));
    final text = tester.widget<SelectableText>(find.byKey(const Key('attribution'))).data!;
    expect(text, startsWith('This work includes material from the System Reference Document 5.2.1'));
    expect(text, endsWith('https://creativecommons.org/licenses/by/4.0/legalcode.'));
  });
}
