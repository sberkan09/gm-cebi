/// The light markdown used in the data files (see docs/data-model.md):
/// `**bold**`, `*italic*`, paragraphs starting with `- ` (bullets) and
/// `### ` / `#### ` (headings). Parsing is pure so it can be unit tested;
/// widgets turn the result into TextSpans.
library;

class MdRun {
  const MdRun(this.text, {this.bold = false, this.italic = false});

  final String text;
  final bool bold;
  final bool italic;

  @override
  bool operator ==(Object other) =>
      other is MdRun && other.text == text && other.bold == bold && other.italic == italic;

  @override
  int get hashCode => Object.hash(text, bold, italic);

  @override
  String toString() => '${bold ? 'B' : ''}${italic ? 'I' : ''}"$text"';
}

enum MdKind { paragraph, bullet, heading3, heading4 }

class MdParagraph {
  const MdParagraph(this.kind, this.runs);

  final MdKind kind;
  final List<MdRun> runs;

  String get plainText => runs.map((r) => r.text).join();
}

/// Splits inline markup into runs. Unbalanced markers are kept as text.
List<MdRun> parseInline(String text) {
  final runs = <MdRun>[];
  var bold = false;
  var italic = false;
  final buf = StringBuffer();

  void flush() {
    if (buf.isEmpty) return;
    final t = buf.toString();
    if (runs.isNotEmpty && runs.last.bold == bold && runs.last.italic == italic) {
      runs[runs.length - 1] = MdRun(runs.last.text + t, bold: bold, italic: italic);
    } else {
      runs.add(MdRun(t, bold: bold, italic: italic));
    }
    buf.clear();
  }

  // Only treat a marker as markup when its closing partner exists.
  bool hasClosing(int from, String marker) => text.indexOf(marker, from) != -1;

  bool isSpace(int i) => i < 0 || i >= text.length || text[i] == ' ' || text[i] == '\n' || text[i] == '\t';

  // The next lone `*` (not half of a `**`) from [from] on, or -1.
  int nextStar(int from) {
    var i = text.indexOf('*', from);
    while (i != -1 && i + 1 < text.length && text[i + 1] == '*') {
      i = text.indexOf('*', i + 2);
    }
    return i;
  }

  // A lone `*` opens italics only when a word follows it and the next lone `*`
  // ends a word. Footnote markers do neither ("Value*", "2 * 3", or the first
  // `*` of "*Halve the value of a *Spell Scroll*"): they stay literal.
  bool opensItalic(int i) {
    if (isSpace(i + 1)) return false;
    final close = nextStar(i + 1);
    return close != -1 && !isSpace(close - 1);
  }

  var i = 0;
  while (i < text.length) {
    if (text.startsWith('**', i)) {
      if (bold || hasClosing(i + 2, '**')) {
        flush();
        bold = !bold;
      } else {
        buf.write('**'); // unpaired: literal
      }
      i += 2;
      continue;
    }
    if (text[i] == '*' && (italic || opensItalic(i))) {
      flush();
      italic = !italic;
      i += 1;
      continue;
    }
    buf.write(text[i]);
    i++;
  }
  flush();
  return runs;
}

MdParagraph parseParagraph(String text) {
  if (text.startsWith('#### ')) return MdParagraph(MdKind.heading4, parseInline(text.substring(5)));
  if (text.startsWith('### ')) return MdParagraph(MdKind.heading3, parseInline(text.substring(4)));
  if (text.startsWith('- ')) return MdParagraph(MdKind.bullet, parseInline(text.substring(2)));
  return MdParagraph(MdKind.paragraph, parseInline(text));
}

/// Paragraphs separated by blank lines (used by monster trait texts).
List<MdParagraph> parseParagraphs(String text) =>
    [for (final p in text.split('\n\n')) if (p.trim().isNotEmpty) parseParagraph(p.trim())];

/// Removes markup, for search indexing and list subtitles. A lone asterisk
/// that is not markup (a footnote marker) is kept, as [parseInline] shows it.
String stripMarkup(String text) {
  var plain = text;
  if (text.contains('*')) {
    // Most marked-up text is bold only: no need to parse it (the index strips every string).
    plain = text.replaceAll('**', '');
    if (plain.contains('*')) plain = parseInline(text).map((r) => r.text).join();
  }
  return plain.replaceFirst(_headingRe, '').replaceFirst(_bulletRe, '');
}

final _headingRe = RegExp(r'^#{3,4} ');
final _bulletRe = RegExp(r'^- ');
