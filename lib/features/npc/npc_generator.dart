import 'dart:math';

import '../../core/turkish.dart';
import 'npc_tables.dart';

export 'npc_tables.dart' show NpcAttitude, NpcSpecies;

enum NpcGender {
  kadin('kadın'),
  erkek('erkek');

  const NpcGender(this.label);
  final String label;
}

/// The parts of an NPC card, in display order. Each can be re-rolled alone.
enum NpcField {
  name('Ad'),
  occupation('Meslek'),
  appearance('Görünüş'),
  personality('Kişilik'),
  motivation('İdeal / motivasyon'),
  flaw('Kusur / sır'),
  speech('Konuşma tarzı'),
  attitude('Tavır'),
  hook('Maceraya bağlantı');

  const NpcField(this.label);
  final String label;
}

/// Optional constraints; null means random.
class NpcFilters {
  const NpcFilters({this.species, this.gender, this.attitude, this.withHook = true});

  final NpcSpecies? species;
  final NpcGender? gender;
  final NpcAttitude? attitude;
  final bool withHook;

  NpcFilters copyWith({
    NpcSpecies? Function()? species,
    NpcGender? Function()? gender,
    NpcAttitude? Function()? attitude,
    bool? withHook,
  }) => NpcFilters(
    species: species == null ? this.species : species(),
    gender: gender == null ? this.gender : gender(),
    attitude: attitude == null ? this.attitude : attitude(),
    withHook: withHook ?? this.withHook,
  );
}

class Npc {
  const Npc({required this.species, required this.gender, required this.attitude, required this.values});

  final NpcSpecies species;
  final NpcGender gender;
  final NpcAttitude attitude;

  /// Text of every field; [NpcField.hook] is absent when hooks are off.
  /// The attitude field holds the attitude's table note.
  final Map<NpcField, String> values;

  String get name => values[NpcField.name]!;

  String? operator [](NpcField f) => values[f];

  /// "Elf · kadın"
  String get summary => '${species.label} · ${gender.label}';

  /// Shown on the card and in notes: "Tavır · Kayıtsız".
  String labelOf(NpcField f) => f == NpcField.attitude ? '${f.label} · ${attitude.label}' : f.label;

  Npc copyWith({NpcSpecies? species, NpcGender? gender, NpcAttitude? attitude, Map<NpcField, String>? values}) => Npc(
    species: species ?? this.species,
    gender: gender ?? this.gender,
    attitude: attitude ?? this.attitude,
    values: values ?? this.values,
  );

  /// Plain text for a session note (the title holds the name).
  String toNoteText() {
    final lines = ['$summary · ${attitude.label}', ''];
    for (final f in NpcField.values) {
      final v = values[f];
      if (f == NpcField.name || v == null) continue;
      lines.add(f == NpcField.attitude ? '${f.label} (${attitude.label}): $v' : '${f.label}: $v');
    }
    return lines.join('\n');
  }

  @override
  bool operator ==(Object other) =>
      other is Npc &&
      other.species == species &&
      other.gender == gender &&
      other.attitude == attitude &&
      other.values.length == values.length &&
      values.entries.every((e) => other.values[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    species,
    gender,
    attitude,
    Object.hashAllUnordered(values.entries.map((e) => Object.hash(e.key, e.value))),
  );

  @override
  String toString() => 'Npc($name, $summary, $values)';
}

/// Offline NPC generator. Deterministic for a given [Random] (tests seed it).
///
/// Every pick draws from the tables with [Random.nextInt] only, and re-rolls
/// exclude the current value instead of retrying, so a re-roll always changes
/// the field and never loops, even with a fixed random source.
class NpcGenerator {
  NpcGenerator(this._rng);

  final Random _rng;

  T _pick<T>(List<T> list, {bool Function(T)? exclude}) {
    final pool = exclude == null ? list : list.where((x) => !exclude(x)).toList();
    final from = pool.isEmpty ? list : pool;
    return from[_rng.nextInt(from.length)];
  }

  /// A new NPC. Fields in [locked] are copied from [keep]; a locked name also
  /// keeps the species and gender, so the name still fits.
  Npc generate([NpcFilters filters = const NpcFilters(), Npc? keep, Set<NpcField> locked = const {}]) {
    bool kept(NpcField f) => keep != null && locked.contains(f) && keep.values.containsKey(f);

    final keepName = kept(NpcField.name);
    final species = keepName ? keep!.species : (filters.species ?? _pick<NpcSpecies>(NpcSpecies.values));
    final gender = keepName ? keep!.gender : (filters.gender ?? _pick<NpcGender>(NpcGender.values));
    final keepAttitude = kept(NpcField.attitude);
    final attitude = keepAttitude ? keep!.attitude : (filters.attitude ?? _pick<NpcAttitude>(NpcAttitude.values));

    final values = <NpcField, String>{};
    for (final f in NpcField.values) {
      if (f == NpcField.hook && !filters.withHook) continue;
      values[f] = kept(f) ? keep!.values[f]! : _roll(f, species, gender, attitude, null);
    }
    return Npc(species: species, gender: gender, attitude: attitude, values: values);
  }

  /// [npc] with only [field] changed (always to a different text). Re-rolling
  /// the attitude follows the attitude filter, or picks any attitude.
  Npc reroll(Npc npc, NpcField field, [NpcFilters filters = const NpcFilters()]) {
    final attitude = field == NpcField.attitude
        ? (filters.attitude ?? _pick<NpcAttitude>(NpcAttitude.values))
        : npc.attitude;
    final values = Map.of(npc.values);
    values[field] = _roll(field, npc.species, npc.gender, attitude, npc.values[field]);
    return npc.copyWith(attitude: attitude, values: values);
  }

  String _roll(NpcField f, NpcSpecies species, NpcGender gender, NpcAttitude attitude, String? current) {
    bool same(String s) => s == current;
    return switch (f) {
      NpcField.name => _name(species, gender, current),
      NpcField.occupation => _pick(npcOccupations, exclude: same),
      NpcField.appearance => _pick([...npcAppearances, ...?npcSpeciesAppearances[species]], exclude: same),
      NpcField.personality => _personality(current),
      NpcField.motivation => _pick(npcMotivations, exclude: same),
      NpcField.flaw => _pick(npcFlawsAndSecrets, exclude: same),
      NpcField.speech => _pick(npcSpeechQuirks, exclude: same),
      NpcField.attitude => _pick(npcAttitudeNotes[attitude]!, exclude: same),
      NpcField.hook => _pick(npcHooks, exclude: same),
    };
  }

  /// Given name plus a family name, or an epithet before the given name
  /// (one in four). A re-roll never reuses the current given name.
  String _name(NpcSpecies species, NpcGender gender, String? current) {
    final set = npcNames[species]!;
    final words = current?.split(' ') ?? const <String>[];
    final given = _pick([
      ...(gender == NpcGender.kadin ? set.female : set.male),
      ...set.neutral,
    ], exclude: words.contains);
    return _rng.nextInt(4) == 0 ? '${_pick(npcEpithets)} $given' : '$given ${_pick(set.family)}';
  }

  /// One or two traits: "Meraklı, kolay güler." A re-roll starts with a trait
  /// that is not in the current text.
  String _personality(String? current) {
    final first = _pick<String>(npcTraits, exclude: current == null ? null : (t) => trLower(current).contains(t));
    final traits = [first];
    if (_rng.nextInt(2) == 1) traits.add(_pick<String>(npcTraits, exclude: (t) => t == first));
    return '${trCapitalize(traits.join(', '))}.';
  }
}
