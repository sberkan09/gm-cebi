import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/features/flags.dart';

void main() {
  test('free core is always available', () {
    const e = Entitlements();
    for (final f in [Feature.reference, Feature.search, Feature.dice]) {
      expect(e.allows(f), isTrue);
    }
  });

  test('GM pack gates initiative and notes', () {
    const free = Entitlements();
    const paid = Entitlements(gmPack: true);
    expect(free.isLocked(Feature.initiative), isTrue);
    expect(free.isLocked(Feature.sessionNotes), isTrue);
    expect(paid.allows(Feature.initiative), isTrue);
    expect(paid.allows(Feature.sessionNotes), isTrue);
  });

  test('reserved features are never available or shown as locked', () {
    const all = Entitlements(gmPack: true, audioSubscription: true);
    expect(all.allows(Feature.npcGenerator), isFalse);
    expect(all.allows(Feature.sessionAudioSummary), isFalse);
    expect(const Entitlements().isLocked(Feature.npcGenerator), isFalse);
  });

  test('store builds ignore a test override left by an internal build', () {
    // Internal build: the Settings test switch wins over the build default.
    expect(resolveGmPack(override: true, internal: true, packDefault: false), isTrue);
    expect(resolveGmPack(override: false, internal: true, packDefault: true), isFalse);
    expect(resolveGmPack(override: null, internal: true, packDefault: true), isTrue);
    // Store build: only the build flag counts.
    expect(resolveGmPack(override: true, internal: false, packDefault: false), isFalse);
    expect(resolveGmPack(override: false, internal: false, packDefault: true), isTrue);
    expect(resolveGmPack(override: null, internal: false, packDefault: false), isFalse);
  });

  test('plain test runs are built like a store build', () {
    // `flutter test` passes no --dart-define: the test switches stay compiled out.
    expect(kInternalBuild, isFalse);
    expect(kGmPackDefault, isFalse);
  });
}
