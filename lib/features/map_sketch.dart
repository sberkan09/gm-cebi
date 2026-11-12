/// Battle-map drawing: palette, painter, stroke helpers and the exports the
/// online scene sends: the terrain lines alone (docs/spikes/sketch-to-scene/
/// README.md: tokens must not reach the model) and the painted regions as a
/// separate layer (docs/online-scene.md, "Alan katmanı").
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/neuracraft/client.dart' show maxRegionsBytes;
import '../db/database.dart';

const mapPaletteNames = ['Mürekkep', 'Su', 'Bitki', 'Tehlike'];

/// Map colours for the current theme. The palette indexes are stored with
/// each stroke, so they must keep their meaning (0 ink, 1 water, 2 plants,
/// 3 danger).
class MapTheme {
  const MapTheme({
    required this.paper,
    required this.grid,
    required this.palette,
    required this.player,
    required this.foe,
    required this.current,
    required this.onToken,
  });

  factory MapTheme.of(ColorScheme s) {
    final dark = s.brightness == Brightness.dark;
    return MapTheme(
      paper: dark ? const Color(0xFF1E1F25) : const Color(0xFFF7F3EA),
      grid: (dark ? Colors.white : Colors.black).withValues(alpha: 0.07),
      palette: [
        dark ? const Color(0xFFE8E2D4) : const Color(0xFF22232A),
        const Color(0xFF4A90D9),
        const Color(0xFF5BAA5B),
        const Color(0xFFD9534F),
      ],
      player: const Color(0xFF2F6FD0),
      foe: const Color(0xFFC63D3D),
      current: s.primary,
      onToken: Colors.white,
    );
  }

  /// Black ink on white: the terrain export (no theme).
  static const export = MapTheme(
    paper: Colors.white,
    grid: Colors.transparent,
    palette: [Colors.black, Colors.black, Colors.black, Colors.black],
    player: Colors.transparent,
    foe: Colors.transparent,
    current: Colors.transparent,
    onToken: Colors.transparent,
  );

  final Color paper;
  final Color grid;
  final List<Color> palette;
  final Color player;
  final Color foe;
  final Color current;
  final Color onToken;
}

class SketchStroke {
  const SketchStroke(this.points, this.color);
  final List<Offset01> points;
  final int color;
}

/// What the area brush ("Alan") paints. The index is stored with each stroke
/// (`map_strokes.region`), so the order must never change; the colours are the
/// region contract with NeuraCraft Cloud (neuracraft-cloud #42) and are sent
/// exactly, opaque, whatever the app's theme.
enum RegionKind {
  water('Su', Color(0xFF2060A0)),
  road('Yol', Color(0xFF8C6E48)),
  forest('Orman', Color(0xFF285C28)),
  stone('Taş zemin', Color(0xFF808080)),
  wall('Duvar', Color(0xFF404040)),
  sand('Kum', Color(0xFFD2B478));

  const RegionKind(this.label, this.color);

  /// Turkish name on the toolbar.
  final String label;

  /// The exact colour of the region layer.
  final Color color;

  static RegionKind of(int index) => values[index.clamp(0, values.length - 1)];
}

/// Area brush widths (fraction of the map's side): İnce, Orta, Kalın.
const regionWidths = [0.025, 0.05, 0.09];
const regionWidthNames = ['İnce', 'Orta', 'Kalın'];

/// A stroke of the area brush: round caps and joins, [width] in map units.
class RegionStroke {
  const RegionStroke(this.points, this.kind, this.width);
  final List<Offset01> points;
  final RegionKind kind;
  final double width;
}

/// On screen the regions are see-through, so the grid and the lines over them
/// stay readable.
const regionScreenOpacity = 0.45;

class MapToken {
  const MapToken({
    required this.position,
    required this.order,
    required this.label,
    required this.isPlayer,
    this.isCurrent = false,
    this.isDown = false,
    this.hpFraction,
  });

  final Offset01 position;

  /// 1-based place in the initiative order (shown on the token).
  final int order;
  final String label;
  final bool isPlayer;
  final bool isCurrent;
  final bool isDown;
  final double? hpFraction;
}

/// Grid cells per side: 5-foot squares on a 100-foot map.
const mapGridCells = 20;

double strokeWidth(double side) => math.max(2.5, side / 160);
double tokenRadius(double side) => math.max(14, side / 30);
double eraserRadius(double side) => math.max(16, side / 28);

class MapPainter extends CustomPainter {
  MapPainter({
    required this.strokes,
    required this.tokens,
    required this.grid,
    required this.theme,
    this.regions = const [],
    this.regionOpacity = regionScreenOpacity,
    this.labelStyle,
    this.background,
    this.paper = true,
  });

