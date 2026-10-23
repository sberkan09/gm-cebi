import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dice.dart';
import '../../providers.dart';

/// Random source for the dice screen; tests override it with a seeded one.
final diceRandomProvider = Provider<Random>((ref) => Random.secure());

/// Dice roller: type any expression (2d20kh1+5) or build one with the big buttons.
class DiceScreen extends ConsumerStatefulWidget {
  const DiceScreen({super.key});

  @override
  ConsumerState<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends ConsumerState<DiceScreen> {
  final _controller = TextEditingController(text: '1d20');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _roll([String? expression]) {
    final expr = (expression ?? _controller.text).trim();
    try {
      final r = DiceExpression.parse(expr).roll(ref.read(diceRandomProvider));
      ref.read(diceHistoryProvider.notifier).add(r);
      setState(() => _error = null);
    } on DiceException catch (e) {
      setState(() => _error = e.message);
    }
  }

  void _setExpression(String e) {
    _controller.text = e;
    _controller.selection = TextSelection.collapsed(offset: e.length);
    setState(() => _error = null);
  }

  /// Adds one die of [sides]: "1d20" → "2d20" when the last term is the same die.
  void _addDie(int sides) {
    final text = _controller.text.trim();
    final die = sides == 100 ? '%' : '$sides';
    final m = RegExp(r'(^|[+\-*/(]\s*)(\d*)[dz]' + RegExp.escape(die) + r'$').firstMatch(text);
    if (m != null) {
      final n = int.tryParse(m.group(2)!.isEmpty ? '1' : m.group(2)!) ?? 1;
      _setExpression('${text.substring(0, m.start)}${m.group(1)}${n + 1}d$die');
    } else if (text.isEmpty) {
      _setExpression('1d$die');
    } else {
      _setExpression('$text+1d$die');
    }
  }

  /// Adjusts the trailing flat modifier by [delta]: "1d20" → "1d20+1" → "1d20+2".
  void _adjustModifier(int delta) {
    final text = _controller.text.trim();
    final m = RegExp(r'([+\-])\s*(\d+)$').firstMatch(text);
    if (m != null && !text.substring(0, m.start).endsWith('d')) {
      final v = (m.group(1) == '-' ? -1 : 1) * int.parse(m.group(2)!) + delta;
      final base = text.substring(0, m.start);
      _setExpression(v == 0 ? base : '$base${v > 0 ? '+' : ''}$v');
    } else {
      _setExpression('${text.isEmpty ? '0' : text}${delta > 0 ? '+' : ''}$delta');
    }
  }

  int _currentModifier() {
    final m = RegExp(r'([+\-])\s*(\d+)$').firstMatch(_controller.text.trim());
    return m == null ? 0 : (m.group(1) == '-' ? -1 : 1) * int.parse(m.group(2)!);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(diceHistoryProvider);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final last = history.isEmpty ? null : history.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zar'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Geçmişi temizle',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => ref.read(diceHistoryProvider.notifier).clear(),
            ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
            _ResultCard(result: last),
            if (history.length > 1) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text('Geçmiş', style: t.titleSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ),
              for (final r in history.skip(1))
                ListTile(
                  dense: false,
                  title: Text('${r.total}', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text('${r.expression}   ${r.breakdown}'),
                  trailing: const Icon(Icons.replay),
                  onTap: () {
                    _setExpression(r.expression);
                    _roll(r.expression);
                  },
                ),
            ],
          ]),
        ),
        Material(
          color: scheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                key: const Key('dice-field'),
                controller: _controller,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _roll(),
                style: t.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                decoration: InputDecoration(
                  hintText: 'ör. 2d20kh1+5',
                  errorText: _error,
                  suffixIcon: IconButton(tooltip: 'Temizle', icon: const Icon(Icons.backspace_outlined), onPressed: () => _setExpression('')),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
                for (final s in const [4, 6, 8, 10, 12, 20, 100])
                  _Key(label: s == 100 ? 'd%' : 'd$s', onTap: () => _addDie(s)),
                _Key(label: '−1', onTap: () => _adjustModifier(-1)),
                _Key(label: '+1', onTap: () => _adjustModifier(1)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('advantage'),
                    onPressed: () {
                      final e = advantageExpression(_currentModifier());
                      _setExpression(e);
                      _roll(e);
                    },
                    child: const Text('Avantaj'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('disadvantage'),
                    onPressed: () {
                      final e = disadvantageExpression(_currentModifier());
                      _setExpression(e);
                      _roll(e);
                    },
                    child: const Text('Dezavantaj'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton.icon(
                  key: const Key('roll'),
                  onPressed: _roll,
                  icon: const Icon(Icons.casino_outlined, size: 28),
                  label: const Text('AT', style: TextStyle(fontSize: 22, letterSpacing: 2)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 72,
        height: 52,
        child: FilledButton.tonal(
          style: FilledButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(56, 52)),
          onPressed: onTap,
          child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final RollResult? result;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final r = result;
    if (r == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'İfadeyi yaz ya da düğmelerle kur, sonra AT.\n2d20kh1+5 = avantajlı +5, 4d6dl1 = en düşüğü at.',
          textAlign: TextAlign.center,
          style: t.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }
    final color = r.isCritical ? scheme.secondary : (r.isFumble ? scheme.error : scheme.primary);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(children: [
          Text(r.expression, style: t.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
          Text('${r.total}', key: const Key('dice-total'), style: t.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
          if (r.isCritical) Text('Doğal 20!', style: t.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
          if (r.isFumble) Text('Doğal 1', style: t.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(r.breakdown, key: const Key('dice-breakdown'), textAlign: TextAlign.center, style: t.bodyLarge),
          if (r.terms.any((x) => x.kept.contains(false)))
            Text('Parantez içindeki zarlar sayılmadı.', style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
