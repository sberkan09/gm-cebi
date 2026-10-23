import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reference.dart';
import '../../db/database.dart';
import '../../features/flags.dart';
import '../../providers.dart';
import '../widgets/locked.dart';
import 'detail_screen.dart';
import 'dice_screen.dart';

/// Initiative tracker (GM pack). Big next/previous buttons at the bottom for
/// one-handed use; tap HP to apply damage or healing, long-press for more.
class InitiativeScreen extends ConsumerWidget {
  const InitiativeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(entitlementsProvider).allows(Feature.initiative)) {
      return Scaffold(appBar: AppBar(title: const Text('İnisiyatif')), body: const GmPackLocked(feature: 'İnisiyatif takibi'));
    }
    final state = ref.watch(encounterProvider);
    final db = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('İnisiyatif'),
        actions: [
          IconButton(
            tooltip: 'Eksik inisiyatifleri at (d20 + bonus)',
            icon: const Icon(Icons.casino_outlined),
            onPressed: () {
              final rng = ref.read(diceRandomProvider);
              db.rollMissingInitiative((bonus) => rng.nextInt(20) + 1 + bonus);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'new') {
                final keep = await _confirmNewEncounter(context);
                if (keep != null) await db.newEncounter(keepPlayers: keep);
              }
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'new', child: Text('Yeni karşılaşma'))],
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (s) => _Tracker(state: s),
      ),
    );
  }
}

class _Tracker extends ConsumerWidget {
  const _Tracker({required this.state});

  final EncounterState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final db = ref.read(databaseProvider);
    final list = state.combatants;
    final current = state.current;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(children: [
          Text('${state.encounter.round}. tur', key: const Key('round'), style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(
            child: current == null
                ? const SizedBox.shrink()
                : Text(
                    'Sıra: ${current.name}',
                    key: const Key('current-turn'),
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium?.copyWith(color: scheme.primary),
                  ),
          ),
          FilledButton.tonalIcon(
            key: const Key('add-combatant'),
            onPressed: () => _showAddSheet(context, ref),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Ekle'),
          ),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Karşılaşma boş. "Ekle" ile oyuncu ya da canavar ekle; canavar sayfalarındaki "İnisiyatife ekle" de buraya ekler.',
                    textAlign: TextAlign.center,
                    style: t.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: list.length,
                padding: const EdgeInsets.only(bottom: 8),
                itemBuilder: (context, i) => _CombatantCard(c: list[i], isCurrent: current?.id == list[i].id),
              ),
      ),
      Material(
        color: scheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('prev-turn'),
                onPressed: list.isEmpty ? null : db.previousTurn,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Önceki'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 64,
                child: FilledButton.icon(
                  key: const Key('next-turn'),
                  onPressed: list.isEmpty ? null : db.nextTurn,
                  icon: const Icon(Icons.chevron_right, size: 28),
                  label: Text('Sonraki', style: t.labelLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _CombatantCard extends ConsumerWidget {
  const _CombatantCard({required this.c, required this.isCurrent});

  final Combatant c;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final data = ref.watch(referenceProvider).value?.data;
    final lang = ref.watch(currentSettingsProvider).contentLang;
    final hpFrac = (c.hpCurrent != null && (c.hpMax ?? 0) > 0) ? (c.hpCurrent! / c.hpMax!).clamp(0.0, 1.0) : null;
    return Card(
      key: ValueKey('combatant-${c.id}'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent ? BorderSide(color: scheme.primary, width: 2.5) : BorderSide.none,
      ),
      color: isCurrent ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => _showCombatantMenu(context, ref, c),
        onTap: () => _showCombatantMenu(context, ref, c),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _editInitiative(context, ref, c),
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: Text(c.initiative?.toString() ?? '–', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  if (c.isPlayer) Padding(padding: const EdgeInsets.only(right: 6), child: Icon(Icons.person, size: 18, color: scheme.secondary)),
                  Expanded(
                    child: Text(
                      c.name,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: c.isDown ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (c.ac != null) Text('ZS ${c.ac}', style: t.labelLarge),
                ]),
                const SizedBox(height: 6),
                if (c.hpCurrent != null)
                  InkWell(
                    key: ValueKey('hp-${c.id}'),
                    onTap: () => _changeHp(context, ref, c),
                    child: Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: hpFrac,
                            minHeight: 10,
                            color: (hpFrac ?? 1) <= 0.5 ? scheme.error : scheme.secondary,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('CP ${c.hpCurrent}/${c.hpMax ?? '?'}', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                  ),
                if (c.conditionIds.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4, children: [
                    for (final id in c.conditionIds)
                      InputChip(
                        visualDensity: VisualDensity.compact,
                        label: Text(data?.find('conditions', id)?.displayName(lang) ?? id),
                        onPressed: () {
                          final r = data?.find('conditions', id);
                          if (r != null) Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(record: r)));
                        },
                        onDeleted: () => ref.read(databaseProvider).toggleCondition(c.id, id),
                      ),
                  ]),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- dialogs

Future<bool?> _confirmNewEncounter(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni karşılaşma'),
        content: const Text('Mevcut karşılaşma kapanır. Oyuncu karakterleri tam Can Puanıyla yeni karşılaşmaya taşınsın mı?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Herkesi sil')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oyuncuları tut')),
        ],
      ),
    );

int? _int(String s) => int.tryParse(s.trim().replaceAll('−', '-'));

Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Oyuncu ya da serbest ekle'),
          onTap: () => Navigator.pop(context, 'manual'),
        ),
        ListTile(
          key: const Key('add-monster'),
          leading: const Icon(Icons.pest_control_outlined),
          title: const Text('Canavar listesinden ekle'),
          onTap: () => Navigator.pop(context, 'monster'),
        ),
      ]),
    ),
  );
  if (!context.mounted) return;
  if (choice == 'manual') {
    await _addManual(context, ref);
  } else if (choice == 'monster') {
    await _addMonster(context, ref);
  }
}

