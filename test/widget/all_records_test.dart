import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/reference.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/flags.dart';
import 'package:gm_cebi/providers.dart';
import 'package:gm_cebi/ui/screens/detail_screen.dart';
import 'package:gm_cebi/ui/theme.dart';
import 'package:gm_cebi/ui/widgets/content.dart';

import 'harness.dart';

int _tables(List<dynamic>? blocks) =>
    (blocks ?? const []).where((b) => (b as Map)['type'] == 'table' || b['rows'] != null).length;

/// Tables a record's content should show (top-level blocks and feature blocks).
int expectedTables(Map<String, dynamic> c) {
  var n = _tables(c['blocks'] as List?);
  for (final f in (c['features'] as List?) ?? const []) {
    n += _tables((f as Map)['blocks'] as List?);
  }
  return n;
}

void main() {
  // Every record with a table or a Turkish translation, in both languages,
  // plus the first records of every dataset: nothing may throw and every table
  // block must be drawn (a translated "type" once hid them).
  final data = testReference().data;
  final picked = <RefRecord>{
    for (final r in data.all)
      if (r.hasTr || expectedTables(r.en) > 0) r,
    for (final ds in data.byDataset.values) ...ds.take(5),
  }.toList();

  testWidgets('detail pages render ${picked.length} records in TR and EN', (tester) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    await tester.binding.setSurfaceSize(const Size(430, 20000)); // tall: build everything
    try {
      for (final r in picked) {
        for (final lang in Lang.values) {
          await tester.pumpWidget(ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              referenceProvider.overrideWith((ref) async => testReference()),
              entitlementsProvider.overrideWithValue(const Entitlements(gmPack: true)),
            ],
            child: MaterialApp(
              theme: buildTheme(Brightness.dark),
              home: DetailScreen(key: ValueKey('${r.key}-$lang'), record: r, initialLang: lang),
            ),
          ));
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '${r.key} $lang');
          expect(find.byType(DataTableView).evaluate().length, greaterThanOrEqualTo(expectedTables(r.content(lang))),
              reason: '${r.key} $lang');
        }
      }
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      final closing = db.close();
      await tester.pump(const Duration(seconds: 1));
      await closing;
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
