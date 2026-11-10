import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/encounter_difficulty.dart';

import '../support.dart';

var _nextId = 1;

Combatant _c(
  String name, {
  bool player = false,
  int? level,
  String? monsterId,
}) => Combatant(
  id: _nextId++,
  encounterId: 1,
  name: name,
  initBonus: 0,
  isPlayer: player,
  conditions: '',
  sortOrder: 0,
  createdAt: DateTime(2026),
  monsterId: monsterId,
  level: level,
);

void main() {
  group('XP budget table', () {
    test('has all 20 levels and grows with level and difficulty', () {
      expect(xpBudgetPerCharacter.keys, List.generate(20, (i) => i + 1));
      for (var l = 1; l <= 20; l++) {
        final low = budgetPerCharacter(l, Difficulty.low);
        final mod = budgetPerCharacter(l, Difficulty.moderate);
        final high = budgetPerCharacter(l, Difficulty.high);
        expect(low < mod && mod < high, isTrue, reason: 'level $l');
        if (l > 1) {
          for (final d in Difficulty.values) {
            expect(
              budgetPerCharacter(l, d),
              greaterThan(budgetPerCharacter(l - 1, d)),
            );
          }
        }
      }
    });

    test('spot checks against the SRD table', () {
      expect(xpBudgetPerCharacter[1], (50, 75, 100));
      expect(xpBudgetPerCharacter[3], (150, 225, 400));
      expect(xpBudgetPerCharacter[5], (500, 750, 1100));
      expect(xpBudgetPerCharacter[15], (3300, 5400, 7800));
      expect(xpBudgetPerCharacter[20], (6400, 13200, 22000));
    });

    test('levels outside 1–20 are clamped', () {
      expect(budgetPerCharacter(0, Difficulty.low), 50);
      expect(budgetPerCharacter(25, Difficulty.high), 22000);
    });
  });

  group('budgetFor', () {
    test('SRD examples', () {
      expect(budgetFor([1, 1, 1, 1], Difficulty.low), 200);
      expect(budgetFor(List.filled(5, 3), Difficulty.moderate), 1125);
      expect(budgetFor(List.filled(6, 15), Difficulty.high), 46800);
    });

    test('mixed levels sum each character’s row', () {
      expect(budgetFor([1, 3, 5], Difficulty.moderate), 75 + 225 + 750);
      expect(budgetFor([2, 2, 4, 4], Difficulty.low), 100 + 100 + 250 + 250);
      expect(budgetFor(const [], Difficulty.high), 0);
    });
  });

  group('parseXp', () {
    test('reads the first number', () {
      expect(parseXp('1,100'), 1100);
      expect(parseXp('10'), 10);
      expect(parseXp('0'), 0);
      expect(parseXp('450'), 450);
      expect(parseXp('5,900, or 7,200 in lair'), 5900);
      expect(parseXp('155,000'), 155000);
      expect(parseXp('10000'), 10000);
    });

    test('no number, no XP', () {
      expect(parseXp(null), isNull);
      expect(parseXp(''), isNull);
      expect(parseXp('—'), isNull);
    });

    test('a malformed first number is rejected, not guessed', () {
      expect(parseXp('1,1000'), isNull);
      expect(parseXp('1,10'), isNull);
      expect(parseXp('1,100,'), 1100);
      expect(parseXp('XP 1,100 (lair 1,400)'), 1100);
    });

    test('monsterXp falls back to the challenge rating', () {
      expect(monsterXp({'cr': '1', 'xp': '200'}), 200);
      expect(monsterXp({'cr': '3', 'xp': null}), 700);
      expect(monsterXp({'cr': '1/4'}), 50);
      expect(monsterXp({'cr': '?'}), isNull);
    });

    test('monsterXp never throws on odd value types', () {
      expect(monsterXp({'cr': 2, 'xp': 450}), 450);
      expect(monsterXp({'cr': '1', 'xp': true}), 200);
      expect(
        monsterXp({
          'cr': '1/2',
          'xp': const ['x'],
        }),
        100,
      );
      expect(
        monsterXp({
          'cr': null,
          'xp': const {'a': 1},
        }),
        1,
      );
    });

    test('every monster in the assets has an XP; Bugbear Warrior is 200', () {
      final data = loadReference();
      final monsters = data.byDataset['monsters']!;
      expect(monsters, isNotEmpty);
      for (final m in monsters) {
        expect(monsterXp(m.en), isNotNull, reason: m.id);
      }
      expect(monsterXp(data.find('monsters', 'bugbear-warrior')!.en), 200);
      expect(
        monsterXp(data.find('monsters', 'adult-red-dragon')!.en),
        18000,
        reason: 'the normal XP, not the lair value',
      );
    });
  });

  group('rate', () {
    const party = [1, 1, 1, 1]; // Low 200, Moderate 300, High 400

    test('SRD example: one Bugbear Warrior (200 XP) is Low for four level-1 '
        'characters', () {
      final r = rate(200, party);
      expect(r.band, DifficultyBand.low);
      expect((r.low, r.moderate, r.high), (200, 300, 400));
      expect(r.shownBudget, 200);
    });

    test('each budget is the ceiling of its band', () {
      expect(rate(0, party).band, DifficultyBand.belowLow);
      expect(rate(99, party).band, DifficultyBand.belowLow);
      expect(rate(100, party).band, DifficultyBand.low);
      expect(rate(201, party).band, DifficultyBand.moderate);
      expect(rate(300, party).band, DifficultyBand.moderate);
      expect(rate(301, party).band, DifficultyBand.high);
      expect(rate(400, party).band, DifficultyBand.high);
      expect(rate(401, party).band, DifficultyBand.aboveHigh);
      expect(rate(401, party).shownBudget, 400);
      expect(rate(50, party).shownBudget, 200);
      expect(rate(250, party).shownBudget, 300);
    });

    test('SRD examples at their budgets', () {
      expect(rate(1125, List.filled(5, 3)).band, DifficultyBand.moderate);
      expect(rate(46800, List.filled(6, 15)).band, DifficultyBand.high);
      expect(rate(46801, List.filled(6, 15)).band, DifficultyBand.aboveHigh);
    });

    test('mixed levels', () {
      // Levels 1, 3, 5: Low 700, Moderate 1,050, High 1,600.
      final r = rate(1050, [1, 3, 5]);
      expect((r.low, r.moderate, r.high), (700, 1050, 1600));
      expect(r.band, DifficultyBand.moderate);
      expect(rate(1051, [1, 3, 5]).band, DifficultyBand.high);
    });

    test('only the outer bands are outside the table', () {
      expect(DifficultyBand.values.where((b) => b.outsideTable), [
        DifficultyBand.belowLow,
        DifficultyBand.aboveHigh,
      ]);
    });
  });

  test('groupDigits uses Turkish thousands dots', () {
    expect(groupDigits(0), '0');
    expect(groupDigits(999), '999');
    expect(groupDigits(1050), '1.050');
    expect(groupDigits(46800), '46.800');
    expect(groupDigits(1000000), '1.000.000');
  });

  group('summarizeEncounter', () {
    int? xpOf(String id) => const {'goblin': 50, 'bugbear': 200}[id];

    test('players are the party; monsters with XP are counted', () {
      final s = summarizeEncounter(
        [
          _c('Ayla', player: true, level: 3),
          _c('Bora', player: true),
          _c('Goblin 1', monsterId: 'goblin'),
          _c('Goblin 2', monsterId: 'goblin'),
          _c('Haydut'),
          _c('Eski kayıt', monsterId: 'gone'),
        ],
        xpOf,
        partyLevel: 2,
      );
      expect(s.levels, [3, 2], reason: 'Bora uses the party level');
      expect(s.players.map((p) => p.name), ['Ayla', 'Bora']);
      expect(s.xp, 100, reason: 'each creature counts');
      expect(s.unknown.map((c) => c.name), ['Haydut', 'Eski kayıt']);
      expect(s.hasRating, isTrue);
      expect(s.rating.low, 150 + 100);
    });

    test('no players: party size × party level', () {
      final s = summarizeEncounter(
        [_c('Bugbear', monsterId: 'bugbear')],
        xpOf,
        partyLevel: 1,
        partySize: 4,
      );
      expect(s.levels, [1, 1, 1, 1]);
      expect(s.players, isEmpty);
      expect(s.rating.band, DifficultyBand.low);
    });

    test('no rating without a monster with known XP', () {
      final s = summarizeEncounter([
        _c('Ayla', player: true),
        _c('Haydut'),
      ], xpOf);
      expect(s.hasRating, isFalse);
    });
  });
}