Future<void> _addManual(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController();
  final init = TextEditingController();
  final bonus = TextEditingController(text: '0');
  final hp = TextEditingController();
  final ac = TextEditingController();
  var isPlayer = true;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Katılımcı ekle'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              key: const Key('combatant-name'),
              controller: name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Ad'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Oyuncu karakteri'),
              value: isPlayer,
              onChanged: (v) => setState(() => isPlayer = v),
            ),
            Row(children: [
              Expanded(child: _numField(init, 'İnisiyatif', key: const Key('combatant-init'))),
              const SizedBox(width: 8),
              Expanded(child: _numField(bonus, 'İnis. bonusu')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(hp, 'Can Puanı', key: const Key('combatant-hp'))),
              const SizedBox(width: 8),
              Expanded(child: _numField(ac, 'ZS')),
            ]),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(key: const Key('combatant-save'), onPressed: () => Navigator.pop(context, true), child: const Text('Ekle')),
        ],
      ),
    ),
  );
  if (ok == true && name.text.trim().isNotEmpty) {
    await ref.read(databaseProvider).addCombatant(
          name: name.text.trim(),
          initiative: _int(init.text),
          initBonus: _int(bonus.text) ?? 0,
          hp: _int(hp.text),
          ac: _int(ac.text),
          isPlayer: isPlayer,
        );
  }
}

Widget _numField(TextEditingController c, String label, {Key? key}) => TextField(
      key: key,
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-−0-9]'))],
      decoration: InputDecoration(labelText: label),
    );

Future<void> _addMonster(BuildContext context, WidgetRef ref) async {
  final r = ref.read(referenceProvider).value;
  if (r == null) return;
  final lang = ref.read(currentSettingsProvider).contentLang;
  final picked = await showDialog<RefRecord>(
    context: context,
    builder: (context) => _MonsterPicker(reference: r, lang: lang),
  );
  if (picked == null) return;
  final m = picked.en;
  final bonus = int.tryParse(RegExp(r'^[+\-]?\d+').stringMatch((m['initiative'] as String? ?? '').replaceAll('−', '-')) ?? '') ?? 0;
  await ref.read(databaseProvider).addCombatant(
        name: picked.displayName(lang),
        initBonus: bonus,
        hp: m['hp'] as int?,
        ac: m['ac'] as int?,
        monsterId: picked.id,
      );
}

class _MonsterPicker extends StatefulWidget {
  const _MonsterPicker({required this.reference, required this.lang});

  final Reference reference;
  final Lang lang;

