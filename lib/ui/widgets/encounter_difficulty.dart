import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../features/encounter_difficulty.dart';
import '../../providers.dart';

/// Colour of a difficulty band.
Color bandColor(DifficultyBand b, ColorScheme scheme) => switch (b) {
  DifficultyBand.belowLow => scheme.onSurfaceVariant,
  DifficultyBand.low => scheme.primary,
  DifficultyBand.moderate => scheme.tertiary,
  DifficultyBand.high => Color.lerp(scheme.tertiary, scheme.error, 0.6)!,
  DifficultyBand.aboveHigh => scheme.error,
};

/// "Orta · 1.050 / 1.500 TP": the encounter XP over the band's budget.
String difficultyChipText(DifficultyRating r) =>
    '${r.band.label} · ${groupDigits(r.xp)} / ${groupDigits(r.shownBudget)} TP';

/// Compact difficulty chip for the initiative screen; opens the sheet.
class DifficultyChip extends StatelessWidget {
  const DifficultyChip({super.key, required this.summary});

  final EncounterSummary summary;

  @override
  Widget build(BuildContext context) {
    final r = summary.rating;
    final scheme = Theme.of(context).colorScheme;
    final text = difficultyChipText(r);
    // The merged label replaces the chip's own semantics, so the tap action
    // is declared here too (Switch Access, keyboard, Voice Access).
    return Semantics(
      button: true,
      label: 'Karşılaşma zorluğu: $text. Ayrıntılar için dokun.',
      excludeSemantics: true,
      onTap: () => showDifficultySheet(context),
      child: ActionChip(
        key: const Key('difficulty-chip'),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        avatar: Icon(Icons.speed, color: bandColor(r.band, scheme)),
        label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        onPressed: () => showDifficultySheet(context),
      ),
    );
  }
}

Future<void> showDifficultySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _DifficultySheet(),
    );

class _DifficultySheet extends ConsumerStatefulWidget {
  const _DifficultySheet();

  @override
  ConsumerState<_DifficultySheet> createState() => _DifficultySheetState();
}

class _DifficultySheetState extends ConsumerState<_DifficultySheet> {
  /// Levels written but maybe not yet back from the database stream, so quick
  /// taps step from the last written value instead of repeating it.
  final _pending = <int, int>{};

  int _levelOf(Combatant p) =>
      _pending[p.id] ??
      clampLevel(p.level ?? ref.read(currentSettingsProvider).partyLevel);

