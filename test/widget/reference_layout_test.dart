import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/reference.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/flags.dart';
import 'package:gm_cebi/providers.dart';
import 'package:gm_cebi/ui/labels.dart';
import 'package:gm_cebi/ui/screens/detail_screen.dart';
import 'package:gm_cebi/ui/screens/search_screen.dart';
import 'package:gm_cebi/ui/theme.dart';
import 'package:gm_cebi/ui/widgets/content.dart';

import 'harness.dart';

/// Runs [body] with a way to show detail pages on their own (no app shell).
void detailTest(
  String description,
  Future<void> Function(WidgetTester tester, Future<void> Function(RefRecord r, Lang lang) show) body, {
  Size surface = const Size(360, 740),
}) {
  testWidgets(description, (tester) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    await tester.binding.setSurfaceSize(surface);
    try {
      await body(tester, (r, lang) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            referenceProvider.overrideWith((ref) async => testReference()),
            entitlementsProvider.overrideWithValue(const Entitlements(gmPack: true)),
          ],
          child: MaterialApp(
            key: ValueKey('${r.key}-$lang'), // a fresh navigator: nothing stays pushed from the page before
            theme: buildTheme(Brightness.dark),
            home: DetailScreen(record: r, initialLang: lang),
          ),
        ));
        await tester.pump();
      });
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      final closing = db.close();
      await tester.pump(const Duration(seconds: 1));
      await closing;
      await tester.binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}

bool _isKeyValue(DataTableView w) =>
    ((w.block['header'] as List?) ?? const []).isEmpty && (w.block['rows'] as List).every((r) => (r as List).length == 2);

