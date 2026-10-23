import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/dice.dart';
import 'data/reference.dart';
import 'data/search.dart';
import 'db/database.dart';
import 'features/flags.dart';

// ---------------------------------------------------------------- database

/// Overridden in tests with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ---------------------------------------------------------------- reference

class Reference {
  const Reference(this.data, this.index);

  final ReferenceData data;
  final SearchIndex index;
}

/// Loads every asset and builds the search index off the UI thread.
Future<Reference> loadReferenceFromAssets(AssetBundle bundle) async {
  final files = <String, String>{};
  for (final name in [...assetDatasets, 'glossary', 'manifest']) {
    files[name] = await bundle.loadString('assets/data/$name.json', cache: false);
  }
  return Isolate.run(() {
    final data = ReferenceData.parse(files);
    return Reference(data, SearchIndex.build(data));
  });
}

final referenceProvider = FutureProvider<Reference>((ref) => loadReferenceFromAssets(rootBundle));

// ---------------------------------------------------------------- settings

class AppSettings {
  const AppSettings({this.contentLang = Lang.tr, this.themeMode = ThemeMode.dark, this.gmPackOverride});

  /// Default language of detail pages (each page has a one-tap toggle).
  final Lang contentLang;

  /// Dark by default: the app is used at the table.
  final ThemeMode themeMode;

  /// Internal builds only: test switch for the GM pack entitlement.
  final bool? gmPackOverride;

  AppSettings copyWith({Lang? contentLang, ThemeMode? themeMode, bool? gmPackOverride, bool clearOverride = false}) =>
      AppSettings(
        contentLang: contentLang ?? this.contentLang,
        themeMode: themeMode ?? this.themeMode,
        gmPackOverride: clearOverride ? null : (gmPackOverride ?? this.gmPackOverride),
      );
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  Future<AppSettings> build() async {
    final m = await _db.readSettings();
    return AppSettings(
      contentLang: m['contentLang'] == 'en' ? Lang.en : Lang.tr,
      themeMode: switch (m['themeMode']) { 'light' => ThemeMode.light, 'system' => ThemeMode.system, _ => ThemeMode.dark },
      gmPackOverride: switch (m['gmPackOverride']) { 'true' => true, 'false' => false, _ => null },
    );
  }

  AppSettings get _current => state.value ?? const AppSettings();

  Future<void> setContentLang(Lang l) async {
    state = AsyncData(_current.copyWith(contentLang: l));
    await _db.writeSetting('contentLang', l.name);
  }

  Future<void> setThemeMode(ThemeMode m) async {
    state = AsyncData(_current.copyWith(themeMode: m));
    await _db.writeSetting('themeMode', m.name);
  }

  Future<void> setGmPackOverride(bool? v) async {
    state = AsyncData(_current.copyWith(gmPackOverride: v, clearOverride: v == null));
    await _db.writeSetting('gmPackOverride', v?.toString());
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Current settings, defaults while loading.
final currentSettingsProvider = Provider<AppSettings>((ref) => ref.watch(settingsProvider).value ?? const AppSettings());

final entitlementsProvider = Provider<Entitlements>((ref) {
  final s = ref.watch(currentSettingsProvider);
  return Entitlements(gmPack: s.gmPackOverride ?? kGmPackDefault);
});

// ---------------------------------------------------------------- user data

final notesProvider = StreamProvider<List<Note>>((ref) => ref.watch(databaseProvider).watchNotes());

final encounterProvider =
    StreamProvider<EncounterState>((ref) => ref.watch(databaseProvider).watchEncounterState());

// ---------------------------------------------------------------- dice

class DiceHistory extends Notifier<List<RollResult>> {
  static const maxEntries = 30;

  @override
  List<RollResult> build() => const [];

  void add(RollResult r) {
    final next = [r, ...state];
    state = next.length > maxEntries ? next.sublist(0, maxEntries) : next;
  }

  void clear() => state = const [];
}

final diceHistoryProvider = NotifierProvider<DiceHistory, List<RollResult>>(DiceHistory.new);
