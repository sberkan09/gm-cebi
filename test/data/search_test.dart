import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/reference.dart';
import 'package:gm_cebi/core/turkish.dart';

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
    final hits = index.search('kördür');
    expect(hits.first.record.key, 'conditions/blinded');
    expect(hits.first.approximate, isTrue);
    // An exact word in a translated name wins over the fallback.
    expect(index.search('körlük').first.record.key, 'spells/blindness-deafness');
  });

  test('inflected Turkish queries find the record by its stem', () {
    expect(top('can puanları').first, 'rules_glossary/hit-points');
    expect(top('kurtarma zarları').first, 'rules_glossary/saving-throw');
    expect(top('yetenek testleri').first, 'rules_glossary/ability-check');
    expect(top('büyü slotları').first, 'terms/spell-slot');
    expect(top('körün').first, 'conditions/blinded');
    expect(top('korun').first, 'conditions/blinded'); // typed without diacritics
    expect(top('iskeletin').first, 'monsters/skeleton');
    expect(top('ateş topuyla').first, 'spells/fireball');
    expect(top('kısa dinlenmeden').first, 'rules_glossary/short-rest');
    expect(index.search('körün').first.approximate, isTrue);
  });

  test('stems: stacked suffixes, buffer letters and consonant softening', () {
    expect(trStems('puanlarinin'), containsAll(['puanlar', 'puan']));
    expect(trStems('zarina'), contains('zar'));
    expect(trStems('buyucunun'), contains('buyucu'));
    expect(trStems('kitabi'), contains('kitap')); // p → b
    expect(trStems('kanadi'), contains('kanat')); // t → d
    expect(trStems('kopegi'), contains('kopek')); // k → ğ (folded g)
    expect(trStems('oklar'), contains('ok'));
    expect(trStems('kor'), isEmpty);
    // Softened stems reach the record: "kalkana" → Kalkan, "değneği" → Değnek…
    expect(top('asanın', 5).join(' '), contains('staff'));
    expect(top('kitaba', 5).every((k) => k.contains('tome') || k.contains('book') || k.contains('manual')), isTrue);
  });

  test('longer stems rank before shorter ones', () {
    final keys = top('büyüleri', 3);
    expect(keys.first, 'rules/spells-intro'); // "Büyüler"
    expect(keys.skip(1), containsAll(['rules_glossary/magic', 'rules_glossary/spell'])); // "Büyü"
  });

  test('glossary terms rank below records that match by name', () {
    for (final q in ['goblin', 'ejderha', 'dragon', 'goblinler']) {
      final hits = index.search(q);
      expect(hits.first.record.dataset, isNot('terms'), reason: q);
      final lastNamed = hits.lastIndexWhere((h) => h.record.dataset != 'terms' && h.score > 200);
      final firstTerm = hits.indexWhere((h) => h.record.dataset == 'terms');
      expect(firstTerm == -1 || firstTerm > lastNamed, isTrue, reason: q);
    }
    expect(top('fırsat saldırısı').first, 'rules_glossary/opportunity-attacks');
    expect(top('fırsat saldırısı', 2).last, 'terms/opportunity-attack');
  });

  test('English names rank the same in any letter case', () {
    List<String> scores(String q) => [for (final h in index.search(q).take(5)) '${h.record.key} ${h.score}'];
    expect(scores('invisible'), scores('Invisible'));
    expect(scores('INVISIBLE'), scores('Invisible'));
    expect(scores('initiative'), scores('Initiative'));
    expect(top('invisible').first, 'conditions/invisible');
    // The exact-spelling bonus still separates Turkish letters.
    expect(top('ISIK', 1), top('ısık', 1));
  });

  test('total hit count is reported beyond the limit', () {
    final r = index.searchAll('büyü');
    expect(r.hits.length, 60);
    expect(r.total, greaterThan(800));
    expect(index.searchAll('büyü', limit: 120).hits.take(60).map((h) => h.record.key), r.hits.map((h) => h.record.key));
    final few = index.searchAll('aboleth');
    expect(few.total, few.hits.length);
    expect(index.searchAll('').total, 0);
  });

  test('terms: glossary entries without a record', () {
    final hits = index.search('çeviklik');
    expect(hits.first.record.dataset, 'terms');
    expect(hits.first.record.en['name'], 'Dexterity');
  });

  test('approximate fallback only matches names, not body text', () {
    final hits = index.search('strahd'); // not in the SRD; stem "str"
    expect(hits.every((h) => h.approximate), isTrue);
    expect(hits.map((h) => h.record.enName), isNot(contains('Restrained')));
    expect(hits.length, lessThan(15));
  });

  test('dataset filter', () {
    final hits = index.search('dragon', limit: 400, only: 'monsters');
    expect(hits, isNotEmpty);
    expect(hits.every((h) => h.record.dataset == 'monsters'), isTrue);
    expect(hits.length, greaterThan(30));
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

  test('inflected queries stay within the per-keystroke budget (5 ms)', () {
    const queries = ['can puanları', 'kurtarma zarlarından', 'büyü slotları', 'körün', 'ejderhalarının', 'fırsat saldırısı', 'strahd'];
    for (final q in queries) {
      index.search(q); // warm-up
      var best = 1 << 30;
      final sw = Stopwatch();
      for (var i = 0; i < 5; i++) {
        sw
          ..reset()
          ..start();
        index.search(q);
        sw.stop();
        if (sw.elapsedMicroseconds < best) best = sw.elapsedMicroseconds;
      }
      expect(best, lessThan(5000), reason: q);
    }
  });

  test('sorted listing uses Turkish collation', () {
    final conds = data.sorted('conditions', Lang.tr).map((r) => r.displayName(Lang.tr)).toList();
    expect(conds.first, 'Bilinçsiz');
    expect(conds.indexOf('Sağır') < conds.indexOf('Sersemlemiş'), isTrue);
    expect(conds.indexOf('Görünmez') < conds.indexOf('Kısıtlanmış'), isTrue);
  });
}
