import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reference.dart';
import '../../data/search.dart';
import '../../features/flags.dart';
import '../../providers.dart';
import '../widgets/content.dart';
import 'browse_screen.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

/// One box, Turkish or English, offline. The box sits at the bottom of the
/// screen so it can be reached with the thumb.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.showTiming = kInternalBuild});

  /// Shows how long the search took next to the hit count. A developer
  /// figure: on in internal (test-group) builds only.
  final bool showTiming;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  /// Results are shown a page at a time; "Daha fazla göster" adds a page.
  static const _pageSize = 60;

  SearchResults _results = const SearchResults([], 0);
  int _micros = 0;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _run(SearchIndex index, String q, {int limit = _pageSize}) {
    final sw = Stopwatch()..start();
    final results = index.searchAll(q, limit: limit);
    sw.stop();
    setState(() {
      _results = results;
      _micros = sw.elapsedMicroseconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reference = ref.watch(referenceProvider);
    final lang = ref.watch(currentSettingsProvider).contentLang;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ara'),
        actions: [
          IconButton(
            tooltip: 'Ayarlar ve Hakkında',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: reference.when(
        loading: () => const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Kurallar yükleniyor…'),
          ]),
        ),
        error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Veri yüklenemedi: $e'))),
        data: (r) => Column(children: [
          Expanded(
            child: _controller.text.trim().isEmpty
                ? _BrowseGrid(data: r.data, lang: lang)
                : _Results(
                    results: _results,
                    lang: lang,
                    micros: widget.showTiming ? _micros : null,
                    onMore: () => _run(r.index, _controller.text, limit: _results.hits.length + _pageSize),
                  ),
          ),
          _SearchBox(
            controller: _controller,
            focusNode: _focus,
            onChanged: (q) => _run(r.index, q),
            onClear: () {
              _controller.clear();
              _run(r.index, '');
            },
          ),
        ]),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.focusNode, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TextField(
            key: const Key('search-field'),
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            autocorrect: false,
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(
              hintText: 'Kural, durum, büyü, canavar… (TR / EN)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => controller.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(tooltip: 'Temizle', icon: const Icon(Icons.close), onPressed: onClear),
              ),
            ),
          ),
        ),
      );
}

class _Results extends StatelessWidget {
  const _Results({required this.results, required this.lang, required this.micros, required this.onMore});

  final SearchResults results;
  final Lang lang;

  /// Search time, when it is to be shown (internal builds).
  final int? micros;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final hits = results.hits;
    if (hits.isEmpty) {
      return Center(child: Text('Sonuç yok', style: t.titleMedium?.copyWith(color: scheme.onSurfaceVariant)));
    }
    // Only the best hits are listed: say how many there are, and offer the rest.
    final more = results.total > hits.length;
    final summary = [
      more ? '${results.total} sonuçtan ilk ${hits.length}' : '${hits.length} sonuç',
      if (micros != null) '${(micros! / 1000).toStringAsFixed(micros! < 10000 ? 1 : 0)} ms',
      if (hits.first.approximate) 'yakın eşleşmeler',
    ].join(' · ');
    return ReadingList(
      key: const Key('search-results'),
      itemCount: hits.length + (more ? 2 : 1),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(summary, key: const Key('search-summary'), style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          );
        }
        if (i > hits.length) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('search-more'),
                icon: const Icon(Icons.expand_more),
                label: const Text('Daha fazla göster'),
                onPressed: onMore,
              ),
            ),
          );
        }
        return RecordTile(record: hits[i - 1].record, lang: lang);
      },
    );
  }
}

/// List row for a record: name in the chosen language, the other name and type below.
class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, required this.lang, this.onTap});

  final RefRecord record;
  final Lang lang;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final other = record.otherName(lang);
    final untranslated = lang == Lang.tr && !record.hasTr && record.aliasTr == null;
    return ListTile(
      leading: Icon(datasetIcon(record.dataset), color: scheme.primary),
      title: Text(record.displayName(lang), style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Row(children: [
        DatasetChip(record.info),
        if (other != null) ...[
          const SizedBox(width: 8),
          Flexible(child: Text(other, overflow: TextOverflow.ellipsis, style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))),
        ],
      ]),
      trailing: untranslated ? Text('EN', style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant)) : null,
      onTap: onTap ?? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(record: record))),
    );
  }
}

