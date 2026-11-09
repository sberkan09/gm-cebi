import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/stat_input.dart';
import '../../features/flags.dart';
import '../../features/npc/npc_generator.dart';
import '../../providers.dart';
import '../widgets/locked.dart';
import 'notes_screen.dart';

class NpcSessionState {
  const NpcSessionState({
    this.current,
    this.recent = const [],
    this.filters = const NpcFilters(),
    this.locked = const {},
  });

  final Npc? current;

  /// Earlier NPCs of this session, newest first (not including [current]).
  final List<Npc> recent;

  final NpcFilters filters;
  final Set<NpcField> locked;

  NpcSessionState copyWith({Npc? current, List<Npc>? recent, NpcFilters? filters, Set<NpcField>? locked}) =>
      NpcSessionState(
        current: current ?? this.current,
        recent: recent ?? this.recent,
        filters: filters ?? this.filters,
        locked: locked ?? this.locked,
      );
}

/// The NPC on the card, the last few before it, the filters and the locks.
/// Kept in memory for the session only (leaving the screen keeps them);
/// anything worth keeping goes to the notes.
class NpcSession extends Notifier<NpcSessionState> {
  static const maxRecent = 10;

  @override
  NpcSessionState build() => const NpcSessionState();

  List<Npc> _withCurrent(List<Npc> rest) =>
      [if (state.current != null) state.current!, ...rest].take(maxRecent).toList();

  /// A newly generated NPC; the previous one moves to the recent list.
  /// Returns false (and changes nothing) when it equals the current NPC,
  /// which happens when every field is locked.
  bool show(Npc npc) {
    if (npc == state.current) return false;
    state = state.copyWith(current: npc, recent: _withCurrent(state.recent));
    return true;
  }

  /// The same NPC with a changed field.
  void update(Npc npc) => state = state.copyWith(current: npc);

  /// Brings back a recent NPC; the one on the card takes its place in the list.
  void restore(int index) {
    final picked = state.recent[index];
    final rest = [...state.recent]..removeAt(index);
    state = state.copyWith(current: picked, recent: _withCurrent(rest));
  }

  void setFilters(NpcFilters filters) => state = state.copyWith(filters: filters);

  void toggleLock(NpcField f) {
    final locked = {...state.locked};
    if (!locked.remove(f)) locked.add(f);
    state = state.copyWith(locked: locked);
  }
}

final npcSessionProvider = NotifierProvider<NpcSession, NpcSessionState>(NpcSession.new);

/// NPC generator (GM pack): one tap gives a table-ready NPC; tap a field to
/// re-roll only that field, lock fields to keep them on "Yeniden üret".
class NpcScreen extends ConsumerStatefulWidget {
  const NpcScreen({super.key});

  @override
  ConsumerState<NpcScreen> createState() => _NpcScreenState();
}

class _NpcScreenState extends ConsumerState<NpcScreen> {
  bool _saving = false;

  /// The NPC last saved to the notes; saving it again is disabled until it
  /// changes, so a double tap never makes two notes.
  Npc? _saved;

  NpcGenerator get _generator => NpcGenerator(ref.read(npcRandomProvider));

  NpcSession get _session => ref.read(npcSessionProvider.notifier);

