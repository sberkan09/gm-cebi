import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/backup/device_files.dart';
import 'package:gm_cebi/features/map_image.dart';
import 'package:gm_cebi/features/map_sketch.dart';
import 'package:gm_cebi/features/online_scene/online_settings.dart';
import 'package:gm_cebi/features/online_scene/scene_controller.dart';

import 'harness.dart';
import 'map_test.dart' show at, openMap, pumped;

/// The file the fake picker hands over; the fake preparer says it is 200 × 100.
final _file = Uint8List.fromList([1, 2, 3, 4]);

ui.Image? _upload;
ui.Image? _online;

/// What the fake preparer does with the next file: null accepts it.
String? _refuse;

final _overrides = [
  mapImagePreparerProvider.overrideWithValue((bytes) async {
    if (_refuse != null) throw MapImageException(_refuse!);
    return (bytes: bytes, width: 200, height: 100);
  }),
  mapImageProvider.overrideWith((ref, id) async => _upload),
];

final _withOnline = [
  ..._overrides,
  onlineFeatureVisibleProvider.overrideWithValue(true),
  activeSceneIdProvider.overrideWithValue(1),
  sceneImageProvider.overrideWith((ref, id) async => _online),
];

MapPainter saved(WidgetTester tester) => tester.widget<CustomPaint>(find.byKey(const Key('map-saved'))).painter! as MapPainter;
MapPainter live(WidgetTester tester) => tester.widget<CustomPaint>(find.byKey(const Key('map-live'))).painter! as MapPainter;

Future<void> menu(WidgetTester tester, String item) async {
  await tester.tap(find.byKey(const Key('map-menu')));
  await settle(tester);
  await tester.tap(find.text(item));
  await settle(tester);
}

/// The ⋮ menu's item texts.
Future<List<String>> menuItems(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('map-menu')));
  await settle(tester);
  final items = [
    for (final t in tester.widgetList<Text>(find.descendant(of: find.byWidgetPredicate((w) => w is PopupMenuEntry), matching: find.byType(Text))))
      t.data!,
  ];
  await tester.tapAt(const Offset(5, 5)); // close it
  await settle(tester);
  return items;
}

Future<MapImage?> stored(WidgetTester tester, AppDatabase db) => pumped(tester, db.select(db.mapImages).getSingleOrNull());

Future<Encounter> encounter(WidgetTester tester, AppDatabase db) => pumped(tester, db.activeEncounter());

Future<void> images(WidgetTester tester) async {
  _refuse = null;
  _upload = await tester.runAsync(() => createTestImage(width: 20, height: 10));
  _online = await tester.runAsync(() => createTestImage(width: 8, height: 8));
}

