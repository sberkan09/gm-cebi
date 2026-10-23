import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reference.dart';
import '../../features/flags.dart';
import '../../providers.dart';
import '../labels.dart';
import '../widgets/content.dart';

/// Detail page for any record. The TR/EN switch in the app bar flips the
/// whole page with one tap; untranslated records fall back to English with a note.
class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.record, this.initialLang});

  final RefRecord record;
  final Lang? initialLang;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late Lang _lang = widget.initialLang ?? ref.read(currentSettingsProvider).contentLang;

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final shownLang = r.isIn(_lang) ? _lang : Lang.en;
    final c = r.content(_lang);
    final labels = ContentLabels.of(shownLang);
    final source = r.en['source'] as Map<String, dynamic>?;
    final other = r.otherName(_lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(r.info.singular),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SegmentedButton<Lang>(
              key: const Key('lang-toggle'),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(minimumSize: const Size(52, 44), visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: Lang.tr, label: Text('TR')),
                ButtonSegment(value: Lang.en, label: Text('EN')),
              ],
              selected: {_lang},
              onSelectionChanged: (s) => setState(() => _lang = s.first),
            ),
          ),
        ],
      ),
      body: SelectionArea(
        child: ListView(
          key: const Key('detail-list'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(r.displayName(_lang), key: const Key('detail-title'), style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (other != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(other, style: t.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              DatasetChip(r.info),
              for (final tag in (c['tags'] as List?)?.cast<String>() ?? const <String>[]) Chip(label: Text(tag), visualDensity: VisualDensity.compact),
              if (source != null)
                Text('SRD 5.2.1 · s. ${source['page']}', style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ]),
            if (_lang == Lang.tr && !r.hasTr) ...[
              const SizedBox(height: 12),
              Container(
                key: const Key('untranslated-banner'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.translate, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu kayıt henüz Türkçeye çevrilmedi; İngilizcesi gösteriliyor.',
                      style: t.bodyMedium?.copyWith(color: scheme.onSecondaryContainer),
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            ..._body(context, r, c, labels),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, RefRecord r, Map<String, dynamic> c, ContentLabels l) {
    switch (r.dataset) {
      case 'spells':
        return [SpellView(c, l)];
      case 'monsters':
        return [
          MonsterStatBlock(c, l),
          if (ref.watch(entitlementsProvider).allows(Feature.initiative)) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('add-to-initiative'),
              icon: const Icon(Icons.add),
              label: const Text('İnisiyatife ekle'),
              onPressed: () => _addToInitiative(context, r),
            ),
          ],
        ];
      case 'classes':
        final data = ref.read(referenceProvider).value?.data;
        return [
          ClassView(c, l, onOpen: _open, titleFor: (id) => data?.find('subclasses', id)?.displayName(_lang) ?? id),
        ];
      case 'terms':
        return [TermView(r)];
      default:
        return [GenericView(c, l, onOpen: _open)];
    }
  }

  void _open(String dataset, String idOrTitle) {
    final data = ref.read(referenceProvider).value?.data;
    if (data == null) return;
    final target = data.find(dataset, idOrTitle) ?? data.findByTitle(idOrTitle);
    if (target == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(record: target, initialLang: _lang)));
  }

  Future<void> _addToInitiative(BuildContext context, RefRecord r) async {
    final m = r.en;
    final bonus = int.tryParse(RegExp(r'^[+\-−]?\d+').stringMatch((m['initiative'] as String? ?? '').replaceAll('−', '-')) ?? '') ?? 0;
    await ref.read(databaseProvider).addCombatant(
          name: r.displayName(_lang),
          initBonus: bonus,
          hp: m['hp'] as int?,
          ac: m['ac'] as int?,
          monsterId: r.id,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${r.displayName(_lang)} inisiyatife eklendi')));
  }
}

// ---------------------------------------------------------------- spells

class SpellView extends StatelessWidget {
  const SpellView(this.c, this.l, {super.key});

  final Map<String, dynamic> c;
  final ContentLabels l;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final comp = c['components'] as Map<String, dynamic>;
    var compText = l.componentLetters(v: comp['verbal'] == true, s: comp['somatic'] == true, m: comp['material'] == true);
    if (comp['material_text'] != null) compText += ' (${comp['material_text']})';
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ]), style: t.bodyLarge),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        l.spellLevelLine(c['level'] as int, c['school'] as String, (c['classes'] as List).cast<String>()),
        style: t.titleMedium?.copyWith(fontStyle: FontStyle.italic, color: scheme.primary),
      ),
      const SizedBox(height: 8),
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            row(l.castingTime, c['casting_time'] as String),
            row(l.range, c['range'] as String),
            row(l.components, compText),
            row(l.duration, c['duration'] as String),
            if (c['ritual'] == true || c['concentration'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(spacing: 8, children: [
                  if (c['concentration'] == true) Chip(label: Text(l.concentration)),
                  if (c['ritual'] == true) Chip(label: Text(l.ritual)),
                ]),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      BlocksView(c['blocks'] as List),
      if (c['higher_levels'] != null) MdParagraphView('**${l.higherLevels}** ${c['higher_levels']}'),
      if (c['cantrip_upgrade'] != null) MdParagraphView('**${l.cantripUpgrade}** ${c['cantrip_upgrade']}'),
    ]);
  }
}

