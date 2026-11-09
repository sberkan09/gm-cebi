/// Encounter difficulty from the SRD 5.2.1 rules ("Combat Encounters",
/// p. 202, CC-BY-4.0): an XP budget per character for the party's level and
/// the chosen difficulty, summed over the characters, against the summed XP of
/// every monster. The 2024 rules have no multipliers.
///
/// The SRD names three difficulties (Low, Moderate, High) and each budget is
/// what an encounter of that difficulty may spend. The app adds two bands
/// outside the table: "Düşük altı" (less than half the Low budget) and
/// "Yüksek üstü" (more than the High budget). See docs/decisions.md.
library;

import '../db/database.dart';

/// The SRD's three difficulties.
enum Difficulty {
  low('Düşük'),
  moderate('Orta'),
  high('Yüksek');

  const Difficulty(this.label);
  final String label;
}

/// Where an encounter falls: the SRD's three difficulties plus the two bands
/// outside the table.
enum DifficultyBand {
  belowLow(
    'Düşük altı',
    'Tablonun altında: grup büyük olasılıkla zorlanmadan kazanır.',
  ),
  low(
    'Düşük',
    'Bir iki korkulu an olabilir ama karakterler kayıpsız kazanmalı; '
        'biri iyileşme harcayabilir.',
  ),
  moderate(
    'Orta',
    'İyileşme ve kaynaklar olmadan kötü gidebilir; zayıf karakterler '
        'düşebilir, küçük bir ölüm ihtimali var.',
  ),
  high(
    'Yüksek',
    'Bir ya da daha fazla karakter için ölümcül olabilir; akıllı taktik, '
        'hızlı düşünme ve biraz şans gerekir.',
  ),
  aboveHigh(
    'Yüksek üstü',
    'Tablonun üstünde: Yüksek bütçeyi aşıyor, grup için ölümcül olabilir.',
  );

  const DifficultyBand(this.label, this.guidance);
  final String label;

  /// One short sentence after the SRD's description of the difficulty.
  final String guidance;

  /// Outside the SRD table (an app convention, not a rule).
  bool get outsideTable => this == belowLow || this == aboveHigh;
}

const minLevel = 1;
const maxLevel = 20;

/// "XP Budget per Character": level → Low, Moderate, High.
const xpBudgetPerCharacter = <int, (int, int, int)>{
  1: (50, 75, 100),
  2: (100, 150, 200),
  3: (150, 225, 400),
  4: (250, 375, 500),
  5: (500, 750, 1100),
  6: (600, 1000, 1400),
  7: (750, 1300, 1700),
  8: (1000, 1700, 2100),
  9: (1300, 2000, 2600),
  10: (1600, 2300, 3100),
  11: (1900, 2900, 4100),
  12: (2200, 3700, 4700),
  13: (2600, 4200, 5400),
  14: (2900, 4900, 6200),
  15: (3300, 5400, 7800),
  16: (3800, 6100, 9800),
  17: (4500, 7200, 11700),
  18: (5000, 8700, 14200),
  19: (5500, 10700, 17200),
  20: (6400, 13200, 22000),
};

int clampLevel(int level) => level.clamp(minLevel, maxLevel);

/// One character's budget; levels outside 1–20 are clamped.
int budgetPerCharacter(int level, Difficulty d) {
  final row = xpBudgetPerCharacter[clampLevel(level)]!;
  return switch (d) {
    Difficulty.low => row.$1,
    Difficulty.moderate => row.$2,
    Difficulty.high => row.$3,
  };
}

/// The party's budget: the sum of every character's budget, so a party of
/// mixed levels works too.
int budgetFor(Iterable<int> levels, Difficulty d) =>
    levels.fold(0, (sum, l) => sum + budgetPerCharacter(l, d));

final _xpNumber = RegExp(r'\d{1,3}(?:,\d{3})+|\d+');

/// The first number of a monster's XP text: "1,100" → 1100,
/// "5,900, or 7,200 in lair" → 5900 (the normal value, not the lair one).
int? parseXp(String? s) {
  if (s == null) return null;
  final m = _xpNumber.firstMatch(s);
  return m == null ? null : int.parse(m.group(0)!.replaceAll(',', ''));
}

