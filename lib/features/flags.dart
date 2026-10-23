/// Feature flags and entitlements.
///
/// Business model (brief): a free core (reference, search, dice), a one-time
/// "GM paketi" purchase (initiative tracker, session notes, NPC generator) and
/// later an audio-summary subscription. Phase 1 contains NO in-app purchase
/// code: entitlements come from build flags and, in internal builds, a test
/// switch in Settings. The purchase layer will only have to set these.
library;

enum Feature {
  reference,
  search,
  dice,
  initiative,
  sessionNotes,
  npcGenerator,
  sessionAudioSummary,
}

enum Entitlement { free, gmPack, audioSubscription }

const featureEntitlement = <Feature, Entitlement>{
  Feature.reference: Entitlement.free,
  Feature.search: Entitlement.free,
  Feature.dice: Entitlement.free,
  Feature.initiative: Entitlement.gmPack,
  Feature.sessionNotes: Entitlement.gmPack,
  Feature.npcGenerator: Entitlement.gmPack,
  Feature.sessionAudioSummary: Entitlement.audioSubscription,
};

/// Features that exist in this build. Others are reserved (flag only).
const builtFeatures = {
  Feature.reference,
  Feature.search,
  Feature.dice,
  Feature.initiative,
  Feature.sessionNotes,
};

/// `--dart-define=GMCEBI_INTERNAL=true` for test-group builds: shows the
/// entitlement test switches in Settings.
const kInternalBuild = bool.fromEnvironment('GMCEBI_INTERNAL');

/// `--dart-define=GMCEBI_GM_PACK=true` unlocks the GM pack by default.
const kGmPackDefault = bool.fromEnvironment('GMCEBI_GM_PACK');

class Entitlements {
  const Entitlements({this.gmPack = false, this.audioSubscription = false});

  final bool gmPack;
  final bool audioSubscription;

  bool has(Entitlement e) => switch (e) {
        Entitlement.free => true,
        Entitlement.gmPack => gmPack,
        Entitlement.audioSubscription => audioSubscription,
      };

  /// Built and paid for.
  bool allows(Feature f) => builtFeatures.contains(f) && has(featureEntitlement[f]!);

  /// Built but locked behind a purchase.
  bool isLocked(Feature f) => builtFeatures.contains(f) && !has(featureEntitlement[f]!);
}
