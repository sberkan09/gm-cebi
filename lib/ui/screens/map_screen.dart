import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/database.dart';
import '../../features/flags.dart';
import '../../features/map_sketch.dart';
import '../../features/online_scene/online_settings.dart';
import '../../features/online_scene/scene_controller.dart';
import '../../providers.dart';
import '../widgets/locked.dart';
import '../widgets/online_scene.dart';

/// Battle map of the active encounter (GM pack): a quick sketch with the
/// initiative tracker's combatants as tokens. Works offline.
///
/// One gesture does everything: a drag that starts on a token moves it,
/// any other drag draws (or erases, in eraser mode).
///
/// Optional online feature (docs/online-scene.md): the terrain sketch can be
/// turned into a picture by NeuraCraft Cloud; the picture becomes the bottom
/// layer and the tokens stay on top. Without it, the map works the same.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

enum _Tool { pen, eraser }

/// One undoable change to the drawing.
sealed class _Op {
  const _Op();
}

class _Added extends _Op {
  const _Added(this.id);
  final int id;
}

/// Strokes the eraser or "clear" removed, kept so undo can put them back.
class _Removed extends _Op {
  const _Removed(this.rows);
  final List<MapStroke> rows;
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _maxUndo = 100;

  _Tool _tool = _Tool.pen;
  int _color = 0;
  bool _grid = true;

  /// Stroke being drawn, in map units.
  List<Offset01>? _drawing;

  /// Last eraser position, so a fast swipe erases along its whole path.
  Offset01? _lastErase;

  /// Strokes removed by the eraser gesture in progress (one undo step).
  final Map<int, MapStroke> _erasing = {};

  /// Token being dragged: combatant id and its live position.
  int? _dragId;
  Offset01? _dragPos;

  /// Undo steps of this screen, for the encounter [_undoEncounter].
  final List<_Op> _undo = [];
  int? _undoEncounter;

  /// Decoded points per stroke id. Strokes never change after they are
  /// saved, so each is parsed once, not on every pointer move.
  final Map<int, List<Offset01>> _decoded = {};

  List<Offset01> _points(MapStroke s) => _decoded.putIfAbsent(s.id, () => s.offsets);

  void _pushUndo(_Op op) {
    _undo.add(op);
    if (_undo.length > _maxUndo) _undo.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(entitlementsProvider).allows(Feature.initiative)) {
      return Scaffold(appBar: AppBar(title: const Text('Harita')), body: const GmPackLocked(feature: 'Savaş haritası'));
    }
    final state = ref.watch(encounterProvider).value;
    final strokes = ref.watch(mapStrokesProvider).value ?? const <MapStroke>[];
    final db = ref.read(databaseProvider);
    final combatants = state?.combatants ?? const <Combatant>[];
    final placed = [for (final c in combatants) if (c.mapPosition != null) c];
    final unplaced = [for (final c in combatants) if (c.mapPosition == null) c];
    final online = ref.watch(onlineFeatureVisibleProvider);
    final sceneBusy = ref.watch(sceneControllerProvider) is SceneWorking;
    final sceneId = online && ref.watch(sceneVisibleProvider) ? ref.watch(activeSceneIdProvider) : null;
    final background = sceneId == null ? null : ref.watch(sceneImageProvider(sceneId)).value;

    // Undo steps belong to one encounter; a new encounter starts clean.
    if (state != null && state.encounter.id != _undoEncounter) {
      _undo.clear();
      _undoEncounter = state.encounter.id;
    }
    if (_decoded.length > strokes.length + 64) {
      final ids = {for (final s in strokes) s.id};
      _decoded.removeWhere((id, _) => !ids.contains(id));
    }

    final toolbar = _Toolbar(
      tool: _tool,
      color: _color,
      onTool: (t) => setState(() => _tool = t),
      onColor: (c) => setState(() {
        _color = c;
        _tool = _Tool.pen;
      }),
    );
    final canvas = _canvas(context, state, strokes, combatants, placed, background);

