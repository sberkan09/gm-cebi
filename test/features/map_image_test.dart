import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/db/database.dart';
import 'package:gm_cebi/features/map_image.dart';
import 'package:gm_cebi/features/map_sketch.dart';

/// A 16 × 8 JPEG stored landscape (left half red, right half blue) with EXIF
/// orientation 6 ("rotate 90° clockwise"): upright it is 8 × 16, red on top.
final rotatedJpeg = base64Decode(
    '/9j/4AAQSkZJRgABAQAAAQABAAD/4QAiRXhpZgAATU0AKgAAAAgAAQESAAMAAAABAAYAAAAAAAD/2wBDAAIBAQEBAQIBAQECAgICAgQDAgICAgUEBAMEBgUGBgYFBgYGBwkIBgcJBwYGCAsICQoKCgoKBggLDAsKDAkKCgr/2wBDAQICAgICAgUDAwUKBwYHCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgr/wAARCAAIABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD4vr5Door+qP2Zf/NV/wDcj/7uH9qftDP+aZ/7nf8A3UP/2Q==');

/// A [width] × [height] picture in one colour.
Future<ui.Image> solid(int width, int height, Color color) {
  final r = ui.PictureRecorder();
  Canvas(r).drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), Paint()..color = color);
  return r.endRecording().toImage(width, height);
}

