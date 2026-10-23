import 'dart:io';

import 'package:gm_cebi/data/reference.dart';
import 'package:gm_cebi/data/search.dart';

/// Loads the real app assets from disk (tests run from the project root).
Map<String, String> assetFiles() => {
      for (final ds in [...assetDatasets, 'glossary', 'manifest'])
        ds: File('assets/data/$ds.json').readAsStringSync(),
    };

ReferenceData? _cache;
SearchIndex? _index;

ReferenceData loadReference() => _cache ??= ReferenceData.parse(assetFiles());
SearchIndex loadIndex() => _index ??= SearchIndex.build(loadReference());
