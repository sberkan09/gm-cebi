import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/data/neuracraft/client.dart' show maxRegionsBytes;
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/map_sketch.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simplify drops near-duplicate points but keeps the ends', () {
    final pts = [for (var i = 0; i <= 100; i++) Offset01(i / 1000, 0)]; // 0.001 apart
    final s = simplify(pts, minStep: 0.004);
    expect(s.first, pts.first);
    expect(s.last, pts.last);
    expect(s.length, lessThan(30));
    expect(simplify(const [Offset01(0, 0)]), const [Offset01(0, 0)]);
  });

  test('strokesNear finds strokes crossing the eraser and dots under it', () {
    final strokes = [
      (1, const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)]), // horizontal line
      (2, const [Offset01(0.5, 0.1), Offset01(0.5, 0.2)]), // short line far above
      (3, const [Offset01(0.52, 0.52)]), // a dot
    ];
    expect(strokesNear(strokes, const Offset01(0.5, 0.51), 0.03), [1, 3]);
    expect(strokesNear(strokes, const Offset01(0.5, 0.15), 0.01), [2]);
    expect(strokesNear(strokes, const Offset01(0.05, 0.05), 0.01), isEmpty);
  });

  test('a fast eraser swipe across a line erases it', () {
    final strokes = [
      (1, const [Offset01(0.2, 0.3), Offset01(0.7, 0.3)]),
      (2, const [Offset01(0.9, 0.9), Offset01(0.95, 0.95)]),
    ];
    // Two pointer events far apart, neither near the line by itself.
    expect(strokesNear(strokes, const Offset01(0.45, 0.1), 0.03), isEmpty);
    expect(strokesNear(strokes, const Offset01(0.45, 0.5), 0.03), isEmpty);
    expect(strokesNearPath(strokes, const Offset01(0.45, 0.1), const Offset01(0.45, 0.5), 0.03), [1]);
  });

  test('terrain export is black on white, square, without tokens or grid', () async {
    final png = await renderTerrainPng(const [
      SketchStroke([Offset01(0.1, 0.5), Offset01(0.9, 0.5)], 1), // water colour still exports black
    ], size: 128);
    final codec = await ui.instantiateImageCodec(png);
    final image = (await codec.getNextFrame()).image;
    expect(image.width, 128);
    expect(image.height, 128);
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    Color at(int x, int y) {
      final i = (y * 128 + x) * 4;
      return Color.fromARGB(data.getUint8(i + 3), data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2));
    }

    expect(at(64, 64), const Color(0xFF000000), reason: 'stroke pixel is black');
    expect(at(64, 10), const Color(0xFFFFFFFF), reason: 'paper is white');
    // Grid lines would sit at multiples of 128/20 = 6.4 px; a column away from the stroke stays white.
    for (var y = 0; y < 50; y++) {
      expect(at(32, y), const Color(0xFFFFFFFF));
    }
    // Only pure black/white/antialiased greys: no token colours.
    for (var i = 0; i < data.lengthInBytes; i += 4) {
      final r = data.getUint8(i), g = data.getUint8(i + 1), b = data.getUint8(i + 2);
      expect((r - g).abs() <= 2 && (g - b).abs() <= 2, isTrue);
    }
  });

  Future<(int, int, Color Function(int, int))> decode(Uint8List png) async {
    final codec = await ui.instantiateImageCodec(png);
    final image = (await codec.getNextFrame()).image;
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final w = image.width;
    return (
      w,
      image.height,
      (int x, int y) {
        final i = (y * w + x) * 4;
        return Color.fromARGB(data.getUint8(i + 3), data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2));
      }
    );
  }

  test('the region palette is the contract with the service (neuracraft-cloud #42)', () {
    expect({for (final k in RegionKind.values) k.label: k.color.toARGB32()}, {
      'Su': 0xFF2060A0,
      'Yol': 0xFF8C6E48,
      'Orman': 0xFF285C28,
      'Taş zemin': 0xFF808080,
      'Duvar': 0xFF404040,
      'Kum': 0xFFD2B478,
    });
    expect(RegionKind.values.map((k) => k.index), [0, 1, 2, 3, 4, 5], reason: 'stored by index: the order must never change');
  });

  test('area strokes never reach the sketch: only the lines are exported', () async {
    MapStroke row(int id, {int? region, double? width}) => MapStroke(
        id: id, encounterId: 1, points: '0.1000,0.5000 0.9000,0.5000', color: 0, createdAt: DateTime(2026), region: region, width: width);
    final rows = [row(1), row(2, region: 0, width: 0.2), row(3, region: 4, width: 0.05)];
    expect(lineStrokesOf(rows), hasLength(1));
    expect(regionStrokesOf(rows).map((r) => r.kind), [RegionKind.water, RegionKind.wall]);
    expect(regionStrokesOf(rows).first.width, 0.2);

    final linesOnly = await renderTerrainPng(lineStrokesOf([row(1)]), size: 128);
    final withAreas = await renderTerrainPng(lineStrokesOf(rows), size: 128);
    expect(withAreas, linesOnly, reason: 'painting areas leaves the sketch byte for byte the same');
  });

  test('region layer: transparent where unpainted, exact opaque colours at the stroke centres', () async {
    final png = await renderRegionsPng(const [
      RegionStroke([Offset01(0.1, 0.25), Offset01(0.9, 0.25)], RegionKind.water, 0.1),
      RegionStroke([Offset01(0.25, 0.75)], RegionKind.wall, 0.1), // a dot
      RegionStroke([Offset01(0.6, 0.6), Offset01(0.9, 0.9)], RegionKind.sand, 0.05),
    ], size: 512);
    expect(png, isNotNull);
    expect(png!.length, lessThan(maxRegionsBytes));
    final (w, h, at) = await decode(png);
    expect((w, h), (512, 512), reason: 'the size of the sketch');
    expect(at(256, 128), const Color(0xFF2060A0));
    expect(at(128, 384), const Color(0xFF404040));
    expect(at(384, 384), const Color(0xFFD2B478));
    expect(at(256, 128 + 20).toARGB32(), 0xFF2060A0, reason: 'within the 51 px width');
    expect(at(256, 128 + 40).a, 0, reason: 'past the width: unpainted');
    expect(at(10, 500).a, 0);
    expect(at(256, 10).a, 0, reason: 'no paper, no grid');
    // Round caps: the line's end reaches past its last point by half the width.
    expect(at((0.9 * 512 + 20).round(), 128), const Color(0xFF2060A0));
  });

  test('no painted areas: no region layer', () async {
    expect(await renderRegionsPng(const []), isNull);
  });

  test('area strokes are hit anywhere on their painted width', () {
    final strokes = [
      (1, const [Offset01(0.1, 0.5), Offset01(0.9, 0.5)]),
    ];
    expect(strokesNear(strokes, const Offset01(0.5, 0.56), 0.02), isEmpty, reason: 'a pen line that far away is missed');
    expect(strokesNear(strokes, const Offset01(0.5, 0.56), 0.02, pad: (_) => 0.045), [1], reason: 'half of a 0.09 wide area');
  });
}
