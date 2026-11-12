import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/markdown.dart';
import '../../data/reference.dart';

/// Widest comfortable column of running text. Wider screens (tablets) centre it.
const kReadingWidth = 720.0;

/// Side margin that keeps a column inside a width of [available] at most
/// [kReadingWidth] wide and centred, never less than [min].
double readingMargin(double available, {double min = 0}) => math.max(min, (available - kReadingWidth) / 2);

/// A lazily built list of rows that stays within the reading width on tablets,
/// centred; the list itself keeps the full width, so it scrolls from the margins too.
class ReadingList extends StatelessWidget {
  const ReadingList({super.key, required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: readingMargin(box.maxWidth)),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      );
}

/// Inline markdown (`**bold**`, `*italic*`) as a rich text.
class MdText extends StatelessWidget {
  const MdText(this.text, {super.key, this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyLarge;
    return Text.rich(
      TextSpan(style: base, children: spansFor(parseInline(text))),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

List<InlineSpan> spansFor(List<MdRun> runs) => [
      for (final r in runs)
        TextSpan(
          text: r.text,
          style: TextStyle(
            fontWeight: r.bold ? FontWeight.w700 : null,
            fontStyle: r.italic ? FontStyle.italic : null,
          ),
        ),
    ];

/// One data paragraph: plain, bullet or heading.
class MdParagraphView extends StatelessWidget {
  const MdParagraphView(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = parseParagraph(text);
    final spans = spansFor(p.runs);
    switch (p.kind) {
      case MdKind.heading3:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text.rich(TextSpan(children: spans), style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        );
      case MdKind.heading4:
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text.rich(
            TextSpan(children: spans),
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
          ),
        );
      case MdKind.bullet:
        return Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: t.bodyLarge),
            Expanded(child: Text.rich(TextSpan(children: spans), style: t.bodyLarge)),
          ]),
        );
      case MdKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text.rich(TextSpan(children: spans), style: t.bodyLarge),
        );
    }
  }
}

/// Multi-paragraph text (paragraphs separated by blank lines).
class MdBody extends StatelessWidget {
  const MdBody(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final p in text.split('\n\n')) if (p.trim().isNotEmpty) MdParagraphView(p.trim())],
      );
}

/// Renders a record's `blocks` (paragraphs and tables).
class BlocksView extends StatelessWidget {
  const BlocksView(this.blocks, {super.key});

  final List<dynamic> blocks;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in blocks.cast<Map<String, dynamic>>())
            if (b['type'] == 'table' || b['rows'] != null)
              DataTableView(b)
            else if (b['text'] != null)
              MdParagraphView(b['text'] as String),
        ],
      );
}

/// Key column of a key/value table: as wide as its longest key, but at most
/// [fraction] of the table, and never squeezed below that (the value column
/// gives way and wraps instead).
class _KeyColumnWidth extends TableColumnWidth {
  const _KeyColumnWidth(this.fraction);

  final double fraction;

  double _width(Iterable<RenderBox> cells, double containerWidth) {
    final content = const IntrinsicColumnWidth().maxIntrinsicWidth(cells, containerWidth);
    return containerWidth.isFinite ? math.min(content, containerWidth * fraction) : content;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) => _width(cells, containerWidth);

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) => _width(cells, containerWidth);
}

/// A table block. Tables with a header row keep their natural column widths
/// and scroll sideways when they are wider than the screen. Header-less
/// two-column tables are key/value lists ("Hit Point Die | D12 per level"):
/// they always fit the width, the value column wraps.
class DataTableView extends StatelessWidget {
  const DataTableView(this.block, {super.key});

  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final header = (block['header'] as List?)?.cast<String>() ?? const [];
    final rows = ((block['rows'] as List?) ?? const []).map((r) => (r as List).cast<String>()).toList();
    final cols = [header.length, for (final r in rows) r.length].fold<int>(0, (a, b) => a > b ? a : b);
    if (cols == 0) return const SizedBox.shrink();
    final keyValue = header.isEmpty && cols == 2;
    Widget cell(String s, {bool head = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: keyValue ? double.infinity : 260),
            child: MdText(s, style: (head ? t.labelLarge?.copyWith(fontWeight: FontWeight.w700) : t.bodyMedium)),
          ),
        );
    List<String> pad(List<String> r) => [...r, for (var i = r.length; i < cols; i++) ''];
    final table = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        // Key/value: the key column takes what it needs up to 40%; the value
        // column is shrunk by the table to the width that is left.
        columnWidths: keyValue ? const {0: _KeyColumnWidth(0.4)} : null,
        border: TableBorder.symmetric(inside: BorderSide(color: scheme.outlineVariant)),
        children: [
          if (header.isNotEmpty)
            TableRow(
              decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
              children: [for (final h in pad(header)) cell(h, head: true)],
            ),
          for (final r in rows) TableRow(children: [for (final c in pad(r)) cell(c)]),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (block['title'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(block['title'] as String, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
        if (keyValue) table else SingleChildScrollView(scrollDirection: Axis.horizontal, child: table),
      ]),
    );
  }
}

IconData datasetIcon(String dataset) => switch (dataset) {
      'conditions' => Icons.healing_outlined,
      'rules_glossary' => Icons.menu_book_outlined,
      'spells' => Icons.auto_awesome_outlined,
      'monsters' => Icons.pest_control_outlined,
      'classes' => Icons.shield_outlined,
      'subclasses' => Icons.account_tree_outlined,
      'species' => Icons.groups_outlined,
      'backgrounds' => Icons.history_edu_outlined,
      'feats' => Icons.star_outline,
      'equipment' => Icons.backpack_outlined,
      'weapon_mastery' || 'weapon_properties' => Icons.gavel_outlined,
      'magic_items' => Icons.diamond_outlined,
      'rules' => Icons.library_books_outlined,
      'terms' => Icons.translate,
      _ => Icons.article_outlined,
    };

/// "Durum" chip used in lists.
class DatasetChip extends StatelessWidget {
  const DatasetChip(this.info, {super.key});

  final DatasetInfo info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Text(info.singular, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSecondaryContainer)),
    );
  }
}