    return OnlineSessionScope(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Harita'),
        actions: [
          if (online)
            IconButton(
              key: const Key('scene-open'),
              tooltip: 'Sahneyi canlandır',
              icon: const Icon(Icons.auto_awesome),
              onPressed: sceneBusy ? null : () => showSceneSheet(context, ref),
            ),
          IconButton(
            key: const Key('map-undo'),
            tooltip: 'Geri al',
            icon: const Icon(Icons.undo),
            onPressed: _undo.isEmpty && strokes.isEmpty ? null : _undoLast,
          ),
          IconButton(
            key: const Key('map-grid'),
            tooltip: _grid ? 'Izgarayı gizle' : 'Izgarayı göster',
            icon: Icon(_grid ? Icons.grid_on : Icons.grid_off),
            onPressed: () => setState(() => _grid = !_grid),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear' && await _confirmClear(context)) {
                final rows = [...strokes];
                await db.clearStrokes();
                if (rows.isNotEmpty) setState(() => _pushUndo(_Removed(rows)));
              }
              if (v == 'tokens') await db.clearTokenPositions();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Çizimi temizle')),
              PopupMenuItem(value: 'tokens', child: Text('Jetonları kaldır')),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, box) {
        // Wide screens (landscape phones, tablets): the map takes the full
        // height on the left and the controls go to a column on the right.
        final wide = box.maxWidth > box.maxHeight * 1.15 && box.maxWidth >= 560;
        if (!wide) {
          return Column(children: [
            toolbar,
            const SceneStatusBar(),
            Expanded(child: Align(alignment: Alignment.topCenter, child: canvas)),
            if (unplaced.isNotEmpty) SizedBox(height: 56, child: _tray(unplaced, combatants, placed, Axis.horizontal)),
            _TurnBar(state: state),
          ]);
        }
        final side = (box.maxWidth * 0.34).clamp(280.0, 400.0);
        return Row(children: [
          Expanded(child: Padding(padding: const EdgeInsets.all(8), child: Center(child: canvas))),
          SizedBox(
            width: side,
            child: Column(children: [
              toolbar,
              const SceneStatusBar(),
              Expanded(child: unplaced.isEmpty ? const SizedBox.shrink() : _tray(unplaced, combatants, placed, Axis.vertical)),
              _TurnBar(state: state),
            ]),
          ),
        ]);
      }),
    ));
  }

  Widget _canvas(
      BuildContext context, EncounterState? state, List<MapStroke> strokes, List<Combatant> combatants, List<Combatant> placed, ui.Image? background) {
    final db = ref.read(databaseProvider);
    final scheme = Theme.of(context).colorScheme;
    final current = state?.current;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, box) {
        final side = box.maxWidth;
        Offset01 toMap(Offset local) => Offset01((local.dx / side).clamp(0.0, 1.0), (local.dy / side).clamp(0.0, 1.0));
        Combatant? tokenAt(Offset local) {
          final r = tokenRadius(side) * 1.3; // a little forgiving for fingers
          for (final c in placed.reversed) {
            final p = c.mapPosition!;
            if ((Offset(p.x * side, p.y * side) - local).distance <= r) return c;
          }
          return null;
        }

        return Semantics(
          container: true,
          label: 'Savaş haritası, ${placed.length} jeton${current == null ? '' : ', sıra: ${current.name}'}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              key: const Key('map-canvas'),
              behavior: HitTestBehavior.opaque,
              // Start strokes and token drags where the finger touched, not
              // where the drag was recognised (after the touch slop).
              dragStartBehavior: DragStartBehavior.down,
              onPanStart: (d) {
                final hit = tokenAt(d.localPosition);
                setState(() {
                  if (hit != null) {
                    _dragId = hit.id;
                    _dragPos = hit.mapPosition;
                    return;
                  }
                  // Editing the sketch: show it rather than the picture.
                  if (background != null) ref.read(sceneVisibleProvider.notifier).set(false);
                  if (_tool == _Tool.pen) {
                    _drawing = [toMap(d.localPosition)];
                  } else {
                    _lastErase = toMap(d.localPosition);
                    _erase(strokes, _lastErase!, _lastErase!, side);
                  }
                });
              },
              onPanUpdate: (d) => setState(() {
                if (_dragId != null) {
                  _dragPos = toMap(d.localPosition);
                } else if (_drawing != null) {
                  _drawing!.add(toMap(d.localPosition));
                } else if (_tool == _Tool.eraser) {
                  final to = toMap(d.localPosition);
                  _erase(strokes, _lastErase ?? to, to, side);
                  _lastErase = to;
                }
              }),
              onPanEnd: (_) => _finishGesture(),
              onPanCancel: _finishGesture,
              onTapUp: (d) async {
                final hit = tokenAt(d.localPosition);
                if (hit != null) {
                  _showTokenMenu(context, hit);
                } else if (_tool == _Tool.pen) {
                  // A tap leaves a dot (a tree, a rock, a torch…).
                  final id = await db.addStroke([toMap(d.localPosition)], color: _color);
                  if (mounted) setState(() => _pushUndo(_Added(id)));
                } else {
                  final at = toMap(d.localPosition);
                  _erase(strokes, at, at, side);
                  _commitErase();
                }
              },
              child: CustomPaint(
                painter: MapPainter(
                  background: background,
                  // Over the picture the sketch is hidden: the picture was made from it.
                  strokes: [
                    if (background == null)
                      for (final s in strokes)
                        if (!_erasing.containsKey(s.id)) SketchStroke(_points(s), s.color),
                    if (_drawing != null) SketchStroke(_drawing!, _color),
                  ],
                  tokens: [
                    for (final c in placed)
                      MapToken(
                        position: c.id == _dragId ? _dragPos! : c.mapPosition!,
                        order: combatants.indexOf(c) + 1,
                        label: c.name,
                        isPlayer: c.isPlayer,
                        isCurrent: current?.id == c.id,
                        isDown: c.isDown,
                        hpFraction: (c.hpCurrent != null && (c.hpMax ?? 0) > 0) ? (c.hpCurrent! / c.hpMax!).clamp(0.0, 1.0) : null,
                      ),
                  ],
                  grid: _grid,
                  theme: MapTheme.of(scheme),
                  labelStyle: Theme.of(context).textTheme.labelLarge,
                ),
                size: Size.square(side),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _tray(List<Combatant> unplaced, List<Combatant> combatants, List<Combatant> placed, Axis axis) {
    final db = ref.read(databaseProvider);
    final theme = MapTheme.of(Theme.of(context).colorScheme);
    final chips = [
      for (final c in unplaced)
        ActionChip(
          key: ValueKey('tray-${c.id}'),
          avatar: CircleAvatar(
            backgroundColor: c.isPlayer ? theme.player : theme.foe,
            child: Text('${combatants.indexOf(c) + 1}', style: const TextStyle(fontSize: 11, color: Colors.white)),
          ),
          label: Text(c.name, overflow: TextOverflow.ellipsis),
          tooltip: 'Haritaya koy',
          onPressed: () => db.setTokenPosition(c.id, _freeSpot(placed)),
        ),
    ];
    return ListView(
      key: const Key('token-tray'),
      scrollDirection: axis,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        for (final chip in chips)
          Padding(
            padding: axis == Axis.horizontal ? const EdgeInsets.only(right: 8) : const EdgeInsets.only(bottom: 4),
            child: axis == Axis.horizontal ? chip : Align(alignment: Alignment.centerLeft, child: chip),
          ),
      ],
    );
  }

  Future<void> _undoLast() async {
    final db = ref.read(databaseProvider);
    if (_undo.isEmpty) {
      // Steps from an earlier visit of the map are not known: remove the newest stroke.
      await db.undoStroke();
      return;
    }
    final op = _undo.removeLast();
    setState(() {});
    switch (op) {
      case _Added(:final id):
        await db.deleteStrokes([id]);
      case _Removed(:final rows):
        await db.restoreStrokes(rows);
    }
  }

  void _finishGesture() {
    final db = ref.read(databaseProvider);
    if (_dragId != null && _dragPos != null) {
      db.setTokenPosition(_dragId!, _dragPos);
    } else if (_drawing != null && _drawing!.isNotEmpty) {
      final pts = simplify(_drawing!);
      db.addStroke(pts, color: _color).then((id) {
        if (mounted) setState(() => _pushUndo(_Added(id)));
      });
    }
    _commitErase();
    setState(() {
      _dragId = null;
      _dragPos = null;
      _drawing = null;
      _lastErase = null;
    });
  }

  /// Erases every stroke within the eraser's reach of the swipe [from] → [to];
  /// each stroke is deleted once per gesture.
  void _erase(List<MapStroke> strokes, Offset01 from, Offset01 to, double side) {
    final live = [for (final s in strokes) if (!_erasing.containsKey(s.id)) s];
    final hits = strokesNearPath(live.map((s) => (s.id, _points(s))), from, to, eraserRadius(side) / side);
    if (hits.isEmpty) return;
    for (final s in live) {
      if (hits.contains(s.id)) _erasing[s.id] = s;
    }
    ref.read(databaseProvider).deleteStrokes(hits);
  }

  /// The erase gesture ended: one undo step for everything it removed.
  void _commitErase() {
    if (_erasing.isEmpty) return;
    final rows = _erasing.values.toList();
    _erasing.clear();
    setState(() => _pushUndo(_Removed(rows)));
  }

  /// New tokens line up along the bottom edge, left to right.
  Offset01 _freeSpot(List<Combatant> placed) {
    for (var i = 0; i < 40; i++) {
      final p = Offset01(0.08 + (i % 10) * 0.093, 0.92 - (i ~/ 10) * 0.09);
      final taken = placed.any((c) {
        final q = c.mapPosition!;
        return (q.x - p.x).abs() < 0.04 && (q.y - p.y).abs() < 0.04;
      });
      if (!taken) return p;
    }
    return const Offset01(0.5, 0.5);
  }

  Future<void> _showTokenMenu(BuildContext context, Combatant c) async {
    final db = ref.read(databaseProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text([
              if (c.initiative != null) 'İnisiyatif ${c.initiative}',
              if (c.hpCurrent != null) 'CP ${c.hpCurrent}/${c.hpMax}',
              if (c.ac != null) 'ZS ${c.ac}',
            ].join(' · ')),
          ),
          ListTile(
            key: const Key('token-remove'),
            leading: const Icon(Icons.close),
            title: const Text('Haritadan kaldır'),
            onTap: () {
              db.setTokenPosition(c.id, null);
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  Future<bool> _confirmClear(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Çizim temizlensin mi?'),
          content: const Text('Jetonlar yerinde kalır.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Temizle')),
          ],
        ),
      ) ??
      false;
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.tool, required this.color, required this.onTool, required this.onColor});

  final _Tool tool;
  final int color;
  final ValueChanged<_Tool> onTool;
  final ValueChanged<int> onColor;

  @override
  Widget build(BuildContext context) {
    final theme = MapTheme.of(Theme.of(context).colorScheme);
    final primary = Theme.of(context).colorScheme.primary;
    // Wrap: on narrow phones (or with large text) the colours move to a
    // second line instead of overflowing.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          SegmentedButton<_Tool>(
            segments: const [
              ButtonSegment(value: _Tool.pen, icon: Icon(Icons.edit), label: Text('Çiz')),
              ButtonSegment(value: _Tool.eraser, icon: Icon(Icons.auto_fix_normal), label: Text('Sil')),
            ],
            selected: {tool},
            onSelectionChanged: (v) => onTool(v.first),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < mapPaletteNames.length; i++)
              Semantics(
                button: true,
                selected: tool == _Tool.pen && color == i,
                label: 'Renk: ${mapPaletteNames[i]}',
                excludeSemantics: true,
                child: Tooltip(
                  message: mapPaletteNames[i],
                  child: InkResponse(
                    key: Key('map-color-$i'),
                    onTap: () => onColor(i),
                    radius: 22,
                    // 44 dp touch target around a 30 dp swatch.
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: theme.palette[i],
                            shape: BoxShape.circle,
                            border: Border.all(color: tool == _Tool.pen && color == i ? primary : Colors.transparent, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ],
      ),
    );
  }
}

/// Run combat from the map: whose turn it is and the next-turn button.
class _TurnBar extends ConsumerWidget {
  const _TurnBar({required this.state});

  final EncounterState? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final current = state?.current;
    final db = ref.read(databaseProvider);
    return Material(
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          child: Row(children: [
            Expanded(
              child: Text(
                current == null ? 'Karşılaşma boş' : '${state!.encounter.round}. tur · Sıra: ${current.name}',
                key: const Key('map-turn'),
                overflow: TextOverflow.ellipsis,
                style: t.titleMedium,
              ),
            ),
            FilledButton.icon(
              key: const Key('map-next-turn'),
              onPressed: current == null ? null : db.nextTurn,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Sonraki'),
            ),
          ]),
        ),
      ),
    );
  }
}
