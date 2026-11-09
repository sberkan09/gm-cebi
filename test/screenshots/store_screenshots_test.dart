// Renders store screenshots (phone size, real fonts) into docs/store/screenshots/.
//
//   flutter test test/screenshots/store_screenshots_test.dart --update-goldens \
//     --dart-define=FLUTTER_ROOT_FONTS=<flutter>/bin/cache/artifacts/material_fonts
//
// Sizes:
//   android/ 1080×1920 (9:16; Google Play accepts at most 2:1)
//   ios/     1320×2868 (6.9" iPhone, the size App Store Connect asks for)
//
// The GM pack is open, as in the store test build (docs/release.md).
// Skipped unless the font directory is given (fonts are not in the repo).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget/harness.dart';
import 'screenshots_test.dart' show fontDir, loadFonts;

class Device {
  const Device(this.dir, this.size, this.pixelRatio);
  final String dir;
  final Size size;
  final double pixelRatio;
}

const devices = [
  Device('android', Size(432, 768), 2.5),
  Device('ios', Size(440, 956), 3),
];

void main() {
  if (fontDir.isEmpty) {
    test('store screenshots (skipped: pass --dart-define=FLUTTER_ROOT_FONTS=…)', () {}, skip: true);
    return;
  }
  setUpAll(loadFonts);

  for (final d in devices) {
    Future<void> shot(String name) =>
        expectLater(find.byType(MaterialApp), matchesGoldenFile('../../docs/store/screenshots/${d.dir}/$name.png'));

    appTest('${d.dir}: search, condition, spell, monster', gmPack: true, surface: d.size, pixelRatio: d.pixelRatio,
        (tester, db) async {
      await tester.enterText(find.byKey(const Key('search-field')), 'ateş');
      await settle(tester);
      await shot('01-arama');
      await tester.enterText(find.byKey(const Key('search-field')), 'kör');
      await settle(tester);
      await tester.tap(find.text('Kör').first);
      await settle(tester);
      await shot('02-durum');
      await goBack(tester);
      await tester.enterText(find.byKey(const Key('search-field')), 'ateş topu');
      await settle(tester);
      await tester.tap(find.text('Ateş Topu').first);
      await settle(tester);
      await shot('03-buyu');
      await goBack(tester);
      await tester.enterText(find.byKey(const Key('search-field')), 'goblin warrior');
      await settle(tester);
      await tester.tap(find.text('Goblin Warrior').first);
      await settle(tester);
      await shot('04-canavar');
    });

    appTest('${d.dir}: dice', gmPack: true, random: FixedRandom([4, 17]), surface: d.size, pixelRatio: d.pixelRatio,
        (tester, db) async {
      await openTab(tester, 'Zar');
      await tester.enterText(find.byKey(const Key('dice-field')), '2d20kh1+5');
      await tester.tap(find.byKey(const Key('roll')));
      await settle(tester);
      await shot('05-zar');
    });

    appTest('${d.dir}: initiative', gmPack: true, surface: d.size, pixelRatio: d.pixelRatio, (tester, db) async {
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
      await shot('06-inisiyatif');
    });
  }
}
