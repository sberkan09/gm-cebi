import 'dart:ui' as ui;

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/map_sketch.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';
import 'package:gm_cebi/providers.dart';
import 'package:gm_cebi/ui/widgets/online_scene.dart';

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

Offset at(Rect canvas, double x, double y) => canvas.topLeft + Offset(canvas.width * x, canvas.height * y);

/// A stroke from (x0, y) to (x1, y), in canvas fractions, with a stylus (or [kind]).
Future<void> penLine(WidgetTester tester, Rect canvas, double x0, double x1, double y,
    {PointerDeviceKind kind = PointerDeviceKind.stylus, int buttons = kPrimaryButton}) async {
  final g = await tester.createGesture(kind: kind, buttons: buttons);
  await g.down(at(canvas, x0, y));
  for (var i = 1; i <= 4; i++) {
    await g.moveTo(at(canvas, x0 + (x1 - x0) * i / 4, y));
  }
  await g.up();
  await settle(tester);
}

/// A stroke from (x, y0) to (x, y1).
Future<void> penLineDown(WidgetTester tester, Rect canvas, double x, double y0, double y1,
    {PointerDeviceKind kind = PointerDeviceKind.stylus, int buttons = kPrimaryButton}) async {
  final g = await tester.createGesture(kind: kind, buttons: buttons);
  await g.down(at(canvas, x, y0));
  for (var i = 1; i <= 4; i++) {
    await g.moveTo(at(canvas, x, y0 + (y1 - y0) * i / 4));
  }
  await g.up();
  await settle(tester);
}

/// Two fingers about [c], spreading from ±[from] to ±[to] horizontally.
Future<void> pinch(WidgetTester tester, Offset c, double from, double to) async {
  final a = await tester.startGesture(c - Offset(from, 0));
  final b = await tester.startGesture(c + Offset(from, 0));
  for (var i = 1; i <= 4; i++) {
    final d = from + (to - from) * i / 4;
    await a.moveTo(c - Offset(d, 0));
    await b.moveTo(c + Offset(d, 0));
  }
  await a.up();
  await b.up();
  await settle(tester);
}

bool penModeOn(WidgetTester tester) => tester.widget<IconButton>(find.byKey(const Key('map-pen-mode'))).isSelected ?? false;

