/// Backup and restore of the user's data as one JSON file
/// (docs/data-model.md, "Yedek dosyası").
///
/// Written generically from drift's table metadata ([AppDatabase.allTables]
/// and each table's columns), so a table or column added later is in the
/// backup without a change here; [backupExcludedTables] lists the tables kept
/// out on purpose (none today).
///
/// Restore replaces everything: the file is decoded and checked completely
/// first ([parseBackup]), then one transaction deletes the user tables and
/// inserts the backup's rows with their ids ([restoreBackup]). Any failure
/// rolls back and leaves the old data as it was.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../app_info.dart';
import '../../db/database.dart';

const backupFormat = 'gm-cebi-backup';

/// Version of the file layout (not of the database: that is `schemaVersion`).
const backupFormatVersion = 1;

/// Files larger than this are refused before they are read.
const maxBackupBytes = 50 * 1024 * 1024;

/// Settings that belong to this device, not to the user's data: consent and
/// switches of the online feature, the internal test switch and when this
/// device last made a backup. Never written to a backup, and a restore keeps
/// this device's values.
const deviceBoundSettings = {'ncConsent', 'ncEnabled', 'gmPackOverride', lastBackupAtKey};

/// Settings key: when a backup was last shared or saved on this device (ISO-8601, UTC).
const lastBackupAtKey = 'lastBackupAt';

/// Tables (SQL names) deliberately not backed up. Every other table is.
const backupExcludedTables = <String>{};

const notABackupMessage = 'Bu dosya bir GM Cebi yedeği değil';
const newerBackupMessage = 'Bu yedek daha yeni bir sürümle alınmış. Uygulamayı güncelle.';
const tooLargeMessage = 'Bu dosya bir yedek için fazla büyük (en çok 50 MB).';
const restoreFailedMessage = 'Yedek geri yüklenemedi; verilerin değişmedi.';

/// A refused file or a failed restore; [message] is shown to the user as is.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => 'BackupException: $message';
}

/// "gm-cebi-yedek-2026-11-12.json"
String backupFileName(DateTime d) =>
    'gm-cebi-yedek-${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}.json';

/// The tables a backup holds, parents before children (declaration order).
List<TableInfo> backupTables(AppDatabase db) =>
    [for (final t in db.allTables) if (!backupExcludedTables.contains(t.actualTableName)) t];

/// Rows left out of a backup: device-bound settings, and pictures that were
/// reported (their bytes are already deleted) or have no bytes.
bool _skipRow(String table, Map<String, Object?> row) => switch (table) {
      'settings' => deviceBoundSettings.contains(row['key']),
      'map_scenes' => row['hidden'] == true || row['png'] == null || (row['png'] as String).isEmpty,
      _ => false,
    };

/// The whole backup as a JSON-ready map. DateTimes are ISO-8601 strings in
/// UTC, blobs base64, booleans `true`/`false`.
Future<Map<String, Object?>> exportBackup(AppDatabase db, {DateTime? now, String app = appVersion}) async {
  final tables = <String, Object?>{};
  for (final t in backupTables(db)) {
    final rows = await db.customSelect('SELECT * FROM "${t.actualTableName}" ORDER BY rowid', readsFrom: {t}).get();
    tables[t.actualTableName] = [
      for (final r in rows)
        if ({for (final c in t.$columns) c.name: _encode(r, c)} case final row when !_skipRow(t.actualTableName, row)) row,
    ];
  }
  return {
    'format': backupFormat,
    'version': backupFormatVersion,
    'schemaVersion': db.schemaVersion,
    'createdAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
    'app': app,
    'tables': tables,
  };
}

/// [exportBackup] as the file's UTF-8 bytes.
Future<Uint8List> exportBackupBytes(AppDatabase db, {DateTime? now, String app = appVersion}) async =>
    utf8.encode(const JsonEncoder.withIndent(' ').convert(await exportBackup(db, now: now, app: app)));

Object? _encode(QueryRow r, GeneratedColumn c) {
  final raw = r.data[c.name];
  if (raw == null) return null;
  return switch (c.type) {
    DriftSqlType.dateTime => r.readNullableWithType(DriftSqlType.dateTime, c.name)!.toUtc().toIso8601String(),
    DriftSqlType.bool => raw == 1 || raw == true,
    DriftSqlType.blob => base64Encode(raw as Uint8List),
    DriftSqlType.bigInt => (raw as num).toInt(),
    _ => raw,
  };
}

/// One table's rows from a backup, ready to insert: the columns the file has
/// (others take their defaults) and each row's values in that order.
class BackupTable {
  const BackupTable(this.table, this.columns, this.rows);

  final TableInfo table;
  final List<GeneratedColumn> columns;
  final List<List<Object?>> rows;
}

/// A checked and decoded backup file.
class ParsedBackup {
  const ParsedBackup({required this.schemaVersion, required this.createdAt, required this.app, required this.tables});

  final int schemaVersion;
  final DateTime? createdAt;
  final String? app;
  final List<BackupTable> tables;

  int count(String table) => tables.where((t) => t.table.actualTableName == table).fold(0, (n, t) => n + t.rows.length);
}