  /// Whether the paper is painted first. False for a layer painted over the
  /// map (the battle map screen paints the saved drawing and what pointer
  /// moves change, the line in progress and the tokens, as two layers).
  final bool paper;

  /// The online picture made from the sketch: the bottom layer, under the
  /// grid, the strokes and the tokens.
  final ui.Image? background;

  /// Painted areas: over the picture, under the grid, the lines and the tokens.
  final List<RegionStroke> regions;

  /// 1 in the region export; see-through on screen.
  final double regionOpacity;

  final List<SketchStroke> strokes;
  final List<MapToken> tokens;
  final bool grid;
  final MapTheme theme;

  /// The app's text style for token numbers (a bare TextStyle would fall back
  /// to the engine's default font, not the theme's).
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (paper) canvas.drawRect(Offset.zero & size, Paint()..color = theme.paper);
    final bg = background;
    if (bg != null) {
      canvas.drawImageRect(
        bg,
        Rect.fromLTWH(0, 0, bg.width.toDouble(), bg.height.toDouble()),
        Rect.fromLTWH(0, 0, side, side),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    paintRegions(canvas, regions, side, opacity: regionOpacity);
    if (grid) {
      final g = Paint()
        ..color = theme.grid
        ..strokeWidth = 1;
      for (var i = 1; i < mapGridCells; i++) {
        final d = side * i / mapGridCells;
        canvas.drawLine(Offset(d, 0), Offset(d, side), g);
        canvas.drawLine(Offset(0, d), Offset(side, d), g);
      }
    }
    final w = strokeWidth(side);
    for (final s in strokes) {
      final paint = Paint()
        ..color = theme.palette[s.color.clamp(0, theme.palette.length - 1)]
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(_px(s.points.first, side), w * 0.9, paint..style = PaintingStyle.fill);
        continue;
      }
      final path = Path()..moveTo(_px(s.points.first, side).dx, _px(s.points.first, side).dy);
      for (final p in s.points.skip(1)) {
        final o = _px(p, side);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, paint);
    }
    for (final t in tokens) {
      _paintToken(canvas, t, side);
    }
  }

  void _paintToken(Canvas canvas, MapToken t, double side) {
    final r = tokenRadius(side);
    final c = _px(t.position, side);
    final base = t.isPlayer ? theme.player : theme.foe;
    final fill = t.isDown ? base.withValues(alpha: 0.35) : base;
    if (t.isCurrent) {
      canvas.drawCircle(c, r + 5, Paint()..color = theme.current);
    }
    canvas.drawCircle(c, r, Paint()..color = fill);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = theme.onToken
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '${t.order}',
        style: (labelStyle ?? const TextStyle())
            .copyWith(color: theme.onToken, fontSize: r * 0.95, fontWeight: FontWeight.w800, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    if (t.isDown) {
      final x = Paint()
        ..color = theme.onToken
        ..strokeWidth = 2.5;
      canvas.drawLine(c + Offset(-r * 0.6, -r * 0.6), c + Offset(r * 0.6, r * 0.6), x);
      canvas.drawLine(c + Offset(-r * 0.6, r * 0.6), c + Offset(r * 0.6, -r * 0.6), x);
    }
    final hp = t.hpFraction;
    if (hp != null) {
      final bar = Rect.fromLTWH(c.dx - r, c.dy + r + (t.isCurrent ? 8 : 3), 2 * r, 4);
      canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(2)), Paint()..color = Colors.black45);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bar.left, bar.top, bar.width * hp, bar.height), const Radius.circular(2)),
        Paint()..color = hp > 0.5 ? const Color(0xFF4CC38A) : (hp > 0.25 ? const Color(0xFFE3A857) : const Color(0xFFE5534B)),
      );
    }
  }

  static Offset _px(Offset01 p, double side) => Offset(p.x * side, p.y * side);

  @override
  bool shouldRepaint(MapPainter old) => true;
}

