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
                for (final f in const ['İnisiyatif takibi', 'Oturum notları', 'NPC üretici (yakında)'])
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
            'Tek seferlik satın alma olacak. Bu test sürümünde satın alma yok.',
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
