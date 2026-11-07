// Renders real-font screenshots of the main screens into docs/screenshots/.
//
//   flutter test test/screenshots --update-goldens --dart-define=FLUTTER_ROOT_FONTS=<flutter>/bin/cache/artifacts/material_fonts
//
// Skipped unless the font directory is given (fonts are not in the repo).
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gm_cebi/db/database.dart';

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

  appTest('06 battle map', gmPack: true, (tester, db) async {
    // The bridge ambush from docs/spikes/sketch-to-scene, drawn on the map.
    List<Offset01> wave(double x, double amp) =>
        [for (var i = 0; i <= 12; i++) Offset01(x + amp * math.sin(i * 1.3), i / 12)];
    List<Offset01> ring(double cx, double cy, double r) =>
        [for (var i = 0; i <= 14; i++) Offset01(cx + r * math.cos(i * math.pi / 7), cy + r * math.sin(i * math.pi / 7))];
    db.addStroke(wave(0.47, 0.015), color: 1);
    db.addStroke(wave(0.61, 0.015), color: 1);
    db.addStroke(const [Offset01(0.39, 0.43), Offset01(0.72, 0.43), Offset01(0.72, 0.55), Offset01(0.39, 0.55), Offset01(0.39, 0.43)]);
    for (final (x, y) in [(0.16, 0.16), (0.25, 0.27), (0.12, 0.64), (0.21, 0.82), (0.84, 0.18), (0.9, 0.74), (0.78, 0.88)]) {
      db.addStroke(ring(x, y, 0.035), color: 2);
    }
    final ids = <int>[];
    for (final (n, init, hp, pc) in [('Ayla', 17, 24, true), ('Kurt', 15, 11, false), ('Doruk', 12, 30, true), ('Kurt 2', 9, 11, false)]) {
      ids.add(await db.addCombatant(name: n, initiative: init, hp: hp, ac: 13, isPlayer: pc));
    }
    await settle(tester);
    db.setTokenPosition(ids[0], const Offset01(0.29, 0.47));
    db.setTokenPosition(ids[1], const Offset01(0.8, 0.45));
    db.setTokenPosition(ids[2], const Offset01(0.24, 0.55));
    db.changeHp(ids[1], 6);
    db.nextTurn();
    await settle(tester);
    await openTab(tester, 'İnisiyatif');
    await tester.tap(find.byKey(const Key('open-map')));
    await settle(tester);
    await shot(tester, '11-harita');
  });

  appTest('05 locked', (tester, db) async {
    await openTab(tester, 'İnisiyatif');
    await shot(tester, '10-gm-paketi-kilitli');
  });
}