// dart format off
/// XP by challenge rating, for the few records whose XP text is missing.
/// CR 0 is 0 (the SRD gives "0 or 10"; the record says which).
const xpByCr = <String, int>{
  '0': 0, '1/8': 25, '1/4': 50, '1/2': 100, '1': 200, '2': 450, '3': 700,
  '4': 1100, '5': 1800, '6': 2300, '7': 2900, '8': 3900, '9': 5000,
  '10': 5900, '11': 7200, '12': 8400, '13': 10000, '14': 11500, '15': 13000,
  '16': 15000, '17': 18000, '18': 20000, '19': 22000, '20': 25000,
  '21': 33000, '22': 41000, '23': 50000, '24': 62000, '25': 75000,
  '26': 90000, '27': 105000, '28': 120000, '29': 135000, '30': 155000,
};
// dart format on

/// XP of a monster record's English content (language independent).
int? monsterXp(Map<String, dynamic> en) =>
    parseXp(en['xp'] as String?) ?? xpByCr[en['cr']?.toString().trim()];

class DifficultyRating {
  const DifficultyRating({
    required this.xp,
    required this.low,
    required this.moderate,
    required this.high,
    required this.band,
  });

  final int xp;
  final int low;
  final int moderate;
  final int high;
  final DifficultyBand band;

  int budget(Difficulty d) => switch (d) {
    Difficulty.low => low,
    Difficulty.moderate => moderate,
    Difficulty.high => high,
  };

  /// The budget shown next to the encounter XP: the ceiling of the band
  /// (Low below the table, High above it).
  int get shownBudget => switch (band) {
    DifficultyBand.belowLow || DifficultyBand.low => low,
    DifficultyBand.moderate => moderate,
    DifficultyBand.high || DifficultyBand.aboveHigh => high,
  };
}

/// Rates [encounterXp] for a party with these character [levels]. A budget is
/// the most an encounter of that difficulty spends: up to Low is Low, up to
/// Moderate is Moderate, up to High is High, above it is beyond the table.
/// Less than half the Low budget is below the table.
DifficultyRating rate(int encounterXp, Iterable<int> levels) {
  final low = budgetFor(levels, Difficulty.low);
  final moderate = budgetFor(levels, Difficulty.moderate);
  final high = budgetFor(levels, Difficulty.high);
  final band = encounterXp > high
      ? DifficultyBand.aboveHigh
      : encounterXp > moderate
      ? DifficultyBand.high
      : encounterXp > low
      ? DifficultyBand.moderate
      : encounterXp * 2 >= low
      ? DifficultyBand.low
      : DifficultyBand.belowLow;
  return DifficultyRating(
    xp: encounterXp,
    low: low,
    moderate: moderate,
    high: high,
    band: band,
  );
}

/// Thousands with a dot, as in Turkish: 1050 → "1.050".
String groupDigits(int n) {
  final s = n.abs().toString();
  final out = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write('.');
    out.write(s[i]);
  }
  return out.toString();
}

/// The active encounter seen as a difficulty question.
class EncounterSummary {
  const EncounterSummary({
    required this.levels,
    required this.players,
    required this.monsters,
    required this.unknown,
  });

  /// One level per character.
  final List<int> levels;

  /// The player combatants that make up the party; empty when the party comes
  /// from the party size setting.
  final List<Combatant> players;

  /// Non-player combatants with their XP.
  final List<(Combatant, int)> monsters;

  /// Non-player combatants without an XP (added by hand, or an unknown
  /// monster id): left out of the total.
  final List<Combatant> unknown;

  int get xp => monsters.fold(0, (sum, m) => sum + m.$2);

  /// False until at least one monster has a known XP.
  bool get hasRating => monsters.isNotEmpty;

  DifficultyRating get rating => rate(xp, levels);
}

/// Splits [combatants] into the party and the monsters. Players are the party
/// (a player without a level uses [partyLevel]); with no players the party is
/// [partySize] characters of [partyLevel]. [xpOf] finds a monster's XP by id.
EncounterSummary summarizeEncounter(
  Iterable<Combatant> combatants,
  int? Function(String monsterId) xpOf, {
  int partyLevel = 1,
  int partySize = 4,
}) {
  final players = <Combatant>[];
  final monsters = <(Combatant, int)>[];
  final unknown = <Combatant>[];
  for (final c in combatants) {
    if (c.isPlayer) {
      players.add(c);
      continue;
    }
    final xp = c.monsterId == null ? null : xpOf(c.monsterId!);
    xp == null ? unknown.add(c) : monsters.add((c, xp));
  }
  final levels = players.isEmpty
      ? List.filled(partySize < 1 ? 1 : partySize, clampLevel(partyLevel))
      : [for (final p in players) clampLevel(p.level ?? partyLevel)];
  return EncounterSummary(
    levels: levels,
    players: players,
    monsters: monsters,
    unknown: unknown,
  );
}
