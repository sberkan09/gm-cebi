/// Reference data (SRD 5.2.1, English + Turkish) loaded from assets/data.
///
/// The asset format is described in docs/data-model.md: each dataset file has
/// `records: [{id, en, tr | null, tr_status}]`. Records keep their raw JSON
/// maps; typed accessors live in the widgets that render them.
library;

import 'dart:convert';

import '../core/turkish.dart';

enum Lang { tr, en }

/// Datasets in display order, with Turkish labels.
class DatasetInfo {
  const DatasetInfo(this.id, this.singular, this.plural, this.priority);

  final String id;
  final String singular;
  final String plural;

  /// Search tie-break: higher wins.
  final int priority;
}

const datasets = <DatasetInfo>[
  DatasetInfo('conditions', 'Durum', 'Durumlar', 30),
  DatasetInfo('rules_glossary', 'Kural', 'Kurallar', 25),
  DatasetInfo('spells', 'Büyü', 'Büyüler', 20),
  DatasetInfo('monsters', 'Canavar', 'Canavarlar', 15),
  DatasetInfo('classes', 'Sınıf', 'Sınıflar', 12),
  DatasetInfo('subclasses', 'Alt Sınıf', 'Alt Sınıflar', 8),
  DatasetInfo('species', 'Soy', 'Soylar', 11),
  DatasetInfo('backgrounds', 'Geçmiş', 'Geçmişler', 9),
  DatasetInfo('feats', 'Hüner', 'Hünerler', 10),
  DatasetInfo('equipment', 'Ekipman', 'Ekipman', 7),
  DatasetInfo('weapon_mastery', 'Silah Ustalığı', 'Silah Ustalıkları', 6),
  DatasetInfo('weapon_properties', 'Silah Özelliği', 'Silah Özellikleri', 6),
  DatasetInfo('terms', 'Terim', 'Terimler', 5),
];

final Map<String, DatasetInfo> datasetById = {for (final d in datasets) d.id: d};

/// Asset file names (without the `terms` pseudo-dataset built from the glossary).
const assetDatasets = [
  'rules_glossary', 'conditions', 'spells', 'monsters', 'classes', 'subclasses', 'species',
  'backgrounds', 'feats', 'equipment', 'weapon_properties', 'weapon_mastery',
];

class GlossaryTerm {
  const GlossaryTerm({required this.id, required this.en, required this.tr, required this.category, required this.status});

  factory GlossaryTerm.fromJson(Map<String, dynamic> j) => GlossaryTerm(
        id: j['id'] as String,
        en: j['en'] as String,
        tr: j['tr'] as String,
        category: j['category'] as String,
        status: j['status'] as String,
      );

  final String id;
  final String en;
  final String tr;
  final String category;

  /// topluluk | öneri | tartışmalı
  final String status;
}

class RefRecord {
  RefRecord({
    required this.dataset,
    required this.id,
    required this.en,
    required this.tr,
    required this.trStatus,
    this.aliasTr,
  });

  final String dataset;
  final String id;
  final Map<String, dynamic> en;
  final Map<String, dynamic>? tr;

  /// complete | partial | none
  final String trStatus;

  /// Turkish name from the glossary for records that are not translated yet
  /// (e.g. "Dagger" → "Hançer").
  String? aliasTr;

  String get key => '$dataset/$id';
  String get enName => en['name'] as String;
  String? get trName => tr?['name'] as String?;
  bool get hasTr => tr != null;

  /// Record content in [lang], falling back to English.
  Map<String, dynamic> content(Lang lang) => lang == Lang.tr && tr != null ? tr! : en;

  /// Whether [content] for [lang] is really in that language.
  bool isIn(Lang lang) => lang == Lang.en || tr != null;

  String displayName(Lang lang) =>
      lang == Lang.tr ? (trName ?? aliasTr ?? enName) : enName;

