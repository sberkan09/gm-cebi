import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_info.dart';
import '../../data/reference.dart';
import '../../features/flags.dart';
import '../../providers.dart';

/// Settings, About and License.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(currentSettingsProvider);
    final ent = ref.watch(entitlementsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final data = ref.watch(referenceProvider).value?.data;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: t.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar ve Hakkında')),
      body: ListView(key: const Key('settings-list'), padding: const EdgeInsets.only(bottom: 32), children: [
        section('Görünüm'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.dark, label: Text('Koyu'), icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: ThemeMode.light, label: Text('Açık'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => notifier.setThemeMode(v.first),
          ),
        ),
        section('İçerik dili'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<Lang>(
            key: const Key('default-lang'),
            segments: const [
              ButtonSegment(value: Lang.tr, label: Text('Türkçe')),
              ButtonSegment(value: Lang.en, label: Text('İngilizce')),
            ],
            selected: {s.contentLang},
            onSelectionChanged: (v) => notifier.setContentLang(v.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Kayıt sayfalarındaki TR/EN düğmesi tek dokunuşla dili değiştirir. Çevrilmemiş kayıtlar İngilizce gösterilir.',
            style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        section('GM Paketi'),
        ListTile(
          leading: Icon(ent.gmPack ? Icons.lock_open : Icons.lock_outline, color: scheme.primary),
          title: Text(ent.gmPack ? 'Açık' : 'Kilitli'),
          subtitle: const Text('İnisiyatif takibi, oturum notları, NPC üretici (yakında). Satın alma sonraki sürümde.'),
        ),
        if (kInternalBuild)
          SwitchListTile(
            key: const Key('gm-pack-test-switch'),
            secondary: const Icon(Icons.science_outlined),
            title: const Text('Test: GM Paketi açık'),
            subtitle: const Text('Yalnızca test sürümlerinde görünür.'),
            value: ent.gmPack,
            onChanged: (v) => notifier.setGmPackOverride(v),
          ),
        section('Hakkında'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('$appName $appVersion'),
          subtitle: Text('$appTagline${kInternalBuild ? ' · test sürümü' : ''}'),
        ),
        if (data != null)
          ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: Text('${data.recordCount} kayıt, ${data.translatedCount} tanesi Türkçe'),
            subtitle: Text('${data.glossary.length} sözlük terimi · çevrimdışı çalışır'),
          ),
        section('Lisans'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(srdAttribution, key: const Key('attribution'), style: t.bodyMedium),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(translationNotice, style: t.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(compatibilityNotice, style: t.bodyMedium),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Açık kaynak lisansları'),
          onTap: () => showLicensePage(context: context, applicationName: appName, applicationVersion: appVersion),
        ),
      ]),
    );
  }
}
