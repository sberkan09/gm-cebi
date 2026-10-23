import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/core/turkish.dart';

void main() {
  group('casing', () {
    test('dotted and dotless i', () {
      expect(trLower('IŞIK İnisiyatif DİKKAT'), 'ışık inisiyatif dikkat');
      expect(trUpper('ışık inisiyatif'), 'IŞIK İNİSİYATİF');
      expect(trCapitalize('istatistik'), 'İstatistik');
      expect(trCapitalize('ışık'), 'Işık');
    });

    test('Dart default casing is wrong for Turkish (why the helpers exist)', () {
      expect('I'.toLowerCase(), 'i');
      expect(trLower('I'), 'ı');
    });
  });

  test('fold for search', () {
    expect(trFold('Cüce'), 'cuce');
    expect(trFold('ÇIĞ ŞÖLEN'), 'cig solen');
    expect(trFold('Initiative'), 'initiative');
    expect(trFold('İnisiyatif'), 'inisiyatif');
  });

  group('collation', () {
    test('Turkish alphabet order', () {
      final words = ['Zehir', 'çanta', 'Cüce', 'ışık', 'iksir', 'Ölü', 'Ok', 'şimşek', 'Sopa', 'ğ', 'Gölge', 'Uzun', 'Ürkek', 'Hançer'];
      words.sort(trCompare);
      expect(words, ['çanta', 'Cüce', 'Gölge', 'ğ', 'Hançer', 'ışık', 'iksir', 'Ok', 'Ölü', 'Sopa', 'şimşek', 'Uzun', 'Ürkek', 'Zehir'].toList()..sort(trCompare));
      expect(trCompare('cüce', 'çanta') < 0, isTrue);
      expect(trCompare('ışık', 'iksir') < 0, isTrue);
      expect(trCompare('Sopa', 'şimşek') < 0, isTrue);
      expect(trCompare('Ok', 'Ölü') < 0, isTrue);
    });

    test('word-by-word: spaces and punctuation sort first', () {
      expect(trCompare('Ak Ejder', 'Akrep') < 0, isTrue);
      expect(trCompare('Ağır-Zırh', 'Ağırlık') < 0, isTrue);
      expect(trCompare('Dragon’s Breath', 'Dragons') < 0, isTrue);
    });

    test('case-insensitive primary order, digits first', () {
      expect(trCompare('apple', 'Banana') < 0, isTrue);
      expect(trCompare('10 fit', 'altın') < 0, isTrue);
      expect(trCompare('a', 'a'), 0);
    });
  });

  group('suffixes', () {
    test('numbers with apostrophe follow how they are read', () {
      expect(withCase('15', TrCase.dative, apostrophe: true), "15'e");
      expect(withCase('40', TrCase.dative, apostrophe: true), "40'a");
      expect(withCase('3', TrCase.locative, apostrophe: true), "3'te");
      expect(withCase('6', TrCase.locative, apostrophe: true), "6'da");
      expect(withCase('5', TrCase.ablative, apostrophe: true), "5'ten");
      expect(withCase('100', TrCase.accusative, apostrophe: true), "100'ü");
      expect(withCase('2', TrCase.genitive, apostrophe: true), "2'nin");
    });

    test('words and proper nouns', () {
      expect(withCase('Goblin', TrCase.dative, apostrophe: true), "Goblin'e");
      expect(withCase('Ork', TrCase.locative, apostrophe: true), "Ork'ta");
      expect(withCase('Kurt', TrCase.accusative, apostrophe: true), "Kurt'u");
      expect(withCase('masa', TrCase.dative), 'masaya');
      expect(withCase('kale', TrCase.genitive), 'kalenin');
      expect(withCase('Aboleth', TrCase.ablative, apostrophe: true), "Aboleth'ten");
    });

    test('abbreviations take suffixes by letter names', () {
      expect(withCase('ZS', TrCase.dative, apostrophe: true), "ZS'ye");
      expect(withCase('NPC', TrCase.dative, apostrophe: true), "NPC'ye");
      expect(withCase('ZD', TrCase.locative, apostrophe: true), "ZD'de");
      expect(possessive3('ZS', apostrophe: true), "ZS'si");
      expect(withCase('KURT', TrCase.dative, apostrophe: true), "KURT'a"); // a word, not letters
    });

    test('plural and counted nouns', () {
      expect(plural('büyü'), 'büyüler');
      expect(plural('kural'), 'kurallar');
      expect(countNoun(3, 'tur'), '3 tur');
    });

    test('compound-noun possessive', () {
      expect(possessive3('Cantrip', apostrophe: true), "Cantrip'i");
      expect(possessive3('Zarı'), 'Zarısı');
      expect(possessive3('Kalkan'), 'Kalkanı');
    });
  });
}
