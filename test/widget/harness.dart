import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/app.dart';
import 'package:gm_cebi/data/search.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/backup/backup.dart' show maxBackupBytes;
import 'package:gm_cebi/features/backup/device_files.dart';
import 'package:gm_cebi/features/flags.dart';
import 'package:gm_cebi/features/map_image.dart' show maxPickBytes;
import 'package:gm_cebi/providers.dart';

import '../support.dart';

/// Faces returned in order (1-based), repeating.
class FixedRandom implements Random {
  FixedRandom(this.faces);
  final List<int> faces;
  var _i = 0;

  @override
  int nextInt(int max) => (faces[_i++ % faces.length] - 1) % max;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

Reference? _ref;
Reference testReference() => _ref ??= Reference(loadReference(), SearchIndex.build(loadReference()));

/// Runs [body] against the whole app with an in-memory database and the real
/// asset data, then unmounts everything inside the test body so no drift
/// timers outlive the test.
void appTest(
  String description,
  Future<void> Function(WidgetTester tester, AppDatabase db) body, {
  bool gmPack = false,
  Random? random,
  Size surface = const Size(430, 932),
  double? pixelRatio,
  List<Override> overrides = const [],
}) {
  testWidgets(description, (tester) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    if (pixelRatio != null) tester.view.devicePixelRatio = pixelRatio;
    await tester.binding.setSurfaceSize(surface);
    try {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          referenceProvider.overrideWith((ref) async => testReference()),
          entitlementsProvider.overrideWithValue(Entitlements(gmPack: gmPack)),
          diceRandomProvider.overrideWithValue(random ?? FixedRandom([10])),
          ...overrides,
        ],
        child: const GmCebiApp(),
      ));
      await settle(tester);
      await body(tester, db);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      final closing = db.close();
      await tester.pump(const Duration(seconds: 1));
      await closing;
      await tester.binding.setSurfaceSize(null);
      if (pixelRatio != null) tester.view.resetDevicePixelRatio();
    }
  }, timeout: const Timeout(Duration(seconds: 90)));
}

Finder scrollableIn(Key key) => find.descendant(of: find.byKey(key), matching: find.byType(Scrollable)).first;

/// Lets drift (synchronous in-memory sqlite) futures, stream timers and
/// animations complete. Everything stays in the fake-async zone: mixing in
/// runAsync() would deadlock on drift's connection lock.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 20));
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await settle(tester);
}

/// System back (Android back button / iOS swipe).
Future<void> goBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await settle(tester);
}

/// Records what would go to the share sheet or the save dialog, and hands
/// [picked] (a backup) or [pickedImage] (a map picture) to the file picker.
class FakeDeviceFiles implements DeviceFiles {
  final shared = <(String, Uint8List)>[];
  final saved = <(String, Uint8List)>[];
  final texts = <(String, String?)>[];
  Uint8List? picked;
  bool cancelSave = false;

  @override
  Future<bool> shareFile(Uint8List bytes, {required String fileName, required String mimeType}) async {
    shared.add((fileName, bytes));
    return true;
  }

  @override
  Future<void> shareText(String text, {String? subject}) async => texts.add((text, subject));

  @override
  Future<bool> saveFile(Uint8List bytes, {required String fileName, required String mimeType}) async {
    if (cancelSave) return false;
    saved.add((fileName, bytes));
    return true;
  }

  @override
  Future<Uint8List?> pickJson({int maxBytes = maxBackupBytes}) async => picked;

  /// Handed to "Harita resmi yükle" (null: the picker was cancelled).
  Uint8List? pickedImage;
  int imagePicks = 0;

  @override
  Future<Uint8List?> pickImage({int maxBytes = maxPickBytes}) async {
    imagePicks++;
    return pickedImage;
  }
}