  @override
  State<_MonsterPicker> createState() => _MonsterPickerState();
}

class _MonsterPickerState extends State<_MonsterPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final List<RefRecord> list = _q.trim().isEmpty
        ? widget.reference.data.sorted('monsters', widget.lang)
        : [
            for (final h in widget.reference.index.search(_q, limit: 200))
              if (h.record.dataset == 'monsters') h.record,
          ];
    return AlertDialog(
      title: const Text('Canavar seç'),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: SizedBox(
        width: 420,
        height: 480,
        child: Column(children: [
          TextField(
            key: const Key('monster-search'),
            autofocus: true,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Ara (ör. goblin, kurt)'),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final m = list[i];
                return ListTile(
                  title: Text(m.displayName(widget.lang)),
                  subtitle: Text('TD ${m.en['cr']} · CP ${m.en['hp']} · ZS ${m.en['ac']}'),
                  onTap: () => Navigator.pop(context, m),
                );
              },
            ),
          ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç'))],
    );
  }
}

Future<void> _changeHp(BuildContext context, WidgetRef ref, Combatant c) async {
  final amount = TextEditingController();
  final result = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${c.name} · CP ${c.hpCurrent}/${c.hpMax ?? '?'}'),
      content: TextField(
        key: const Key('hp-amount'),
        controller: amount,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(context).textTheme.headlineSmall,
        decoration: const InputDecoration(labelText: 'Miktar'),
      ),
      actions: [
        TextButton(
          key: const Key('hp-heal'),
          onPressed: () => Navigator.pop(context, -(int.tryParse(amount.text) ?? 0)),
          child: const Text('İyileştir'),
        ),
        FilledButton(
          key: const Key('hp-damage'),
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.pop(context, int.tryParse(amount.text) ?? 0),
          child: const Text('Hasar'),
        ),
      ],
    ),
  );
  if (result != null && result != 0) await ref.read(databaseProvider).changeHp(c.id, result);
}

Future<void> _editInitiative(BuildContext context, WidgetRef ref, Combatant c) async {
  final ctrl = TextEditingController(text: c.initiative?.toString() ?? '');
  final rng = ref.read(diceRandomProvider);
  final v = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${c.name} · inisiyatif'),
      content: _numField(ctrl, 'İnisiyatif'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, '${rng.nextInt(20) + 1 + c.initBonus}'),
          child: Text('At (d20${c.initBonus >= 0 ? '+' : ''}${c.initBonus})'),
        ),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Kaydet')),
      ],
    ),
  );
  if (v == null) return;
  await ref.read(databaseProvider).updateCombatant(c.copyWith(initiative: Value(_int(v))));
}

Future<void> _showCombatantMenu(BuildContext context, WidgetRef ref, Combatant c) async {
  final data = ref.read(referenceProvider).value?.data;
  final lang = ref.read(currentSettingsProvider).contentLang;
  final conditions = data?.sorted('conditions', lang) ?? const <RefRecord>[];
  final monster = c.monsterId == null ? null : data?.find('monsters', c.monsterId!);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => Consumer(builder: (context, ref, _) {
      final live = ref.watch(encounterProvider).value?.combatants.where((x) => x.id == c.id).firstOrNull ?? c;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Text(live.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('Durumlar', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final cond in conditions)
                FilterChip(
                  label: Text(cond.displayName(lang)),
                  selected: live.conditionIds.contains(cond.id),
                  onSelected: (_) => ref.read(databaseProvider).toggleCondition(live.id, cond.id),
                ),
            ]),
            const SizedBox(height: 12),
            if (live.hpCurrent != null)
              ListTile(leading: const Icon(Icons.favorite_outline), title: const Text('Hasar / iyileştirme'), onTap: () => _changeHp(context, ref, live)),
            ListTile(leading: const Icon(Icons.flag_outlined), title: const Text('İnisiyatifi değiştir'), onTap: () => _editInitiative(context, ref, live)),
            if (monster != null)
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Canavar kartını aç'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(record: monster))),
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: const Text('Karşılaşmadan çıkar'),
              onTap: () {
                ref.read(databaseProvider).removeCombatant(live.id);
                Navigator.pop(context);
              },
            ),
          ]),
        ),
      );
    }),
  );
}