/// Reads and checks a backup file without touching the database. Throws a
/// [BackupException]: not a backup ([notABackupMessage]), from a newer app
/// ([newerBackupMessage]) or too large ([tooLargeMessage]).
///
/// A file from an older schema is accepted: tables and columns it lacks take
/// their defaults (an empty table, a column's default value). Unknown tables
/// and columns are ignored. Device-bound settings in the file are ignored.
ParsedBackup parseBackup(AppDatabase db, Uint8List bytes) {
  if (bytes.length > maxBackupBytes) throw const BackupException(tooLargeMessage);
  Object? json;
  try {
    json = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    throw const BackupException(notABackupMessage);
  }
  if (json is! Map<String, Object?> || json['format'] != backupFormat) throw const BackupException(notABackupMessage);
  final version = json['version'], schema = json['schemaVersion'], tables = json['tables'];
  if (version is! int || schema is! int || tables is! Map<String, Object?>) throw const BackupException(notABackupMessage);
  if (version > backupFormatVersion || schema > db.schemaVersion) throw const BackupException(newerBackupMessage);
  final out = <BackupTable>[];
  for (final t in backupTables(db)) {
    final name = t.actualTableName;
    final list = tables[name];
    if (list == null) {
      // A table of the current schema missing from a current file: damaged.
      // An older schema may simply not have had it yet.
      if (schema == db.schemaVersion) throw const BackupException(notABackupMessage);
      out.add(BackupTable(t, const [], const []));
      continue;
    }
    if (list is! List) throw const BackupException(notABackupMessage);
    final keys = <String>{};
    for (final row in list) {
      if (row is! Map<String, Object?>) throw const BackupException(notABackupMessage);
      keys.addAll(row.keys);
    }
    final columns = [for (final c in t.$columns) if (keys.contains(c.name)) c];
    final rows = <List<Object?>>[];
    for (final row in list.cast<Map<String, Object?>>()) {
      if (name == 'settings' && deviceBoundSettings.contains(row['key'])) continue;
      // A row without a column some other row has: that column's default.
      rows.add([for (final c in columns) row.containsKey(c.name) ? _decode(row[c.name], c) : _missing]);
    }
    out.add(BackupTable(t, columns, rows));
  }
  final created = json['createdAt'];
  return ParsedBackup(
    schemaVersion: schema,
    createdAt: created is String ? DateTime.tryParse(created) : null,
    app: json['app'] is String ? json['app'] as String : null,
    tables: out,
  );
}

/// Marks a column a row of the file does not have: it takes the default.
const Object _missing = _Missing();

class _Missing {
  const _Missing();
}

Object? _decode(Object? v, GeneratedColumn c) {
  if (v == null) return null;
  try {
    return switch (c.type) {
      DriftSqlType.dateTime => DateTime.parse(v as String),
      DriftSqlType.bool => switch (v) { true || 1 => true, false || 0 => false, _ => throw const FormatException() },
      DriftSqlType.blob => base64Decode(v as String),
      DriftSqlType.int || DriftSqlType.bigInt => (v as num) == v.truncate() ? v.toInt() : throw const FormatException(),
      DriftSqlType.double => (v as num).toDouble(),
      DriftSqlType.string => v as String,
      _ => v,
    };
  } on FormatException {
    throw const BackupException(notABackupMessage);
  } on TypeError {
    throw const BackupException(notABackupMessage);
  }
}

/// Replaces the user's data with [backup] in one transaction, keeping the
/// backup's ids (foreign keys and the turn record `initiativeActed` refer to
/// them). This device's [deviceBoundSettings] stay as they are. On any
/// failure nothing changes and a [BackupException] ([restoreFailedMessage])
/// is thrown. Watching queries refresh afterwards.
Future<void> restoreBackup(AppDatabase db, ParsedBackup backup) async {
  final tables = [for (final t in backup.tables) t.table];
  try {
    await db.transaction(() async {
      // Foreign keys are checked at the end, so the order of the rows within
      // the file does not matter; a dangling reference still fails below.
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final t in tables.reversed) {
        if (t.actualTableName == 'settings') {
          await db.customStatement(
              'DELETE FROM "settings" WHERE "key" NOT IN (${List.filled(deviceBoundSettings.length, '?').join(', ')})',
              deviceBoundSettings.toList());
        } else {
          await db.customStatement('DELETE FROM "${t.actualTableName}"');
        }
      }
      for (final t in backup.tables) {
        for (final row in t.rows) {
          final cols = <String>[];
          final vars = <Variable>[];
          for (var i = 0; i < t.columns.length; i++) {
            if (identical(row[i], _missing)) continue;
            cols.add('"${t.columns[i].name}"');
            vars.add(Variable<Object>(row[i]));
          }
          await db.customInsert(
            cols.isEmpty
                ? 'INSERT INTO "${t.table.actualTableName}" DEFAULT VALUES'
                : 'INSERT INTO "${t.table.actualTableName}" (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')})',
            variables: vars,
          );
        }
      }
      if ((await db.customSelect('PRAGMA foreign_key_check').get()).isNotEmpty) {
        throw const BackupException(restoreFailedMessage);
      }
    });
  } on BackupException {
    rethrow;
  } catch (_) {
    throw const BackupException(restoreFailedMessage);
  }
  db.notifyUpdates({for (final t in tables) TableUpdate.onTable(t)});
}

/// Reads when this device last made a backup.
Future<DateTime?> readLastBackupAt(AppDatabase db) async {
  final v = (await db.readSettings())[lastBackupAtKey];
  return v == null ? null : DateTime.tryParse(v)?.toLocal();
}

Future<void> writeLastBackupAt(AppDatabase db, DateTime at) => db.writeSetting(lastBackupAtKey, at.toUtc().toIso8601String());
