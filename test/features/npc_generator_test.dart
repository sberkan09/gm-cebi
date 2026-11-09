import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/core/turkish.dart';
import 'package:gm_cebi/features/npc/npc_generator.dart';
import 'package:gm_cebi/features/npc/npc_tables.dart';

/// Always the first option: re-rolls must still change the field.
class _ZeroRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

Set<String> _givenNames(NpcSpecies s) {
  final n = npcNames[s]!;
  return {...n.female, ...n.male, ...n.neutral};
}

void main() {
  group('generator', () {
    test('is deterministic for a seeded Random', () {
      final a = NpcGenerator(Random(42));
      final b = NpcGenerator(Random(42));
      for (var i = 0; i < 20; i++) {
        expect(a.generate(), b.generate());
      }
      expect(NpcGenerator(Random(1)).generate(), isNot(NpcGenerator(Random(2)).generate()));
    });

    test('every field is filled', () {
      final g = NpcGenerator(Random(7));
      for (var i = 0; i < 500; i++) {
        final npc = g.generate();
        for (final f in NpcField.values) {
          expect(npc[f], isNotNull, reason: '$f');
          expect(npc[f]!.trim(), isNotEmpty, reason: '$f');
        }
        expect(npc.name.split(' ').length, greaterThanOrEqualTo(2), reason: npc.name);
        expect(npc.name.split(' ').any(_givenNames(npc.species).contains), isTrue, reason: npc.name);
      }
    });

    test('hook can be turned off', () {
      final npc = NpcGenerator(Random(3)).generate(const NpcFilters(withHook: false));
      expect(npc[NpcField.hook], isNull);
      expect(npc.values.length, NpcField.values.length - 1);
    });

    test('species, gender and attitude filters are respected', () {
      final g = NpcGenerator(Random(11));
      for (final s in NpcSpecies.values) {
        for (final gender in NpcGender.values) {
          final names = npcNames[s]!;
          final allowed = {...(gender == NpcGender.kadin ? names.female : names.male), ...names.neutral};
          for (var i = 0; i < 25; i++) {
            final npc = g.generate(NpcFilters(species: s, gender: gender, attitude: NpcAttitude.kayitsiz));
            expect(npc.species, s);
            expect(npc.gender, gender);
            expect(npc.name.split(' ').any(allowed.contains), isTrue, reason: '${npc.name} ($s, $gender)');
            expect(npc.attitude, NpcAttitude.kayitsiz);
            expect(npcAttitudeNotes[NpcAttitude.kayitsiz], contains(npc[NpcField.attitude]));
          }
        }
      }
    });

    test('species-specific details only go to that species', () {
      final g = NpcGenerator(Random(5));
      for (final s in NpcSpecies.values) {
        final foreign = {
          for (final e in npcSpeciesAppearances.entries)
            if (e.key != s) ...e.value,
        };
        for (var i = 0; i < 60; i++) {
          expect(foreign, isNot(contains(g.generate(NpcFilters(species: s))[NpcField.appearance])));
        }
      }
    });

    test('re-rolling a field changes only that field', () {
      for (final rng in [Random(9), _ZeroRandom()]) {
        final g = NpcGenerator(rng);
        for (var i = 0; i < 30; i++) {
          final npc = g.generate();
          for (final f in NpcField.values) {
            final next = g.reroll(npc, f);
            expect(next[f], isNot(npc[f]), reason: '$f');
            expect(next.species, npc.species);
            expect(next.gender, npc.gender);
            if (f != NpcField.attitude) expect(next.attitude, npc.attitude);
            for (final other in NpcField.values.where((o) => o != f)) {
              expect(next[other], npc[other], reason: 're-rolled $f, changed $other');
            }
          }
        }
      }
    });

    test('re-rolling the attitude follows the attitude filter', () {
      final g = NpcGenerator(Random(4));
      final npc = g.generate(const NpcFilters(attitude: NpcAttitude.dostca));
      final next = g.reroll(npc, NpcField.attitude, const NpcFilters(attitude: NpcAttitude.dusmanca));
      expect(next.attitude, NpcAttitude.dusmanca);
      expect(npcAttitudeNotes[NpcAttitude.dusmanca], contains(next[NpcField.attitude]));
    });

    test('locked fields survive a new generation; a locked name keeps species and gender', () {
      final g = NpcGenerator(Random(21));
      final npc = g.generate(const NpcFilters(species: NpcSpecies.cuce, gender: NpcGender.kadin));
      final locked = {NpcField.name, NpcField.occupation, NpcField.attitude};
      for (var i = 0; i < 20; i++) {
        final next = g.generate(const NpcFilters(species: NpcSpecies.elf), npc, locked);
        expect(next.name, npc.name);
        expect(next.species, NpcSpecies.cuce);
        expect(next.gender, NpcGender.kadin);
        expect(next.attitude, npc.attitude);
        expect(next[NpcField.occupation], npc[NpcField.occupation]);
        expect(next[NpcField.attitude], npc[NpcField.attitude]);
      }
      final unlocked = g.generate(const NpcFilters(species: NpcSpecies.elf), npc, {NpcField.occupation});
      expect(unlocked.species, NpcSpecies.elf);
      expect(unlocked[NpcField.occupation], npc[NpcField.occupation]);
    });

    test('note text holds every field', () {
      final npc = NpcGenerator(Random(8)).generate();
      final text = npc.toNoteText();
      expect(text, startsWith('${npc.species.label} · ${npc.gender.label} · ${npc.attitude.label}'));
      for (final f in NpcField.values.where((f) => f != NpcField.name)) {
        expect(text, contains(npc[f]!));
        expect(text, contains(f.label));
      }
    });
  });

  group('consistency', () {
    test('details that do not fit a species never go to it', () {
      final g = NpcGenerator(Random(17));
      for (final s in NpcSpecies.values) {
        final foreign = {...?npcAppearancesNotFor[s]};
        for (var i = 0; i < 300; i++) {
          final a = g.generate(NpcFilters(species: s))[NpcField.appearance];
          expect(foreign, isNot(contains(a)), reason: '$s: $a');
          expect(appearancesFor(s), contains(a));
        }
      }
    });

    test('a locked appearance that does not fit the new species is re-rolled', () {
      final g = NpcGenerator(Random(23));
      final tail = npcSpeciesAppearances[NpcSpecies.tiefling]!.first;
      final hair = npcAppearancesNotFor[NpcSpecies.ejderdogan]!.first;
      final tiefling = g.generate(const NpcFilters(species: NpcSpecies.tiefling));
      final withTail = tiefling.copyWith(values: {...tiefling.values, NpcField.appearance: tail});
      final withHair = tiefling.copyWith(values: {...tiefling.values, NpcField.appearance: hair});
      const locked = {NpcField.appearance};
      for (var i = 0; i < 20; i++) {
        expect(
          g.generate(const NpcFilters(species: NpcSpecies.elf), withTail, locked)[NpcField.appearance],
          isNot(tail),
        );
        expect(g.generate(const NpcFilters(species: NpcSpecies.tiefling), withTail, locked)[NpcField.appearance], tail);
        expect(
          g.generate(const NpcFilters(species: NpcSpecies.ejderdogan), withHair, locked)[NpcField.appearance],
          isNot(hair),
        );
        expect(g.generate(const NpcFilters(species: NpcSpecies.insan), withHair, locked)[NpcField.appearance], hair);
      }
    });

    test('no opposite traits, no epithet that contradicts a trait', () {
      for (final rng in [Random(31), _ZeroRandom()]) {
        final g = NpcGenerator(rng);
        for (var i = 0; i < 2000; i++) {
          var npc = g.generate();
          if (i.isOdd) npc = g.reroll(g.reroll(npc, NpcField.personality), NpcField.name);
          final traits = traitsOf(npc[NpcField.personality]);
          for (final (a, b) in npcOppositeTraits) {
            expect(traits.contains(a) && traits.contains(b), isFalse, reason: npc[NpcField.personality]);
          }
          final clashes = npcEpithetClashes[epithetOf(npc.name)] ?? const <String>{};
          expect(traits.where(clashes.contains), isEmpty, reason: '${npc.name}: ${npc[NpcField.personality]}');
        }
      }
    });

    test('a family name never repeats the given name', () {
      for (final s in NpcSpecies.values) {
        final n = npcNames[s]!;
        for (final given in [...n.female, ...n.male, ...n.neutral]) {
          expect(n.family.where((f) => !trLower(f).contains(trLower(given))), isNotEmpty, reason: given);
        }
      }
      final g = NpcGenerator(Random(41));
      for (var i = 0; i < 3000; i++) {
        var npc = g.generate();
        if (i.isOdd) npc = g.reroll(npc, NpcField.name);
        final words = npc.name.split(' ');
        if (epithetOf(npc.name) != null) continue;
        expect(trLower(words.last).contains(trLower(words.first)), isFalse, reason: npc.name);
      }
    });
  });

  group('tables', () {
    void unique(String what, List<String> list) {
      final seen = <String>{};
      for (final s in list) {
        expect(s, s.trim(), reason: '$what: "$s" has extra spaces');
        expect(s, isNotEmpty, reason: what);
        expect(seen.add(trLower(s)), isTrue, reason: '$what: duplicate "$s"');
      }
    }

    test('species use the glossary names', () {
      expect(NpcSpecies.values.map((s) => s.label).toList(), [
        'İnsan',
        'Elf',
        'Cüce',
        'Buçukluk',
        'Gnom',
        'Ork',
        'Ejderdoğan',
        'Tiefling',
        'Goliat',
      ]);
      expect(NpcAttitude.values.map((a) => a.label).toList(), ['Dostça', 'Kayıtsız', 'Düşmanca']);
    });

    test('minimum sizes, no duplicates', () {
      for (final s in NpcSpecies.values) {
        final n = npcNames[s]!;
        expect(n.female.length, greaterThanOrEqualTo(12), reason: '$s female');
        expect(n.male.length, greaterThanOrEqualTo(12), reason: '$s male');
        expect(n.neutral.length, greaterThanOrEqualTo(4), reason: '$s neutral');
        expect(n.female.length + n.male.length + n.neutral.length, greaterThanOrEqualTo(30), reason: '$s');
        expect(n.family.length, greaterThanOrEqualTo(15), reason: '$s family');
        unique('$s given', [...n.female, ...n.male, ...n.neutral]);
        unique('$s family', n.family);
        expect(npcSpeciesAppearances[s], isNotEmpty, reason: '$s appearance');
      }
      expect(npcEpithets.length, greaterThanOrEqualTo(15));
      expect(npcOccupations.length, greaterThanOrEqualTo(40));
      expect(npcAppearances.length, greaterThanOrEqualTo(40));
      expect(npcTraits.length, greaterThanOrEqualTo(50));
      expect(npcMotivations.length, greaterThanOrEqualTo(30));
      expect(npcFlawsAndSecrets.length, greaterThanOrEqualTo(30));
      expect(npcSpeechQuirks.length, greaterThanOrEqualTo(25));
      expect(npcHooks.length, greaterThanOrEqualTo(30));
      for (final a in NpcAttitude.values) {
        expect(npcAttitudeNotes[a]!.length, greaterThanOrEqualTo(5), reason: '$a');
      }

      unique('epithets', npcEpithets);
      unique('occupations', npcOccupations);
      unique('appearances', [...npcAppearances, for (final l in npcSpeciesAppearances.values) ...l]);
      unique('traits', npcTraits);
      unique('motivations', npcMotivations);
      unique('flaws', npcFlawsAndSecrets);
      unique('speech', npcSpeechQuirks);
      unique('hooks', npcHooks);
      unique('attitude notes', [for (final l in npcAttitudeNotes.values) ...l]);
    });

    test('exclusion and clash tables point at real entries', () {
      for (final e in npcAppearancesNotFor.entries) {
        for (final a in e.value) {
          expect(npcAppearances, contains(a), reason: '${e.key}: $a');
        }
      }
      for (final (a, b) in npcOppositeTraits) {
        expect(npcTraits, containsAll([a, b]));
      }
      for (final e in npcEpithetClashes.entries) {
        expect(npcEpithets, contains(e.key));
        expect(npcTraits, containsAll(e.value));
      }
    });

    test('sentences are punctuated, traits are lowercase predicates', () {
      final sentences = [
        ...npcAppearances,
        for (final l in npcSpeciesAppearances.values) ...l,
        ...npcMotivations,
        ...npcFlawsAndSecrets,
        ...npcSpeechQuirks,
        ...npcHooks,
        for (final l in npcAttitudeNotes.values) ...l,
      ];
      for (final s in sentences) {
        expect(RegExp(r'[.?!"]$').hasMatch(s), isTrue, reason: s);
        expect(s[0], trUpper(s[0]), reason: s);
      }
      for (final t in npcTraits) {
        expect(t, trLower(t), reason: t);
        expect(RegExp(r'[.,;]').hasMatch(t), isFalse, reason: t);
      }
    });

    test('no product-identity or published names', () {
      const banned = [
        'd&d',
        'dungeons',
        'dragons',
        'faerûn',
        'faerun',
        'waterdeep',
        'neverwinter',
        'baldur',
        'forgotten realms',
        'greyhawk',
        'eberron',
        'ravenloft',
        'dragonlance',
        'drizzt',
        'elminster',
        'mordenkainen',
        'bigby',
        'tasha',
        'xanathar',
        'volo',
        'strahd',
        'vecna',
        'tiamat',
        'bahamut',
        'lolth',
        'moradin',
        'corellon',
        'gruumsh',
        'asmodeus',
        'zariel',
        'fizban',
        'raistlin',
        'gandalf',
        'frodo',
        'bilbo',
        'legolas',
        'galadriel',
        'tolkien',
        'tarikat',
      ];
      final all = [
        for (final n in npcNames.values) ...[...n.female, ...n.male, ...n.neutral, ...n.family],
        ...npcEpithets,
        ...npcOccupations,
        ...npcAppearances,
        for (final l in npcSpeciesAppearances.values) ...l,
        ...npcTraits,
        ...npcMotivations,
        ...npcFlawsAndSecrets,
        ...npcSpeechQuirks,
        ...npcHooks,
        for (final l in npcAttitudeNotes.values) ...l,
      ];
      for (final s in all) {
        final low = trLower(s);
        for (final b in banned) {
          expect(low.contains(b), isFalse, reason: '"$s" contains "$b"');
        }
      }
    });
  });
}
