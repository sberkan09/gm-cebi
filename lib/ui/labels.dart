/// Labels inside reference content, in the language the content is shown in.
/// (UI chrome is always Turkish.)
library;

import '../core/turkish.dart';
import '../data/reference.dart';

class ContentLabels {
  const ContentLabels._(this.lang);

  factory ContentLabels.of(Lang lang) => lang == Lang.tr ? tr : en;

  static const tr = ContentLabels._(Lang.tr);
  static const en = ContentLabels._(Lang.en);

  final Lang lang;
  bool get _t => lang == Lang.tr;

  // Spells
  String get castingTime => _t ? 'Yapma Süresi' : 'Casting Time';
  String get range => _t ? 'Menzil' : 'Range';
  String get components => _t ? 'Bileşenler' : 'Components';
  String get duration => _t ? 'Süre' : 'Duration';
  String get ritual => _t ? 'Ritüel' : 'Ritual';
  String get concentration => _t ? 'Konsantrasyon' : 'Concentration';
  String get higherLevels => _t ? 'Daha Yüksek Seviyeli Büyü Slotu Kullanma.' : 'Using a Higher-Level Spell Slot.';
  String get cantripUpgrade => _t ? 'Cantrip Gelişimi.' : 'Cantrip Upgrade.';

  /// "2. Seviye Oluşturma (Sihirbaz)" / "Level 2 Evocation (Wizard)".
  String spellLevelLine(int level, String school, List<String> classes) {
    final head = _t
        ? (level == 0 ? possessive3('$school Cantrip', apostrophe: true) : '$level. Seviye $school')
        : (level == 0 ? '$school Cantrip' : 'Level $level $school');
    return classes.isEmpty ? head : '$head (${classes.join(', ')})';
  }

  /// Verbal/Somatic/Material letters: S/B/M in Turkish, V/S/M in English.
  String componentLetters({required bool v, required bool s, required bool m}) => [
        if (v) _t ? 'S' : 'V',
        if (s) _t ? 'B' : 'S',
        if (m) 'M',
      ].join(', ');

  // Monsters
  String get ac => _t ? 'ZS' : 'AC';
  String get initiative => _t ? 'İnisiyatif' : 'Initiative';
  String get hp => _t ? 'CP' : 'HP';
  String get speed => _t ? 'Hız' : 'Speed';
  String get cr => _t ? 'TD' : 'CR';
  String get xp => _t ? 'TP' : 'XP';
  String get pb => _t ? 'YB' : 'PB';
  String get mod => _t ? 'DEĞ' : 'MOD';
  String get save => _t ? 'KZ' : 'SAVE';
  List<String> get abilityAbbr => _t ? ['Güç', 'Çev', 'Day', 'Zek', 'Bil', 'Kar'] : ['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'];

  Map<String, String> get monsterSections => _t
      ? {
          'traits': 'Özellikler',
          'actions': 'Eylemler',
          'bonus_actions': 'Bonus Eylemler',
          'reactions': 'Reaksiyonlar',
          'legendary_actions': 'Efsanevi Eylemler',
        }
      : {
          'traits': 'Traits',
          'actions': 'Actions',
          'bonus_actions': 'Bonus Actions',
          'reactions': 'Reactions',
          'legendary_actions': 'Legendary Actions',
        };

  // Classes, origins, feats
  String get features => _t ? 'Sınıf Özellikleri' : 'Class Features';
  String get subclassFeatures => _t ? 'Alt Sınıf Özellikleri' : 'Subclass Features';
  String get subclasses => _t ? 'Alt Sınıflar' : 'Subclasses';
  String level(int n) => _t ? '$n. Seviye' : 'Level $n';
  String get creatureType => _t ? 'Yaratık Türü' : 'Creature Type';
  String get size => _t ? 'Boyut' : 'Size';
  String get prerequisite => _t ? 'Ön koşul' : 'Prerequisite';
  String get abilityScores => _t ? 'Yetenek Puanları' : 'Ability Scores';
  String get feat => _t ? 'Hüner' : 'Feat';
  String get skillProficiencies => _t ? 'Beceri Yetkinlikleri' : 'Skill Proficiencies';
  String get toolProficiency => _t ? 'Alet Yetkinliği' : 'Tool Proficiency';
  String get equipment => _t ? 'Ekipman' : 'Equipment';
  String get seeAlso => _t ? 'Ayrıca bkz.' : 'See also';
}
