/// UI of the optional online scene feature on the battle map: the session
/// scope, the status bar, the "bring the scene to life" sheet with first-use
/// consent and sign-in, and the report sheet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/neuracraft/auth.dart';
import '../../data/neuracraft/client.dart';
import '../../data/neuracraft/errors.dart';
import '../../data/neuracraft/models.dart';
import '../../features/online_scene/account.dart';
import '../../features/online_scene/messages.dart';
import '../../features/online_scene/online_settings.dart';
import '../../features/online_scene/scene_controller.dart';
import '../../features/online_scene/session_controller.dart';
import '../../providers.dart';
import 'sign_in_sheet.dart';

/// Holds the NeuraCraft session open while [child] (the battle map) is on
/// screen, with heartbeats only while the app is in the foreground.
class OnlineSessionScope extends ConsumerStatefulWidget {
  const OnlineSessionScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OnlineSessionScope> createState() => _OnlineSessionScopeState();
}

class _OnlineSessionScopeState extends ConsumerState<OnlineSessionScope> {
  late final OnlineSessionController _session;
  late final AppLifecycleListener _lifecycle;
  bool _acquired = false;

  @override
  void initState() {
    super.initState();
    _session = ref.read(onlineSessionProvider.notifier);
    // After the first frame: opening changes provider state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _acquired = true;
      _session.acquire();
    });
    _lifecycle = AppLifecycleListener(onStateChange: (s) {
      switch (s) {
        case AppLifecycleState.resumed:
          _session.setForeground(true);
        case AppLifecycleState.paused || AppLifecycleState.hidden || AppLifecycleState.detached:
          _session.setForeground(false);
        case AppLifecycleState.inactive:
          break; // transient (a system dialog, the app switcher)
      }
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    if (_acquired) _session.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Whether the online picture or the bare sketch is shown under the tokens.
class SceneVisibility extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool v) => state = v;
}

final sceneVisibleProvider = NotifierProvider<SceneVisibility, bool>(SceneVisibility.new);


