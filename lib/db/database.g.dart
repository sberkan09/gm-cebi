// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    pinned,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String title;
  final String body;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['pinned'] = Variable<bool>(pinned);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      pinned: Value(pinned),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'pinned': serializer.toJson<bool>(pinned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? body,
    bool? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    pinned: pinned ?? this.pinned,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('pinned: $pinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, body, pinned, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.pinned == this.pinned &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<bool> pinned;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.pinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.pinned = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<bool>? pinned,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (pinned != null) 'pinned': pinned,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<bool>? pinned,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('pinned: $pinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EncountersTable extends Encounters
    with TableInfo<$EncountersTable, Encounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
    'round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _turnIndexMeta = const VerificationMeta(
    'turnIndex',
  );
  @override
  late final GeneratedColumn<int> turnIndex = GeneratedColumn<int>(
    'turn_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedMeta = const VerificationMeta(
    'started',
  );
  @override
  late final GeneratedColumn<bool> started = GeneratedColumn<bool>(
    'started',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("started" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    round,
    turnIndex,
    started,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Encounter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    }
    if (data.containsKey('turn_index')) {
      context.handle(
        _turnIndexMeta,
        turnIndex.isAcceptableOrUnknown(data['turn_index']!, _turnIndexMeta),
      );
    }
    if (data.containsKey('started')) {
      context.handle(
        _startedMeta,
        started.isAcceptableOrUnknown(data['started']!, _startedMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Encounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Encounter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round'],
      )!,
      turnIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_index'],
      )!,
      started: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}started'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EncountersTable createAlias(String alias) {
    return $EncountersTable(attachedDatabase, alias);
  }
}

class Encounter extends DataClass implements Insertable<Encounter> {
  final int id;
  final String name;
  final int round;

  /// Index into the initiative-sorted combatant list.
  final int turnIndex;

