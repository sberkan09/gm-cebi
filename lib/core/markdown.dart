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
  bool hasClosing(int from, String marker) {
    var i = text.indexOf(marker, from);
    while (i != -1) {
      if (marker == '*' && i + 1 < text.length && text[i + 1] == '*') {
        i = text.indexOf(marker, i + 2);
        continue;
      }
      return true;
    }
    return false;
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
    if (text[i] == '*' && (italic || hasClosing(i + 1, '*'))) {
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

/// Removes markup, for search indexing and list subtitles.
String stripMarkup(String text) =>
    text.replaceAll('**', '').replaceAll('*', '').replaceFirst(RegExp(r'^#{3,4} '), '').replaceFirst(RegExp(r'^- '), '');