Matrix4 mapView(WidgetTester tester) => tester.widget<Transform>(find.byKey(const Key('map-view'))).transform;

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

  appTest('Alan: paint areas under the lines; the eraser erases the layer of the tool; undo', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    // A pen line first, across the middle.
    await tester.dragFrom(at(canvas, 0.2, 0.5), Offset(canvas.width * 0.6, 0));
    await settle(tester);

    await tester.tap(find.text('Alan'));
    await settle(tester);
    expect(find.byKey(const Key('map-color-0')), findsNothing, reason: 'the area palette replaces the pen colours');
    for (final kind in ['water', 'road', 'forest', 'stone', 'wall', 'sand']) {
      expect(find.byKey(Key('map-region-$kind')), findsOneWidget);
    }
    expect(find.bySemanticsLabel('Alan: Taş zemin'), findsOneWidget);
    // Water, wide by default: a river across the top.
    await tester.dragFrom(at(canvas, 0.1, 0.25), Offset(canvas.width * 0.8, 0));
    await settle(tester);
    // A thin road dot.
    await tester.tap(find.byKey(const Key('map-region-road')));
    await tester.tap(find.byKey(const Key('map-width-0')));
    await tester.tapAt(at(canvas, 0.8, 0.8));
    await settle(tester);
    var strokes = await strokesOf(tester, db);
    expect(strokes, hasLength(3));
    expect(strokes[0].isRegion, isFalse);
    expect(strokes[1].region, RegionKind.water.index);
    expect(strokes[1].width, regionWidths.last);
    expect(strokes[1].offsets.first.y, closeTo(0.25, 0.03));
    expect(strokes[2].region, RegionKind.road.index);
    expect(strokes[2].width, regionWidths.first);
    expect(strokes[2].offsets, hasLength(1));

    // The eraser after "Alan" erases areas: a swipe down the middle crosses the
    // river and the pen line, only the river goes.
    await tester.tap(find.text('Sil'));
    await settle(tester);
    await tester.dragFrom(at(canvas, 0.5, 0.05), Offset(0, canvas.height * 0.6));
    await settle(tester);
    strokes = await strokesOf(tester, db);
    expect(strokes.map((s) => s.region), [null, RegionKind.road.index], reason: 'the pen line stays');

    // Undo brings the river back.
    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(3));

    // After "Çiz", the eraser erases lines and leaves the areas.
    await tester.tap(find.text('Çiz'));
    await settle(tester);
    await tester.tap(find.text('Sil'));
    await settle(tester);
    expect(find.byKey(const Key('map-color-0')), findsOneWidget);
    await tester.dragFrom(at(canvas, 0.5, 0.05), Offset(0, canvas.height * 0.6));
    await settle(tester);
    strokes = await strokesOf(tester, db);
    expect(strokes.map((s) => s.region), [RegionKind.water.index, RegionKind.road.index]);

    // Undo the drawing itself: the newest area first.
    await tester.tap(find.byKey(const Key('map-undo'))); // the erased line back
    await tester.tap(find.byKey(const Key('map-undo'))); // the road dot gone
    await settle(tester);
    expect((await strokesOf(tester, db)).map((s) => s.region), [null, RegionKind.water.index]);
  });

  appTest('Alan with a stylus: pen mode rules apply; the eraser end erases areas', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await tester.tap(find.text('Alan'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('map-region-forest')));
    await settle(tester);
    await penLine(tester, canvas, 0.2, 0.7, 0.3);
    expect(penModeOn(tester), isTrue);
    var strokes = await strokesOf(tester, db);
    expect(strokes.single.region, RegionKind.forest.index);
    expect(strokes.single.offsets.first.x, closeTo(0.2, 0.002), reason: 'the area starts where the pen touched');

    // Pen mode: a finger pans, it never paints.
    await tester.dragFrom(at(canvas, 0.2, 0.7), Offset(canvas.width * 0.5, 0));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(1));

    // The eraser end erases the area (it is about 0.045 of the side away: within its painted width).
    await penLineDown(tester, canvas, 0.45, 0.1, 0.25, kind: PointerDeviceKind.invertedStylus);
    expect(await strokesOf(tester, db), isEmpty);
    await penLine(tester, canvas, 0.2, 0.7, 0.6);
    strokes = await strokesOf(tester, db);
    expect(strokes.single.region, RegionKind.forest.index, reason: 'the tip still paints areas');
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

  appTest('pen: the first stylus touch turns pen mode on and draws exactly where it touched; the setting is kept', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    expect(penModeOn(tester), isFalse);

    await penLine(tester, canvas, 0.2, 0.7, 0.3);
    final strokes = await strokesOf(tester, db);
    expect(strokes, hasLength(1));
    expect(strokes.single.offsets.first.x, closeTo(0.2, 0.002), reason: 'the stroke starts on pointer-down, no touch slop');
    expect(strokes.single.offsets.first.y, closeTo(0.3, 0.002));
    expect(strokes.single.offsets.last.x, closeTo(0.7, 0.002));
    expect(penModeOn(tester), isTrue);
    expect((await pumped(tester, db.readSettings()))['mapPenMode'], 'true');

    // A stylus tap leaves a dot.
    await tester.tapAt(at(canvas, 0.8, 0.8), kind: PointerDeviceKind.stylus);
    await settle(tester);
    expect((await strokesOf(tester, db)).last.offsets, hasLength(1));

    // Settings shows it and can turn it off.
    await goBack(tester);
    await openTab(tester, 'Ara');
    await tester.tap(find.byTooltip('Ayarlar ve Hakkında'));
    await settle(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('pen-mode-switch')), 300, scrollable: scrollableIn(const Key('settings-list')));
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('pen-mode-switch'))).value, isTrue);
    await tester.tap(find.byKey(const Key('pen-mode-switch')));
    await settle(tester);
    expect((await pumped(tester, db.readSettings()))['mapPenMode'], 'false');
  });

  appTest('pen mode: a finger never draws, but still moves and opens tokens', gmPack: true, (tester, db) async {
    final goblin = await db.addCombatant(name: 'Goblin', initiative: 15, hp: 7);
    db.setTokenPosition(goblin, const Offset01(0.2, 0.2));
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await tester.tap(find.byKey(const Key('map-pen-mode')));
    await settle(tester);
    expect(penModeOn(tester), isTrue);

    await tester.dragFrom(at(canvas, 0.3, 0.6), Offset(canvas.width * 0.4, 0));
    await tester.tapAt(at(canvas, 0.7, 0.7));
    await settle(tester);
    expect(await strokesOf(tester, db), isEmpty, reason: 'touch (a palm) does not draw in pen mode');

    final g = await tester.startGesture(at(canvas, 0.2, 0.2));
    await g.moveBy(const Offset(0, 30));
    await g.moveTo(canvas.center);
    await g.up();
    await settle(tester);
    final c = await combatant(tester, db, goblin);
    expect(c.mapPosition!.x, closeTo(0.5, 0.03));
    expect(c.mapPosition!.y, closeTo(0.5, 0.03));
    await tester.tapAt(canvas.center);
    await settle(tester);
    expect(find.byKey(const Key('token-remove')), findsOneWidget);
    await goBack(tester);

    // A palm that lands (and drifts) just before the stylus: its pan is undone
    // when the pen touches, and it changes nothing while the pen draws.
    await pinch(tester, canvas.center, 40, 80);
    final before = mapView(tester).getTranslation();
    final palm = await tester.startGesture(at(canvas, 0.9, 0.9));
    await palm.moveBy(const Offset(-40, -40));
    await tester.pump();
    expect(mapView(tester).getTranslation().x, isNot(closeTo(before.x, 1)), reason: 'one finger pans in pen mode');
    final pen = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await pen.down(at(canvas, 0.1, 0.8));
    await palm.moveBy(const Offset(-60, -60));
    await pen.moveTo(at(canvas, 0.4, 0.8));
    await pen.up();
    await palm.up();
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(1));
    expect(mapView(tester).getTranslation().x, closeTo(before.x, 0.01));
    expect(mapView(tester).getTranslation().y, closeTo(before.y, 0.01));
  });

  appTest('the stylus eraser end erases (undo restores); the toolbar stays on the pen', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await penLine(tester, canvas, 0.2, 0.7, 0.3);
    await penLine(tester, canvas, 0.2, 0.7, 0.7);
    expect(await strokesOf(tester, db), hasLength(2));

    await penLineDown(tester, canvas, 0.45, 0.1, 0.5, kind: PointerDeviceKind.invertedStylus);
    final strokes = await strokesOf(tester, db);
    expect(strokes, hasLength(1));
    expect(strokes.single.offsets.first.y, closeTo(0.7, 0.01), reason: 'only the upper line was crossed');

    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(2));

    // The pen tip still draws: the eraser end did not switch the tool.
    await penLine(tester, canvas, 0.2, 0.7, 0.5);
    expect(await strokesOf(tester, db), hasLength(3));
  });

  appTest('the stylus barrel button erases for that stroke only', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await penLine(tester, canvas, 0.2, 0.7, 0.3);
    expect(await strokesOf(tester, db), hasLength(1));

    await penLineDown(tester, canvas, 0.45, 0.1, 0.5, buttons: kPrimaryButton | kSecondaryStylusButton);
    expect(await strokesOf(tester, db), isEmpty);

    await penLine(tester, canvas, 0.2, 0.7, 0.6);
    expect(await strokesOf(tester, db), hasLength(1), reason: 'without the button the pen draws again');
    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    final back = await strokesOf(tester, db);
    expect(back, hasLength(1), reason: 'the erased line is back');
    expect(back.single.offsets.first.y, closeTo(0.3, 0.01));
  });

  appTest('a hovering stylus shows the brush or the eraser; leaving clears it', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    final pen = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await pen.addPointer(location: at(canvas, 0.5, 0.5));
    await pen.moveTo(at(canvas, 0.55, 0.5));
    await tester.pump();
    expect(find.byKey(const ValueKey('map-hover-pen')), findsOneWidget);
    expect(find.byKey(const ValueKey('map-hover-eraser')), findsNothing);

    // Off the map: gone.
    await pen.moveTo(Offset(canvas.center.dx, canvas.bottom + 40));
    await tester.pump();
    expect(find.byKey(const ValueKey('map-hover-pen')), findsNothing);
    await pen.moveTo(at(canvas, 0.4, 0.4));
    await tester.pump();
    expect(find.byKey(const ValueKey('map-hover-pen')), findsOneWidget);
    await pen.removePointer();
    await tester.pump();
    expect(find.byKey(const ValueKey('map-hover-pen')), findsNothing);

    // The eraser end shows the eraser; it goes when the hover stops.
    final eraser = await tester.createGesture(kind: PointerDeviceKind.invertedStylus);
    await eraser.addPointer(location: at(canvas, 0.5, 0.5));
    await eraser.moveTo(at(canvas, 0.52, 0.5));
    await tester.pump();
    expect(find.byKey(const ValueKey('map-hover-eraser')), findsOneWidget);
    await eraser.removePointer();
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const ValueKey('map-hover-eraser')), findsNothing);
  });

  appTest('two fingers zoom and pan; strokes drawn zoomed in land at the right map place', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    final c = canvas.center;

    // Pen mode off: the first finger's stroke is dropped when the second lands.
    await pinch(tester, c, 40, 80);
    expect(await strokesOf(tester, db), isEmpty);
    var view = mapView(tester);
    expect(view.getMaxScaleOnAxis(), closeTo(2, 0.01));
    // Zoomed about the centre: the map's centre stays in the middle.
    expect(view.getTranslation().x, closeTo(-canvas.width / 2, 1));

    // Map = (screen / side - pan) / scale = (0.25 + 0.5) / 2 = 0.375 ... 0.625.
    await penLine(tester, canvas, 0.25, 0.75, 0.25);
    final s = (await strokesOf(tester, db)).single;
    expect(s.offsets.first.x, closeTo(0.375, 0.005));
    expect(s.offsets.first.y, closeTo(0.375, 0.005));
    expect(s.offsets.last.x, closeTo(0.625, 0.005));

    // Pen mode (now on): one finger pans, without drawing; the pan is clamped.
    await tester.dragFrom(c, Offset(canvas.width, canvas.width));
    await settle(tester);
    view = mapView(tester);
    expect(view.getTranslation().x, closeTo(0, 0.5), reason: 'the map edge stops at the canvas edge');
    expect(view.getTranslation().y, closeTo(0, 0.5));
    expect(await strokesOf(tester, db), hasLength(1));

    // Zoom is clamped at 4x, and the fit button brings the whole map back.
    await pinch(tester, c, 20, 200);
    expect(mapView(tester).getMaxScaleOnAxis(), closeTo(4, 0.001));
    await tester.tap(find.byKey(const Key('map-fit')));
    await settle(tester);
    expect(mapView(tester).getMaxScaleOnAxis(), closeTo(1, 0.001));
    expect(find.byKey(const Key('map-fit')), findsNothing);
  });

  appTest('pen mode turned off by the user stays off when the stylus touches again', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await penLine(tester, canvas, 0.2, 0.7, 0.3);
    expect(penModeOn(tester), isTrue);
    await tester.tap(find.byKey(const Key('map-pen-mode')));
    await settle(tester);
    expect(penModeOn(tester), isFalse);
    await penLine(tester, canvas, 0.2, 0.7, 0.5);
    expect(penModeOn(tester), isFalse, reason: 'the user turned it off');
    expect(await strokesOf(tester, db), hasLength(2), reason: 'the stylus still draws');
    expect((await pumped(tester, db.readSettings()))['mapPenMode'], 'false');
  });

  appTest('an explicit "off" from an earlier launch is not overridden by the stylus', gmPack: true, (tester, db) async {
    await pumped(tester, db.writeSetting('mapPenMode', 'false'));
    // As on the next launch: the settings are read again.
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).invalidate(settingsProvider);
    await settle(tester);
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await penLine(tester, canvas, 0.2, 0.7, 0.3);
    expect(penModeOn(tester), isFalse);
  });

  appTest('pen mode off, eraser tool: a pinch starting on a line does not erase it', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await penLine(tester, canvas, 0.2, 0.8, 0.5, kind: PointerDeviceKind.touch);
    expect(await strokesOf(tester, db), hasLength(1));
    await tester.tap(find.text('Sil'));
    await settle(tester);
    // The first finger lands on the line.
    await pinch(tester, at(canvas, 0.5, 0.5) + const Offset(40, 0), 40, 80);
    expect(mapView(tester).getMaxScaleOnAxis(), greaterThan(1.5));
    expect(await strokesOf(tester, db), hasLength(1), reason: 'a pinch does not erase');
    await tester.tap(find.byKey(const Key('map-undo')));
    await settle(tester);
    expect(await strokesOf(tester, db), isEmpty, reason: 'no erase undo step: undo removes the line itself');
  });

  appTest('pen mode off: a second finger after an erase began puts the erased line back', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await penLine(tester, canvas, 0.2, 0.8, 0.5, kind: PointerDeviceKind.touch);
    await tester.tap(find.text('Sil'));
    await settle(tester);
    final a = await tester.startGesture(at(canvas, 0.5, 0.3));
    await a.moveTo(at(canvas, 0.5, 0.45));
    await a.moveTo(at(canvas, 0.5, 0.55));
    await settle(tester);
    expect(await strokesOf(tester, db), isEmpty, reason: 'the finger dragged across the line');
    final b = await tester.startGesture(at(canvas, 0.8, 0.8));
    await b.moveTo(at(canvas, 0.9, 0.9));
    await a.up();
    await b.up();
    await settle(tester);
    expect(await strokesOf(tester, db), hasLength(1), reason: 'the dropped gesture leaves no trace');
  });

  appTest('a pinch over the scene picture keeps the picture', gmPack: true, overrides: [
    onlineFeatureVisibleProvider.overrideWithValue(true),
    activeSceneIdProvider.overrideWithValue(1),
    sceneImageProvider.overrideWith((ref, id) async => _sceneImage),
  ], (tester, db) async {
    _sceneImage = await tester.runAsync(() => createTestImage(width: 8, height: 8));
    await openMap(tester);
    final container = ProviderScope.containerOf(tester.element(find.byKey(const Key('map-canvas'))));
    expect(container.read(sceneVisibleProvider), isTrue);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await pinch(tester, canvas.center, 40, 80);
    expect(mapView(tester).getMaxScaleOnAxis(), greaterThan(1.5));
    expect(container.read(sceneVisibleProvider), isTrue, reason: 'zooming does not hide the picture');
    // Drawing does (the sketch is shown while editing).
    await tester.dragFrom(at(canvas, 0.2, 0.2), const Offset(60, 0));
    await settle(tester);
    expect(container.read(sceneVisibleProvider), isFalse);
  });

  appTest('pen mode: a two-finger zoom is kept when the stylus lands while the fingers are still down', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await tester.tap(find.byKey(const Key('map-pen-mode')));
    await settle(tester);
    final c = canvas.center;
    final a = await tester.startGesture(c - const Offset(40, 0));
    final b = await tester.startGesture(c + const Offset(40, 0));
    for (var i = 1; i <= 4; i++) {
      await a.moveTo(c - Offset(40.0 + 10 * i, 0));
      await b.moveTo(c + Offset(40.0 + 10 * i, 0));
    }
    await tester.pump();
    final zoomed = mapView(tester).getMaxScaleOnAxis();
    expect(zoomed, greaterThan(1.5));
    final pen = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await pen.down(at(canvas, 0.1, 0.8));
    await pen.moveTo(at(canvas, 0.3, 0.8));
    await pen.up();
    await a.up();
    await b.up();
    await settle(tester);
    expect(mapView(tester).getMaxScaleOnAxis(), closeTo(zoomed, 0.001));
    expect(await strokesOf(tester, db), hasLength(1));
  });

  appTest('a hovering stylus does not rebuild the map layer', gmPack: true, (tester, db) async {
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    CustomPainter? mapPainter() =>
        tester.widget<CustomPaint>(find.descendant(of: find.byKey(const Key('map-view')), matching: find.byType(CustomPaint))).painter;
    final before = mapPainter();
    final pen = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await pen.addPointer(location: at(canvas, 0.5, 0.5));
    for (var i = 1; i <= 10; i++) {
      await pen.moveTo(at(canvas, 0.5 + i / 100, 0.5));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('map-hover-pen')), findsOneWidget);
    expect(identical(mapPainter(), before), isTrue, reason: 'only the cursor layer was rebuilt');
    await pen.removePointer();
    await tester.pump();
  });

  appTest('zoomed in, a token from the tray lands in the part of the map in view', gmPack: true, (tester, db) async {
    final goblin = await db.addCombatant(name: 'Goblin', initiative: 15, hp: 7);
    await openMap(tester);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    // Zoom 2x about the top-left quarter's centre: the view is map 0…0.5.
    await pinch(tester, at(canvas, 0.25, 0.25), 20, 40);
    final view = mapView(tester);
    final s = view.getMaxScaleOnAxis();
    final left = -view.getTranslation().x / canvas.width / s, top = -view.getTranslation().y / canvas.width / s;
    await tester.tap(find.byKey(ValueKey('tray-$goblin')));
    await settle(tester);
    final p = (await combatant(tester, db, goblin)).mapPosition!;
    expect(p.x, inInclusiveRange(left, left + 1 / s));
    expect(p.y, inInclusiveRange(top, top + 1 / s));
  });

  // Wide layout: the toolbar lives in the side column (280–400 dp).
  for (final scale in [1.0, 1.3, 1.6]) {
    for (final size in [const Size(820, 560), const Size(1280, 800)]) {
      appTest('the toolbar fits at text scale $scale on ${size.width.toInt()}x${size.height.toInt()}', gmPack: true, surface: size, (tester, db) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        try {
          await openMap(tester);
          expect(tester.takeException(), isNull, reason: 'no overflow');
          expect(find.byKey(const Key('map-pen-mode')), findsOneWidget);
        } finally {
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        }
      });
    }
  }
}

ui.Image? _sceneImage;
