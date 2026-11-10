import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_info.dart';
import '../../data/reference.dart';
import '../../data/neuracraft/auth.dart';
import '../../data/neuracraft/errors.dart';
import '../../features/flags.dart';
import '../../features/online_scene/account.dart';
import '../../features/online_scene/messages.dart';
import '../../features/online_scene/online_settings.dart';
import '../../features/online_scene/scene_controller.dart';
import '../../providers.dart';
import '../widgets/sign_in_sheet.dart';

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
        if (ent.allows(Feature.initiative)) ...[
          section('Savaş haritası'),
          SwitchListTile(
            key: const Key('pen-mode-switch'),
            secondary: const Icon(Icons.draw_outlined),
            title: const Text('Kalem modu'),
            subtitle: const Text('Yalnızca kalem çizer, avuç içi çizmez. Parmakla haritayı kaydır ve yakınlaştır, jetonları taşı. '
                'Kalem haritaya ilk dokunduğunda kendiliğinden açılır.'),
            value: s.penMode,
            onChanged: notifier.setPenMode,
          ),
        ],
        section('GM Paketi'),
        ListTile(
          leading: Icon(ent.gmPack ? Icons.lock_open : Icons.lock_outline, color: scheme.primary),
          title: Text(ent.gmPack ? 'Açık' : 'Kilitli'),
          subtitle: const Text('İnisiyatif takibi, oturum notları, NPC üretici. Satın alma sonraki sürümde.'),
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
        if (ref.watch(ncClientProvider) != null) ...[
          section('Çevrimiçi sahne'),
          const _OnlineSceneSettings(),
        ],
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

/// The optional online scene feature (only in builds configured for it).
class _OnlineSceneSettings extends ConsumerWidget {
  const _OnlineSceneSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(onlineSettingsProvider).value;
    if (s == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      SwitchListTile(
        key: const Key('online-enabled'),
        secondary: const Icon(Icons.auto_awesome),
        title: const Text('Haritadan resim üret'),
        subtitle: const Text('Savaş haritasındaki çizimi sunucuda resme dönüştürür. Kapalıyken hiçbir şey gönderilmez.'),
        value: s.enabled,
        onChanged: s.authInvalid
            ? null
            : (v) {
                if (!v) ref.read(sceneControllerProvider.notifier).cancel();
                ref.read(onlineSettingsProvider.notifier).setEnabled(v);
              },
      ),
      if (s.authInvalid)
        ListTile(
          leading: Icon(Icons.system_update, color: scheme.error),
          title: Text(messageForReaction(NcReaction.authInvalid)),
        ),
      ListTile(
        key: const Key('online-privacy'),
        leading: const Icon(Icons.privacy_tip_outlined),
        title: const Text('Gizlilik'),
        subtitle: Text(s.consented ? 'Onay verildi' : 'İlk kullanımda onay istenir'),
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(consentTitle),
            content: const SingleChildScrollView(child: Text(consentText)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam'))],
          ),
        ),
      ),
      const _OnlineAccount(),
    ]);
  }
}

/// "Çevrimiçi sahne hesabı": sign-in, today's quota, sign-out and account
/// deletion (which also deletes everything on the server).
class _OnlineAccount extends ConsumerWidget {
  const _OnlineAccount();

  void _snack(BuildContext context, String text) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _confirm(BuildContext context, {required String title, required String text, required String action, required Key key}) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
            FilledButton(key: key, onPressed: () => Navigator.pop(context, true), child: Text(action)),
          ],
        ),
      ) ==
      true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(ncAccountProvider);
    final scheme = Theme.of(context).colorScheme;
    const title = Text('Çevrimiçi sahne hesabı');
    switch (a.status) {
      case NcAuthStatus.loading:
        return const SizedBox.shrink();
      case NcAuthStatus.blocked:
        return ListTile(
          key: const Key('online-account'),
          leading: Icon(Icons.block, color: scheme.error),
          title: title,
          subtitle: Text(messageForReaction(NcReaction.blocked)),
        );
      case NcAuthStatus.signedOut:
        return Column(children: [
          ListTile(
            key: const Key('online-sign-in'),
            leading: const Icon(Icons.login),
            title: title,
            subtitle: Text(a.expired ? 'Oturumun sona erdi, tekrar giriş yap.' : 'Giriş yapılmadı. Dokun ve e-postanla giriş yap.'),
            onTap: () => showSignInSheet(context),
          ),
          ListTile(
            key: const Key('online-delete-local'),
            leading: const Icon(Icons.delete_outline),
            title: const Text('Uygulamadaki çevrimiçi resimleri sil'),
            onTap: () async {
              if (!await _confirm(context,
                  title: 'Resimler silinsin mi?', text: deleteLocalInfo, action: 'Sil', key: const Key('online-delete-local-confirm'))) {
                return;
              }
              await ref.read(sceneControllerProvider.notifier).cancel();
              await ref.read(databaseProvider).deleteAllScenes();
              if (context.mounted) _snack(context, 'Uygulamadaki çevrimiçi resimler silindi.');
            },
          ),
        ]);
      case NcAuthStatus.signedIn:
        final me = ref.watch(ncMeProvider).value;
        final quota = me?.daily != null && me?.used != null ? 'Bugün: ${me!.used}/${me.daily} harita' : null;
        return Column(children: [
          ListTile(
            key: const Key('online-account'),
            leading: const Icon(Icons.account_circle_outlined),
            title: title,
            subtitle: Text([a.email ?? 'Giriş yapıldı', ?quota].join('\n'), key: const Key('online-account-details')),
            isThreeLine: quota != null,
          ),
          ListTile(
            key: const Key('online-sign-out'),
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış yap'),
            onTap: () async {
              await signOutOnline(ref);
              if (context.mounted) _snack(context, 'Çıkış yapıldı.');
            },
          ),
          ListTile(
            key: const Key('online-delete-account'),
            leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
            title: const Text('Hesabımı sil'),
            subtitle: const Text('Hesabın ve sunucudaki tüm verilerin hemen silinir'),
            onTap: () async {
              if (!await _confirm(context,
                  title: 'Hesabın silinsin mi?', text: deleteAccountInfo, action: 'Hesabımı sil', key: const Key('online-delete-account-confirm'))) {
                return;
              }
              try {
                await deleteOnlineAccount(ref);
                if (context.mounted) _snack(context, 'Hesabın ve tüm verilerin silindi.');
              } on NcException catch (e) {
                if (context.mounted) {
                  _snack(
                      context,
                      e.reaction == NcReaction.offline
                          ? 'Sunucuya ulaşılamadı; hesabın silinmedi. Bağlantını kontrol edip tekrar dene.'
                          : 'Hesap silinemedi: ${messageFor(e)}');
                }
              }
            },
          ),
        ]);
    }
  }
}
