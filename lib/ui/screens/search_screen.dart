import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reference.dart';
import '../../data/search.dart';
import '../../providers.dart';
import '../widgets/content.dart';
import 'browse_screen.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

/// One box, Turkish or English, offline. The box sits at the bottom of the
/// screen so it can be reached with the thumb.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  List<SearchHit> _hits = const [];
  int _micros = 0;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _run(SearchIndex index, String q) {
    final sw = Stopwatch()..start();
    final hits = index.search(q);
    sw.stop();
    setState(() {
      _hits = hits;
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
                : _Results(hits: _hits, lang: lang, micros: _micros),
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
  const _Results({required this.hits, required this.lang, required this.micros});

  final List<SearchHit> hits;
  final Lang lang;
  final int micros;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ms = (micros / 1000).toStringAsFixed(micros < 10000 ? 1 : 0);
    if (hits.isEmpty) {
      return Center(child: Text('Sonuç yok', style: t.titleMedium?.copyWith(color: scheme.onSurfaceVariant)));
    }
    final approximate = hits.first.approximate;
    return ListView.builder(
      key: const Key('search-results'),
      itemCount: hits.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '${hits.length} sonuç · $ms ms${approximate ? ' · yakın eşleşmeler' : ''}',
              style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
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

class _BrowseGrid extends StatelessWidget {
  const _BrowseGrid({required this.data, required this.lang});

  final ReferenceData data;
  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final shown = datasets.where((d) => (data.byDataset[d.id]?.isNotEmpty ?? false)).toList();
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
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisExtent: 76,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: shown.length,
          itemBuilder: (context, i) {
            final d = shown[i];
            final n = data.byDataset[d.id]!.length;
            return Material(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BrowseScreen(dataset: d))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(children: [
                    Icon(datasetIcon(d.id), color: scheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.plural, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                        Text('$n', style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
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
  }
}
