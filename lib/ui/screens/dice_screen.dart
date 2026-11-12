import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dice.dart';
import '../../providers.dart';

export '../../providers.dart' show diceRandomProvider;

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
      final n = int.tryParse(m.group(2)!);
      if (n == null) return; // too many digits for a number: "AT" says so
      final v = (m.group(1) == '-' ? -1 : 1) * n + delta;
      final base = text.substring(0, m.start);
      _setExpression(v == 0 ? base : '$base${v > 0 ? '+' : ''}$v');
    } else {
      _setExpression('${text.isEmpty ? '0' : text}${delta > 0 ? '+' : ''}$delta');
    }
  }

  /// "Avantaj" / "Dezavantaj": only for a single d20 roll, which becomes
  /// 2d20kh1 / 2d20kl1 and is rolled; for anything else (2d6+3) the button is
  /// off and says why on a long press.
  Widget _advantageButton(String key, String label, {required bool disadvantage}) {
    String? rewritten() => withAdvantage(_controller.text, disadvantage: disadvantage);
    return Expanded(
      child: Tooltip(
        message: rewritten() == null ? 'Yalnızca tek d20 atışında (ör. 1d20+5)' : '',
        child: OutlinedButton(
          key: Key(key),
          onPressed: rewritten() == null
              ? null
              : () {
                  final e = rewritten(); // of the text as it is now
                  if (e == null) return;
                  _setExpression(e);
                  _roll(e);
                },
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, softWrap: false)),
        ),
      ),
    );
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
      // The field and "AT" always stay in view; with little room (keyboard
      // open, small phone, large text) the dice keys between them scroll, and
      // a strip stays free above for the result.
      body: CustomMultiChildLayout(
        delegate: _DiceLayout(minResult: _CompactResult.height(context)),
        children: [
          LayoutId(
            id: _Slot.results,
            child: LayoutBuilder(builder: (context, box) {
              if (last == null) return _EmptyHint(size: box.biggest);
              final compact = box.maxHeight < _ResultCard.minHeight(context);
              return ListView(padding: EdgeInsets.symmetric(vertical: compact ? 0 : 8), children: [
                if (compact) _CompactResult(result: last) else _ResultCard(result: last),
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
              ]);
            }),
          ),
          LayoutId(id: _Slot.panel, child: Material(color: scheme.surfaceContainerLow)),
          LayoutId(
            id: _Slot.field,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TextField(
                key: const Key('dice-field'),
                controller: _controller,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _roll(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null); // the error was about the old text
                },
                style: t.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                decoration: InputDecoration(
                  hintText: 'ör. 2d20kh1+5',
                  errorText: _error,
                  suffixIcon: IconButton(tooltip: 'Temizle', icon: const Icon(Icons.backspace_outlined), onPressed: () => _setExpression('')),
                ),
              ),
            ),
          ),
          LayoutId(
            id: _Slot.keys,
            child: SingleChildScrollView(
              key: const Key('dice-keys'),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
                  for (final s in const [4, 6, 8, 10, 12, 20, 100])
                    _Key(label: s == 100 ? 'd%' : 'd$s', onTap: () => _addDie(s)),
                  _Key(label: '−1', onTap: () => _adjustModifier(-1)),
                  _Key(label: '+1', onTap: () => _adjustModifier(1)),
                ]),
                const SizedBox(height: 8),
                // Rebuilt as the expression changes: the buttons follow what is typed.
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => Row(children: [
                    _advantageButton('advantage', 'Avantaj', disadvantage: false),
                    const SizedBox(width: 8),
                    _advantageButton('disadvantage', 'Dezavantaj', disadvantage: true),
                  ]),
                ),
              ]),
            ),
          ),
          LayoutId(
            id: _Slot.roll,
            // As high as the layout says (64, or 52 with little room).
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: FilledButton.icon(
                key: const Key('roll'),
                onPressed: _roll,
                icon: const Icon(Icons.casino_outlined, size: 28),
                label: const Text('AT', style: TextStyle(fontSize: 22, letterSpacing: 2, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Slot { results, panel, field, keys, roll }

/// Results on top, then the panel: the expression field, the dice keys and
/// "AT" at the bottom. The field gets the height it asks for and "AT" its
/// fixed height; the keys get what is left after [minResult] is set aside for
/// the result (and scroll when that is less than they need); the results
/// take the rest.
class _DiceLayout extends MultiChildLayoutDelegate {
  _DiceLayout({required this.minResult});

  /// Height kept for the result as long as the field and "AT" leave it.
  final double minResult;

  @override
  void performLayout(Size size) {
    BoxConstraints upTo(double height) => BoxConstraints(minWidth: size.width, maxWidth: size.width, maxHeight: math.max(0, height));
    // "AT" with its 12 below: lower when the keyboard leaves little room.
    final rollHeight = math.min(size.height, size.height < 360 ? 64.0 : 76.0);
    final roll = layoutChild(_Slot.roll, BoxConstraints.tight(Size(size.width, rollHeight)));
    final field = layoutChild(_Slot.field, upTo(size.height - roll.height));
    final rest = math.max(0.0, size.height - roll.height - field.height);
    final keys = layoutChild(_Slot.keys, upTo(rest - math.min(minResult, rest)));
    final results = rest - keys.height;
    layoutChild(_Slot.results, BoxConstraints.tight(Size(size.width, results)));
    layoutChild(_Slot.panel, BoxConstraints.tight(Size(size.width, size.height - results)));
    positionChild(_Slot.results, Offset.zero);
    positionChild(_Slot.panel, Offset(0, results));
    positionChild(_Slot.field, Offset(0, results));
    positionChild(_Slot.keys, Offset(0, results + field.height));
    positionChild(_Slot.roll, Offset(0, size.height - roll.height));
  }

  @override
  bool shouldRelayout(_DiceLayout oldDelegate) => oldDelegate.minResult != minResult;
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
          // No colour here: the button supplies its foreground colour.
          child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
      );
}

/// Shown before the first roll. Never cut off: with little room (large text,
/// keyboard open) the margins shrink, then the examples are left out, and as
/// a last resort the text is drawn smaller.
class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.size});

  /// The room there is.
  final Size size;

  static const _how = 'İfadeyi yaz ya da düğmelerle kur, sonra AT.';
  static const _examples = '2d20kh1+5 = avantajlı +5, 4d6dl1 = en düşüğü at.';

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    final scaler = MediaQuery.textScalerOf(context);
    bool fits(String text, EdgeInsets padding) {
      final p = TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout(maxWidth: math.max(0, size.width - padding.horizontal));
      final ok = p.height + padding.vertical <= size.height;
      p.dispose();
      return ok;
    }

    const roomy = EdgeInsets.all(32), tight = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    const both = '$_how\n$_examples';
    final padding = fits(both, roomy) ? roomy : tight;
    final all = padding == roomy || fits(both, tight);
    return Align(
      alignment: Alignment.topCenter,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: size.width,
          child: Padding(
            padding: padding,
            child: Text(all ? both : _how, key: const Key('dice-hint'), textAlign: TextAlign.center, style: style),
          ),
        ),
      ),
    );
  }
}

/// The newest roll on one line, for when there is no room for [_ResultCard].
class _CompactResult extends StatelessWidget {
  const _CompactResult({required this.result});

  final RollResult result;

  /// Its height (margin and padding, and two lines of text), a little rounded up.
  static double height(BuildContext context) => 24 + MediaQuery.textScalerOf(context).scale(48);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final r = result;
    final color = r.isCritical ? scheme.secondary : (r.isFumble ? scheme.error : scheme.primary);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Text('${r.total}', key: const Key('dice-total'), style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: r.expression),
                  if (r.isCritical || r.isFumble)
                    TextSpan(text: r.isCritical ? '  Doğal 20!' : '  Doğal 1', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(r.breakdown, key: const Key('dice-breakdown'), maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodyMedium),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final RollResult result;

  /// The room the card needs to show the expression and the whole total (the
  /// breakdown below them can be scrolled to); with less, [_CompactResult].
  static double minHeight(BuildContext context) {
    final t = Theme.of(context).textTheme;
    double line(TextStyle? s) => (s?.fontSize ?? 14) * (s?.height ?? 1.2);
    return 8 + 6 + 24 + MediaQuery.textScalerOf(context).scale(line(t.titleMedium) + line(t.displayLarge));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final r = result;
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