Future<Uint8List> png(ui.Image image) async => (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();

/// RGBA of one pixel.
Future<List<int>> pixel(ui.Image image, int x, int y) async {
  final b = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  final i = (y * image.width + x) * 4;
  return [b.getUint8(i), b.getUint8(i + 1), b.getUint8(i + 2), b.getUint8(i + 3)];
}

/// What [painter] paints on a [side] × [side] canvas.
Future<ui.Image> paint(MapPainter painter, int side) {
  final r = ui.PictureRecorder();
  painter.paint(Canvas(r), Size.square(side.toDouble()));
  return r.endRecording().toImage(side, side);
}

const paper = Color(0xFF00FF00);
const theme = MapTheme(
  paper: paper,
  grid: Colors.transparent,
  palette: [Colors.black, Colors.black, Colors.black, Colors.black],
  player: Color(0xFF0000FF),
  foe: Color(0xFFFF0000),
  current: Colors.yellow,
  onToken: Color(0xFF0000FF),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sığdır / Doldur: a 2:1 picture in a square map', () {
    // Where a corner of the picture lands on the map.
    Offset land(({Rect src, Rect dst}) r, Offset corner) {
      final s = r.dst.width / r.src.width;
      return r.dst.topLeft + (corner - r.src.topLeft) * s;
    }

    const w = 200.0, h = 100.0, side = 100.0;
    const corners = [Offset(0, 0), Offset(w, 0), Offset(0, h), Offset(w, h)];

    test('Sığdır (contain, default): all of it, centred, paper above and below', () {
      final r = fitRects(MapFit.contain, w, h, side);
      expect(r.src, const Rect.fromLTWH(0, 0, w, h));
      expect(r.dst, const Rect.fromLTWH(0, 25, 100, 50));
      expect([for (final c in corners) land(r, c)], const [Offset(0, 25), Offset(100, 25), Offset(0, 75), Offset(100, 75)]);
      expect(MapFit.of('contain'), MapFit.contain);
      expect(MapFit.of('anything else'), MapFit.contain);
    });

    test('Doldur (cover): the square filled, the sides cropped evenly', () {
      final r = fitRects(MapFit.cover, w, h, side);
      expect(r.src, const Rect.fromLTWH(50, 0, 100, 100));
      expect(r.dst, const Rect.fromLTWH(0, 0, 100, 100));
      // The corners fall outside the map: a quarter of the width cut on each side.
      expect([for (final c in corners) land(r, c)], const [Offset(-50, 0), Offset(150, 0), Offset(-50, 100), Offset(150, 100)]);
      // A tall picture: top and bottom cropped.
      expect(fitRects(MapFit.cover, 100, 300, 50).src, const Rect.fromLTWH(0, 100, 100, 100));
    });

    test('the painter places the picture so: paper around it with Sığdır, none with Doldur', () async {
      final red = await solid(200, 100, const Color(0xFFFF0000));
      Future<ui.Image> map(MapFit fit) => paint(MapPainter(strokes: const [], tokens: const [], grid: false, theme: theme, background: red, backgroundFit: fit), 100);
      final contain = await map(MapFit.contain);
      expect(await pixel(contain, 50, 10), [0, 255, 0, 255], reason: 'paper above the picture');
      expect(await pixel(contain, 50, 90), [0, 255, 0, 255], reason: 'paper below');
      expect(await pixel(contain, 2, 50), [255, 0, 0, 255], reason: 'the whole width is shown');
      final cover = await map(MapFit.cover);
      expect(await pixel(cover, 50, 2), [255, 0, 0, 255]);
      expect(await pixel(cover, 50, 97), [255, 0, 0, 255]);
    });
  });

  group('picking: limits and formats', () {
    test('a small picture is kept as it is', () async {
      final bytes = await png(await solid(30, 20, Colors.red));
      final p = await prepareMapImage(bytes);
      expect(p.bytes, bytes);
      expect((p.width, p.height), (30, 20));
    });

    test('not a picture: refused with its message', () async {
      for (final junk in [Uint8List.fromList(utf8.encode('bu bir resim değil')), Uint8List(0), Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 1, 2, 3])]) {
        await expectLater(prepareMapImage(junk), throwsA(isA<MapImageException>().having((e) => e.message, 'message', notAnImageMessage)));
      }
      expect(notAnImageMessage, 'Bu dosya bir resim olarak açılamadı');
    });

    test('a side over 4096 px: scaled to 2048 px on the longer side, stored as PNG', () async {
      final p = await prepareMapImage(await png(await solid(5000, 50, Colors.blue)));
      expect((p.width, p.height), (2048, 20));
      expect(p.bytes.sublist(0, 4), [0x89, 0x50, 0x4e, 0x47]);
      final back = await decodeForDisplay(p.bytes);
      expect((back.width, back.height), (2048, 20));
    });

    test('a file over the size limit is re-encoded smaller, even with a small picture', () async {
      final small = await png(await solid(100, 50, Colors.blue));
      // Bytes after the end of the PNG: decoders ignore them, but the file is "large".
      final padded = Uint8List.fromList([...small, ...List.filled(5000, 0)]);
      final p = await prepareMapImage(padded, keepBytes: 1000);
      expect(p.bytes.length, lessThan(padded.length));
      expect((p.width, p.height), (100, 50));
    });

    test('still too large after scaling down: refused with its message', () async {
      final bytes = await png(await solid(3000, 3000, Colors.blue));
      await expectLater(prepareMapImage(bytes, keepBytes: 10, maxStored: 10),
          throwsA(isA<MapImageException>().having((e) => e.message, 'message', imageTooLargeMessage)));
      expect(imageTooLargeMessage, 'Resim çok büyük; daha küçük bir resim dene');
    });

    test('a JPEG with an EXIF rotation is stored with its upright size and shows upright', () async {
      final p = await prepareMapImage(rotatedJpeg);
      expect((p.width, p.height), (8, 16), reason: 'stored 16 × 8, shown 8 × 16');
      final image = await decodeForDisplay(p.bytes);
      expect((image.width, image.height), (8, 16));
      final top = await pixel(image, 4, 2), bottom = await pixel(image, 4, 13);
      expect(top[0], greaterThan(200), reason: 'red on top');
      expect(top[2], lessThan(60));
      expect(bottom[2], greaterThan(200), reason: 'blue at the bottom');
      expect(bottom[0], lessThan(60));
    });

    test('the screen gets at most 2048 px on the longer side', () async {
      final image = await decodeForDisplay(await png(await solid(3000, 1500, Colors.blue)));
      expect((image.width, image.height), (2048, 1024));
    });
  });

  group('background choice', () {
    test('only the pictures that exist can be chosen', () {
      expect(backgroundChoices(hasUpload: false, hasOnline: false), [MapBackground.none]);
      expect(backgroundChoices(hasUpload: true, hasOnline: false), [MapBackground.none, MapBackground.upload]);
      expect(backgroundChoices(hasUpload: true, hasOnline: true), MapBackground.values);
      expect(MapBackground.values.map((b) => b.label), ['Yok (yalnızca çizim)', 'Yüklediğim resim', 'Çevrimiçi resim']);
    });

    test('a choice whose picture is gone falls back to the other picture, then none', () {
      MapBackground shown(MapBackground c, bool up, bool on) => shownBackground(c, hasUpload: up, hasOnline: on);
      expect(shown(MapBackground.upload, true, true), MapBackground.upload);
      expect(shown(MapBackground.upload, false, true), MapBackground.online);
      expect(shown(MapBackground.upload, false, false), MapBackground.none);
      expect(shown(MapBackground.online, true, true), MapBackground.online);
      expect(shown(MapBackground.online, true, false), MapBackground.upload);
      expect(shown(MapBackground.online, false, false), MapBackground.none);
      expect(shown(MapBackground.none, true, true), MapBackground.none);
      expect(MapBackground.of('garbage'), MapBackground.online);
    });
  });

  group('token size', () {
    test('Küçük / Orta / Büyük', () {
      expect(tokenScales, [0.6, 1.0, 1.5]);
      expect(tokenScaleNames, ['Küçük', 'Orta', 'Büyük']);
      expect([for (final s in [0.6, 1.0, 1.5, 0.7, 2.0]) tokenScaleIndex(s)], [0, 1, 2, 0, 2]);
    });

    test('the painted token follows the scale', () async {
      const side = 300; // tokenRadius 14
      expect(tokenRadius(side.toDouble()), 14);
      Future<ui.Image> token(double scale) => paint(
          MapPainter(
            paper: false,
            strokes: const [],
            grid: false,
            theme: theme,
            tokenScale: scale,
            tokens: const [MapToken(position: Offset01(0.5, 0.5), order: 1, label: 'Goblin', isPlayer: false)],
          ),
          side);
      Future<int> alphaAt(double scale, double dx) async => (await pixel(await token(scale), (150 + dx).round(), 150))[3];
      // 18 px right of the centre: outside a 14 px token, inside a 21 px one.
      expect(await alphaAt(1.0, 18), 0);
      expect(await alphaAt(1.5, 18), 255);
      // 10 px: inside a normal token, outside a small one (8.4 px).
      expect(await alphaAt(1.0, 10), 255);
      expect(await alphaAt(0.6, 10), 0);
    });
  });
}