/// Above the map: the job in progress, the last error, or the server status;
/// and the picture's actions once there is one.
class SceneStatusBar extends ConsumerWidget {
  const SceneStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(onlineFeatureVisibleProvider)) return const SizedBox.shrink();
    final job = ref.watch(sceneControllerProvider);
    final session = ref.watch(onlineSessionProvider);
    final scene = ref.watch(activeSceneProvider).value;
    final account = ref.watch(ncAccountProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ctl = ref.read(sceneControllerProvider.notifier);

    Widget bar(List<Widget> children, {Color? color}) => Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Material(
            color: color ?? scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            child: Padding(padding: const EdgeInsets.fromLTRB(12, 6, 4, 6), child: Row(children: children)),
          ),
        );

    switch (job) {
      case SceneWorking(:final phase, :final progress):
        final text = switch (phase) {
          ScenePhase.sending => 'Çizim gönderiliyor…',
          ScenePhase.queued => switch (session.capacity) {
              NcCapacityWarming(:final etaSeconds) => 'Sırada; sunucu hazırlanıyor${etaSeconds == null ? '' : ' (~$etaSeconds sn)'}',
              _ => 'Sırada…',
            },
          ScenePhase.running => 'Resim hazırlanıyor…',
          ScenePhase.downloading => 'Resim indiriliyor…',
        };
        return bar([
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(text, key: const Key('scene-progress-text'), style: t.bodyMedium),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: progress, borderRadius: BorderRadius.circular(4)),
            ]),
          ),
          const SizedBox(width: 8),
          TextButton(key: const Key('scene-cancel'), onPressed: ctl.cancel, child: const Text('İptal')),
        ]);
      case SceneFailed(:final message, :final retryable):
        return bar(color: scheme.errorContainer.withValues(alpha: 0.6), [
          Expanded(child: Text(message, key: const Key('scene-error'), style: t.bodyMedium)),
          if (retryable) TextButton(key: const Key('scene-retry'), onPressed: ctl.retry, child: const Text('Yeniden dene')),
          IconButton(key: const Key('scene-dismiss'), tooltip: 'Kapat', icon: const Icon(Icons.close), onPressed: ctl.dismissError),
        ]);
      case SceneIdle() when account.expired || account.status == NcAuthStatus.blocked:
        // The server ended the sign-in (or blocked this user): say so on the map.
        final blocked = account.status == NcAuthStatus.blocked;
        return bar([
          Icon(blocked ? Icons.block : Icons.cloud_off_outlined, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(messageForReaction(blocked ? NcReaction.blocked : NcReaction.signInRequired),
                key: const Key('account-status'), style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          if (!blocked) TextButton(key: const Key('sign-in-again'), onPressed: () => showSignInSheet(context), child: const Text('Giriş yap')),
        ]);
      case SceneIdle():
        if (scene == null && session.phase == SessionPhase.idle) return const SizedBox.shrink();
        final visible = ref.watch(sceneVisibleProvider);
        return bar([
          Icon(Icons.cloud_outlined, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(capacityLabel(session), key: const Key('capacity-label'), style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          if (scene != null) ...[
            FilterChip(
              key: const Key('scene-toggle'),
              label: const Text('Resim'),
              selected: visible,
              onSelected: (v) => ref.read(sceneVisibleProvider.notifier).set(v),
            ),
            PopupMenuButton<String>(
              key: const Key('scene-menu'),
              tooltip: 'Resim',
              onSelected: (v) async {
                switch (v) {
                  case 'retry':
                    await ctl.generate(mode: SceneMode.values.byName(scene.mode), narrative: scene.narrative);
                  case 'report':
                    if (context.mounted) await showReportSheet(context, ref, scene);
                  case 'remove':
                    await ref.read(databaseProvider).deleteScene(scene.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'retry', child: Text('Yeniden dene (yeni resim)')),
                PopupMenuItem(key: Key('scene-report'), value: 'report', child: Text('Bildir')),
                PopupMenuItem(value: 'remove', child: Text('Resmi kaldır')),
              ],
            ),
          ],
        ]);
    }
  }
}

/// "Sahneyi canlandır": asks for consent the first time, then for sign-in
/// when signed out, then the mode and the description.
Future<void> showSceneSheet(BuildContext context, WidgetRef ref) async {
  final settings = ref.read(onlineSettingsProvider).value;
  if (settings == null) return;
  if (!settings.consented) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(consentTitle),
        content: const SingleChildScrollView(child: Text(consentText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(key: const Key('consent-accept'), onPressed: () => Navigator.pop(context, true), child: const Text('Kabul et')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(onlineSettingsProvider.notifier).setConsented(true);
  }
  if (!context.mounted) return;
  await ref.read(ncAccountProvider.notifier).load();
  if (!context.mounted) return;
  final account = ref.read(ncAccountProvider);
  if (account.status == NcAuthStatus.blocked) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageForReaction(NcReaction.blocked))));
    return;
  }
  if (!account.signedIn) {
    if (!await showSignInSheet(context) || !context.mounted) return;
  }
  final last = ref.read(activeSceneProvider).value;
  final result = await showModalBottomSheet<({SceneMode mode, String narrative})>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SceneForm(initialNarrative: last?.narrative ?? '', initialMode: last == null ? SceneMode.map : SceneMode.values.byName(last.mode)),
  );
  if (result != null) {
    ref.read(sceneVisibleProvider.notifier).set(true);
    await ref.read(sceneControllerProvider.notifier).generate(mode: result.mode, narrative: result.narrative);
  }
}

class _SceneForm extends ConsumerStatefulWidget {
  const _SceneForm({required this.initialNarrative, required this.initialMode});

  final String initialNarrative;
  final SceneMode initialMode;