void main() {
  final data = testReference().data;

  group('key/value tables', () {
    detailTest('fit a 360dp phone on every class, species and background page', surface: const Size(360, 20000),
        (tester, show) async {
      var checked = 0;
      for (final ds in ['classes', 'species', 'backgrounds']) {
        for (final r in data.byDataset[ds]!) {
          for (final lang in Lang.values) {
            await show(r, lang);
            expect(tester.takeException(), isNull, reason: '${r.key} $lang');
            for (final e in find.byType(DataTableView).evaluate()) {
              if (!_isKeyValue(e.widget as DataTableView)) continue;
              final table = find.descendant(of: find.byWidget(e.widget), matching: find.byType(Table));
              expect(tester.getSize(table).width, lessThanOrEqualTo(360 - 32), reason: '${r.key} $lang');
              // Nothing to scroll sideways: the value column wraps instead.
              expect(find.ancestor(of: table, matching: find.byType(SingleChildScrollView)), findsNothing);
              checked++;
            }
          }
        }
      }
      expect(checked, greaterThan(40));
    });

    detailTest('key column takes at most 40%, short tables stay compact', (tester, show) async {
      await show(data.find('classes', 'barbarian')!, Lang.tr);
      final table = tester.renderObject<RenderTable>(find.descendant(of: find.byType(DataTableView).first, matching: find.byType(Table)));
      final firstKey = table.row(0).first;
      expect(firstKey.size.width, lessThanOrEqualTo(table.size.width * 0.4 + 0.5));
      expect(table.size.width, closeTo(328, 0.5)); // long values: the whole width is used
      // The glossary term card ("Türkçe | Çeviklik") is far narrower than the screen.
      await show(data.find('terms', 'dexterity')!, Lang.tr);
      expect(tester.getSize(find.byType(Table)).width, lessThan(328));
    });

    detailTest('tables with a header still scroll sideways', (tester, show) async {
      await show(data.find('classes', 'wizard')!, Lang.tr);
      final headed = find.byWidgetPredicate((w) => w is DataTableView && ((w.block['header'] as List?) ?? const []).isNotEmpty);
      expect(headed, findsWidgets);
      expect(find.descendant(of: headed.first, matching: find.byType(SingleChildScrollView)), findsOneWidget);
    });
  });

  group('class pages', () {
    test('every core trait has a Turkish label', () {
      for (final r in data.byDataset['classes']!) {
        for (final key in (r.en['core_traits'] as Map<String, dynamic>).keys) {
          expect(ContentLabels.tr.fieldLabel(key), isNot(key), reason: '${r.id}: $key');
          expect(ContentLabels.en.fieldLabel(key), key);
        }
      }
      // Glossary terms: Hit Point Dice → Can Zarı, Saving Throw → Kurtarma Zarı, Proficiency → Yetkinlik.
      expect(ContentLabels.tr.fieldLabel('Hit Point Die'), 'Can Zarı');
      expect(ContentLabels.tr.fieldLabel('Saving Throw Proficiencies'), 'Kurtarma Zarı Yetkinlikleri');
    });

    detailTest('Turkish page shows Turkish trait labels, English page the SRD ones', (tester, show) async {
      final barbarian = data.find('classes', 'barbarian')!;
      await show(barbarian, Lang.tr);
      for (final label in ['Birincil Yetenek', 'Can Zarı', 'Kurtarma Zarı Yetkinlikleri', 'Zırh Eğitimi', 'Başlangıç Ekipmanı']) {
        expect(find.text(label, findRichText: true), findsOneWidget, reason: label);
      }
      expect(find.textContaining('Primary Ability', findRichText: true), findsNothing);
      expect(find.textContaining('Hit Point Die', findRichText: true), findsNothing);
      await show(barbarian, Lang.en);
      expect(find.text('Primary Ability', findRichText: true), findsOneWidget);
      expect(find.text('Hit Point Die', findRichText: true), findsOneWidget);
    });
  });

  group('see also', () {
    test('every see-also title leads to a record, in Turkish and English', () {
      var n = 0;
      for (final r in data.all) {
        for (final lang in Lang.values) {
          if (!r.isIn(lang)) continue;
          for (final title in (r.content(lang)['see_also'] as List?)?.cast<String>() ?? const <String>[]) {
            expect(data.find('rules_glossary', title) ?? resolveTitle(data, title), isNotNull, reason: '${r.key} $lang: $title');
            n++;
          }
        }
      }
      expect(n, greaterThan(300));
      // A rule chapter without a section of its own name opens at its first section; an abbreviation opens its term.
      expect(resolveTitle(data, 'Karakter Oluşturma')!.en['chapter'], 'Character Creation');
      expect(resolveTitle(data, 'Character Creation')!.dataset, 'rules');
      expect(resolveTitle(data, 'NPC')!.key, 'terms/npc');
      expect(resolveTitle(data, 'Siper')!.key, 'rules_glossary/cover');
      expect(resolveTitle(data, 'No Such Rule'), isNull);
    });

    detailTest('chips for a rule chapter and a glossary term open a page', surface: const Size(360, 3000), (tester, show) async {
      Future<String> open(String record, String chip) async {
        await show(data.find('rules_glossary', record)!, Lang.tr);
        await tester.tap(find.widgetWithText(ActionChip, chip));
        await tester.pumpAndSettle();
        return tester.widgetList<Text>(find.byKey(const Key('detail-title'))).last.data!;
      }

      expect(find.byKey(const Key('detail-title')), findsNothing);
      final chapter = resolveTitle(data, 'Karakter Oluşturma')!;
      expect(await open('alignment', 'Karakter Oluşturma'), chapter.displayName(Lang.tr));
      expect(find.text('Karakter Oluşturma'), findsWidgets); // the chapter line of the opened section
      expect(await open('monster', 'NPC'), 'NPC');
      expect(find.byType(TermView), findsOneWidget);
    });

    testWidgets('a chip that leads nowhere is not shown', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GenericView(
            const {'name': 'X', 'see_also': ['Cover', 'No Such Rule']},
            ContentLabels.en,
            onOpen: (_, _) {},
            canOpen: (title) => resolveTitle(data, title) != null,
          ),
        ),
      ));
      expect(find.widgetWithText(ActionChip, 'Cover'), findsOneWidget);
      expect(find.text('No Such Rule'), findsNothing);
    });
  });

  group('tablet', () {
    appTest('reading column is capped at 720dp and centred', surface: const Size(1280, 800), (tester, db) async {
      await tester.enterText(find.byKey(const Key('search-field')), 'ateş topu');
      await settle(tester);
      for (final tile in tester.renderObjectList<RenderBox>(find.descendant(of: find.byKey(const Key('search-results')), matching: find.byType(ListTile)))) {
        expect(tile.size.width, kReadingWidth);
        expect(tile.localToGlobal(Offset.zero).dx, (1280 - kReadingWidth) / 2);
      }
      await tester.tap(find.text('Ateş Topu').first);
      await settle(tester);
      final paragraphs = tester.renderObjectList<RenderParagraph>(find.descendant(of: find.byKey(const Key('detail-list')), matching: find.byType(RichText)));
      expect(paragraphs.map((p) => p.size.width).reduce((a, b) => a > b ? a : b), kReadingWidth);
      for (final p in paragraphs) {
        final left = p.localToGlobal(Offset.zero).dx;
        expect(left, greaterThanOrEqualTo((1280 - kReadingWidth) / 2));
        expect(left + p.size.width, lessThanOrEqualTo((1280 + kReadingWidth) / 2));
      }
    });

    detailTest('phones keep the 16dp margins', (tester, show) async {
      await show(data.find('spells', 'fireball')!, Lang.tr);
      expect(tester.getTopLeft(find.byKey(const Key('detail-title'))).dx, 16);
      expect(readingMargin(360, min: 16), 16);
      expect(readingMargin(720), 0);
      expect(readingMargin(1280), 280);
    });
  });

  group('language switch', () {
    detailTest('TR and EN are 48dp tap targets', (tester, show) async {
      await show(data.find('conditions', 'blinded')!, Lang.tr);
      final segments = find.descendant(of: find.byKey(const Key('lang-toggle')), matching: find.byType(TextButton));
      expect(segments, findsNWidgets(2));
      for (final s in segments.evaluate()) {
        final size = (s.renderObject! as RenderBox).size;
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      final handle = tester.ensureSemantics();
      for (final label in ['TR', 'EN']) {
        final rect = tester.getSemantics(find.descendant(of: find.byKey(const Key('lang-toggle')), matching: find.text(label))).rect;
        expect(rect.width, greaterThanOrEqualTo(48), reason: label);
        expect(rect.height, greaterThanOrEqualTo(48), reason: label);
      }
      handle.dispose();
      await tester.tap(find.text('EN'));
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const Key('detail-title'))).data, 'Blinded');
    });
  });

  group('browse grid and large fonts', () {
    const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5);
    const count = TextStyle(fontSize: 12, height: 1.33);
    final names = [for (final d in datasets) d.plural];

    test('columns follow what the names need', () {
      // Test font: every letter is as wide as the font size (16dp), "Özellikleri" = 176dp.
      ({int columns, int titleLines, double height}) fit(double width, double scale) => fitBrowseGrid(
          width: width, names: names, titleStyle: title, countStyle: count, scaler: TextScaler.linear(scale));
      final wide = fit(1256, 1);
      expect(wide.columns, 5);
      expect(wide.titleLines, 2); // "Silah / Özellikleri"
      final phone = fit(336, 1);
      expect(phone.columns, 1);
      expect(phone.titleLines, 1);
      expect(phone.height, 76);
      final large = fit(336, 2);
      expect(large.columns, 1);
      expect(large.height, greaterThan(phone.height + 40));
      // Short names only: two columns at the default size, one when the font doubles.
      ({int columns, int titleLines, double height}) short(double scale) => fitBrowseGrid(
          width: 336, names: const ['Soylar', 'Zar'], titleStyle: title, countStyle: count, scaler: TextScaler.linear(scale));
      expect(short(1).columns, 2);
      expect(short(1).height, 76);
      expect(short(2).columns, 1);
    });

    for (final scale in [1.0, 1.3, 2.0]) {
      appTest('no name is cut off at text scale $scale on a 360dp phone', surface: const Size(360, 740), (tester, db) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await settle(tester);
        expect(tester.takeException(), isNull);
        final scrollable = find.descendant(of: find.byType(SearchScreen), matching: find.byType(Scrollable)).first;
        var seen = 0;
        for (final d in datasets) {
          final tile = find.byKey(ValueKey('browse-${d.id}'));
          await tester.scrollUntilVisible(tile, 120, scrollable: scrollable);
          expect(tester.takeException(), isNull, reason: d.plural);
          final name = tester.renderObject<RenderParagraph>(find.descendant(of: tile, matching: find.text(d.plural)));
          expect(name.didExceedMaxLines, isFalse, reason: d.plural);
          expect(name.size.width, lessThanOrEqualTo(tester.getSize(tile).width - 64 + 0.5), reason: d.plural);
          if (scale > 1) expect(tester.getSize(tile).height, greaterThan(76), reason: d.plural);
          seen++;
        }
        expect(seen, datasets.length);
      });
    }
  });

  group('result header', () {
    appTest('says how many hits there are beyond the first page; more on request', (tester, db) async {
      await tester.enterText(find.byKey(const Key('search-field')), 'büyü');
      await settle(tester);
      String summary() => tester.widget<Text>(find.byKey(const Key('search-summary'))).data!;
      final total = testReference().index.searchAll('büyü').total;
      expect(total, greaterThan(800));
      expect(summary(), '$total sonuçtan ilk 60');
      final list = scrollableIn(const Key('search-results'));
      await tester.scrollUntilVisible(find.byKey(const Key('search-more')), 2000, scrollable: list, maxScrolls: 200);
      await tester.ensureVisible(find.byKey(const Key('search-more')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('search-more')));
      await settle(tester);
      await tester.scrollUntilVisible(find.byKey(const Key('search-summary')), -4000, scrollable: list, maxScrolls: 200);
      expect(summary(), '$total sonuçtan ilk 120');
      // A new query starts from the first page again; few hits need no paging.
      await tester.enterText(find.byKey(const Key('search-field')), 'aboleth');
      await settle(tester);
      expect(summary(), matches(RegExp(r'^\d+ sonuç$')));
      expect(find.byKey(const Key('search-more')), findsNothing);
      await tester.enterText(find.byKey(const Key('search-field')), 'körün');
      await settle(tester);
      expect(summary(), endsWith(' sonuç · yakın eşleşmeler'));
    });

    appTest('search time is hidden outside internal builds', (tester, db) async {
      expect(kInternalBuild, isFalse);
      await tester.enterText(find.byKey(const Key('search-field')), 'kör');
      await settle(tester);
      expect(find.textContaining(' ms'), findsNothing);
    });

    testWidgets('internal builds show the search time', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [referenceProvider.overrideWith((ref) async => testReference())],
        child: MaterialApp(theme: buildTheme(Brightness.dark), home: const SearchScreen(showTiming: true)),
      ));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('search-field')), 'kör');
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const Key('search-summary'))).data, matches(RegExp(r'^\d+ sonuçtan ilk 60 · \d+(\.\d)? ms$')));
    });
  });
}