// ---------------------------------------------------------------- monsters

class MonsterStatBlock extends StatelessWidget {
  const MonsterStatBlock(this.c, this.l, {super.key});

  final Map<String, dynamic> c;
  final ContentLabels l;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    String signed(int v) => v >= 0 ? '+$v' : '−${-v}';
    final ab = c['abilities'] as Map<String, dynamic>;
    final keys = ['str', 'dex', 'con', 'int', 'wis', 'cha'];
    final details = (c['details'] as Map<String, dynamic>? ?? {}).cast<String, String>();
    final intros = (c['section_intros'] as Map<String, dynamic>? ?? {}).cast<String, String>();
    Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ]), style: t.bodyLarge),
        );
    final cr = [c['cr'], if (c['xp'] != null) '${l.xp} ${c['xp']}', if (c['proficiency_bonus'] != null) '${l.pb} ${signed(c['proficiency_bonus'] as int)}'];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('${c['size']} ${c['creature_type']}, ${c['alignment']}', style: t.titleMedium?.copyWith(fontStyle: FontStyle.italic, color: scheme.primary)),
      const SizedBox(height: 10),
      Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(spacing: 20, runSpacing: 4, children: [
              line(l.ac, '${c['ac']}${c['ac_note'] != null ? ' ${c['ac_note']}' : ''}'),
              line(l.initiative, c['initiative'] as String),
            ]),
            line(l.hp, '${c['hp']}${c['hp_formula'] != null ? ' (${c['hp_formula']})' : ''}'),
            line(l.speed, c['speed'] as String),
            const SizedBox(height: 10),
            Table(
              key: const Key('ability-table'),
              children: [
                for (var row = 0; row < 2; row++)
                  TableRow(children: [
                    for (var col = 0; col < 3; col++)
                      Builder(builder: (context) {
                        final i = row * 3 + col;
                        final a = ab[keys[i]] as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                          child: Column(children: [
                            Text(l.abilityAbbr[i], style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary)),
                            Text('${a['score']}', style: t.titleLarge),
                            Text('${l.mod} ${signed(a['mod'] as int)} · ${l.save} ${signed(a['save'] as int)}', style: t.labelMedium),
                          ]),
                        );
                      }),
                  ]),
              ],
            ),
            const SizedBox(height: 8),
            for (final e in details.entries) line(e.key, e.value),
            line(l.cr, cr.length == 1 ? '${cr.first}' : '${cr.first} (${cr.skip(1).join('; ')})'),
          ]),
        ),
      ),
      for (final s in l.monsterSections.entries)
        if (((c[s.key] as List?) ?? const []).isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: Text(s.value, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary)),
          ),
          if (intros[s.key] != null) MdParagraphView('*${intros[s.key]}*'),
          for (final e in (c[s.key] as List).cast<Map<String, dynamic>>()) _Named(e),
        ],
    ]);
  }
}

class _Named extends StatelessWidget {
  const _Named(this.e);

  final Map<String, dynamic> e;

  @override
  Widget build(BuildContext context) {
    final paras = (e['text'] as String).split('\n\n');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      MdParagraphView('**${e['name']}.** ${paras.first}'),
      for (final p in paras.skip(1)) MdParagraphView(p),
    ]);
  }
}

// ---------------------------------------------------------------- classes

class ClassView extends StatelessWidget {
  const ClassView(this.c, this.l, {super.key, required this.onOpen, required this.titleFor});

