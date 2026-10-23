import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/app.dart';
import 'package:gm_cebi/data/search.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/flags.dart';
import 'package:gm_cebi/providers.dart';
import 'package:gm_cebi/ui/screens/dice_screen.dart';

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
}) {
  testWidgets(description, (tester) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    await tester.binding.setSurfaceSize(const Size(430, 932));
    try {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          referenceProvider.overrideWith((ref) async => testReference()),
          entitlementsProvider.overrideWithValue(Entitlements(gmPack: gmPack)),
          diceRandomProvider.overrideWithValue(random ?? FixedRandom([10])),
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
