import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/core/markdown.dart';

void main() {
  test('bold and italic runs', () {
    expect(parseInline('**Göremez.** Hiçbir *şey* göremezsin.'), [
      const MdRun('Göremez.', bold: true),
      const MdRun(' Hiçbir '),
      const MdRun('şey', italic: true),
      const MdRun(' göremezsin.'),
    ]);
  });

  test('unbalanced markers stay as text', () {
    expect(parseInline('5 * 3 = 15'), [const MdRun('5 * 3 = 15')]);
    expect(parseInline('**açık'), [const MdRun('**açık')]);
  });

  test('footnote asterisks stay literal next to real italics', () {
    // rules/magic-items-magic-item-rarity: a footnote that mentions an italic item name.
    expect(parseInline('*Halve the value for an item other than a *Spell Scroll*. The value of a *Spell Scroll* is double.'), [
      const MdRun('*Halve the value for an item other than a '),
      const MdRun('Spell Scroll', italic: true),
      const MdRun('. The value of a '),
      const MdRun('Spell Scroll', italic: true),
      const MdRun(' is double.'),
    ]);
    expect(parseInline('*Değeri, *Büyü Parşömeni* dışındaki eşyalar için yarıya indir. Bir *Büyü Parşömeni*\'nin değeri iki katıdır.'), [
      const MdRun('*Değeri, '),
      const MdRun('Büyü Parşömeni', italic: true),
      const MdRun(' dışındaki eşyalar için yarıya indir. Bir '),
      const MdRun('Büyü Parşömeni', italic: true),
      const MdRun('\'nin değeri iki katıdır.'),
    ]);
    // rules/magic-items-crafting-magic-items
    expect(parseInline('*The time and cost are halved for an item other than a *Spell Scroll*, whose cost is given.'), [
      const MdRun('*The time and cost are halved for an item other than a '),
      const MdRun('Spell Scroll', italic: true),
      const MdRun(', whose cost is given.'),
    ]);
    // Markers at the end of a table cell or before a space are not emphasis.
    expect(parseInline('Value*'), [const MdRun('Value*')]);
    expect(parseInline('Fast* and Slow*'), [const MdRun('Fast* and Slow*')]);
    expect(parseInline('2 * 3 * 4'), [const MdRun('2 * 3 * 4')]);
    expect(parseInline('5* then *italic* text'), [const MdRun('5* then '), const MdRun('italic', italic: true), const MdRun(' text')]);
    expect(parseInline('**Bold.** *Note without an end.'), [const MdRun('Bold.', bold: true), const MdRun(' *Note without an end.')]);
    expect(stripMarkup('*Halve the value of a *Spell Scroll*.'), '*Halve the value of a Spell Scroll.');
    expect(stripMarkup('Value*'), 'Value*');
  });

  test('italic inside bold', () {
    expect(parseInline('**Ateş *Topu***'), [
      const MdRun('Ateş ', bold: true),
      const MdRun('Topu', bold: true, italic: true),
    ]);
  });

  test('paragraph kinds', () {
    expect(parseParagraph('- Koni').kind, MdKind.bullet);
    expect(parseParagraph('### Otherworldly Steed').kind, MdKind.heading3);
    expect(parseParagraph('#### Actions').plainText, 'Actions');
    expect(parseParagraphs('a\n\nb').length, 2);
    expect(stripMarkup('**Etiket.** *metin*'), 'Etiket. metin');
  });
}
