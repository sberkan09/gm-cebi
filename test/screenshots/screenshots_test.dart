// Renders real-font screenshots of the main screens into docs/screenshots/.
//
//   flutter test test/screenshots --update-goldens --dart-define=FLUTTER_ROOT_FONTS=<flutter>/bin/cache/artifacts/material_fonts
//
// Skipped unless the font directory is given (fonts are not in the repo).
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget/harness.dart';

const fontDir = String.fromEnvironment('FLUTTER_ROOT_FONTS');

Future<void> loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(File('$fontDir/$f').readAsBytesSync())));
    }
    await loader.load();
  }

  await family('Roboto', ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Italic.ttf', 'Roboto-BoldItalic.ttf', 'Roboto-Black.ttf']);
  await family('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

Future<void> shot(WidgetTester tester, String name) async {
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('../../docs/screenshots/$name.png'));
}

void main() {
  if (fontDir.isEmpty) {
    test('screenshots (skipped: pass --dart-define=FLUTTER_ROOT_FONTS=…)', () {}, skip: true);
    return;
  }
  setUpAll(loadFonts);

  appTest('01 search', gmPack: true, (tester, db) async {
    await shot(tester, '01-gozat');
    await tester.enterText(find.byKey(const Key('search-field')), 'kör');
    await settle(tester);
    await shot(tester, '02-arama');
    await tester.tap(find.text('Kör').first);
    await settle(tester);
    await shot(tester, '03-durum-tr');
    await tester.tap(find.text('EN'));
    await settle(tester);
    await shot(tester, '04-durum-en');
  });

  appTest('02 spell and monster', gmPack: true, (tester, db) async {
    await tester.enterText(find.byKey(const Key('search-field')), 'ateş topu');
    await settle(tester);
    await tester.tap(find.text('Ateş Topu').first);
    await settle(tester);
    await shot(tester, '05-buyu');
    await goBack(tester);
    await tester.enterText(find.byKey(const Key('search-field')), 'aboleth');
    await settle(tester);
    await tester.tap(find.text('Aboleth').first);
    await settle(tester);
    await shot(tester, '06-canavar');
  });

  appTest('03 dice', random: FixedRandom([4, 17]), (tester, db) async {
    await openTab(tester, 'Zar');
    await tester.enterText(find.byKey(const Key('dice-field')), '2d20kh1+5');
    await tester.tap(find.byKey(const Key('roll')));
    await settle(tester);
    await shot(tester, '07-zar');
  });

  appTest('04 initiative and notes', gmPack: true, (tester, db) async {
    db.addCombatant(name: 'Ayla', initiative: 17, hp: 24, ac: 15, isPlayer: true);
    db.addCombatant(name: 'Goblin Warrior', initiative: 14, hp: 10, ac: 15, monsterId: 'goblin-warrior');
    db.addCombatant(name: 'Wolf', initiative: 9, hp: 11, ac: 12, monsterId: 'wolf');
    await settle(tester);
    db.nextTurn();
    await settle(tester);
    // Fresh in-memory database: ids are 1, 2, 3 in insertion order.
    db.changeHp(2, 6);
    db.toggleCondition(3, 'prone');
    await settle(tester);
    await openTab(tester, 'İnisiyatif');
    await shot(tester, '08-inisiyatif');
    db.createNote(title: '3. oturum – Gölgeli Orman', body: 'Kurt sürüsü köprüde pusu kurdu. Ayla bir kurdu yere düşürdü.');
    await settle(tester);
    await openTab(tester, 'Notlar');
    await shot(tester, '09-notlar');
  });

  appTest('05 locked', (tester, db) async {
    await openTab(tester, 'İnisiyatif');
    await shot(tester, '10-gm-paketi-kilitli');
  });
}
