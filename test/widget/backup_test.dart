import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/features/backup/backup.dart';
import 'package:gm_cebi/features/backup/device_files.dart';
import 'package:gm_cebi/ui/widgets/backup_settings.dart';

import 'harness.dart';
import 'map_test.dart' show pumped;

Future<void> openBackupSettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Ayarlar ve Hakkında'));
  await settle(tester);
  await tester.scrollUntilVisible(find.byKey(const Key('backup-create')), 300, scrollable: scrollableIn(const Key('settings-list')));
  await settle(tester);
}

String lastBackupLine(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('backup-last'))).data!;

void main() {
  final files = FakeDeviceFiles();
  setUp(() {
    files.shared.clear();
    files.saved.clear();
    files.texts.clear();
    files.picked = null;
    files.cancelSave = false;
  });

  appTest('back up to a file, then restore it (without the GM pack)', overrides: [deviceFilesProvider.overrideWithValue(files)],
      (tester, db) async {
    await pumped(tester, db.createNote(title: 'Oturum 1', body: 'Goblin pususu'));
    await pumped(tester, db.addCombatant(name: 'Goblin', initiative: 12));
    await openBackupSettings(tester);
    expect(find.text(backupContentsText), findsOneWidget);
    expect(lastBackupLine(tester), 'Henüz yedek alınmadı');

    // Cancelled save: no backup recorded.
    files.cancelSave = true;
    await tester.tap(find.byKey(const Key('backup-create')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('backup-save')));
    await settle(tester);
    expect(lastBackupLine(tester), 'Henüz yedek alınmadı');

    files.cancelSave = false;
    await tester.tap(find.byKey(const Key('backup-create')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('backup-save')));
    await settle(tester);
    final (name, bytes) = files.saved.single;
    expect(name, matches(RegExp(r'^gm-cebi-yedek-\d{4}-\d{2}-\d{2}\.json$')));
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    expect(json['format'], 'gm-cebi-backup');
    expect(((json['tables'] as Map)['notes'] as List).single, containsPair('title', 'Oturum 1'));
    expect(lastBackupLine(tester), startsWith('Son yedek: '));
    expect(lastBackupLine(tester), matches(RegExp(r'^Son yedek: \d{1,2} \S{3} \d{4} \d{2}:\d{2}$')));
    expect((await pumped(tester, db.readSettings()))[lastBackupAtKey], isNotNull);

    // Share works the same way.
    await tester.tap(find.byKey(const Key('backup-create')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('backup-share')));
    await settle(tester);
    expect(files.shared.single.$1, name);

    // Things change after the backup…
    await pumped(tester, db.createNote(title: 'Sonradan'));
    await pumped(tester, db.newEncounter(keepPlayers: false));

    // …restore: confirmation first, Vazgeç changes nothing.
    files.picked = bytes;
    await tester.tap(find.byKey(const Key('backup-restore')));
    await settle(tester);
    expect(find.textContaining(restoreWarningText), findsOneWidget);
    expect(find.textContaining('1 not, 1 savaşçı'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await settle(tester);
    expect((await pumped(tester, db.select(db.notes).get())), hasLength(2));

    await tester.tap(find.byKey(const Key('backup-restore')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('restore-confirm')));
    await settle(tester);
    expect(find.text('Yedek geri yüklendi.'), findsOneWidget);
    expect((await pumped(tester, db.select(db.notes).get())).map((n) => n.title), ['Oturum 1']);
    final combatants = await pumped(tester, db.select(db.combatants).get());
    expect(combatants.map((c) => c.name), ['Goblin']);
    expect(lastBackupLine(tester), startsWith('Son yedek: ')); // device-bound: kept
  });

  appTest('restore refuses other files with a message', overrides: [deviceFilesProvider.overrideWithValue(files)], (tester, db) async {
    await pumped(tester, db.createNote(title: 'Kalacak'));
    await openBackupSettings(tester);

    files.picked = Uint8List.fromList(utf8.encode('{"format": "baska"}'));
    await tester.tap(find.byKey(const Key('backup-restore')));
    await settle(tester);
    expect(find.text(notABackupMessage), findsOneWidget);
    expect(find.byKey(const Key('restore-confirm')), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    await settle(tester);

    final newer = await pumped(tester, exportBackup(db));
    newer['schemaVersion'] = db.schemaVersion + 1;
    files.picked = Uint8List.fromList(utf8.encode(jsonEncode(newer)));
    await tester.tap(find.byKey(const Key('backup-restore')));
    await settle(tester);
    expect(find.text(newerBackupMessage), findsOneWidget);
    expect(find.byKey(const Key('restore-confirm')), findsNothing);
    expect((await pumped(tester, db.select(db.notes).get())).single.title, 'Kalacak');
  });

  appTest('restore brings back the settings in use', overrides: [deviceFilesProvider.overrideWithValue(files)], (tester, db) async {
    await pumped(tester, db.writeSetting('themeMode', 'light'));
    final backup = await pumped(tester, exportBackup(db));
    await pumped(tester, db.writeSetting('themeMode', 'dark'));
    await openBackupSettings(tester);
    files.picked = Uint8List.fromList(utf8.encode(jsonEncode(backup)));
    await tester.tap(find.byKey(const Key('backup-restore')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('restore-confirm')));
    await settle(tester);
    expect(Theme.of(tester.element(find.byKey(const Key('settings-list')))).brightness, Brightness.light);
  });
}
