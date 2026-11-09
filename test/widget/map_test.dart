import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';

import 'harness.dart';

/// Runs a database future to completion inside the fake-async test zone.
Future<T> pumped<T>(WidgetTester tester, Future<T> f) async {
  late T value;
  var done = false;
  f.then((v) {
    value = v;
    done = true;
  });
  for (var i = 0; i < 100 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(done, isTrue, reason: 'database future did not complete');
  return value;
}

Future<List<MapStroke>> strokesOf(WidgetTester tester, AppDatabase db) =>
    pumped(tester, (db.select(db.mapStrokes)..orderBy([(s) => OrderingTerm.asc(s.id)])).get());

Future<Combatant> combatant(WidgetTester tester, AppDatabase db, int id) =>
    pumped(tester, (db.select(db.combatants)..where((c) => c.id.equals(id))).getSingle());

Future<void> openMap(WidgetTester tester) async {
  await openTab(tester, 'İnisiyatif');
  await tester.tap(find.byKey(const Key('open-map')));
  await settle(tester);
}

void main() {
  appTest('no map without the GM pack', (tester, db) async {
    await openTab(tester, 'İnisiyatif');
    expect(find.text('İnisiyatif takibi GM Paketi ile açılır.'), findsOneWidget);
    expect(find.byKey(const Key('open-map')), findsNothing);
  });

  appTest('draw, undo, erase', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    expect(canvas.width, closeTo(canvas.height, 0.5), reason: 'the map is square');

    await tester.dragFrom(canvas.topLeft + Offset(canvas.width * 0.2, canvas.height * 0.3), Offset(canvas.width * 0.5, 0));
    await settle(tester);
    var strokes = await strokesOf(tester, db);
    expect(strokes, hasLength(1));
    expect(strokes.single.offsets.first.x, closeTo(0.2, 0.05));
    expect(strokes.single.offsets.last.x, greaterThan(0.6));

    // A tap leaves a dot in the chosen colour.
    await tester.tap(find.byKey(const Key('map-color-2')));
    await tester.tapAt(canvas.topLeft + Offset(canvas.width * 0.8, canvas.height * 0.8));
    await settle(tester);
    strokes = await strokesOf(tester, db);
    expect(strokes, hasLength(2));
    expect(strokes.last.color, 2);
    expect(strokes.last.offsets, hasLength(1));

    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(1));

    await tester.tap(find.text('Sil'));
    await settle(tester);
    await tester.dragFrom(canvas.topLeft + Offset(canvas.width * 0.45, canvas.height * 0.1), Offset(0, canvas.height * 0.4));
    await settle(tester);
    expect(await strokesOf(tester, db), isEmpty, reason: 'the eraser crossed the line');
  });

  appTest('tokens: place from the tray, drag, remove; turn from the map', gmPack: true, (tester, db) async {
    final goblin = await db.addCombatant(name: 'Goblin', initiative: 15, hp: 7);
    await db.addCombatant(name: 'Ayla', initiative: 12, hp: 20, isPlayer: true);
    await openMap(tester);
    expect(find.text('1. tur · Sıra: Goblin'), findsOneWidget);
    expect(find.byKey(const Key('token-tray')), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('tray-$goblin')));
    await settle(tester);
    var c = await combatant(tester, db, goblin);
    expect(c.mapPosition, isNotNull);
    expect(find.byKey(ValueKey('tray-$goblin')), findsNothing);

    // Dragging from the token moves it instead of drawing.
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    final from = canvas.topLeft + Offset(c.mapPosition!.x * canvas.width, c.mapPosition!.y * canvas.height);
    final gesture = await tester.startGesture(from);
    await gesture.moveBy(const Offset(0, -30));
    await gesture.moveTo(canvas.center);
    await gesture.up();
    await settle(tester);
    c = await combatant(tester, db, goblin);
    expect(c.mapPosition!.x, closeTo(0.5, 0.03));
    expect(c.mapPosition!.y, closeTo(0.5, 0.03));
    expect(await strokesOf(tester, db), isEmpty, reason: 'moving a token draws nothing');

    await tester.tap(find.byKey(const Key('map-next-turn')));
    await settle(tester);
    expect(find.text('1. tur · Sıra: Ayla'), findsOneWidget);

    await tester.tapAt(canvas.center);
    await settle(tester);
    await tester.tap(find.byKey(const Key('token-remove')));
    await settle(tester);
    c = await combatant(tester, db, goblin);
    expect(c.mapPosition, isNull);
  });

  appTest('undo brings back what the eraser and "clear" removed', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await tester.dragFrom(canvas.topLeft + Offset(canvas.width * 0.2, canvas.height * 0.3), Offset(canvas.width * 0.5, 0));
    await settle(tester);
    await tester.dragFrom(canvas.topLeft + Offset(canvas.width * 0.2, canvas.height * 0.7), Offset(canvas.width * 0.5, 0));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(2));

    // Erase the upper line by mistake, then undo: it is back, the lower one untouched.
    await tester.tap(find.text('Sil'));
    await settle(tester);
    await tester.dragFrom(canvas.topLeft + Offset(canvas.width * 0.45, canvas.height * 0.1), Offset(0, canvas.height * 0.4));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(1));
    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(2));

    // Clear everything, then undo.
    await tester.tap(find.byType(PopupMenuButton<String>));
    await settle(tester);
    await tester.tap(find.text('Çizimi temizle'));
    await settle(tester);
    await tester.tap(find.text('Temizle'));
    await settle(tester);
    expect(await strokesOf(tester, db), isEmpty);
    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(2));

    // Undo the drawing itself, newest first.
    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(1));
  });

  appTest('landscape tablet: the map takes the full height, controls on the side', gmPack: true, surface: const Size(1280, 800), (tester, db) async {
    await db.addCombatant(name: 'Goblin', initiative: 15, hp: 7);
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    expect(canvas.height, greaterThan(600), reason: 'nearly the full height of an 800 dp screen');
    expect(canvas.width, closeTo(canvas.height, 0.5));
    final tray = tester.getRect(find.byKey(const Key('token-tray')));
    expect(tray.left, greaterThan(canvas.right), reason: 'the tray is in the side column');
  });

  appTest('a 320 dp phone: the toolbar wraps instead of overflowing', gmPack: true, surface: const Size(320, 640), (tester, db) async {
    await openMap(tester);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('map-color-3')), findsOneWidget);
    await tester.tap(find.byKey(const Key('map-color-3')));
    await settle(tester);
  });
}
