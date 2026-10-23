import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/turkish.dart';
import '../../db/database.dart';
import '../../features/flags.dart';
import '../../providers.dart';
import '../widgets/locked.dart';

const _months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

/// "21 Ekim 2026, 19:05"
String formatDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Session notes (GM pack): a simple list with search, newest first, pinned on top.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(entitlementsProvider).allows(Feature.sessionNotes)) {
      return Scaffold(appBar: AppBar(title: const Text('Notlar')), body: const GmPackLocked(feature: 'Oturum notları'));
    }
    final notes = ref.watch(notesProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Oturum Notları')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new-note'),
        heroTag: 'fab-notes',
        onPressed: () async {
          final id = await ref.read(databaseProvider).createNote();
          if (!context.mounted) return;
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: id)));
        },
        icon: const Icon(Icons.edit_note),
        label: const Text('Yeni not'),
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (all) {
          final f = trFold(_filter.trim());
          final list = f.isEmpty ? all : all.where((n) => trFold('${n.title} ${n.body}').contains(f)).toList();
          return Column(children: [
            if (all.length > 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Notlarda ara'),
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ),
            Expanded(
              child: all.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Henüz not yok. Oturumda olanları, NPC adlarını ve ipuçlarını buraya yaz.',
                          textAlign: TextAlign.center,
                          style: t.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: list.length,
                      itemBuilder: (context, i) => _NoteTile(note: list[i]),
                    ),
            ),
          ]);
        },
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final title = note.title.trim().isEmpty ? 'Başlıksız not' : note.title.trim();
    final preview = note.body.trim().replaceAll(RegExp(r'\s+'), ' ');
    return Card(
      child: ListTile(
        leading: note.pinned ? Icon(Icons.push_pin, color: scheme.primary) : const Icon(Icons.sticky_note_2_outlined),
        title: Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (preview.isNotEmpty) Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(formatDate(note.updatedAt), style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ]),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: note.id))),
      ),
    );
  }
}

/// Editor with autosave (debounced while typing, and on leaving the screen).
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.noteId});

  final int noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _pinned = false;
  bool _loaded = false;
  bool _dirty = false;
  Timer? _debounce;
  late final AppDatabase _db = ref.read(databaseProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await _db.getNote(widget.noteId);
    if (!mounted || n == null) return;
    setState(() {
      _title.text = n.title;
      _body.text = n.body;
      _pinned = n.pinned;
      _loaded = true;
    });
  }

  void _changed() {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    if (!_dirty) return;
    _dirty = false;
    await _db.updateNote(widget.noteId, title: _title.text, body: _body.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final empty = _title.text.trim().isEmpty && _body.text.trim().isEmpty;
    if (_loaded && empty) {
      _db.deleteNote(widget.noteId); // don't keep blank notes
    } else {
      _save();
    }
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not'),
        actions: [
          IconButton(
            tooltip: _pinned ? 'Sabitlemeyi kaldır' : 'Üste sabitle',
            icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () async {
              setState(() => _pinned = !_pinned);
              await _db.updateNote(widget.noteId, pinned: _pinned);
            },
          ),
          IconButton(
            key: const Key('delete-note'),
            tooltip: 'Sil',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Not silinsin mi?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
                    FilledButton(key: const Key('confirm-delete'), onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                  ],
                ),
              );
              if (ok != true) return;
              _debounce?.cancel();
              _dirty = false;
              _title.clear();
              _body.clear();
              await _db.deleteNote(widget.noteId);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(children: [
                TextField(
                  key: const Key('note-title'),
                  controller: _title,
                  onChanged: (_) => _changed(),
                  textCapitalization: TextCapitalization.sentences,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(hintText: 'Başlık (ör. 3. oturum – Gölgeli Orman)'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    key: const Key('note-body'),
                    controller: _body,
                    onChanged: (_) => _changed(),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: t.bodyLarge,
                    decoration: const InputDecoration(hintText: 'Notlar…'),
                  ),
                ),
              ]),
            ),
    );
  }
}