/// Paints [regions] in their exact colours. Below 1, [opacity] applies to the
/// layer as a whole, so overlapping strokes of one kind do not get darker.
void paintRegions(Canvas canvas, List<RegionStroke> regions, double side, {double opacity = 1}) {
  if (regions.isEmpty || opacity <= 0) return;
  final layered = opacity < 1;
  if (layered) canvas.saveLayer(Offset.zero & Size.square(side), Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
  for (final r in regions) {
    final w = r.width * side;
    final paint = Paint()
      ..color = r.kind.color
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    if (r.points.isEmpty) continue;
    final first = MapPainter._px(r.points.first, side);
    if (r.points.length == 1) {
      canvas.drawCircle(first, w / 2, paint..style = PaintingStyle.fill);
      continue;
    }
    final path = Path()..moveTo(first.dx, first.dy);
    for (final p in r.points.skip(1)) {
      final o = MapPainter._px(p, side);
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(path, paint);
  }
  if (layered) canvas.restore();
}

/// Drops points closer than [minStep] (map units) to the previous kept point;
/// the first and last points always stay.
List<Offset01> simplify(List<Offset01> points, {double minStep = 0.004}) {
  if (points.length < 3) return [...points];
  final out = <Offset01>[points.first];
  for (final p in points.skip(1).take(points.length - 2)) {
    final q = out.last;
    if (math.sqrt(math.pow(p.x - q.x, 2) + math.pow(p.y - q.y, 2)) >= minStep) out.add(p);
  }
  out.add(points.last);
  return out;
}

/// Ids of the strokes passing within [radius] (map units) of [at]. [pad]
/// widens the reach per stroke id (half an area stroke's width: touching its
/// painted edge is enough).
List<int> strokesNear(Iterable<(int, List<Offset01>)> strokes, Offset01 at, double radius, {double Function(int id)? pad}) {
  final hits = <int>[];
  for (final (id, pts) in strokes) {
    final reach = radius + (pad?.call(id) ?? 0);
    if (pts.length == 1) {
      if (_dist(pts.first, at) <= reach) hits.add(id);
      continue;
    }
    for (var i = 0; i + 1 < pts.length; i++) {
      if (_segDist(at, pts[i], pts[i + 1]) <= reach) {
        hits.add(id);
        break;
      }
    }
  }
  return hits;
}

/// Ids of the strokes within [radius] of the eraser's path [from] → [to]
/// (sampled every half radius, so fast swipes do not skip lines).
List<int> strokesNearPath(Iterable<(int, List<Offset01>)> strokes, Offset01 from, Offset01 to, double radius,
    {double Function(int id)? pad}) {
  final list = strokes.toList();
  final steps = math.max(1, (_dist(from, to) / (radius / 2)).ceil());
  final hits = <int>{};
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    hits.addAll(strokesNear(list, Offset01(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t), radius, pad: pad));
  }
  return [...hits];
}

double _dist(Offset01 a, Offset01 b) => math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));

double _segDist(Offset01 p, Offset01 a, Offset01 b) {
  final dx = b.x - a.x, dy = b.y - a.y;
  final len2 = dx * dx + dy * dy;
  if (len2 == 0) return _dist(p, a);
  final t = (((p.x - a.x) * dx + (p.y - a.y) * dy) / len2).clamp(0.0, 1.0);
  return _dist(p, Offset01(a.x + t * dx, a.y + t * dy));
}

/// The pen lines of a map's stroke rows (the sketch), oldest first.
List<SketchStroke> lineStrokesOf(Iterable<MapStroke> rows) => [for (final s in rows) if (!s.isRegion) SketchStroke(s.offsets, s.color)];

/// The area-brush strokes of a map's stroke rows (the region layer), oldest first.
List<RegionStroke> regionStrokesOf(Iterable<MapStroke> rows) =>
    [for (final s in rows) if (s.isRegion) RegionStroke(s.offsets, RegionKind.of(s.region!), s.width ?? regionWidths.last)];

/// The terrain alone (no tokens, no grid, no painted areas) as a
/// black-on-white PNG: the input a sketch-to-scene service gets. Tokens stay
/// in the app and are drawn on top of whatever image comes back.
Future<Uint8List> renderTerrainPng(List<SketchStroke> strokes, {int size = 512}) =>
    _renderPng(size, (canvas) => MapPainter(strokes: strokes, tokens: const [], grid: false, theme: MapTheme.export)
        .paint(canvas, Size.square(size.toDouble())));

/// The region layer: each area stroke in its exact opaque colour on a
/// transparent background (transparent = unpainted), the same size as the
/// sketch. Null when nothing is painted. Throws [RegionsTooLarge] if the PNG is
/// over [maxRegionsBytes] (it is never downscaled: it must match the sketch;
/// flat colours at 512 × 512 compress to a few kilobytes).
Future<Uint8List?> renderRegionsPng(List<RegionStroke> regions, {int size = 512}) async {
  if (regions.isEmpty) return null;
  final png = await _renderPng(size, (canvas) => paintRegions(canvas, regions, size.toDouble()));
  if (png.length > maxRegionsBytes) {
    throw RegionsTooLarge(png.length);
  }
  return png;
}

/// The region layer came out over [maxRegionsBytes].
class RegionsTooLarge implements Exception {
  const RegionsTooLarge(this.bytes);
  final int bytes;
  @override
  String toString() => 'RegionsTooLarge: $bytes bytes, over the $maxRegionsBytes limit';
}

Future<Uint8List> _renderPng(int size, void Function(Canvas canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  picture.dispose();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}