  final Map<String, dynamic> c;
  final ContentLabels l;
  final void Function(String dataset, String id) onOpen;
  final String Function(String subclassId) titleFor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final core = (c['core_traits'] as Map<String, dynamic>).cast<String, String>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DataTableView({'header': const <String>[], 'rows': [for (final e in core.entries) ['**${e.key}**', e.value]]}),
      BlocksView(c['blocks'] as List),
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(l.features, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ),
      for (final f in (c['features'] as List).cast<Map<String, dynamic>>()) _Feature(f, l),
      if ((c['subclasses'] as List?)?.isNotEmpty ?? false) ...[
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(l.subclasses, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ),
        for (final id in (c['subclasses'] as List).cast<String>())
          ListTile(
            leading: Icon(datasetIcon('subclasses')),
            title: Text(titleFor(id)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpen('subclasses', id),
          ),
      ],
    ]);
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.f, this.l);

  final Map<String, dynamic> f;
  final ContentLabels l;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final lvl = f['level'] as int?;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text('${lvl != null ? '${l.level(lvl)}: ' : ''}${f['name']}',
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
      ),
      BlocksView(f['blocks'] as List),
    ]);
  }
}

// ---------------------------------------------------------------- terms

class TermView extends StatelessWidget {
  const TermView(this.r, {super.key});

  final RefRecord r;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final status = r.en['status'] as String;
    final note = switch (status) {
      'topluluk' => 'Türkçe FRP topluluğunda kullanılan karşılık.',
      'tartışmalı' => 'Toplulukta birden fazla karşılık var; seçim inceleme bekliyor.',
      _ => 'Topluluk kullanımı bulunamadı; GM Cebi önerisi.',
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DataTableView({
        'header': const <String>[],
        'rows': [
          ['**Türkçe**', r.tr!['name'] as String],
          ['**İngilizce**', r.en['name'] as String],
          ['**Tür**', r.en['category'] as String],
          ['**Durum**', status],
        ],
      }),
      Text(note, style: t.bodyLarge),
    ]);
  }
}

// ---------------------------------------------------------------- everything else

/// Rules, conditions, species, backgrounds, feats, equipment, subclasses,
/// weapon properties and masteries.
class GenericView extends StatelessWidget {
  const GenericView(this.c, this.l, {super.key, required this.onOpen});

  final Map<String, dynamic> c;
  final ContentLabels l;
  final void Function(String dataset, String title) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rows = <List<String>>[
      if (c['creature_type'] != null) ['**${l.creatureType}**', c['creature_type'] as String],
      if (c['size'] != null) ['**${l.size}**', c['size'] as String],
      if (c['speed'] != null) ['**${ContentLabels.of(l.lang).speed}**', c['speed'] as String],
      if (c['ability_scores'] != null) ['**${l.abilityScores}**', (c['ability_scores'] as List).join(', ')],
      if (c['feat'] != null) ['**${l.feat}**', c['feat'] as String],
      if (c['skill_proficiencies'] != null) ['**${l.skillProficiencies}**', c['skill_proficiencies'] as String],
      if (c['tool_proficiency'] != null) ['**${l.toolProficiency}**', c['tool_proficiency'] as String],
      if (c['equipment'] != null) ['**${l.equipment}**', c['equipment'] as String],
      if (c['prerequisite'] != null) ['**${l.prerequisite}**', c['prerequisite'] as String],
      if (c['fields'] != null)
        for (final e in (c['fields'] as Map<String, dynamic>).entries)
          if ((e.value as String).isNotEmpty) ['**${e.key}**', e.value as String],
    ];
    final seeAlso = (c['see_also'] as List?)?.cast<String>() ?? const <String>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (c['category'] is String && c['kind'] == 'feat')
        Text(l.lang == Lang.tr ? '${c['category']} Hüneri' : '${c['category']} Feat',
            style: t.titleMedium?.copyWith(fontStyle: FontStyle.italic)),
      if (rows.isNotEmpty) DataTableView({'header': const <String>[], 'rows': rows}),
      if (c['text'] != null) MdBody(c['text'] as String),
      if (c['blocks'] != null) BlocksView(c['blocks'] as List),
      for (final tr in (c['traits'] as List?)?.cast<Map<String, dynamic>>() ?? const <Map<String, dynamic>>[]) _Named(tr),
      for (final f in (c['features'] as List?)?.cast<Map<String, dynamic>>() ?? const <Map<String, dynamic>>[]) _Feature(f, l),
      if (seeAlso.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(l.seeAlso, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in seeAlso) ActionChip(label: Text(s), onPressed: () => onOpen('rules_glossary', s)),
        ]),
      ],
    ]);
  }
}