  @override
  ConsumerState<_SceneForm> createState() => _SceneFormState();
}

class _SceneFormState extends ConsumerState<_SceneForm> {
  late final _text = TextEditingController(text: widget.initialNarrative);
  late SceneMode _mode = widget.initialMode;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(onlineSessionProvider);
    final hasSketch = (ref.watch(mapStrokesProvider).value ?? const []).isNotEmpty;
    final warning = capacityWarning(session);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Sahneyi canlandır', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Çizdiğin arazi bir resme dönüşür; jetonlar resmin üstünde kalır.', style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        SegmentedButton<SceneMode>(
          key: const Key('scene-mode'),
          segments: const [
            ButtonSegment(value: SceneMode.map, icon: Icon(Icons.map_outlined), label: Text('Harita')),
            ButtonSegment(value: SceneMode.atmosphere, icon: Icon(Icons.landscape_outlined), label: Text('Atmosfer')),
          ],
          selected: {_mode},
          onSelectionChanged: (v) => setState(() => _mode = v.first),
        ),
        const SizedBox(height: 6),
        Text(
          _mode == SceneMode.map
              ? 'Çizimin düzeni korunur, yukarıdan bakış. Ağaçları küçük dairelerle çiz; nehri, suyu ve masa, '
                  'sandalye gibi küçük eşyaları açıklamada da belirt.'
              : 'Daha serbest ve atmosferik; düzen birebir korunmaz.',
          style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('scene-narrative'),
          controller: _text,
          maxLength: maxNarrativeChars,
          minLines: 2,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Sahneyi anlat (isteğe bağlı)',
            hintText: 'Ör. İki kıyı arasında akan bir nehir, üzerinde ahşap bir köprü; kuzeyde sık bir orman',
            border: OutlineInputBorder(),
          ),
        ),
        if (warning != null) ...[
          Text(warning, key: const Key('scene-capacity-warning'), style: t.bodySmall?.copyWith(color: scheme.tertiary)),
          const SizedBox(height: 8),
        ],
        if (!hasSketch) ...[
          Text('Önce haritaya araziyi çiz: nehir, yol, duvar, orman…', style: t.bodySmall?.copyWith(color: scheme.error)),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          key: const Key('scene-generate'),
          onPressed: hasSketch ? () => Navigator.pop(context, (mode: _mode, narrative: _text.text)) : null,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Resmi oluştur'),
        ),
      ]),
    );
  }
}

/// "Bildir": the picture is hidden at once and the report goes to the service.
Future<void> showReportSheet(BuildContext context, WidgetRef ref, MapSceneView scene) async {
  final picked = await showModalBottomSheet<(ReportReason, String)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _ReportForm(),
  );
  if (picked == null) return;
  final message = await reportScene(ref.read(databaseProvider), ref.read(ncClientProvider), scene, picked.$1, note: picked.$2);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Resim bildirildi ve gizlendi.')));
  }
}

class _ReportForm extends StatefulWidget {
  const _ReportForm();

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  ReportReason? _reason;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Resmi bildir', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Resim hemen gizlenir ve incelenmek üzere gönderilir.', style: t.bodyMedium),
        RadioGroup<ReportReason>(
          groupValue: _reason,
          onChanged: (v) => setState(() => _reason = v),
          child: Column(children: [
            for (final r in ReportReason.values)
              RadioListTile<ReportReason>(key: Key('report-${r.wire}'), value: r, title: Text(reportReasonLabels[r]!)),
          ]),
        ),
        TextField(
          key: const Key('report-note'),
          controller: _note,
          maxLength: maxReportNoteChars,
          decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)', border: OutlineInputBorder()),
        ),
        FilledButton(
          key: const Key('report-send'),
          onPressed: _reason == null ? null : () => Navigator.pop(context, (_reason!, _note.text)),
          child: const Text('Bildir'),
        ),
      ]),
    );
  }
}
