import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/features/npc/npc_generator.dart';
import 'package:gm_cebi/ui/screens/npc_screen.dart';

void main() {
  test('session keeps filters, locks and the last 10 NPCs; no duplicates', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final session = c.read(npcSessionProvider.notifier);
    final g = NpcGenerator(Random(1));

    session.setFilters(const NpcFilters(species: NpcSpecies.gnom));
    session.toggleLock(NpcField.name);
    expect(c.read(npcSessionProvider).filters.species, NpcSpecies.gnom);
    expect(c.read(npcSessionProvider).locked, {NpcField.name});

    for (var i = 0; i < 15; i++) {
      expect(session.show(g.generate()), isTrue);
    }
    final s = c.read(npcSessionProvider);
    expect(s.recent, hasLength(NpcSession.maxRecent));
    expect(s.recent, isNot(contains(s.current)));

    // Everything locked: the same NPC again is not pushed into the list.
    final current = s.current!;
    expect(session.show(g.generate(const NpcFilters(), current, NpcField.values.toSet())), isFalse);
    expect(c.read(npcSessionProvider).recent, s.recent);

    session.restore(2);
    expect(c.read(npcSessionProvider).current, s.recent[2]);
    expect(c.read(npcSessionProvider).recent.first, current);

    session.toggleLock(NpcField.name);
    expect(c.read(npcSessionProvider).locked, isEmpty);
    expect(c.read(npcSessionProvider).filters.species, NpcSpecies.gnom);
  });
}