  void _generate() {
    final s = ref.read(npcSessionProvider);
    if (!_session.show(_generator.generate(s.filters, s.current, s.locked))) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Tüm alanlar kilitli; değişecek bir şey yok.')));
    }
  }

  void _reroll(Npc npc, NpcField f) => _session.update(_generator.reroll(npc, f, ref.read(npcSessionProvider).filters));

  Future<void> _saveNote(Npc npc) async {
    if (_saving || _saved == npc) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final id = await ref.read(databaseProvider).createNote(title: 'NPC: ${npc.name}', body: npc.toNoteText());
      _saved = npc;
      messenger.showSnackBar(
        SnackBar(
          content: Text('${npc.name} notlara kaydedildi'),
          action: SnackBarAction(
            label: 'Aç',
            onPressed: () => navigator.push(MaterialPageRoute<void>(builder: (_) => NoteEditorScreen(noteId: id))),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addToInitiative(Npc npc) async {
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);
    final added = await showDialog<_InitiativeEntry>(
      context: context,
      builder: (_) => _InitiativeDialog(name: npc.name),
    );
    if (added == null) return;
    await db.addCombatant(name: added.name, initBonus: added.bonus, hp: added.hp, ac: added.ac);
    messenger.showSnackBar(SnackBar(content: Text('${added.name} inisiyatife eklendi')));
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(entitlementsProvider).allows(Feature.npcGenerator)) {
      return Scaffold(
        appBar: AppBar(title: const Text('NPC Üret')),
        body: const GmPackLocked(feature: 'NPC üretici'),
      );
    }
    final session = ref.watch(npcSessionProvider);
    final npc = session.current;
    final locked = session.locked;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('NPC Üret')),
      body: ListView(
        key: const Key('npc-list'),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
        children: [
          _Filters(
            filters: session.filters,
            nameLocked: npc != null && locked.contains(NpcField.name),
            onChanged: _session.setFilters,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('npc-generate'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            onPressed: _generate,
            icon: Icon(npc == null ? Icons.auto_awesome : Icons.refresh),
            label: Text(
              npc == null ? 'NPC üret' : 'Yeniden üret',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            npc == null
                ? 'Tek dokunuşla masaya hazır bir NPC: ad, soy, meslek, görünüş, kişilik, sır ve maceraya bağlantı.'
                : 'Bir alana dokununca yalnızca o alan değişir. Kilitli alanlar "Yeniden üret"te korunur.',
            style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (npc != null) ...[
            const SizedBox(height: 8),
            _NpcCard(npc: npc, locked: locked, onReroll: (f) => _reroll(npc, f), onToggleLock: _session.toggleLock),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('npc-save-note'),
                  style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: _saving || _saved == npc ? null : () => _saveNote(npc),
                  icon: Icon(_saved == npc ? Icons.check : Icons.note_add_outlined),
                  label: Text(_saved == npc ? 'Notlara kaydedildi' : 'Nota kaydet'),
                ),
                FilledButton.tonalIcon(
                  key: const Key('npc-add-initiative'),
                  style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => _addToInitiative(npc),
                  icon: const Icon(Icons.format_list_numbered),
                  label: const Text('İnisiyatife ekle'),
                ),
              ],
            ),
          ],
          if (session.recent.isNotEmpty) ...[
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text("Son NPC'ler", style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 4),
            for (final (i, r) in session.recent.indexed)
              Card(
                child: ListTile(
                  key: ValueKey('npc-recent-$i'),
                  leading: const Icon(Icons.history),
                  title: Text(r.name),
                  subtitle: Text('${r.summary} · ${r[NpcField.occupation]}'),
                  onTap: () => _session.restore(i),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.filters, required this.nameLocked, required this.onChanged});

  final NpcFilters filters;

  /// A locked name keeps the species and gender, so those chips are disabled.
  final bool nameLocked;
  final ValueChanged<NpcFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final summary = [
      filters.species?.label ?? 'Rastgele soy',
      filters.gender == null ? 'Cinsiyet fark etmez' : _genderLabel(filters.gender!),
      filters.attitude?.label ?? 'Rastgele tavır',
    ].join(' · ');

    Widget group<T>(String title, List<(T?, String)> options, T? selected, ValueChanged<T?>? onSelect) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            children: [
              for (final (value, label) in options)
                ChoiceChip(
                  label: Text(label),
                  selected: selected == value,
                  onSelected: onSelect == null ? null : (_) => onSelect(value),
                ),
            ],
          ),
        ],
      ),
    );

    return Card(
      child: ExpansionTile(
        key: const Key('npc-filters'),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.tune),
        title: const Text('Filtreler'),
        subtitle: Text(nameLocked ? 'Ad kilitli: soy ve cinsiyet korunuyor' : summary),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nameLocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ad kilitli: soy ve cinsiyet korunuyor. Değiştirmek için adın kilidini aç.',
                      key: const Key('npc-name-locked-hint'),
                      style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          group<NpcSpecies>(
            'Soy',
            [(null, 'Rastgele'), for (final s in NpcSpecies.values) (s, s.label)],
            filters.species,
            nameLocked ? null : (v) => onChanged(filters.copyWith(species: () => v)),
          ),
          group<NpcGender>(
            'Cinsiyet',
            [(null, 'Fark etmez'), for (final g in NpcGender.values) (g, _genderLabel(g))],
            filters.gender,
            nameLocked ? null : (v) => onChanged(filters.copyWith(gender: () => v)),
          ),
          group<NpcAttitude>(
            'Tavır',
            [(null, 'Rastgele'), for (final a in NpcAttitude.values) (a, a.label)],
            filters.attitude,
            (v) => onChanged(filters.copyWith(attitude: () => v)),
          ),
          SwitchListTile(
            key: const Key('npc-with-hook'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Maceraya bağlantı'),
            value: filters.withHook,
            onChanged: (v) => onChanged(filters.copyWith(withHook: v)),
          ),
        ],
      ),
    );
  }
}

String _genderLabel(NpcGender g) => g == NpcGender.kadin ? 'Kadın' : 'Erkek';

