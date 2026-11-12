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

  appTest('a natural 20 is announced when other dice are rolled with the d20', random: FixedRandom([20, 3]), (tester, db) async {
    await openTab(tester, 'Zar');
    await tester.enterText(find.byKey(const Key('dice-field')), '1d20+1d4+5');
    await tester.tap(find.byKey(const Key('roll')));
    await settle(tester);
    expect(tester.widget<Text>(find.byKey(const Key('dice-total'))).data, '28');
    expect(find.text('Doğal 20!'), findsOneWidget);
  });

  appTest('advantage and disadvantage are off unless the expression is a single d20 roll', random: FixedRandom([3, 15]), (tester, db) async {
    await openTab(tester, 'Zar');
    String field() => tester.widget<TextField>(find.byKey(const Key('dice-field'))).controller!.text;
    bool enabled(String key) => tester.widget<OutlinedButton>(find.byKey(Key(key))).onPressed != null;
    Future<void> type(String e) async {
      await tester.enterText(find.byKey(const Key('dice-field')), e);
      await tester.pump();
    }

    expect(enabled('advantage') && enabled('disadvantage'), isTrue, reason: 'the screen opens with 1d20');
    for (final e in ['2d6+3', '1d20+1d4+5', '2d20', '8d6']) {
      await type(e);
      expect(enabled('advantage') || enabled('disadvantage'), isFalse, reason: e);
      await tester.tap(find.byKey(const Key('advantage')), warnIfMissed: false);
      await tester.tap(find.byKey(const Key('disadvantage')), warnIfMissed: false);
      await settle(tester);
      expect(field(), e, reason: 'the expression is left as typed');
      expect(find.byKey(const Key('dice-total')), findsNothing, reason: 'nothing is rolled');
    }
    expect(find.byTooltip('Yalnızca tek d20 atışında (ör. 1d20+5)'), findsNWidgets(2));

    // The dice buttons build expressions too: the buttons follow them.
    await type('1d20');
    expect(enabled('advantage'), isTrue);
    await tester.tap(find.text('d4'));
    await tester.pump();
    expect(field(), '1d20+1d4');
    expect(enabled('advantage'), isFalse);

    await type('d20 + 4');
    expect(enabled('advantage') && enabled('disadvantage'), isTrue);
    await tester.tap(find.byKey(const Key('disadvantage')));
    await settle(tester);
    expect(field(), '2d20kl1+4');
    expect(tester.widget<Text>(find.byKey(const Key('dice-total'))).data, '7');
    await tester.tap(find.byKey(const Key('advantage'))); // from disadvantage to advantage
    await settle(tester);
    expect(field(), '2d20kh1+4');
    expect(tester.widget<Text>(find.byKey(const Key('dice-total'))).data, '19');
  });

  appTest('"+1" on a modifier too long to be a number does nothing', (tester, db) async {
    await openTab(tester, 'Zar');
    await tester.enterText(find.byKey(const Key('dice-field')), '1d20+99999999999999999999');
    await tester.tap(find.text('+1'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(tester.widget<TextField>(find.byKey(const Key('dice-field'))).controller!.text, '1d20+99999999999999999999');
  });

  group('little room', () {
    void keyboard(WidgetTester tester, double height) {
      tester.view.viewInsets = FakeViewPadding(bottom: height * tester.view.devicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
    }

    void textScale(WidgetTester tester, double scale) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }

    /// The part of the screen between the app bar and the expression field.
    Rect resultArea(WidgetTester tester) {
      final bar = tester.getRect(find.widgetWithText(AppBar, 'Zar'));
      return Rect.fromLTRB(bar.left, bar.bottom, bar.right, tester.getRect(find.byKey(const Key('dice-field'))).top - 8);
    }

    void expectInside(Rect inner, Rect outer, String what) {
      expect(inner.top, greaterThanOrEqualTo(outer.top), reason: '$what: top');
      expect(inner.bottom, lessThanOrEqualTo(outer.bottom), reason: '$what: bottom');
      expect(inner.left, greaterThanOrEqualTo(outer.left), reason: '$what: left');
      expect(inner.right, lessThanOrEqualTo(outer.right), reason: '$what: right');
    }

    for (final (size, kb, scale) in const [
      (Size(360, 640), 280.0, 1.0),
      (Size(360, 640), 280.0, 1.3),
      (Size(320, 568), 250.0, 1.0),
      (Size(412, 915), 300.0, 1.6),
      (Size(1280, 800), 400.0, 1.0),
    ]) {
      appTest('keyboard open on ${size.width.toInt()}x${size.height.toInt()} at text scale $scale: the field, "AT" and the result stay in view',
          random: FixedRandom([4, 17]), surface: size, (tester, db) async {
        textScale(tester, scale);
        await openTab(tester, 'Zar');
        keyboard(tester, kb);
        await settle(tester);
        expect(tester.takeException(), isNull, reason: 'nothing overflows');
        final visible = Rect.fromLTRB(0, 0, size.width, size.height - kb);
        expectInside(tester.getRect(find.byKey(const Key('dice-field'))), visible, 'field');
        expectInside(tester.getRect(find.byKey(const Key('roll'))), visible, 'AT');
        expectInside(tester.getRect(find.byKey(const Key('dice-hint'))), resultArea(tester), 'hint');

        await tester.enterText(find.byKey(const Key('dice-field')), '2d20kh1+5');
        await tester.tap(find.byKey(const Key('roll')));
        await settle(tester);
        expect(tester.takeException(), isNull);
        expect(tester.widget<Text>(find.byKey(const Key('dice-total'))).data, '22');
        expectInside(tester.getRect(find.byKey(const Key('dice-total'))), resultArea(tester), 'total');
        expectInside(tester.getRect(find.byKey(const Key('roll'))), visible, 'AT after a roll');

        // An error under the field takes room too.
        await tester.enterText(find.byKey(const Key('dice-field')), '2d');
        await tester.tap(find.byKey(const Key('roll')));
        await settle(tester);
        expect(tester.takeException(), isNull);
        expect(find.textContaining('yüz sayısı'), findsOneWidget);
        expectInside(tester.getRect(find.byKey(const Key('roll'))), visible, 'AT with an error');
        expectInside(tester.getRect(find.byKey(const Key('dice-field'))), visible, 'field with an error');

        // The dice keys are still there: they scroll.
        await tester.enterText(find.byKey(const Key('dice-field')), '1d20');
        await tester.ensureVisible(find.byKey(const Key('advantage')));
        await settle(tester);
        expect(tester.getRect(find.byKey(const Key('dice-keys'))).contains(tester.getCenter(find.byKey(const Key('advantage')))), isTrue,
            reason: 'at least a row of keys shows');
        await tester.tap(find.byKey(const Key('advantage')));
        await settle(tester);
        expect(tester.widget<TextField>(find.byKey(const Key('dice-field'))).controller!.text, '2d20kh1');
      });
    }

    for (final (size, scale) in const [(Size(360, 720), 1.0), (Size(360, 720), 1.3), (Size(360, 720), 1.6), (Size(320, 568), 1.6), (Size(412, 915), 1.6)]) {
      appTest('the hint before the first roll is not cut off at text scale $scale on ${size.width.toInt()}x${size.height.toInt()}', surface: size,
          (tester, db) async {
        textScale(tester, scale);
        await openTab(tester, 'Zar');
        expect(tester.takeException(), isNull);
        final hint = find.byKey(const Key('dice-hint'));
        expect(tester.widget<Text>(hint).data, startsWith('İfadeyi yaz ya da düğmelerle kur, sonra AT.'));
        expectInside(tester.getRect(hint), resultArea(tester), 'hint');
        expectInside(tester.getRect(find.byKey(const Key('roll'))), Offset.zero & size, 'AT');
      });
    }

    appTest('with room, the result is the big card and every dice key is in view', random: FixedRandom([4, 17]), (tester, db) async {
      await openTab(tester, 'Zar');
      expect(tester.widget<Text>(find.byKey(const Key('dice-hint'))).data, contains('4d6dl1'));
      await tester.enterText(find.byKey(const Key('dice-field')), '2d20kh1+5');
      await tester.tap(find.byKey(const Key('roll')));
      await settle(tester);
      expect(find.text('Parantez içindeki zarlar sayılmadı.'), findsOneWidget);
      expect(tester.getSize(find.byKey(const Key('dice-total'))).height, greaterThan(56));
      final keys = tester.getRect(find.byKey(const Key('dice-keys')));
      expectInside(tester.getRect(find.byKey(const Key('disadvantage'))), keys, 'the last key');
      expect(tester.getRect(find.byKey(const Key('roll'))).top, greaterThanOrEqualTo(keys.bottom));
    });
  });
}
