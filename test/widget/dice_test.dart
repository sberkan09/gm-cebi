import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  appTest('typed expression rolls with advantage and shows the dropped die', random: FixedRandom([4, 17]), (tester, db) async {
    await openTab(tester, 'Zar');
    await tester.enterText(find.byKey(const Key('dice-field')), '2d20kh1+5');
    await tester.tap(find.byKey(const Key('roll')));
    await settle(tester);
    expect(tester.widget<Text>(find.byKey(const Key('dice-total'))).data, '22');
    expect(tester.widget<Text>(find.byKey(const Key('dice-breakdown'))).data, '[(4), 17] + 5');
  });

  appTest('die buttons build the expression', (tester, db) async {
    await openTab(tester, 'Zar');
    await tester.tap(find.text('d6'));
    await tester.tap(find.text('d6'));
    await tester.tap(find.text('+1'));
    await tester.pump();
    final field = tester.widget<TextField>(find.byKey(const Key('dice-field')));
    expect(field.controller!.text, '1d20+2d6+1');
  });

  appTest('advantage button keeps the modifier', random: FixedRandom([3, 15]), (tester, db) async {
    await openTab(tester, 'Zar');
    await tester.enterText(find.byKey(const Key('dice-field')), '1d20+4');
    await tester.tap(find.byKey(const Key('advantage')));
    await settle(tester);
    expect(tester.widget<Text>(find.byKey(const Key('dice-total'))).data, '19');
  });

  appTest('invalid expression shows a Turkish error', (tester, db) async {
    await openTab(tester, 'Zar');
    await tester.enterText(find.byKey(const Key('dice-field')), '2d');
    await tester.tap(find.byKey(const Key('roll')));
    await settle(tester);
    expect(find.textContaining('yüz sayısı'), findsOneWidget);
  });
}