  void _stepLevel(Combatant p, int delta) {
    final v = clampLevel(_levelOf(p) + delta);
    setState(() => _pending[p.id] = v);
    ref.read(databaseProvider).setLevel(p.id, v);
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(encounterDifficultyProvider);
    final settings = ref.watch(currentSettingsProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    if (summary == null) return const SizedBox(height: 120);
    final r = summary.rating;
    final notifier = ref.read(settingsProvider.notifier);
    // Settings change synchronously in the notifier: read them at tap time.
    AppSettings now() => ref.read(currentSettingsProvider);
    final levels = summary.levels;
    final minL = levels.reduce((a, b) => a < b ? a : b);
    final maxL = levels.reduce((a, b) => a > b ? a : b);
    final levelText = minL == maxL ? '$minL. seviye' : '$minL–$maxL. seviye';

    Widget header(String s) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        s,
        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('difficulty-sheet'),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Karşılaşma zorluğu',
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (!summary.hasRating)
              Text(
                'Canavar listesinden eklenen bir canavar olunca zorluk hesaplanır.',
                style: t.bodyLarge,
              )
            else ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  r.band.label,
                  key: const Key('difficulty-band'),
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: bandColor(r.band, scheme),
                  ),
                ),
              ),
              Text(
                '${groupDigits(r.xp)} TP · ${summary.levels.length} karakter, $levelText',
                style: t.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(r.band.guidance, style: t.bodyMedium),
              const SizedBox(height: 12),
              _BudgetBar(rating: r),
              const SizedBox(height: 8),
              for (final d in Difficulty.values)
                _BudgetRow(
                  difficulty: d,
                  budget: r.budget(d),
                  selected: r.band.name == d.name,
                ),
              const SizedBox(height: 4),
              Text(
                'Bütçe: her karakterin kendi seviyesine göre TP bütçesi '
                'toplanır (SRD 5.2.1, "Combat Encounters"). Düşük altı ve '
                'Yüksek üstü tablonun dışındadır.',
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            header('Grup · ${summary.levels.length} karakter'),
            if (summary.players.isEmpty) ...[
              Text(
                'Karşılaşmada oyuncu yok: grup büyüklüğünü ve seviyesini '
                'buradan ayarla.',
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              _Stepper(
                id: 'party-size',
                label: 'Grup büyüklüğü',
                value: settings.partySize,
                min: minPartySize,
                max: maxPartySize,
                onStep: (d) => notifier.setPartySize(now().partySize + d),
              ),
            ] else
              for (final p in summary.players)
                _Stepper(
                  id: 'level-${p.id}',
                  label: p.name,
                  sublabel: p.level == null && !_pending.containsKey(p.id)
                      ? 'grup seviyesi'
                      : null,
                  value:
                      _pending[p.id] ??
                      clampLevel(p.level ?? settings.partyLevel),
                  min: minLevel,
                  max: maxLevel,
                  onStep: (d) => _stepLevel(p, d),
                ),
            _Stepper(
              id: 'party-level',
              label: 'Grup seviyesi',
              sublabel: summary.players.isEmpty
                  ? null
                  : 'Seviyesi girilmemiş oyuncular için',
              value: settings.partyLevel,
              min: minLevel,
              max: maxLevel,
              onStep: (d) => notifier.setPartyLevel(now().partyLevel + d),
            ),
            header('Canavarlar · ${groupDigits(summary.xp)} TP'),
            for (final (c, xp) in summary.monsters)
              _XpRow(name: c.name, value: '${groupDigits(xp)} TP'),
            for (final c in summary.unknown)
              _XpRow(name: c.name, value: 'TP bilinmiyor', muted: true),
            if (summary.unknown.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'TP\'si bilinmeyenler (canavar listesinden eklenmeyenler) '
                  'toplama katılmaz.',
                  key: const Key('difficulty-unknown-note'),
                  style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.difficulty,
    required this.budget,
    required this.selected,
  });

  final Difficulty difficulty;
  final int budget;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final style = selected
        ? t.titleSmall?.copyWith(fontWeight: FontWeight.w800)
        : t.bodyMedium;
    return Semantics(
      label:
          '${difficulty.label} bütçesi ${groupDigits(budget)} TP'
          '${selected ? ', karşılaşma bu aralıkta' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: selected ? const Icon(Icons.arrow_right, size: 20) : null,
            ),
            Expanded(child: Text(difficulty.label, style: style)),
            Text(
              '${groupDigits(budget)} TP',
              key: Key('budget-${difficulty.name}'),
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class _XpRow extends StatelessWidget {
  const _XpRow({required this.name, required this.value, this.muted = false});

  final String name;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = muted ? Theme.of(context).colorScheme.onSurfaceVariant : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: t.bodyMedium?.copyWith(color: color),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: t.bodyMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Label, − value + with 48 dp buttons.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.id,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onStep,
    this.sublabel,
  });

  final String id;
  final String label;
  final String? sublabel;
  final int value;
  final int min;
  final int max;

  /// Called with -1 or +1; the owner steps from its current value.
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, overflow: TextOverflow.ellipsis, style: t.bodyLarge),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: t.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          key: Key('$id-dec'),
          tooltip: '$label: azalt',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: value > min ? () => onStep(-1) : null,
          icon: const Icon(Icons.remove),
        ),
        Semantics(
          label: '$label: $value',
          excludeSemantics: true,
          child: SizedBox(
            width: 32,
            child: Text(
              '$value',
              key: Key('$id-value'),
              textAlign: TextAlign.center,
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        IconButton(
          key: Key('$id-inc'),
          tooltip: '$label: artır',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: value < max ? () => onStep(1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// A bar from 0 past the High budget: the three budgets as ticks and the
/// encounter XP as a marker.
class _BudgetBar extends StatelessWidget {
  const _BudgetBar({required this.rating});

  final DifficultyRating rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = rating;
    return Semantics(
      label:
          'Karşılaşma ${groupDigits(r.xp)} TP; Düşük ${groupDigits(r.low)}, '
          'Orta ${groupDigits(r.moderate)}, Yüksek ${groupDigits(r.high)} TP',
      excludeSemantics: true,
      child: SizedBox(
        height: 28,
        width: double.infinity,
        child: CustomPaint(
          painter: _BudgetBarPainter(
            rating: r,
            colors: [
              for (final b in DifficultyBand.values) bandColor(b, scheme),
            ],
            track: scheme.surfaceContainerHighest,
            marker: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _BudgetBarPainter extends CustomPainter {
  _BudgetBarPainter({
    required this.rating,
    required this.colors,
    required this.track,
    required this.marker,
  });

  final DifficultyRating rating;
  final List<Color> colors;
  final Color track;
  final Color marker;

  @override
  void paint(Canvas canvas, Size size) {
    final r = rating;
    final end = [
      r.high * 1.25,
      r.xp * 1.05,
      1.0,
    ].reduce((a, b) => a > b ? a : b);
    double x(num v) => (v / end).clamp(0.0, 1.0) * size.width;
    const barTop = 8.0, barHeight = 12.0;
    final rect = RRect.fromLTRBR(
      0,
      barTop,
      size.width,
      barTop + barHeight,
      const Radius.circular(6),
    );
    canvas.save();
    canvas.clipRRect(rect);
    canvas.drawRect(Offset.zero & size, Paint()..color = track);
    final bounds = [0, r.low / 2, r.low, r.moderate, r.high, end];
    for (var i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTRB(
          x(bounds[i]),
          barTop,
          x(bounds[i + 1]),
          barTop + barHeight,
        ),
        Paint()..color = colors[i].withValues(alpha: 0.55),
      );
    }
    canvas.restore();
    final tick = Paint()
      ..color = track
      ..strokeWidth = 2;
    for (final v in [r.low, r.moderate, r.high]) {
      canvas.drawLine(
        Offset(x(v), barTop),
        Offset(x(v), barTop + barHeight),
        tick,
      );
    }
    final m = x(r.xp);
    canvas.drawLine(
      Offset(m, 2),
      Offset(m, size.height - 2),
      Paint()
        ..color = marker
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_BudgetBarPainter old) =>
      old.rating.xp != rating.xp ||
      old.rating.high != rating.high ||
      old.rating.low != rating.low ||
      old.rating.moderate != rating.moderate ||
      old.colors.toString() != colors.toString() ||
      old.track != track ||
      old.marker != marker;
}
