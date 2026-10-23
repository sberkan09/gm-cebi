// Measures reference parsing, index build and search latency on the real assets.
//   dart run tool/bench_search.dart
import 'dart:io';

import 'package:gm_cebi/data/reference.dart';
import 'package:gm_cebi/data/search.dart';

void main() {
  final files = {
    for (final ds in [...assetDatasets, 'glossary', 'manifest']) ds: File('assets/data/$ds.json').readAsStringSync(),
  };
  final sw = Stopwatch()..start();
  final data = ReferenceData.parse(files);
  final parseMs = sw.elapsedMilliseconds;
  sw.reset();
  final index = SearchIndex.build(data);
  final buildMs = sw.elapsedMilliseconds;
  final queries = ['a', 'k', 'kör', 'ateş', 'dragon', 'saving throw', 'can puanı', 'hançer', 'zzzz', 'the', 'i'];
  var worst = 0;
  for (var round = 0; round < 3; round++) {
    for (final q in queries) {
      sw.reset();
      index.search(q);
      final us = sw.elapsedMicroseconds;
      if (round > 0 && us > worst) worst = us;
      if (round == 2) stdout.write('$q=${(us / 1000).toStringAsFixed(1)} ');
    }
  }
  stdout.writeln('records=${index.size} parse=${parseMs}ms index=${buildMs}ms worstSearch=${(worst / 1000).toStringAsFixed(2)}ms');
}
