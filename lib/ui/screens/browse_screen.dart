import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reference.dart';
import '../../providers.dart';
import 'search_screen.dart';

/// All records of one dataset, in Turkish alphabetical order.
class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key, required this.dataset});

  final DatasetInfo dataset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(referenceProvider).value;
    final lang = ref.watch(currentSettingsProvider).contentLang;
    final list = r?.data.sorted(dataset.id, lang) ?? const <RefRecord>[];
    return Scaffold(
      appBar: AppBar(title: Text(dataset.plural)),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) => RecordTile(record: list[i], lang: lang),
      ),
    );
  }
}
