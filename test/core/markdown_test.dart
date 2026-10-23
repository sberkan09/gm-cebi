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