  /// The name in the other language, if it differs.
  String? otherName(Lang lang) {
    final other = lang == Lang.tr ? enName : (trName ?? aliasTr);
    return other == null || other == displayName(lang) ? null : other;
  }

  DatasetInfo get info => datasetById[dataset]!;
}

class ReferenceData {
  ReferenceData(this.byDataset, this.glossary, this.manifest)
      : byKey = {for (final list in byDataset.values) for (final r in list) r.key: r};

  final Map<String, List<RefRecord>> byDataset;
  final Map<String, RefRecord> byKey;
  final List<GlossaryTerm> glossary;
  final Map<String, dynamic> manifest;

  Iterable<RefRecord> get all => byDataset.values.expand((l) => l);

  RefRecord? find(String dataset, String id) => byKey['$dataset/$id'];

  /// Looks a record up by an English or Turkish title, for cross-references
  /// ("See also “Cover”").
  RefRecord? findByTitle(String title) {
    final f = trFold(title);
    for (final ds in ['rules_glossary', 'conditions', 'spells', 'monsters', ...assetDatasets]) {
      for (final r in byDataset[ds] ?? const <RefRecord>[]) {
        if (trFold(r.enName) == f || (r.trName != null && trFold(r.trName!) == f)) return r;
      }
    }
    return null;
  }

  /// Records of a dataset sorted by their name in [lang] (Turkish collation).
  List<RefRecord> sorted(String dataset, Lang lang) {
    final list = [...?byDataset[dataset]];
    list.sort((a, b) => trCompare(a.displayName(lang), b.displayName(lang)));
    return list;
  }

  int get translatedCount => all.where((r) => r.hasTr && r.dataset != 'terms').length;
  int get recordCount => all.where((r) => r.dataset != 'terms').length;

  /// Parses the asset JSON strings: `{dataset: json, 'glossary': json, 'manifest': json}`.
  static ReferenceData parse(Map<String, String> files) {
    final glossary = [
      for (final j in jsonDecode(files['glossary']!) as List) GlossaryTerm.fromJson(j as Map<String, dynamic>),
    ];
    final manifest = jsonDecode(files['manifest']!) as Map<String, dynamic>;
    final byDataset = <String, List<RefRecord>>{};
    for (final ds in assetDatasets) {
      final raw = files[ds];
      if (raw == null) continue;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      byDataset[ds] = [
        for (final r in (j['records'] as List).cast<Map<String, dynamic>>())
          RefRecord(
            dataset: ds,
            id: r['id'] as String,
            en: r['en'] as Map<String, dynamic>,
            tr: r['tr'] as Map<String, dynamic>?,
            trStatus: r['tr_status'] as String,
          ),
      ];
    }

    // Glossary: Turkish aliases for untranslated records; the rest become "terms".
    final byEnName = <String, List<RefRecord>>{};
    for (final list in byDataset.values) {
      for (final r in list) {
        byEnName.putIfAbsent(trFold(r.enName), () => []).add(r);
      }
    }
    final terms = <RefRecord>[];
    for (final g in glossary) {
      if (g.category == 'bölüm') continue;
      final en = trFold(g.en.replaceAll(RegExp(r'\s*\[.*\]$'), ''));
      final matches = byEnName[en];
      if (matches != null) {
        for (final r in matches) {
          if (g.category == 'büyü adı' && r.dataset != 'spells') continue;
          r.aliasTr ??= r.trName == null ? g.tr : null;
        }
        if (g.category != 'kısaltma') continue;
      }
      if (g.category == 'büyü adı') continue;
      terms.add(RefRecord(
        dataset: 'terms',
        id: g.id,
        en: {'name': g.en, 'category': g.category, 'status': g.status},
        tr: {'name': g.tr, 'category': g.category, 'status': g.status},
        trStatus: 'complete',
      ));
    }
    byDataset['terms'] = terms;
    return ReferenceData(byDataset, glossary, manifest);
  }
}