void main() {
  late FakeDeviceFiles files;

  setUp(() => files = FakeDeviceFiles()..pickedImage = _file);

  appTest('load a picture from the menu: shown under the map, fit and grid hint; change and remove', gmPack: true, overrides: [
    ..._overrides,
    deviceFilesProvider.overrideWith((ref) => files),
  ], (tester, db) async {
    await images(tester);
    await openMap(tester);
    expect(await menuItems(tester), isNot(contains('Resmi kaldır')));
    expect(await menuItems(tester), isNot(contains('Arka plan: Yok (yalnızca çizim)')), reason: 'nothing to choose without a picture');

    await menu(tester, 'Harita resmi yükle');
    expect(files.imagePicks, 1);
    final row = (await stored(tester, db))!;
    expect(row.bytes, _file);
    expect((row.width, row.height, row.fit), (200, 100, 'contain'));
    expect(saved(tester).background, same(_upload));
    expect(saved(tester).backgroundFit, MapFit.contain, reason: 'Sığdır by default');

    // The app's grid is not per map: a one-time hint, with a button to turn it off.
    expect(find.text(mapImageGridHint), findsOneWidget);
    expect(saved(tester).grid, isTrue);
    await tester.tap(find.text('Izgarayı kapat'));
    await settle(tester);
    expect(saved(tester).grid, isFalse);

    final items = await menuItems(tester);
    expect(items, containsAll(['Resmi değiştir', 'Resmi kaldır', 'Resim: Sığdır', 'Resim: Doldur']));
    expect(items, containsAll(['Arka plan: Yok (yalnızca çizim)', 'Arka plan: Yüklediğim resim']));
    expect(items, isNot(contains('Arka plan: Çevrimiçi resim')), reason: 'no online picture');

    await menu(tester, 'Resim: Doldur');
    expect((await stored(tester, db))!.fit, 'cover');
    expect(saved(tester).backgroundFit, MapFit.cover);

    // Change: a new row, the fit kept, no second hint.
    await tester.tap(find.byKey(const Key('map-grid')));
    await settle(tester);
    await menu(tester, 'Resmi değiştir');
    final replaced = (await stored(tester, db))!;
    expect(replaced.id, isNot(row.id));
    expect(replaced.fit, 'cover');
    expect(find.text(mapImageGridHint), findsNothing, reason: 'the hint is shown once');

    await menu(tester, 'Resmi kaldır');
    expect(await stored(tester, db), isNull);
    expect(saved(tester).background, isNull);
  });

  appTest('a refused file says why and stores nothing; a cancelled picker does nothing', gmPack: true, overrides: [
    ..._overrides,
    deviceFilesProvider.overrideWith((ref) => files),
  ], (tester, db) async {
    await images(tester);
    await openMap(tester);
    for (final message in [notAnImageMessage, imageTooLargeMessage]) {
      _refuse = message;
      await menu(tester, 'Harita resmi yükle');
      expect(find.text(message), findsOneWidget);
      expect(await stored(tester, db), isNull);
      ScaffoldMessenger.of(tester.element(find.byKey(const Key('map-canvas')))).removeCurrentSnackBar();
      await settle(tester);
    }
    _refuse = null;
    files.pickedImage = null;
    await menu(tester, 'Harita resmi yükle');
    expect(await stored(tester, db), isNull);
    expect(find.byType(SnackBar), findsNothing);
  });

  appTest('background: only the pictures that exist; switching; the drawing over my picture, hidden over the online one', gmPack: true,
      overrides: _withOnline, (tester, db) async {
    await images(tester);
    await db.addScene(assetId: 'a1', png: Uint8List.fromList([1]), mode: 'map', narrative: '', seed: 1); // id 1
    await db.addStroke(const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)]);
    await db.addStroke(const [Offset01(0.2, 0.2), Offset01(0.4, 0.3)], region: RegionKind.water.index, width: 0.05);
    await openMap(tester);
    // The online picture, as before: the drawing hidden.
    expect(saved(tester).background, same(_online));
    expect(saved(tester).strokes, isEmpty);
    expect(saved(tester).regions, isEmpty);
    expect((await menuItems(tester)).where((t) => t.startsWith('Arka plan')), ['Arka plan: Yok (yalnızca çizim)', 'Arka plan: Çevrimiçi resim']);

    await pumped(tester, db.setMapImage(_file, width: 200, height: 100));
    await settle(tester);
    expect(saved(tester).background, same(_upload), reason: 'uploading selects the upload');
    expect(saved(tester).strokes, hasLength(1), reason: 'the drawing stays visible over my picture');
    expect(saved(tester).regions, hasLength(1));
    expect(saved(tester).regionOpacity, lessThan(1), reason: 'areas see-through over the picture');
    expect((await menuItems(tester)).where((t) => t.startsWith('Arka plan')),
        ['Arka plan: Yok (yalnızca çizim)', 'Arka plan: Yüklediğim resim', 'Arka plan: Çevrimiçi resim']);

    await menu(tester, 'Arka plan: Çevrimiçi resim');
    expect((await encounter(tester, db)).mapBackground, 'online');
    expect(saved(tester).background, same(_online));
    expect(saved(tester).backgroundFit, isNull);
    expect(saved(tester).strokes, isEmpty);

    // The online chip still switches the online picture off: my picture shows again.
    await tester.tap(find.byKey(const Key('scene-toggle')));
    await settle(tester);
    expect(saved(tester).background, same(_upload));

    await menu(tester, 'Arka plan: Yok (yalnızca çizim)');
    expect(saved(tester).background, isNull);
    expect(saved(tester).strokes, hasLength(1));

    await menu(tester, 'Arka plan: Yüklediğim resim');
    expect(saved(tester).background, same(_upload));

    // Drawing over my picture keeps it (over the online picture, drawing shows the sketch instead).
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    await tester.dragFrom(at(canvas, 0.2, 0.8), Offset(canvas.width * 0.3, 0));
    await settle(tester);
    expect((await encounter(tester, db)).mapBackground, 'upload');
    expect(saved(tester).strokes, hasLength(2));
  });

  appTest('token size: painted size and hit area follow it', gmPack: true, overrides: _overrides, (tester, db) async {
    await images(tester);
    final goblin = await db.addCombatant(name: 'Goblin', initiative: 15, hp: 7);
    await db.setTokenPosition(goblin, const Offset01(0.5, 0.5));
    await openMap(tester);
    expect(live(tester).tokenScale, 1.0);
    final canvas = tester.getRect(find.byKey(const Key('map-canvas')));
    final r = tokenRadius(canvas.width);
    // Inside a large token's reach, outside a normal one's (1.3 × radius).
    final off = r * 1.7;

    await tester.tapAt(at(canvas, 0.5, 0.5) + Offset(off, 0));
    await settle(tester);
    expect(find.byKey(const Key('token-remove')), findsNothing, reason: 'a normal token is not hit: a dot is drawn');
    expect(await pumped(tester, db.select(db.mapStrokes).get()), hasLength(1));

    expect(await menuItems(tester), containsAll(['Jeton boyutu: Küçük', 'Jeton boyutu: Orta', 'Jeton boyutu: Büyük']));
    await menu(tester, 'Jeton boyutu: Büyük');
    expect((await encounter(tester, db)).tokenScale, 1.5);
    expect(live(tester).tokenScale, 1.5);
    await tester.tapAt(at(canvas, 0.5, 0.5) + Offset(off, 0));
    await settle(tester);
    expect(find.byKey(const Key('token-remove')), findsOneWidget, reason: 'the large token is hit');
    await tester.tapAt(const Offset(5, 5));
    await settle(tester);

    await menu(tester, 'Jeton boyutu: Küçük');
    expect(live(tester).tokenScale, 0.6);
    await tester.tapAt(at(canvas, 0.5, 0.5) + Offset(r * 1.0, 0));
    await settle(tester);
    expect(find.byKey(const Key('token-remove')), findsNothing, reason: 'a small token is hit only near its centre');
  });

  appTest('tablet side panel: background, fit and token size', gmPack: true, surface: const Size(1280, 800), overrides: _withOnline,
      (tester, db) async {
    await images(tester);
    await db.setMapImage(_file, width: 200, height: 100);
    await openMap(tester);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('panel-background')), findsOneWidget);
    await tester.tap(find.descendant(of: find.byKey(const Key('panel-fit')), matching: find.text('Doldur')));
    await settle(tester);
    expect((await stored(tester, db))!.fit, 'cover');
    await tester.tap(find.descendant(of: find.byKey(const Key('panel-token-size')), matching: find.text('Küçük')));
    await settle(tester);
    expect((await encounter(tester, db)).tokenScale, 0.6);
    await tester.tap(find.descendant(of: find.byKey(const Key('panel-background')), matching: find.text('Çevrimiçi')));
    await settle(tester);
    expect(saved(tester).background, same(_online));
  });
}