  /// Becomes true at the first "next turn". Before that the marker stays on
  /// the top of the order while combatants are added and initiative is rolled.
  final bool started;
  final bool active;
  final DateTime createdAt;
  const Encounter({
    required this.id,
    required this.name,
    required this.round,
    required this.turnIndex,
    required this.started,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['round'] = Variable<int>(round);
    map['turn_index'] = Variable<int>(turnIndex);
    map['started'] = Variable<bool>(started);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EncountersCompanion toCompanion(bool nullToAbsent) {
    return EncountersCompanion(
      id: Value(id),
      name: Value(name),
      round: Value(round),
      turnIndex: Value(turnIndex),
      started: Value(started),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory Encounter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Encounter(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      round: serializer.fromJson<int>(json['round']),
      turnIndex: serializer.fromJson<int>(json['turnIndex']),
      started: serializer.fromJson<bool>(json['started']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'round': serializer.toJson<int>(round),
      'turnIndex': serializer.toJson<int>(turnIndex),
      'started': serializer.toJson<bool>(started),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Encounter copyWith({
    int? id,
    String? name,
    int? round,
    int? turnIndex,
    bool? started,
    bool? active,
    DateTime? createdAt,
  }) => Encounter(
    id: id ?? this.id,
    name: name ?? this.name,
    round: round ?? this.round,
    turnIndex: turnIndex ?? this.turnIndex,
    started: started ?? this.started,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  Encounter copyWithCompanion(EncountersCompanion data) {
    return Encounter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      round: data.round.present ? data.round.value : this.round,
      turnIndex: data.turnIndex.present ? data.turnIndex.value : this.turnIndex,
      started: data.started.present ? data.started.value : this.started,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Encounter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('round: $round, ')
          ..write('turnIndex: $turnIndex, ')
          ..write('started: $started, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, round, turnIndex, started, active, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Encounter &&
          other.id == this.id &&
          other.name == this.name &&
          other.round == this.round &&
          other.turnIndex == this.turnIndex &&
          other.started == this.started &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class EncountersCompanion extends UpdateCompanion<Encounter> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> round;
  final Value<int> turnIndex;
  final Value<bool> started;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const EncountersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.round = const Value.absent(),
    this.turnIndex = const Value.absent(),
    this.started = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EncountersCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.round = const Value.absent(),
    this.turnIndex = const Value.absent(),
    this.started = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<Encounter> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? round,
    Expression<int>? turnIndex,
    Expression<bool>? started,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (round != null) 'round': round,
      if (turnIndex != null) 'turn_index': turnIndex,
      if (started != null) 'started': started,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EncountersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? round,
    Value<int>? turnIndex,
    Value<bool>? started,
    Value<bool>? active,
    Value<DateTime>? createdAt,
  }) {
    return EncountersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      round: round ?? this.round,
      turnIndex: turnIndex ?? this.turnIndex,
      started: started ?? this.started,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (turnIndex.present) {
      map['turn_index'] = Variable<int>(turnIndex.value);
    }
    if (started.present) {
      map['started'] = Variable<bool>(started.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncountersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('round: $round, ')
          ..write('turnIndex: $turnIndex, ')
          ..write('started: $started, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CombatantsTable extends Combatants
    with TableInfo<$CombatantsTable, Combatant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CombatantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _encounterIdMeta = const VerificationMeta(
    'encounterId',
  );
  @override
  late final GeneratedColumn<int> encounterId = GeneratedColumn<int>(
    'encounter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES encounters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initiativeMeta = const VerificationMeta(
    'initiative',
  );
  @override
  late final GeneratedColumn<int> initiative = GeneratedColumn<int>(
    'initiative',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initBonusMeta = const VerificationMeta(
    'initBonus',
  );
  @override
  late final GeneratedColumn<int> initBonus = GeneratedColumn<int>(
    'init_bonus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hpCurrentMeta = const VerificationMeta(
    'hpCurrent',
  );
  @override
  late final GeneratedColumn<int> hpCurrent = GeneratedColumn<int>(
    'hp_current',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hpMaxMeta = const VerificationMeta('hpMax');
  @override
  late final GeneratedColumn<int> hpMax = GeneratedColumn<int>(
    'hp_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acMeta = const VerificationMeta('ac');
  @override
  late final GeneratedColumn<int> ac = GeneratedColumn<int>(
    'ac',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPlayerMeta = const VerificationMeta(
    'isPlayer',
  );
  @override
  late final GeneratedColumn<bool> isPlayer = GeneratedColumn<bool>(
    'is_player',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_player" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _conditionsMeta = const VerificationMeta(
    'conditions',
  );
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
    'conditions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _monsterIdMeta = const VerificationMeta(
    'monsterId',
  );
  @override
  late final GeneratedColumn<String> monsterId = GeneratedColumn<String>(
    'monster_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<double> posX = GeneratedColumn<double>(
    'pos_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<double> posY = GeneratedColumn<double>(
    'pos_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encounterId,
    name,
    initiative,
    initBonus,
    hpCurrent,
    hpMax,
    ac,
    isPlayer,
    conditions,
    monsterId,
    sortOrder,
    createdAt,
    posX,
    posY,
    level,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'combatants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Combatant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
        _encounterIdMeta,
        encounterId.isAcceptableOrUnknown(
          data['encounter_id']!,
          _encounterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encounterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('initiative')) {
      context.handle(
        _initiativeMeta,
        initiative.isAcceptableOrUnknown(data['initiative']!, _initiativeMeta),
      );
    }
    if (data.containsKey('init_bonus')) {
      context.handle(
        _initBonusMeta,
        initBonus.isAcceptableOrUnknown(data['init_bonus']!, _initBonusMeta),
      );
    }
    if (data.containsKey('hp_current')) {
      context.handle(
        _hpCurrentMeta,
        hpCurrent.isAcceptableOrUnknown(data['hp_current']!, _hpCurrentMeta),
      );
    }
    if (data.containsKey('hp_max')) {
      context.handle(
        _hpMaxMeta,
        hpMax.isAcceptableOrUnknown(data['hp_max']!, _hpMaxMeta),
      );
    }
    if (data.containsKey('ac')) {
      context.handle(_acMeta, ac.isAcceptableOrUnknown(data['ac']!, _acMeta));
    }
    if (data.containsKey('is_player')) {
      context.handle(
        _isPlayerMeta,
        isPlayer.isAcceptableOrUnknown(data['is_player']!, _isPlayerMeta),
      );
    }
    if (data.containsKey('conditions')) {
      context.handle(
        _conditionsMeta,
        conditions.isAcceptableOrUnknown(data['conditions']!, _conditionsMeta),
      );
    }
    if (data.containsKey('monster_id')) {
      context.handle(
        _monsterIdMeta,
        monsterId.isAcceptableOrUnknown(data['monster_id']!, _monsterIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('pos_x')) {
      context.handle(
        _posXMeta,
        posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta),
      );
    }
    if (data.containsKey('pos_y')) {
      context.handle(
        _posYMeta,
        posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Combatant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Combatant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      encounterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encounter_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      initiative: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initiative'],
      ),
      initBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}init_bonus'],
      )!,
      hpCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp_current'],
      ),
      hpMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp_max'],
      ),
      ac: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ac'],
      ),
      isPlayer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_player'],
      )!,
      conditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conditions'],
      )!,
      monsterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monster_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      posX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pos_x'],
      ),
      posY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pos_y'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
    );
  }

  @override
  $CombatantsTable createAlias(String alias) {
    return $CombatantsTable(attachedDatabase, alias);
  }
}

class Combatant extends DataClass implements Insertable<Combatant> {
  final int id;
  final int encounterId;
  final String name;
  final int? initiative;
  final int initBonus;
  final int? hpCurrent;
  final int? hpMax;
  final int? ac;
  final bool isPlayer;

  /// Comma-separated condition ids (e.g. "prone,poisoned").
  final String conditions;

  /// Source monster id, when added from the bestiary.
  final String? monsterId;

  /// Tie-break for equal initiative (lower first).
  final int sortOrder;
  final DateTime createdAt;

  /// Token position on the battle map, 0..1 of the map's width and height;
  /// null while the token is not on the map. (schema 2)
  final double? posX;
  final double? posY;

  /// A player character's level (1–20) for encounter difficulty; null uses
  /// the party level setting. (schema 4)
  final int? level;
  const Combatant({
    required this.id,
    required this.encounterId,
    required this.name,
    this.initiative,
    required this.initBonus,
    this.hpCurrent,
    this.hpMax,
    this.ac,
    required this.isPlayer,
    required this.conditions,
    this.monsterId,
    required this.sortOrder,
    required this.createdAt,
    this.posX,
    this.posY,
    this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['encounter_id'] = Variable<int>(encounterId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || initiative != null) {
      map['initiative'] = Variable<int>(initiative);
    }
    map['init_bonus'] = Variable<int>(initBonus);
    if (!nullToAbsent || hpCurrent != null) {
      map['hp_current'] = Variable<int>(hpCurrent);
    }
    if (!nullToAbsent || hpMax != null) {
      map['hp_max'] = Variable<int>(hpMax);
    }
    if (!nullToAbsent || ac != null) {
      map['ac'] = Variable<int>(ac);
    }
    map['is_player'] = Variable<bool>(isPlayer);
    map['conditions'] = Variable<String>(conditions);
    if (!nullToAbsent || monsterId != null) {
      map['monster_id'] = Variable<String>(monsterId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || posX != null) {
      map['pos_x'] = Variable<double>(posX);
    }
    if (!nullToAbsent || posY != null) {
      map['pos_y'] = Variable<double>(posY);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    return map;
  }

  CombatantsCompanion toCompanion(bool nullToAbsent) {
    return CombatantsCompanion(
      id: Value(id),
      encounterId: Value(encounterId),
      name: Value(name),
      initiative: initiative == null && nullToAbsent
          ? const Value.absent()
          : Value(initiative),
      initBonus: Value(initBonus),
      hpCurrent: hpCurrent == null && nullToAbsent
          ? const Value.absent()
          : Value(hpCurrent),
      hpMax: hpMax == null && nullToAbsent
          ? const Value.absent()
          : Value(hpMax),
      ac: ac == null && nullToAbsent ? const Value.absent() : Value(ac),
      isPlayer: Value(isPlayer),
      conditions: Value(conditions),
      monsterId: monsterId == null && nullToAbsent
          ? const Value.absent()
          : Value(monsterId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      posX: posX == null && nullToAbsent ? const Value.absent() : Value(posX),
      posY: posY == null && nullToAbsent ? const Value.absent() : Value(posY),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
    );
  }

  factory Combatant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Combatant(
      id: serializer.fromJson<int>(json['id']),
      encounterId: serializer.fromJson<int>(json['encounterId']),
      name: serializer.fromJson<String>(json['name']),
      initiative: serializer.fromJson<int?>(json['initiative']),
      initBonus: serializer.fromJson<int>(json['initBonus']),
      hpCurrent: serializer.fromJson<int?>(json['hpCurrent']),
      hpMax: serializer.fromJson<int?>(json['hpMax']),
      ac: serializer.fromJson<int?>(json['ac']),
      isPlayer: serializer.fromJson<bool>(json['isPlayer']),
      conditions: serializer.fromJson<String>(json['conditions']),
      monsterId: serializer.fromJson<String?>(json['monsterId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      posX: serializer.fromJson<double?>(json['posX']),
      posY: serializer.fromJson<double?>(json['posY']),
      level: serializer.fromJson<int?>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'encounterId': serializer.toJson<int>(encounterId),
      'name': serializer.toJson<String>(name),
      'initiative': serializer.toJson<int?>(initiative),
      'initBonus': serializer.toJson<int>(initBonus),
      'hpCurrent': serializer.toJson<int?>(hpCurrent),
      'hpMax': serializer.toJson<int?>(hpMax),
      'ac': serializer.toJson<int?>(ac),
      'isPlayer': serializer.toJson<bool>(isPlayer),
      'conditions': serializer.toJson<String>(conditions),
      'monsterId': serializer.toJson<String?>(monsterId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'posX': serializer.toJson<double?>(posX),
      'posY': serializer.toJson<double?>(posY),
      'level': serializer.toJson<int?>(level),
    };
  }

  Combatant copyWith({
    int? id,
    int? encounterId,
    String? name,
    Value<int?> initiative = const Value.absent(),
    int? initBonus,
    Value<int?> hpCurrent = const Value.absent(),
    Value<int?> hpMax = const Value.absent(),
    Value<int?> ac = const Value.absent(),
    bool? isPlayer,
    String? conditions,
    Value<String?> monsterId = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    Value<double?> posX = const Value.absent(),
    Value<double?> posY = const Value.absent(),
    Value<int?> level = const Value.absent(),
  }) => Combatant(
    id: id ?? this.id,
    encounterId: encounterId ?? this.encounterId,
    name: name ?? this.name,
    initiative: initiative.present ? initiative.value : this.initiative,
    initBonus: initBonus ?? this.initBonus,
    hpCurrent: hpCurrent.present ? hpCurrent.value : this.hpCurrent,
    hpMax: hpMax.present ? hpMax.value : this.hpMax,
    ac: ac.present ? ac.value : this.ac,
    isPlayer: isPlayer ?? this.isPlayer,
    conditions: conditions ?? this.conditions,
    monsterId: monsterId.present ? monsterId.value : this.monsterId,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    posX: posX.present ? posX.value : this.posX,
    posY: posY.present ? posY.value : this.posY,
    level: level.present ? level.value : this.level,
  );
  Combatant copyWithCompanion(CombatantsCompanion data) {
    return Combatant(
      id: data.id.present ? data.id.value : this.id,
      encounterId: data.encounterId.present
          ? data.encounterId.value
          : this.encounterId,
      name: data.name.present ? data.name.value : this.name,
      initiative: data.initiative.present
          ? data.initiative.value
          : this.initiative,
      initBonus: data.initBonus.present ? data.initBonus.value : this.initBonus,
      hpCurrent: data.hpCurrent.present ? data.hpCurrent.value : this.hpCurrent,
      hpMax: data.hpMax.present ? data.hpMax.value : this.hpMax,
      ac: data.ac.present ? data.ac.value : this.ac,
      isPlayer: data.isPlayer.present ? data.isPlayer.value : this.isPlayer,
      conditions: data.conditions.present
          ? data.conditions.value
          : this.conditions,
      monsterId: data.monsterId.present ? data.monsterId.value : this.monsterId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Combatant(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('name: $name, ')
          ..write('initiative: $initiative, ')
          ..write('initBonus: $initBonus, ')
          ..write('hpCurrent: $hpCurrent, ')
          ..write('hpMax: $hpMax, ')
          ..write('ac: $ac, ')
          ..write('isPlayer: $isPlayer, ')
          ..write('conditions: $conditions, ')
          ..write('monsterId: $monsterId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    encounterId,
    name,
    initiative,
    initBonus,
    hpCurrent,
    hpMax,
    ac,
    isPlayer,
    conditions,
    monsterId,
    sortOrder,
    createdAt,
    posX,
    posY,
    level,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Combatant &&
          other.id == this.id &&
          other.encounterId == this.encounterId &&
          other.name == this.name &&
          other.initiative == this.initiative &&
          other.initBonus == this.initBonus &&
          other.hpCurrent == this.hpCurrent &&
          other.hpMax == this.hpMax &&
          other.ac == this.ac &&
          other.isPlayer == this.isPlayer &&
          other.conditions == this.conditions &&
          other.monsterId == this.monsterId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.level == this.level);
}

class CombatantsCompanion extends UpdateCompanion<Combatant> {
  final Value<int> id;
  final Value<int> encounterId;
  final Value<String> name;
  final Value<int?> initiative;
  final Value<int> initBonus;
  final Value<int?> hpCurrent;
  final Value<int?> hpMax;
  final Value<int?> ac;
  final Value<bool> isPlayer;
  final Value<String> conditions;
  final Value<String?> monsterId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<double?> posX;
  final Value<double?> posY;
  final Value<int?> level;
  const CombatantsCompanion({
    this.id = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.name = const Value.absent(),
    this.initiative = const Value.absent(),
    this.initBonus = const Value.absent(),
    this.hpCurrent = const Value.absent(),
    this.hpMax = const Value.absent(),
    this.ac = const Value.absent(),
    this.isPlayer = const Value.absent(),
    this.conditions = const Value.absent(),
    this.monsterId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.level = const Value.absent(),
  });
  CombatantsCompanion.insert({
    this.id = const Value.absent(),
    required int encounterId,
    required String name,
    this.initiative = const Value.absent(),
    this.initBonus = const Value.absent(),
    this.hpCurrent = const Value.absent(),
    this.hpMax = const Value.absent(),
    this.ac = const Value.absent(),
    this.isPlayer = const Value.absent(),
    this.conditions = const Value.absent(),
    this.monsterId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.level = const Value.absent(),
  }) : encounterId = Value(encounterId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Combatant> custom({
    Expression<int>? id,
    Expression<int>? encounterId,
    Expression<String>? name,
    Expression<int>? initiative,
    Expression<int>? initBonus,
    Expression<int>? hpCurrent,
    Expression<int>? hpMax,
    Expression<int>? ac,
    Expression<bool>? isPlayer,
    Expression<String>? conditions,
    Expression<String>? monsterId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<double>? posX,
    Expression<double>? posY,
    Expression<int>? level,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterId != null) 'encounter_id': encounterId,
      if (name != null) 'name': name,
      if (initiative != null) 'initiative': initiative,
      if (initBonus != null) 'init_bonus': initBonus,
      if (hpCurrent != null) 'hp_current': hpCurrent,
      if (hpMax != null) 'hp_max': hpMax,
      if (ac != null) 'ac': ac,
      if (isPlayer != null) 'is_player': isPlayer,
      if (conditions != null) 'conditions': conditions,
      if (monsterId != null) 'monster_id': monsterId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (level != null) 'level': level,
    });
  }

  CombatantsCompanion copyWith({
    Value<int>? id,
    Value<int>? encounterId,
    Value<String>? name,
    Value<int?>? initiative,
    Value<int>? initBonus,
    Value<int?>? hpCurrent,
    Value<int?>? hpMax,
    Value<int?>? ac,
    Value<bool>? isPlayer,
    Value<String>? conditions,
    Value<String?>? monsterId,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<double?>? posX,
    Value<double?>? posY,
    Value<int?>? level,
  }) {
    return CombatantsCompanion(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      name: name ?? this.name,
      initiative: initiative ?? this.initiative,
      initBonus: initBonus ?? this.initBonus,
      hpCurrent: hpCurrent ?? this.hpCurrent,
      hpMax: hpMax ?? this.hpMax,
      ac: ac ?? this.ac,
      isPlayer: isPlayer ?? this.isPlayer,
      conditions: conditions ?? this.conditions,
      monsterId: monsterId ?? this.monsterId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      level: level ?? this.level,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<int>(encounterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (initiative.present) {
      map['initiative'] = Variable<int>(initiative.value);
    }
    if (initBonus.present) {
      map['init_bonus'] = Variable<int>(initBonus.value);
    }
    if (hpCurrent.present) {
      map['hp_current'] = Variable<int>(hpCurrent.value);
    }
    if (hpMax.present) {
      map['hp_max'] = Variable<int>(hpMax.value);
    }
    if (ac.present) {
      map['ac'] = Variable<int>(ac.value);
    }
    if (isPlayer.present) {
      map['is_player'] = Variable<bool>(isPlayer.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (monsterId.present) {
      map['monster_id'] = Variable<String>(monsterId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<double>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<double>(posY.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CombatantsCompanion(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('name: $name, ')
          ..write('initiative: $initiative, ')
          ..write('initBonus: $initBonus, ')
          ..write('hpCurrent: $hpCurrent, ')
          ..write('hpMax: $hpMax, ')
          ..write('ac: $ac, ')
          ..write('isPlayer: $isPlayer, ')
          ..write('conditions: $conditions, ')
          ..write('monsterId: $monsterId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }
}

class $MapStrokesTable extends MapStrokes
    with TableInfo<$MapStrokesTable, MapStroke> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapStrokesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _encounterIdMeta = const VerificationMeta(
    'encounterId',
  );
  @override
  late final GeneratedColumn<int> encounterId = GeneratedColumn<int>(
    'encounter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES encounters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<String> points = GeneratedColumn<String>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encounterId,
    points,
    color,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'map_strokes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MapStroke> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
        _encounterIdMeta,
        encounterId.isAcceptableOrUnknown(
          data['encounter_id']!,
          _encounterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encounterIdMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MapStroke map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapStroke(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      encounterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encounter_id'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}points'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MapStrokesTable createAlias(String alias) {
    return $MapStrokesTable(attachedDatabase, alias);
  }
}

class MapStroke extends DataClass implements Insertable<MapStroke> {
  final int id;
  final int encounterId;

  /// Points as "x,y x,y …", each coordinate 0..1 of the map's side.
  final String points;

  /// Index into the map palette (0 ink, 1 water, 2 plants, 3 danger).
  final int color;
  final DateTime createdAt;
  const MapStroke({
    required this.id,
    required this.encounterId,
    required this.points,
    required this.color,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['encounter_id'] = Variable<int>(encounterId);
    map['points'] = Variable<String>(points);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MapStrokesCompanion toCompanion(bool nullToAbsent) {
    return MapStrokesCompanion(
      id: Value(id),
      encounterId: Value(encounterId),
      points: Value(points),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory MapStroke.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapStroke(
      id: serializer.fromJson<int>(json['id']),
      encounterId: serializer.fromJson<int>(json['encounterId']),
      points: serializer.fromJson<String>(json['points']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'encounterId': serializer.toJson<int>(encounterId),
      'points': serializer.toJson<String>(points),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MapStroke copyWith({
    int? id,
    int? encounterId,
    String? points,
    int? color,
    DateTime? createdAt,
  }) => MapStroke(
    id: id ?? this.id,
    encounterId: encounterId ?? this.encounterId,
    points: points ?? this.points,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
  );
  MapStroke copyWithCompanion(MapStrokesCompanion data) {
    return MapStroke(
      id: data.id.present ? data.id.value : this.id,
      encounterId: data.encounterId.present
          ? data.encounterId.value
          : this.encounterId,
      points: data.points.present ? data.points.value : this.points,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapStroke(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('points: $points, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, encounterId, points, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapStroke &&
          other.id == this.id &&
          other.encounterId == this.encounterId &&
          other.points == this.points &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class MapStrokesCompanion extends UpdateCompanion<MapStroke> {
  final Value<int> id;
  final Value<int> encounterId;
  final Value<String> points;
  final Value<int> color;
  final Value<DateTime> createdAt;
  const MapStrokesCompanion({
    this.id = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.points = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MapStrokesCompanion.insert({
    this.id = const Value.absent(),
    required int encounterId,
    required String points,
    this.color = const Value.absent(),
    required DateTime createdAt,
  }) : encounterId = Value(encounterId),
       points = Value(points),
       createdAt = Value(createdAt);
  static Insertable<MapStroke> custom({
    Expression<int>? id,
    Expression<int>? encounterId,
    Expression<String>? points,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterId != null) 'encounter_id': encounterId,
      if (points != null) 'points': points,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MapStrokesCompanion copyWith({
    Value<int>? id,
    Value<int>? encounterId,
    Value<String>? points,
    Value<int>? color,
    Value<DateTime>? createdAt,
  }) {
    return MapStrokesCompanion(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      points: points ?? this.points,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<int>(encounterId.value);
    }
    if (points.present) {
      map['points'] = Variable<String>(points.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapStrokesCompanion(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('points: $points, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MapScenesTable extends MapScenes
    with TableInfo<$MapScenesTable, MapScene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _encounterIdMeta = const VerificationMeta(
    'encounterId',
  );
  @override
  late final GeneratedColumn<int> encounterId = GeneratedColumn<int>(
    'encounter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES encounters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pngMeta = const VerificationMeta('png');
  @override
  late final GeneratedColumn<Uint8List> png = GeneratedColumn<Uint8List>(
    'png',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _narrativeMeta = const VerificationMeta(
    'narrative',
  );
  @override
  late final GeneratedColumn<String> narrative = GeneratedColumn<String>(
    'narrative',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encounterId,
    assetId,
    png,
    mode,
    narrative,
    seed,
    hidden,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'map_scenes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MapScene> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
        _encounterIdMeta,
        encounterId.isAcceptableOrUnknown(
          data['encounter_id']!,
          _encounterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encounterIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('png')) {
      context.handle(
        _pngMeta,
        png.isAcceptableOrUnknown(data['png']!, _pngMeta),
      );
    } else if (isInserting) {
      context.missing(_pngMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('narrative')) {
      context.handle(
        _narrativeMeta,
        narrative.isAcceptableOrUnknown(data['narrative']!, _narrativeMeta),
      );
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MapScene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapScene(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      encounterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encounter_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      png: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}png'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      narrative: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrative'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MapScenesTable createAlias(String alias) {
    return $MapScenesTable(attachedDatabase, alias);
  }
}

class MapScene extends DataClass implements Insertable<MapScene> {
  final int id;
  final int encounterId;

  /// The service's asset id (for reporting).
  final String assetId;
  final Uint8List png;

  /// `map` or `atmosphere`.
  final String mode;
  final String narrative;
  final int seed;

  /// Reported by the user: never shown again.
  final bool hidden;
  final DateTime createdAt;
  const MapScene({
    required this.id,
    required this.encounterId,
    required this.assetId,
    required this.png,
    required this.mode,
    required this.narrative,
    required this.seed,
    required this.hidden,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['encounter_id'] = Variable<int>(encounterId);
    map['asset_id'] = Variable<String>(assetId);
    map['png'] = Variable<Uint8List>(png);
    map['mode'] = Variable<String>(mode);
    map['narrative'] = Variable<String>(narrative);
    map['seed'] = Variable<int>(seed);
    map['hidden'] = Variable<bool>(hidden);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MapScenesCompanion toCompanion(bool nullToAbsent) {
    return MapScenesCompanion(
      id: Value(id),
      encounterId: Value(encounterId),
      assetId: Value(assetId),
      png: Value(png),
      mode: Value(mode),
      narrative: Value(narrative),
      seed: Value(seed),
      hidden: Value(hidden),
      createdAt: Value(createdAt),
    );
  }

  factory MapScene.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapScene(
      id: serializer.fromJson<int>(json['id']),
      encounterId: serializer.fromJson<int>(json['encounterId']),
      assetId: serializer.fromJson<String>(json['assetId']),
      png: serializer.fromJson<Uint8List>(json['png']),
      mode: serializer.fromJson<String>(json['mode']),
      narrative: serializer.fromJson<String>(json['narrative']),
      seed: serializer.fromJson<int>(json['seed']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'encounterId': serializer.toJson<int>(encounterId),
      'assetId': serializer.toJson<String>(assetId),
      'png': serializer.toJson<Uint8List>(png),
      'mode': serializer.toJson<String>(mode),
      'narrative': serializer.toJson<String>(narrative),
      'seed': serializer.toJson<int>(seed),
      'hidden': serializer.toJson<bool>(hidden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MapScene copyWith({
    int? id,
    int? encounterId,
    String? assetId,
    Uint8List? png,
    String? mode,
    String? narrative,
    int? seed,
    bool? hidden,
    DateTime? createdAt,
  }) => MapScene(
    id: id ?? this.id,
    encounterId: encounterId ?? this.encounterId,
    assetId: assetId ?? this.assetId,
    png: png ?? this.png,
    mode: mode ?? this.mode,
    narrative: narrative ?? this.narrative,
    seed: seed ?? this.seed,
    hidden: hidden ?? this.hidden,
    createdAt: createdAt ?? this.createdAt,
  );
  MapScene copyWithCompanion(MapScenesCompanion data) {
    return MapScene(
      id: data.id.present ? data.id.value : this.id,
      encounterId: data.encounterId.present
          ? data.encounterId.value
          : this.encounterId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      png: data.png.present ? data.png.value : this.png,
      mode: data.mode.present ? data.mode.value : this.mode,
      narrative: data.narrative.present ? data.narrative.value : this.narrative,
      seed: data.seed.present ? data.seed.value : this.seed,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapScene(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('assetId: $assetId, ')
          ..write('png: $png, ')
          ..write('mode: $mode, ')
          ..write('narrative: $narrative, ')
          ..write('seed: $seed, ')
          ..write('hidden: $hidden, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    encounterId,
    assetId,
    $driftBlobEquality.hash(png),
    mode,
    narrative,
    seed,
    hidden,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapScene &&
          other.id == this.id &&
          other.encounterId == this.encounterId &&
          other.assetId == this.assetId &&
          $driftBlobEquality.equals(other.png, this.png) &&
          other.mode == this.mode &&
          other.narrative == this.narrative &&
          other.seed == this.seed &&
          other.hidden == this.hidden &&
          other.createdAt == this.createdAt);
}

class MapScenesCompanion extends UpdateCompanion<MapScene> {
  final Value<int> id;
  final Value<int> encounterId;
  final Value<String> assetId;
  final Value<Uint8List> png;
  final Value<String> mode;
  final Value<String> narrative;
  final Value<int> seed;
  final Value<bool> hidden;
  final Value<DateTime> createdAt;
  const MapScenesCompanion({
    this.id = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.png = const Value.absent(),
    this.mode = const Value.absent(),
    this.narrative = const Value.absent(),
    this.seed = const Value.absent(),
    this.hidden = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MapScenesCompanion.insert({
    this.id = const Value.absent(),
    required int encounterId,
    required String assetId,
    required Uint8List png,
    required String mode,
    this.narrative = const Value.absent(),
    required int seed,
    this.hidden = const Value.absent(),
    required DateTime createdAt,
  }) : encounterId = Value(encounterId),
       assetId = Value(assetId),
       png = Value(png),
       mode = Value(mode),
       seed = Value(seed),
       createdAt = Value(createdAt);
  static Insertable<MapScene> custom({
    Expression<int>? id,
    Expression<int>? encounterId,
    Expression<String>? assetId,
    Expression<Uint8List>? png,
    Expression<String>? mode,
    Expression<String>? narrative,
    Expression<int>? seed,
    Expression<bool>? hidden,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterId != null) 'encounter_id': encounterId,
      if (assetId != null) 'asset_id': assetId,
      if (png != null) 'png': png,
      if (mode != null) 'mode': mode,
      if (narrative != null) 'narrative': narrative,
      if (seed != null) 'seed': seed,
      if (hidden != null) 'hidden': hidden,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MapScenesCompanion copyWith({
    Value<int>? id,
    Value<int>? encounterId,
    Value<String>? assetId,
    Value<Uint8List>? png,
    Value<String>? mode,
    Value<String>? narrative,
    Value<int>? seed,
    Value<bool>? hidden,
    Value<DateTime>? createdAt,
  }) {
    return MapScenesCompanion(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      assetId: assetId ?? this.assetId,
      png: png ?? this.png,
      mode: mode ?? this.mode,
      narrative: narrative ?? this.narrative,
      seed: seed ?? this.seed,
      hidden: hidden ?? this.hidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<int>(encounterId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (png.present) {
      map['png'] = Variable<Uint8List>(png.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (narrative.present) {
      map['narrative'] = Variable<String>(narrative.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapScenesCompanion(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('assetId: $assetId, ')
          ..write('png: $png, ')
          ..write('mode: $mode, ')
          ..write('narrative: $narrative, ')
          ..write('seed: $seed, ')
          ..write('hidden: $hidden, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $EncountersTable encounters = $EncountersTable(this);
  late final $CombatantsTable combatants = $CombatantsTable(this);
  late final $MapStrokesTable mapStrokes = $MapStrokesTable(this);
  late final $MapScenesTable mapScenes = $MapScenesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    notes,
    encounters,
    combatants,
    mapStrokes,
    mapScenes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'encounters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('combatants', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'encounters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('map_strokes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'encounters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('map_scenes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> body,
  Value<bool> pinned,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> body,
  Value<bool> pinned,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                title: title,
                body: body,
                pinned: pinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => NotesCompanion.insert(
                id: id,
                title: title,
                body: body,
                pinned: pinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, Note>(table),
                  BaseReferences<_$AppDatabase, $NotesTable, Note>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;
typedef $$EncountersTableCreateCompanionBuilder = EncountersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> round,
  Value<int> turnIndex,
  Value<bool> started,
  Value<bool> active,
  required DateTime createdAt,
});
typedef $$EncountersTableUpdateCompanionBuilder = EncountersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> round,
  Value<int> turnIndex,
  Value<bool> started,
  Value<bool> active,
  Value<DateTime> createdAt,
});

final class $$EncountersTableReferences
    extends BaseReferences<_$AppDatabase, $EncountersTable, Encounter> {
  $$EncountersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CombatantsTable, List<Combatant>>
  _combatantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.combatants,
    aliasName: 'encounters__id__combatants__encounter_id',
  );

  $$CombatantsTableProcessedTableManager get combatantsRefs {
    final manager = $$CombatantsTableTableManager(
      $_db,
      $_db.combatants,
    ).filter((f) => f.encounterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_combatantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MapStrokesTable, List<MapStroke>>
  _mapStrokesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mapStrokes,
    aliasName: 'encounters__id__map_strokes__encounter_id',
  );

  $$MapStrokesTableProcessedTableManager get mapStrokesRefs {
    final manager = $$MapStrokesTableTableManager(
      $_db,
      $_db.mapStrokes,
    ).filter((f) => f.encounterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mapStrokesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MapScenesTable, List<MapScene>>
  _mapScenesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mapScenes,
    aliasName: 'encounters__id__map_scenes__encounter_id',
  );

  $$MapScenesTableProcessedTableManager get mapScenesRefs {
    final manager = $$MapScenesTableTableManager(
      $_db,
      $_db.mapScenes,
    ).filter((f) => f.encounterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mapScenesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EncountersTableFilterComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnIndex => $composableBuilder(
    column: $table.turnIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get started => $composableBuilder(
    column: $table.started,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> combatantsRefs(
    Expression<bool> Function($$CombatantsTableFilterComposer f) f,
  ) {
    final $$CombatantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.combatants,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CombatantsTableFilterComposer(
            $db: $db,
            $table: $db.combatants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mapStrokesRefs(
    Expression<bool> Function($$MapStrokesTableFilterComposer f) f,
  ) {
    final $$MapStrokesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mapStrokes,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MapStrokesTableFilterComposer(
            $db: $db,
            $table: $db.mapStrokes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mapScenesRefs(
    Expression<bool> Function($$MapScenesTableFilterComposer f) f,
  ) {
    final $$MapScenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mapScenes,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MapScenesTableFilterComposer(
            $db: $db,
            $table: $db.mapScenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EncountersTableOrderingComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnIndex => $composableBuilder(
    column: $table.turnIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get started => $composableBuilder(
    column: $table.started,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EncountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<int> get turnIndex =>
      $composableBuilder(column: $table.turnIndex, builder: (column) => column);

  GeneratedColumn<bool> get started =>
      $composableBuilder(column: $table.started, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> combatantsRefs<T extends Object>(
    Expression<T> Function($$CombatantsTableAnnotationComposer a) f,
  ) {
    final $$CombatantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.combatants,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CombatantsTableAnnotationComposer(
            $db: $db,
            $table: $db.combatants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mapStrokesRefs<T extends Object>(
    Expression<T> Function($$MapStrokesTableAnnotationComposer a) f,
  ) {
    final $$MapStrokesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mapStrokes,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MapStrokesTableAnnotationComposer(
            $db: $db,
            $table: $db.mapStrokes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mapScenesRefs<T extends Object>(
    Expression<T> Function($$MapScenesTableAnnotationComposer a) f,
  ) {
    final $$MapScenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mapScenes,
      getReferencedColumn: (t) => t.encounterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MapScenesTableAnnotationComposer(
            $db: $db,
            $table: $db.mapScenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EncountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EncountersTable,
          Encounter,
          $$EncountersTableFilterComposer,
          $$EncountersTableOrderingComposer,
          $$EncountersTableAnnotationComposer,
          $$EncountersTableCreateCompanionBuilder,
          $$EncountersTableUpdateCompanionBuilder,
          (Encounter, $$EncountersTableReferences),
          Encounter,
          PrefetchHooks Function({
            bool combatantsRefs,
            bool mapStrokesRefs,
            bool mapScenesRefs,
          })
        > {
  $$EncountersTableTableManager(_$AppDatabase db, $EncountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<int> turnIndex = const Value.absent(),
                Value<bool> started = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EncountersCompanion(
                id: id,
                name: name,
                round: round,
                turnIndex: turnIndex,
                started: started,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> round = const Value.absent(),
                Value<int> turnIndex = const Value.absent(),
                Value<bool> started = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdAt,
              }) => EncountersCompanion.insert(
                id: id,
                name: name,
                round: round,
                turnIndex: turnIndex,
                started: started,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EncountersTable, Encounter>(table),
                  $$EncountersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                combatantsRefs = false,
                mapStrokesRefs = false,
                mapScenesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (combatantsRefs) db.combatants,
                    if (mapStrokesRefs) db.mapStrokes,
                    if (mapScenesRefs) db.mapScenes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (combatantsRefs)
                        await $_getPrefetchedData<
                          Encounter,
                          $EncountersTable,
                          Combatant
                        >(
                          currentTable: table,
                          referencedTable: $$EncountersTableReferences
                              ._combatantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EncountersTableReferences(
                                db,
                                table,
                                p0,
                              ).combatantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.encounterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mapStrokesRefs)
                        await $_getPrefetchedData<
                          Encounter,
                          $EncountersTable,
                          MapStroke
                        >(
                          currentTable: table,
                          referencedTable: $$EncountersTableReferences
                              ._mapStrokesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EncountersTableReferences(
                                db,
                                table,
                                p0,
                              ).mapStrokesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.encounterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mapScenesRefs)
                        await $_getPrefetchedData<
                          Encounter,
                          $EncountersTable,
                          MapScene
                        >(
                          currentTable: table,
                          referencedTable: $$EncountersTableReferences
                              ._mapScenesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EncountersTableReferences(
                                db,
                                table,
                                p0,
                              ).mapScenesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.encounterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EncountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EncountersTable,
      Encounter,
      $$EncountersTableFilterComposer,
      $$EncountersTableOrderingComposer,
      $$EncountersTableAnnotationComposer,
      $$EncountersTableCreateCompanionBuilder,
      $$EncountersTableUpdateCompanionBuilder,
      (Encounter, $$EncountersTableReferences),
      Encounter,
      PrefetchHooks Function({
        bool combatantsRefs,
        bool mapStrokesRefs,
        bool mapScenesRefs,
      })
    >;
typedef $$CombatantsTableCreateCompanionBuilder = CombatantsCompanion Function({
  Value<int> id,
  required int encounterId,
  required String name,
  Value<int?> initiative,
  Value<int> initBonus,
  Value<int?> hpCurrent,
  Value<int?> hpMax,
  Value<int?> ac,
  Value<bool> isPlayer,
  Value<String> conditions,
  Value<String?> monsterId,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<double?> posX,
  Value<double?> posY,
  Value<int?> level,
});
typedef $$CombatantsTableUpdateCompanionBuilder = CombatantsCompanion Function({
  Value<int> id,
  Value<int> encounterId,
  Value<String> name,
  Value<int?> initiative,
  Value<int> initBonus,
  Value<int?> hpCurrent,
  Value<int?> hpMax,
  Value<int?> ac,
  Value<bool> isPlayer,
  Value<String> conditions,
  Value<String?> monsterId,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<double?> posX,
  Value<double?> posY,
  Value<int?> level,
});

final class $$CombatantsTableReferences
    extends BaseReferences<_$AppDatabase, $CombatantsTable, Combatant> {
  $$CombatantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EncountersTable _encounterIdTable(_$AppDatabase db) =>
      db.encounters.createAlias('combatants__encounter_id__encounters__id');

  $$EncountersTableProcessedTableManager get encounterId {
    final $_column = $_itemColumn<int>('encounter_id')!;

    final manager = $$EncountersTableTableManager(
      $_db,
      $_db.encounters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_encounterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CombatantsTableFilterComposer
    extends Composer<_$AppDatabase, $CombatantsTable> {
  $$CombatantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initiative => $composableBuilder(
    column: $table.initiative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initBonus => $composableBuilder(
    column: $table.initBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hpCurrent => $composableBuilder(
    column: $table.hpCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hpMax => $composableBuilder(
    column: $table.hpMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ac => $composableBuilder(
    column: $table.ac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlayer => $composableBuilder(
    column: $table.isPlayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monsterId => $composableBuilder(
    column: $table.monsterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  $$EncountersTableFilterComposer get encounterId {
    final $$EncountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableFilterComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CombatantsTableOrderingComposer
    extends Composer<_$AppDatabase, $CombatantsTable> {
  $$CombatantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initiative => $composableBuilder(
    column: $table.initiative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initBonus => $composableBuilder(
    column: $table.initBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hpCurrent => $composableBuilder(
    column: $table.hpCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hpMax => $composableBuilder(
    column: $table.hpMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ac => $composableBuilder(
    column: $table.ac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayer => $composableBuilder(
    column: $table.isPlayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monsterId => $composableBuilder(
    column: $table.monsterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get posX => $composableBuilder(
    column: $table.posX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get posY => $composableBuilder(
    column: $table.posY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  $$EncountersTableOrderingComposer get encounterId {
    final $$EncountersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableOrderingComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CombatantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CombatantsTable> {
  $$CombatantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get initiative => $composableBuilder(
    column: $table.initiative,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initBonus =>
      $composableBuilder(column: $table.initBonus, builder: (column) => column);

  GeneratedColumn<int> get hpCurrent =>
      $composableBuilder(column: $table.hpCurrent, builder: (column) => column);

  GeneratedColumn<int> get hpMax =>
      $composableBuilder(column: $table.hpMax, builder: (column) => column);

  GeneratedColumn<int> get ac =>
      $composableBuilder(column: $table.ac, builder: (column) => column);

  GeneratedColumn<bool> get isPlayer =>
      $composableBuilder(column: $table.isPlayer, builder: (column) => column);

  GeneratedColumn<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monsterId =>
      $composableBuilder(column: $table.monsterId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<double> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  $$EncountersTableAnnotationComposer get encounterId {
    final $$EncountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableAnnotationComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CombatantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CombatantsTable,
          Combatant,
          $$CombatantsTableFilterComposer,
          $$CombatantsTableOrderingComposer,
          $$CombatantsTableAnnotationComposer,
          $$CombatantsTableCreateCompanionBuilder,
          $$CombatantsTableUpdateCompanionBuilder,
          (Combatant, $$CombatantsTableReferences),
          Combatant,
          PrefetchHooks Function({bool encounterId})
        > {
  $$CombatantsTableTableManager(_$AppDatabase db, $CombatantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CombatantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CombatantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CombatantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> encounterId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> initiative = const Value.absent(),
                Value<int> initBonus = const Value.absent(),
                Value<int?> hpCurrent = const Value.absent(),
                Value<int?> hpMax = const Value.absent(),
                Value<int?> ac = const Value.absent(),
                Value<bool> isPlayer = const Value.absent(),
                Value<String> conditions = const Value.absent(),
                Value<String?> monsterId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double?> posX = const Value.absent(),
                Value<double?> posY = const Value.absent(),
                Value<int?> level = const Value.absent(),
              }) => CombatantsCompanion(
                id: id,
                encounterId: encounterId,
                name: name,
                initiative: initiative,
                initBonus: initBonus,
                hpCurrent: hpCurrent,
                hpMax: hpMax,
                ac: ac,
                isPlayer: isPlayer,
                conditions: conditions,
                monsterId: monsterId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                posX: posX,
                posY: posY,
                level: level,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int encounterId,
                required String name,
                Value<int?> initiative = const Value.absent(),
                Value<int> initBonus = const Value.absent(),
                Value<int?> hpCurrent = const Value.absent(),
                Value<int?> hpMax = const Value.absent(),
                Value<int?> ac = const Value.absent(),
                Value<bool> isPlayer = const Value.absent(),
                Value<String> conditions = const Value.absent(),
                Value<String?> monsterId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<double?> posX = const Value.absent(),
                Value<double?> posY = const Value.absent(),
                Value<int?> level = const Value.absent(),
              }) => CombatantsCompanion.insert(
                id: id,
                encounterId: encounterId,
                name: name,
                initiative: initiative,
                initBonus: initBonus,
                hpCurrent: hpCurrent,
                hpMax: hpMax,
                ac: ac,
                isPlayer: isPlayer,
                conditions: conditions,
                monsterId: monsterId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                posX: posX,
                posY: posY,
                level: level,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CombatantsTable, Combatant>(table),
                  $$CombatantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({encounterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (encounterId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.encounterId,
                        referencedTable: $$CombatantsTableReferences
                            ._encounterIdTable(db),
                        referencedColumn: $$CombatantsTableReferences
                            ._encounterIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CombatantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CombatantsTable,
      Combatant,
      $$CombatantsTableFilterComposer,
      $$CombatantsTableOrderingComposer,
      $$CombatantsTableAnnotationComposer,
      $$CombatantsTableCreateCompanionBuilder,
      $$CombatantsTableUpdateCompanionBuilder,
      (Combatant, $$CombatantsTableReferences),
      Combatant,
      PrefetchHooks Function({bool encounterId})
    >;
typedef $$MapStrokesTableCreateCompanionBuilder = MapStrokesCompanion Function({
  Value<int> id,
  required int encounterId,
  required String points,
  Value<int> color,
  required DateTime createdAt,
});
typedef $$MapStrokesTableUpdateCompanionBuilder = MapStrokesCompanion Function({
  Value<int> id,
  Value<int> encounterId,
  Value<String> points,
  Value<int> color,
  Value<DateTime> createdAt,
});

final class $$MapStrokesTableReferences
    extends BaseReferences<_$AppDatabase, $MapStrokesTable, MapStroke> {
  $$MapStrokesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EncountersTable _encounterIdTable(_$AppDatabase db) =>
      db.encounters.createAlias('map_strokes__encounter_id__encounters__id');

  $$EncountersTableProcessedTableManager get encounterId {
    final $_column = $_itemColumn<int>('encounter_id')!;

    final manager = $$EncountersTableTableManager(
      $_db,
      $_db.encounters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_encounterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MapStrokesTableFilterComposer
    extends Composer<_$AppDatabase, $MapStrokesTable> {
  $$MapStrokesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EncountersTableFilterComposer get encounterId {
    final $$EncountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableFilterComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MapStrokesTableOrderingComposer
    extends Composer<_$AppDatabase, $MapStrokesTable> {
  $$MapStrokesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EncountersTableOrderingComposer get encounterId {
    final $$EncountersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableOrderingComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MapStrokesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapStrokesTable> {
  $$MapStrokesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EncountersTableAnnotationComposer get encounterId {
    final $$EncountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableAnnotationComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MapStrokesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MapStrokesTable,
          MapStroke,
          $$MapStrokesTableFilterComposer,
          $$MapStrokesTableOrderingComposer,
          $$MapStrokesTableAnnotationComposer,
          $$MapStrokesTableCreateCompanionBuilder,
          $$MapStrokesTableUpdateCompanionBuilder,
          (MapStroke, $$MapStrokesTableReferences),
          MapStroke,
          PrefetchHooks Function({bool encounterId})
        > {
  $$MapStrokesTableTableManager(_$AppDatabase db, $MapStrokesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MapStrokesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MapStrokesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MapStrokesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> encounterId = const Value.absent(),
                Value<String> points = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MapStrokesCompanion(
                id: id,
                encounterId: encounterId,
                points: points,
                color: color,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int encounterId,
                required String points,
                Value<int> color = const Value.absent(),
                required DateTime createdAt,
              }) => MapStrokesCompanion.insert(
                id: id,
                encounterId: encounterId,
                points: points,
                color: color,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MapStrokesTable, MapStroke>(table),
                  $$MapStrokesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({encounterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (encounterId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.encounterId,
                        referencedTable: $$MapStrokesTableReferences
                            ._encounterIdTable(db),
                        referencedColumn: $$MapStrokesTableReferences
                            ._encounterIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MapStrokesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MapStrokesTable,
      MapStroke,
      $$MapStrokesTableFilterComposer,
      $$MapStrokesTableOrderingComposer,
      $$MapStrokesTableAnnotationComposer,
      $$MapStrokesTableCreateCompanionBuilder,
      $$MapStrokesTableUpdateCompanionBuilder,
      (MapStroke, $$MapStrokesTableReferences),
      MapStroke,
      PrefetchHooks Function({bool encounterId})
    >;
typedef $$MapScenesTableCreateCompanionBuilder = MapScenesCompanion Function({
  Value<int> id,
  required int encounterId,
  required String assetId,
  required Uint8List png,
  required String mode,
  Value<String> narrative,
  required int seed,
  Value<bool> hidden,
  required DateTime createdAt,
});
typedef $$MapScenesTableUpdateCompanionBuilder = MapScenesCompanion Function({
  Value<int> id,
  Value<int> encounterId,
  Value<String> assetId,
  Value<Uint8List> png,
  Value<String> mode,
  Value<String> narrative,
  Value<int> seed,
  Value<bool> hidden,
  Value<DateTime> createdAt,
});

final class $$MapScenesTableReferences
    extends BaseReferences<_$AppDatabase, $MapScenesTable, MapScene> {
  $$MapScenesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EncountersTable _encounterIdTable(_$AppDatabase db) =>
      db.encounters.createAlias('map_scenes__encounter_id__encounters__id');

  $$EncountersTableProcessedTableManager get encounterId {
    final $_column = $_itemColumn<int>('encounter_id')!;

    final manager = $$EncountersTableTableManager(
      $_db,
      $_db.encounters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_encounterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MapScenesTableFilterComposer
    extends Composer<_$AppDatabase, $MapScenesTable> {
  $$MapScenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get png => $composableBuilder(
    column: $table.png,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrative => $composableBuilder(
    column: $table.narrative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EncountersTableFilterComposer get encounterId {
    final $$EncountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableFilterComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MapScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $MapScenesTable> {
  $$MapScenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get png => $composableBuilder(
    column: $table.png,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrative => $composableBuilder(
    column: $table.narrative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EncountersTableOrderingComposer get encounterId {
    final $$EncountersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableOrderingComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MapScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapScenesTable> {
  $$MapScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<Uint8List> get png =>
      $composableBuilder(column: $table.png, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get narrative =>
      $composableBuilder(column: $table.narrative, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EncountersTableAnnotationComposer get encounterId {
    final $$EncountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.encounterId,
      referencedTable: $db.encounters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EncountersTableAnnotationComposer(
            $db: $db,
            $table: $db.encounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MapScenesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MapScenesTable,
          MapScene,
          $$MapScenesTableFilterComposer,
          $$MapScenesTableOrderingComposer,
          $$MapScenesTableAnnotationComposer,
          $$MapScenesTableCreateCompanionBuilder,
          $$MapScenesTableUpdateCompanionBuilder,
          (MapScene, $$MapScenesTableReferences),
          MapScene,
          PrefetchHooks Function({bool encounterId})
        > {
  $$MapScenesTableTableManager(_$AppDatabase db, $MapScenesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MapScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MapScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MapScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> encounterId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<Uint8List> png = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> narrative = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MapScenesCompanion(
                id: id,
                encounterId: encounterId,
                assetId: assetId,
                png: png,
                mode: mode,
                narrative: narrative,
                seed: seed,
                hidden: hidden,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int encounterId,
                required String assetId,
                required Uint8List png,
                required String mode,
                Value<String> narrative = const Value.absent(),
                required int seed,
                Value<bool> hidden = const Value.absent(),
                required DateTime createdAt,
              }) => MapScenesCompanion.insert(
                id: id,
                encounterId: encounterId,
                assetId: assetId,
                png: png,
                mode: mode,
                narrative: narrative,
                seed: seed,
                hidden: hidden,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MapScenesTable, MapScene>(table),
                  $$MapScenesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({encounterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (encounterId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.encounterId,
                        referencedTable: $$MapScenesTableReferences
                            ._encounterIdTable(db),
                        referencedColumn: $$MapScenesTableReferences
                            ._encounterIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MapScenesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MapScenesTable,
      MapScene,
      $$MapScenesTableFilterComposer,
      $$MapScenesTableOrderingComposer,
      $$MapScenesTableAnnotationComposer,
      $$MapScenesTableCreateCompanionBuilder,
      $$MapScenesTableUpdateCompanionBuilder,
      (MapScene, $$MapScenesTableReferences),
      MapScene,
      PrefetchHooks Function({bool encounterId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db, _db.encounters);
  $$CombatantsTableTableManager get combatants =>
      $$CombatantsTableTableManager(_db, _db.combatants);
  $$MapStrokesTableTableManager get mapStrokes =>
      $$MapStrokesTableTableManager(_db, _db.mapStrokes);
  $$MapScenesTableTableManager get mapScenes =>
      $$MapScenesTableTableManager(_db, _db.mapScenes);
}
