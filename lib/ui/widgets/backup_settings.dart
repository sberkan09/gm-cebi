import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/backup/backup.dart';
import '../../features/backup/device_files.dart';
import '../../providers.dart';

const _shortMonths = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

/// "12 Kas 2026 14:05"
String formatShortDate(DateTime d) =>
    '${d.day} ${_shortMonths[d.month - 1]} ${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// When this device last made a backup (a device-bound setting).
final lastBackupAtProvider = FutureProvider<DateTime?>((ref) => readLastBackupAt(ref.watch(databaseProvider)));

const backupContentsText = 'Notlar, karşılaşma, harita (yüklediğin harita resmi dahil) ve çevrimiçi resimler. Giriş bilgilerin yedeğe girmez.';
const restoreWarningText = 'Buradaki notlar, karşılaşma ve harita silinir; yedektekiler gelir. Geri alınamaz.';

enum _BackupTarget { share, save }

/// Settings → "Yedekleme": back up to a file, restore from one. Available to
/// everyone, with or without the GM pack.
class BackupSettings extends ConsumerStatefulWidget {
  const BackupSettings({super.key});

  @override
  ConsumerState<BackupSettings> createState() => _BackupSettingsState();
}

class _BackupSettingsState extends ConsumerState<BackupSettings> {
  bool _busy = false;

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on BackupException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('İşlem tamamlanamadı. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backup() async {
    final target = await showModalBottomSheet<_BackupTarget>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            key: const Key('backup-share'),
            leading: const Icon(Icons.share_outlined),
            title: const Text('Paylaş'),
            subtitle: const Text('E-postayla, mesajla ya da bir bulut sürücüsüne gönder'),
            onTap: () => Navigator.pop(context, _BackupTarget.share),
          ),
          ListTile(
            key: const Key('backup-save'),
            leading: const Icon(Icons.save_alt),
            title: const Text('Dosyaya kaydet'),
            subtitle: const Text('Telefonda bir klasöre kaydet'),
            onTap: () => Navigator.pop(context, _BackupTarget.save),
          ),
        ]),
      ),
    );
    if (target == null) return;
    await _run(() async {
      final db = ref.read(databaseProvider);
      final files = ref.read(deviceFilesProvider);
      final now = DateTime.now();
      final bytes = await exportBackupBytes(db, now: now);
      final name = backupFileName(now);
      bool done;
      try {
        done = target == _BackupTarget.share
            ? await files.shareFile(bytes, fileName: name, mimeType: 'application/json')
            : await files.saveFile(bytes, fileName: name, mimeType: 'application/json');
      } catch (_) {
        throw const BackupException('Yedek alınamadı. Tekrar dene.');
      }
      if (!done) return;
      await writeLastBackupAt(db, now);
      ref.invalidate(lastBackupAtProvider);
      _snack(target == _BackupTarget.save ? 'Yedek kaydedildi: $name' : 'Yedek hazırlandı: $name');
    });
  }

  Future<void> _restore() async {
    final db = ref.read(databaseProvider);
    ParsedBackup? backup;
    // A refused file is refused before anything is asked or touched.
    await _run(() async {
      final bytes = await ref.read(deviceFilesProvider).pickJson();
      if (bytes != null) backup = parseBackup(db, bytes);
    });
    final b = backup;
    if (b == null || !mounted) return;
    final created = b.createdAt == null ? null : formatShortDate(b.createdAt!.toLocal());
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yedekten geri yüklensin mi?'),
        content: Text([
          restoreWarningText,
          '',
          'Yedek${created == null ? '' : ' ($created)'}: ${b.count('notes')} not, ${b.count('combatants')} savaşçı, '
              '${b.count('map_strokes')} harita çizgisi.',
        ].join('\n')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(key: const Key('restore-confirm'), onPressed: () => Navigator.pop(context, true), child: const Text('Geri yükle')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() async {
      await restoreBackup(db, b);
      // Settings are read once into memory; the rest follows the database.
      ref.invalidate(settingsProvider);
      _snack('Yedek geri yüklendi.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final last = ref.watch(lastBackupAtProvider).value;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Text(backupContentsText, style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      ),
      ListTile(
        key: const Key('backup-create'),
        enabled: !_busy,
        leading: const Icon(Icons.backup_outlined),
        title: const Text('Yedek al'),
        subtitle: Text(last == null ? 'Henüz yedek alınmadı' : 'Son yedek: ${formatShortDate(last)}', key: const Key('backup-last')),
        trailing: _busy ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
        onTap: _backup,
      ),
      ListTile(
        key: const Key('backup-restore'),
        enabled: !_busy,
        leading: const Icon(Icons.settings_backup_restore),
        title: const Text('Yedekten geri yükle'),
        onTap: _restore,
      ),
    ]);
  }
}