class _NpcCard extends StatelessWidget {
  const _NpcCard({required this.npc, required this.locked, required this.onReroll, required this.onToggleLock});

  final Npc npc;
  final Set<NpcField> locked;
  final ValueChanged<NpcField> onReroll;
  final ValueChanged<NpcField> onToggleLock;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('npc-card'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                npc.summary,
                key: const Key('npc-summary'),
                style: t.labelLarge?.copyWith(color: scheme.secondary),
              ),
            ),
            for (final f in NpcField.values)
              if (npc[f] != null)
                _FieldRow(
                  field: f,
                  label: npc.labelOf(f),
                  value: npc[f]!,
                  locked: locked.contains(f),
                  onTap: () => onReroll(f),
                  onLock: () => onToggleLock(f),
                ),
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.field,
    required this.label,
    required this.value,
    required this.locked,
    required this.onTap,
    required this.onLock,
  });

  final NpcField field;
  final String label;
  final String value;
  final bool locked;
  final VoidCallback onTap;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isName = field == NpcField.name;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Semantics(
            button: !locked,
            label: '$label: $value',
            hint: locked ? 'Kilitli' : 'Yeniden üretmek için dokun',
            excludeSemantics: true,
            child: InkWell(
              key: Key('npc-field-${field.name}'),
              borderRadius: BorderRadius.circular(8),
              onTap: locked ? null : onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isName) Text(label, style: t.labelMedium?.copyWith(color: scheme.primary)),
                      Text(
                        value,
                        key: Key('npc-value-${field.name}'),
                        style: isName ? t.headlineSmall?.copyWith(fontWeight: FontWeight.w800) : t.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          key: Key('npc-lock-${field.name}'),
          tooltip: locked ? '${field.label} kilidini aç' : '${field.label} alanını kilitle',
          isSelected: locked,
          icon: const Icon(Icons.lock_open_outlined),
          selectedIcon: Icon(Icons.lock, color: scheme.primary),
          onPressed: onLock,
        ),
      ],
    );
  }
}

class _InitiativeEntry {
  const _InitiativeEntry(this.name, this.bonus, this.hp, this.ac);

  final String name;
  final int bonus;
  final int? hp;
  final int? ac;
}

/// Name prefilled; HP, AC and initiative bonus are optional. Same checks as
/// the initiative screen's add dialog (lib/core/stat_input.dart).
class _InitiativeDialog extends StatefulWidget {
  const _InitiativeDialog({required this.name});

  final String name;

  @override
  State<_InitiativeDialog> createState() => _InitiativeDialogState();
}

class _InitiativeDialogState extends State<_InitiativeDialog> {
  late final _name = TextEditingController(text: widget.name);
  final _hp = TextEditingController();
  final _ac = TextEditingController();
  final _bonus = TextEditingController(text: '0');

  /// Errors show after the first "Ekle".
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_name, _hp, _ac, _bonus]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _nameError => _name.text.trim().isEmpty ? 'Ad gerekli' : null;
  String? get _hpError => statError(_hp.text, min: 1);
  String? get _acError => statError(_ac.text, min: 1);
  String? get _bonusError => statError(_bonus.text);

  void _changed(String _) {
    if (_tried) setState(() {});
  }

  Widget _num(TextEditingController c, String label, Key key, String? error) => TextField(
    key: key,
    controller: c,
    onChanged: _changed,
    maxLength: statFieldMaxLength,
    keyboardType: const TextInputType.numberWithOptions(signed: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-−0-9]'))],
    decoration: InputDecoration(labelText: label, counterText: '', errorText: _tried ? error : null, errorMaxLines: 2),
  );

  void _save() {
    if (_nameError != null || _hpError != null || _acError != null || _bonusError != null) {
      setState(() => _tried = true);
      return;
    }
    Navigator.pop(
      context,
      _InitiativeEntry(_name.text.trim(), parseStat(_bonus.text) ?? 0, parseStat(_hp.text), parseStat(_ac.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('İnisiyatife ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('npc-init-name'),
              controller: _name,
              onChanged: _changed,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: 'Ad', errorText: _tried ? _nameError : null),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _num(_hp, 'Can Puanı', const Key('npc-init-hp'), _hpError)),
                const SizedBox(width: 8),
                Expanded(child: _num(_ac, 'ZS', const Key('npc-init-ac'), _acError)),
              ],
            ),
            const SizedBox(height: 8),
            _num(_bonus, 'İnis. bonusu', const Key('npc-init-bonus'), _bonusError),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
        FilledButton(key: const Key('npc-init-save'), onPressed: _save, child: const Text('Ekle')),
      ],
    );
  }
}
