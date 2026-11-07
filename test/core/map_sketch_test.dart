import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
