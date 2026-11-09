import 'dart:async';
import 'dart:math' as math;
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
/// any other drag draws (or erases, in eraser mode). Two fingers pan and zoom.
///
/// Kalem modu (pen mode, turned on by the first stylus touch): only a stylus
/// draws or erases; a finger (or a resting palm) never draws, it pans the map
/// and still moves tokens. The stylus' eraser end or barrel button erases for
/// that stroke, and a hovering stylus shows where it will draw.
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

/// What the pointers on the map are doing.
enum _Gesture { none, pending, draw, erase, token, pan, pinch, ignore }

/// A hovering stylus: where, and whether it would erase.
typedef _Hover = ({Offset at, bool erases});

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

  /// The view: zoom (1×–4×) and pan. The pan is in units of the map's side, so
  /// it survives a resize. Strokes and tokens are stored in map units: every
  /// pointer position goes through [_toMap] before it is used or stored.
  double _scale = 1;
  Offset _pan = Offset.zero;

  /// Pointer routing (see [_onDown]): the gesture, the pointer that owns it
  /// (none for a pinch) and whether that pointer is a stylus. A finger with
  /// pen mode off is [_Gesture.pending] until it moves or lifts, so the start
  /// of a pinch has no side effects (no erase, the picture stays).
  _Gesture _gesture = _Gesture.none;
  int? _pointer;
  bool _byStylus = false;
  Offset _downAt = Offset.zero;

  /// The owning pointer left its slop: not a tap.
  bool _moved = false;

  /// Fingers (and mice) on the map, by pointer id.
  final Map<int, Offset> _touches = {};

  /// The view when the first finger landed: a pan a resting palm made before
  /// the stylus touched is undone.
  (double, Offset)? _viewAtTouch;
  Offset _panFrom = Offset.zero, _panStart = Offset.zero;
  Offset _pinchFocal = Offset.zero, _pinchPan = Offset.zero;
  double _pinchSpan = 1, _pinchScale = 1;

  /// A hovering stylus (its own listenable: hover events come at 120–240 Hz).
  final _hover = ValueNotifier<_Hover?>(null);
  Timer? _hoverTimer;

  /// Bumped on pointer moves: repaints the canvas without rebuilding the screen.
  final _canvasTick = ValueNotifier<int>(0);

  /// From the last build, for the pointer handlers.
  double _side = 1;
  List<MapStroke> _strokes = const [];
  List<Combatant> _placed = const [];
  bool _hasBackground = false;

  bool get _penActive => _byStylus && _pointer != null;

  /// Decoded points per stroke id. Strokes never change after they are
  /// saved, so each is parsed once, not on every pointer move.
  final Map<int, List<Offset01>> _decoded = {};

  List<Offset01> _points(MapStroke s) => _decoded.putIfAbsent(s.id, () => s.offsets);

  void _pushUndo(_Op op) {
    _undo.add(op);
    if (_undo.length > _maxUndo) _undo.removeAt(0);
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _hover.dispose();
    _canvasTick.dispose();
    super.dispose();
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

    final penMode = ref.watch(currentSettingsProvider.select((s) => s.penMode));
    final toolbar = _Toolbar(
      tool: _tool,
      color: _color,
      penMode: penMode,
      onPenMode: (v) => ref.read(settingsProvider.notifier).setPenMode(v),
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
    final scheme = Theme.of(context).colorScheme;
    final theme = MapTheme.of(scheme);
    final current = state?.current;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, box) {
        final side = box.maxWidth;
        _side = side;
        _strokes = strokes;
        _placed = placed;
        _hasBackground = background != null;

        return Semantics(
          container: true,
          label: 'Savaş haritası, ${placed.length} jeton${current == null ? '' : ', sıra: ${current.name}'}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // Pointer moves repaint only this, not the whole screen.
            child: ValueListenableBuilder<int>(
              valueListenable: _canvasTick,
              builder: (context, _, _) => Stack(children: [
                MouseRegion(
                  opaque: false,
                  onExit: (_) => _clearHover(),
                  // A raw listener, not a GestureDetector: pointers are routed
                  // by kind (stylus or finger) and count; a stylus stroke
                  // starts on pointer-down, exactly where the pen touched.
                  child: Listener(
                    key: const Key('map-canvas'),
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _onDown,
                    onPointerMove: _onMove,
                    onPointerUp: _onUp,
                    onPointerCancel: (e) => _onUp(e, cancelled: true),
                    onPointerHover: _onHover,
                    child: SizedBox.square(
                      dimension: side,
                      child: Stack(children: [
                        Transform(
                          key: const Key('map-view'),
                          transform: Matrix4.diagonal3Values(_scale, _scale, 1)..setTranslationRaw(_pan.dx * side, _pan.dy * side, 0),
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
                              theme: theme,
                              labelStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                            size: Size.square(side),
                          ),
                        ),
                        // The hover cursor has its own listenable: a hovering
                        // stylus (120–240 events a second) repaints only this.
                        ValueListenableBuilder<_Hover?>(
                          valueListenable: _hover,
                          builder: (context, h, _) => h == null
                              ? const SizedBox.shrink()
                              : IgnorePointer(
                                  child: CustomPaint(
                                    key: ValueKey(h.erases ? 'map-hover-eraser' : 'map-hover-pen'),
                                    painter: _CursorPainter(
                                      at: h.at,
                                      eraser: h.erases,
                                      // On screen: the eraser keeps its size when zoomed, the pen line grows with the map.
                                      radius: h.erases ? eraserRadius(side) : strokeWidth(side) * _scale / 2,
                                      color: theme.palette[_color],
                                      outline: scheme.onSurface,
                                    ),
                                    size: Size.square(side),
                                  ),
                                ),
                        ),
                      ]),
                    ),
                  ),
                ),
                if (_scale > 1.001)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton.filledTonal(
                      key: const Key('map-fit'),
                      tooltip: 'Haritayı sığdır',
                      icon: const Icon(Icons.fit_screen),
                      onPressed: () => setState(() => _setView(1, Offset.zero)),
                    ),
                  ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // ------------------------------------------------------------ pointers

  void _repaint() => _canvasTick.value++;

  /// Screen (canvas-local) position → map units, through the view transform.
  Offset01 _toMap(Offset local) {
    final x = (local.dx / _side - _pan.dx) / _scale, y = (local.dy / _side - _pan.dy) / _scale;
    return Offset01(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
  }

  Combatant? _tokenAt(Offset local) {
    final at = _toMap(local);
    final r = tokenRadius(_side) * 1.3 / _side; // a little forgiving for fingers
    for (final c in _placed.reversed) {
      final p = c.mapPosition!;
      if (math.sqrt(math.pow(p.x - at.x, 2) + math.pow(p.y - at.y, 2)) <= r) return c;
    }
    return null;
  }

  /// Zoom 1×–4×; the pan keeps the map covering the whole canvas, so it
  /// can never be lost off screen.
  void _setView(double scale, Offset pan) {
    final s = scale.clamp(1.0, 4.0);
    _scale = s;
    _pan = Offset(pan.dx.clamp(1 - s, 0.0), pan.dy.clamp(1 - s, 0.0));
  }

  static bool _isStylus(PointerDeviceKind k) => k == PointerDeviceKind.stylus || k == PointerDeviceKind.invertedStylus;

  /// The stylus' eraser end, or its barrel button: erase, for this gesture only.
  static bool _stylusErases(PointerEvent e) =>
      e.kind == PointerDeviceKind.invertedStylus || (e.kind == PointerDeviceKind.stylus && e.buttons & kSecondaryStylusButton != 0);

  /// Routes a new pointer:
  /// - a stylus always draws or erases at once (and turns pen mode on the first
  ///   time, unless the user decided); it wins over whatever fingers or a palm
  ///   were doing;
  /// - one finger: on a token it moves the token; elsewhere, in pen mode, it
  ///   pans the map (palm rejection); otherwise it is pending until it moves
  ///   past the touch slop (draw or erase) or lifts (a dot, or a tap-erase);
  /// - a second finger: pinch to zoom and pan. A pending finger had no effect
  ///   yet; a stroke or erase the first finger began is dropped.
  void _onDown(PointerDownEvent e) {
    if (_isStylus(e.kind)) {
      _clearHover();
      ref.read(settingsProvider.notifier).stylusSeen();
      if (_penActive) return; // one pen at a time
      _dropTouchGesture(revertPalmPan: true);
      _begin(e.pointer, e.localPosition, stylus: true, erases: _stylusErases(e));
      return;
    }
    if (e.kind == PointerDeviceKind.mouse && e.buttons & kPrimaryMouseButton == 0) return; // right/middle click
    _touches[e.pointer] = e.localPosition;
    if (_penActive) return; // a palm resting while the pen draws
    if (_touches.length == 1) {
      _viewAtTouch = (_scale, _pan);
      final local = e.localPosition;
      if (_tokenAt(local) != null) {
        _begin(e.pointer, local, stylus: false, erases: false);
      } else if (ref.read(currentSettingsProvider).penMode) {
        _startPan(e.pointer, local);
      } else if (e.kind == PointerDeviceKind.touch) {
        _gesture = _Gesture.pending;
        _pointer = e.pointer;
        _byStylus = false;
        _downAt = local;
        _moved = false;
      } else {
        _begin(e.pointer, local, stylus: false, erases: false); // a mouse cannot pinch: no need to wait
      }
    } else if (_touches.length == 2) {
      _dropTouchGesture(revertPalmPan: false);
      _startPinch();
    }
  }

  /// Starts drawing, erasing or moving a token at [local].
  void _begin(int pointer, Offset local, {required bool stylus, required bool erases}) {
    final hit = erases ? null : _tokenAt(local);
    _pointer = pointer;
    _byStylus = stylus;
    _downAt = local;
    _moved = false;
    setState(() {
      if (hit != null) {
        _gesture = _Gesture.token;
        _dragId = hit.id;
        _dragPos = hit.mapPosition;
        return;
      }
      // Editing the sketch: show it rather than the picture.
      if (_hasBackground) ref.read(sceneVisibleProvider.notifier).set(false);
      if (erases || _tool == _Tool.eraser) {
        _gesture = _Gesture.erase;
        _lastErase = _toMap(local);
        _erase(_lastErase!, _lastErase!);
      } else {
        _gesture = _Gesture.draw;
        _drawing = [_toMap(local)];
      }
    });
  }

  void _startPan(int pointer, Offset local) {
    _gesture = _Gesture.pan;
    _pointer = pointer;
    _byStylus = false;
    _downAt = local;
    _moved = false;
    _panFrom = local;
    _panStart = _pan;
  }

  (Offset, double) _pinchGeometry() {
    final p = _touches.values.take(2).toList();
    return ((p[0] + p[1]) / 2, (p[0] - p[1]).distance);
  }

  void _startPinch() {
    final (focal, span) = _pinchGeometry();
    _gesture = _Gesture.pinch;
    _pointer = null;
    _byStylus = false;
    _pinchFocal = focal;
    _pinchSpan = math.max(span, 1);
    _pinchScale = _scale;
    _pinchPan = _pan;
  }

  void _updatePinch() {
    final (focal, span) = _pinchGeometry();
    final s = (_pinchScale * span / _pinchSpan).clamp(1.0, 4.0);
    // The map point that was under the fingers' midpoint stays under it.
    final m = (_pinchFocal / _side - _pinchPan) / _pinchScale;
    _setView(s, focal / _side - m * s);
    _repaint();
  }

  /// Drops what the fingers were doing, leaving no trace: a stroke the palm
  /// (or the first of two fingers) began, a token drag, and anything its
  /// eraser removed is put back. With [revertPalmPan], a one-finger pan (a
  /// palm resting before the stylus touched) is undone too; a two-finger
  /// zoom is deliberate and stays.
  void _dropTouchGesture({required bool revertPalmPan}) {
    final view = _viewAtTouch;
    if (revertPalmPan && view != null && _gesture == _Gesture.pan) _setView(view.$1, view.$2);
    if (_erasing.isNotEmpty) {
      ref.read(databaseProvider).restoreStrokes(_erasing.values.toList());
      _erasing.clear();
    }
    setState(() {
      _gesture = _touches.isEmpty ? _Gesture.none : _Gesture.ignore;
      _pointer = null;
      _byStylus = false;
      _drawing = null;
      _lastErase = null;
      _dragId = null;
      _dragPos = null;
    });
  }

  void _onMove(PointerMoveEvent e) {
    if (_touches.containsKey(e.pointer)) _touches[e.pointer] = e.localPosition;
    if (_gesture == _Gesture.pinch) {
      if (_touches.containsKey(e.pointer)) _updatePinch();
      return;
    }
    if (e.pointer != _pointer) return;
    final local = e.localPosition;
    // A finger may wobble a little during a tap; a stylus is precise.
    if ((local - _downAt).distance > (e.kind == PointerDeviceKind.touch ? kTouchSlop : 4)) _moved = true;
    if (_gesture == _Gesture.pending) {
      if (!_moved) return;
      // A real drag, not the start of a pinch: draw (or erase) from where the finger touched.
      _begin(e.pointer, _downAt, stylus: false, erases: false);
      _moved = true;
    }
    switch (_gesture) {
      case _Gesture.token:
        _dragPos = _toMap(local);
      case _Gesture.draw:
        _drawing!.add(_toMap(local));
      case _Gesture.erase:
        final to = _toMap(local);
        _erase(_lastErase ?? to, to);
        _lastErase = to;
      case _Gesture.pan:
        _setView(_scale, _panStart + (local - _panFrom) / _side);
      case _Gesture.none || _Gesture.pending || _Gesture.pinch || _Gesture.ignore:
        return;
    }
    _repaint();
  }

  void _onUp(PointerEvent e, {bool cancelled = false}) {
    final wasTouch = _touches.remove(e.pointer) != null;
    if (_gesture == _Gesture.pinch) {
      if (!wasTouch) return;
      setState(() {
        if (_touches.length >= 2) {
          _startPinch(); // a third finger lifted: go on with the other two
        } else if (_touches.length == 1 && ref.read(currentSettingsProvider).penMode) {
          // Pen mode: the finger that stayed keeps panning. The zoom so far was
          // deliberate: a stylus landing now keeps it.
          final rest = _touches.entries.single;
          _startPan(rest.key, rest.value);
          _viewAtTouch = (_scale, _pan);
          _moved = true;
        } else {
          _gesture = _touches.isEmpty ? _Gesture.none : _Gesture.ignore;
        }
      });
      return;
    }
    if (e.pointer != _pointer) {
      if (_touches.isEmpty && _gesture == _Gesture.ignore) _gesture = _Gesture.none;
      return;
    }
    if (_gesture == _Gesture.pending) {
      if (cancelled) {
        _dropTouchGesture(revertPalmPan: false);
        return;
      }
      // A tap: a dot, or a tap of the eraser.
      _begin(e.pointer, _downAt, stylus: false, erases: false);
    }
    _finishGesture(tap: !_moved && !cancelled, cancelled: cancelled);
  }

  void _onHover(PointerHoverEvent e) {
    if (!_isStylus(e.kind)) return;
    // Not every platform says when the pen leaves: hide the cursor when the
    // hover stops.
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(seconds: 2), _clearHover);
    _hover.value = (at: e.localPosition, erases: _stylusErases(e) || _tool == _Tool.eraser);
  }

  void _clearHover() {
    _hoverTimer?.cancel();
    _hoverTimer = null;
    if (mounted) _hover.value = null;
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

  /// The owning pointer lifted: a tap on a token opens its menu, a tap
  /// elsewhere leaves a dot; a drag saves the stroke or the token's place.
  void _finishGesture({required bool tap, bool cancelled = false}) {
    final db = ref.read(databaseProvider);
    final moved = !tap && !cancelled;
    switch (_gesture) {
      case _Gesture.token:
        final hit = _placed.where((c) => c.id == _dragId).firstOrNull;
        if (tap && hit != null) {
          _showTokenMenu(context, hit);
        } else if (moved && _dragPos != null) {
          db.setTokenPosition(_dragId!, _dragPos);
        }
      case _Gesture.draw when _drawing != null && _drawing!.isNotEmpty && (tap || moved):
        // A tap leaves a dot (a tree, a rock, a torch…).
        final pts = tap ? [_drawing!.first] : simplify(_drawing!);
        db.addStroke(pts, color: _color).then((id) {
          if (mounted) setState(() => _pushUndo(_Added(id)));
        });
      case _Gesture.none || _Gesture.pending || _Gesture.draw || _Gesture.erase || _Gesture.pan || _Gesture.pinch || _Gesture.ignore:
        break;
    }
    _commitErase();
    setState(() {
      _gesture = _touches.isEmpty ? _Gesture.none : _Gesture.ignore;
      _pointer = null;
      _byStylus = false;
      _dragId = null;
      _dragPos = null;
      _drawing = null;
      _lastErase = null;
    });
  }

  /// Erases every stroke within the eraser's reach of the swipe [from] → [to];
  /// each stroke is deleted once per gesture. The reach is the same on screen
  /// at any zoom, so a zoomed-in eraser is finer.
  void _erase(Offset01 from, Offset01 to) {
    final live = [for (final s in _strokes) if (!_erasing.containsKey(s.id)) s];
    final hits = strokesNearPath(live.map((s) => (s.id, _points(s))), from, to, eraserRadius(_side) / _side / _scale);
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

  /// New tokens line up along the bottom edge of the part of the map in view
  /// (all of it unless zoomed in), left to right.
  Offset01 _freeSpot(List<Combatant> placed) {
    // The visible square in map units: screen 0…1 through the view transform.
    final left = -_pan.dx / _scale, top = -_pan.dy / _scale, size = 1 / _scale;
    final tol = 0.04 * size;
    Offset01 inView(double x, double y) => Offset01(left + x * size, top + y * size);
    for (var i = 0; i < 40; i++) {
      final p = inView(0.08 + (i % 10) * 0.093, 0.92 - (i ~/ 10) * 0.09);
      final taken = placed.any((c) {
        final q = c.mapPosition!;
        return (q.x - p.x).abs() < tol && (q.y - p.y).abs() < tol;
      });
      if (!taken) return p;
    }
    return inView(0.5, 0.5);
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
  const _Toolbar({
    required this.tool,
    required this.color,
    required this.penMode,
    required this.onTool,
    required this.onColor,
    required this.onPenMode,
  });

  final _Tool tool;
  final int color;
  final bool penMode;
  final ValueChanged<bool> onPenMode;
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
          // Pen mode: only the stylus draws, fingers pan and zoom. Its own
          // Wrap child, so with large text it moves down instead of overflowing.
          Semantics(
            toggled: penMode,
            child: IconButton(
              key: const Key('map-pen-mode'),
              tooltip: 'Kalem modu',
              isSelected: penMode,
              icon: const Icon(Icons.draw_outlined),
              selectedIcon: const Icon(Icons.draw),
              onPressed: () => onPenMode(!penMode),
            ),
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

/// Where a hovering stylus would draw (a ring in the pen's colour around the
/// line's width) or erase (the eraser's reach). Screen coordinates.
class _CursorPainter extends CustomPainter {
  const _CursorPainter({required this.at, required this.eraser, required this.radius, required this.color, required this.outline});

  final Offset at;
  final bool eraser;
  final double radius;
  final Color color;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    if (eraser) {
      canvas.drawCircle(at, radius, Paint()..color = outline.withValues(alpha: 0.12));
      canvas.drawCircle(
        at,
        radius,
        Paint()
          ..color = outline.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      return;
    }
    canvas.drawCircle(at, radius, Paint()..color = color.withValues(alpha: 0.6));
    canvas.drawCircle(
      at,
      radius + 4,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_CursorPainter old) =>
      old.at != at || old.eraser != eraser || old.radius != radius || old.color != color || old.outline != outline;
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
