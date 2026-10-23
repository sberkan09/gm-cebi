import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/reference.dart';

import '../support.dart';

void main() {
  late final data = loadReference();
  late final index = loadIndex();

  List<String> top(String q, [int n = 3]) => [for (final h in index.search(q).take(n)) h.record.key];

  test('all datasets load', () {
    expect(data.byDataset['spells']!.length, 339);
    expect(data.byDataset['monsters']!.length, 330);
    expect(data.byDataset['conditions']!.length, 15);
    expect(data.byDataset['terms']!.length, greaterThan(100));
    expect(data.find('conditions', 'blinded')!.trName, 'Kör');
  });

  test('Turkish name finds the record first', () {
    expect(top('kör').first, 'conditions/blinded');
    expect(top('ateş topu').first, 'spells/fireball');
    expect(top('Kurtarma Zarı').first, 'rules_glossary/saving-throw');
  });

  test('English name finds the same record', () {
    expect(top('blinded').first, 'conditions/blinded');
    expect(top('fireball').first, 'spells/fireball');
    expect(top('saving throw').first, 'rules_glossary/saving-throw');
  });

  test('case, dotted i and diacritics do not matter', () {
    expect(top('KÖR').first, 'conditions/blinded');
    expect(top('cuce').first, 'species/dwarf');
    expect(top('İNİSİYATİF').first, 'rules_glossary/initiative');
    expect(top('inisiyatif').first, 'rules_glossary/initiative');
  });

  test('glossary aliases make untranslated records findable in Turkish', () {
    expect(top('hançer').first, 'equipment/dagger');
    expect(top('barbar').first, 'classes/barbarian');
    final dwarf = data.find('species', 'dwarf')!;
    expect(dwarf.displayName(Lang.tr), 'Cüce');
    expect(dwarf.otherName(Lang.tr), 'Dwarf');
  });

  test('prefix and substring matches', () {
    expect(top('abol').first, 'monsters/aboleth');
    expect(top('ball', 10), contains('spells/fireball'));
    expect(top('drag', 30).where((k) => k.startsWith('monsters/')).length, greaterThan(5));
  });

  test('exact Turkish spelling ranks above folded matches', () {
    final keys = top('kör', 4);
    expect(keys.take(3), containsAll(['conditions/blinded', 'rules_glossary/blindsight']));
    expect(!keys.contains('classes/ranger') || keys.indexOf('classes/ranger') > 1, isTrue);
  });

  test('body text is searchable at lower rank', () {
    final hits = index.search('tentacle');
    expect(hits.map((h) => h.record.key), contains('monsters/aboleth'));
  });

  test('Turkish suffix fallback', () {
    final hits = index.search('körlük');
    expect(hits.first.record.key, 'conditions/blinded');
    expect(hits.first.approximate, isTrue);
  });

  test('terms: glossary entries without a record', () {
    final hits = index.search('çeviklik');
    expect(hits.first.record.dataset, 'terms');
    expect(hits.first.record.en['name'], 'Dexterity');
  });

  test('empty and junk queries', () {
    expect(index.search(''), isEmpty);
    expect(index.search('   '), isEmpty);
    expect(index.search('!!!'), isEmpty);
    expect(index.search('qqqqzzzz'), isEmpty);
  });

  test('every search over the full data set takes under 100 ms', () {
    index.search('warmup');
    const queries = ['a', 'k', 'kö', 'kör', 'ateş', 'dragon', 'saving throw', 'can puanı', 'hançer', 'zzz', 'the', 'büyü slotu', 'i'];
    final sw = Stopwatch();
    for (final q in queries) {
      sw
        ..reset()
        ..start();
      index.search(q);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(100), reason: q);
    }
  });

  test('sorted listing uses Turkish collation', () {
    final conds = data.sorted('conditions', Lang.tr).map((r) => r.displayName(Lang.tr)).toList();
    expect(conds.first, 'Bilinçsiz');
    expect(conds.indexOf('Sağır') < conds.indexOf('Sersemlemiş'), isTrue);
    expect(conds.indexOf('Görünmez') < conds.indexOf('Kısıtlanmış'), isTrue);
  });
}
