import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/flags.dart';
import '../../providers.dart';

/// Shown instead of a GM-pack screen when the entitlement is missing.
/// There is no purchase flow in Phase 1; internal builds can unlock for testing.
class GmPackLocked extends ConsumerWidget {
  const GmPackLocked({super.key, required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_outline, size: 56, color: scheme.primary),
          const SizedBox(height: 16),
          Text('GM Paketi', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('$feature GM Paketi ile açılır.', style: t.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final f in const ['İnisiyatif takibi', 'Oturum notları', 'NPC üretici'])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Icon(Icons.check, color: scheme.secondary),
                      const SizedBox(width: 12),
                      Flexible(child: Text(f, style: t.bodyLarge)),
                    ]),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            kInternalBuild
                ? 'Tek seferlik satın alma olacak. Bu test sürümünde satın alma yok.'
                : 'Tek seferlik satın alma olacak. Satın alma bir sonraki sürümde gelecek.',
            style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          if (kInternalBuild) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => ref.read(settingsProvider.notifier).setGmPackOverride(true),
              icon: const Icon(Icons.science_outlined),
              label: const Text('Test için aç'),
            ),
          ],
        ]),
      ),
    );
  }
}

/// On top of a GM-pack screen whose existing data stays readable without the
/// entitlement (session notes): what is locked, and that nothing is lost.
class GmPackLockedBanner extends StatelessWidget {
  const GmPackLockedBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('gm-pack-locked-banner'),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(Icons.lock_outline, color: scheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: t.bodyMedium?.copyWith(color: scheme.onSecondaryContainer))),
        ]),
      ),
    );
  }
}