/// Columns and tile height of the browse grid for the text as it will really
/// be drawn (font, weight, the user's text scale).
///
/// As many columns as fit tiles of up to [_BrowseGrid.maxTile], fewer when a
/// name would have to break inside a word ("Canavarlar" at 1.3× on a 360dp
/// phone: one column). Names may wrap between words; every tile is as tall as
/// the tallest name needs, so nothing is cut off at any text scale.
({int columns, int titleLines, double height}) fitBrowseGrid({
  required double width,
  required Iterable<String> names,
  required TextStyle titleStyle,
  required TextStyle countStyle,
  required TextScaler scaler,
  TextDirection direction = TextDirection.ltr,
}) {
  final painter = TextPainter(textDirection: direction, textScaler: scaler);
  double textWidth(int columns) => (width - _BrowseGrid.gap * (columns - 1)) / columns - _BrowseGrid.tileChrome;
  var longestWord = 0.0;
  for (final word in names.expand((n) => n.split(' '))) {
    painter
      ..text = TextSpan(text: word, style: titleStyle)
      ..layout();
    longestWord = math.max(longestWord, painter.width);
  }
  var columns = math.max(1, ((width + _BrowseGrid.gap) / (_BrowseGrid.maxTile + _BrowseGrid.gap)).ceil());
  while (columns > 1 && textWidth(columns) < longestWord) {
    columns--;
  }
  var titleLines = 1;
  var titleHeight = 0.0;
  for (final name in names) {
    painter
      ..text = TextSpan(text: name, style: titleStyle)
      ..layout(maxWidth: math.max(1, textWidth(columns).floorToDouble()));
    titleLines = math.max(titleLines, painter.computeLineMetrics().length);
    titleHeight = math.max(titleHeight, painter.height);
  }
  painter
    ..text = TextSpan(text: '0', style: countStyle)
    ..layout();
  final height = math.max(_BrowseGrid.minTileHeight, titleHeight + painter.height + 2 * _BrowseGrid.tilePadding);
  painter.dispose();
  return (columns: columns, titleLines: titleLines, height: height.ceilToDouble());
}

class _BrowseGrid extends StatelessWidget {
  const _BrowseGrid({required this.data, required this.lang});

  final ReferenceData data;
  final Lang lang;

  static const maxTile = 260.0;
  static const minTileHeight = 76.0;
  static const gap = 8.0;
  static const margin = 12.0;
  static const tilePadding = 14.0;

  /// Tile width that is not text: side padding, icon, space after the icon.
  static const tileChrome = 2 * tilePadding + 24 + 12;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final base = DefaultTextStyle.of(context).style;
    final titleStyle = base.merge(t.titleMedium?.copyWith(fontWeight: FontWeight.w600));
    final countStyle = base.merge(t.labelMedium?.copyWith(color: scheme.onSurfaceVariant));
    final shown = datasets.where((d) => (data.byDataset[d.id]?.isNotEmpty ?? false)).toList();
    return LayoutBuilder(builder: (context, box) {
      final grid = fitBrowseGrid(
        width: box.maxWidth - 2 * margin,
        names: shown.map((d) => d.plural),
        titleStyle: titleStyle,
        countStyle: countStyle,
        scaler: MediaQuery.textScalerOf(context),
        direction: Directionality.of(context),
      );
      return CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Göz at · ${data.translatedCount} / ${data.recordCount} kayıt Türkçe',
              style: t.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(margin),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: grid.columns,
              mainAxisExtent: grid.height,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
            ),
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final d = shown[i];
              final n = data.byDataset[d.id]!.length;
              return Material(
                key: ValueKey('browse-${d.id}'),
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BrowseScreen(dataset: d))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: tilePadding),
                    child: Row(children: [
                      Icon(datasetIcon(d.id), color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.plural, style: titleStyle, maxLines: grid.titleLines, overflow: TextOverflow.ellipsis),
                          Text('$n', style: countStyle),
                        ]),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]);
    });
  }
}
