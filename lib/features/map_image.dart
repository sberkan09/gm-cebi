/// The user's own picture as the battle map: checking and shrinking a picked
/// file, laying a non-square picture into the square map ("Sığdır" /
/// "Doldur"), which background is shown, the token size, and the decoded
/// image cache. The picture never leaves the device: nothing here talks to a
/// server, and the online scene sends the drawing only.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers.dart';
import 'online_scene/online_settings.dart';
import 'online_scene/scene_controller.dart';

export 'map_sketch.dart' show MapFit, fitRects;

/// What is under the map ([Encounters.mapBackground]).
enum MapBackground {
  none('Yok (yalnızca çizim)'),
  upload('Yüklediğim resim'),
  online('Çevrimiçi resim');

  const MapBackground(this.label);
  final String label;

  static MapBackground of(String name) => values.firstWhere((b) => b.name == name, orElse: () => online);
}

/// The background shown for the stored [chosen] one: a choice whose picture
/// does not exist (removed, or the online feature switched off) falls back to
/// the other picture, then to none.
MapBackground shownBackground(MapBackground chosen, {required bool hasUpload, required bool hasOnline}) => switch (chosen) {
      MapBackground.none => MapBackground.none,
      MapBackground.upload => hasUpload ? MapBackground.upload : (hasOnline ? MapBackground.online : MapBackground.none),
      MapBackground.online => hasOnline ? MapBackground.online : (hasUpload ? MapBackground.upload : MapBackground.none),
    };

/// "Jeton boyutu": Küçük, Orta, Büyük (factors of `tokenRadius`).
const tokenScales = [0.6, 1.0, 1.5];
const tokenScaleNames = ['Küçük', 'Orta', 'Büyük'];

/// Index into [tokenScales] of a stored scale (the nearest one).
int tokenScaleIndex(double scale) {
  var best = 1;
  for (var i = 0; i < tokenScales.length; i++) {
    if ((tokenScales[i] - scale).abs() < (tokenScales[best] - scale).abs()) best = i;
  }
  return best;
}

// ---------------------------------------------------------------- picking and limits

/// A file this size or smaller (and [keepMaxSide] px or smaller) is kept as it is.
const keepMaxBytes = 6 * 1024 * 1024;
const keepMaxSide = 4096;

/// Larger files are scaled down to this longer side and stored as PNG.
const shrinkSide = 2048;

/// A stored picture is never larger than this.
const maxStoredBytes = 12 * 1024 * 1024;

/// Files larger than this are refused before they are read.
const maxPickBytes = 64 * 1024 * 1024;

/// Pictures are decoded for the screen at no more than this longer side.
const displayMaxSide = 2048;

const notAnImageMessage = 'Bu dosya bir resim olarak açılamadı';
const imageTooLargeMessage = 'Resim çok büyük; daha küçük bir resim dene';

/// A refused picture; [message] is shown as is.
class MapImageException implements Exception {
  const MapImageException(this.message);
  final String message;
  @override
  String toString() => 'MapImageException: $message';
}

/// A picked picture ready to store: its bytes and its size as shown.
typedef PreparedMapImage = ({Uint8List bytes, int width, int height});

/// Checks a picked file and makes what is stored: the original file when it
/// is at most [keepMaxBytes] and [keepMaxSide] px, otherwise a PNG scaled down
/// to [shrinkSide] px on the longer side. Whatever `dart:ui` decodes is
/// accepted (PNG, JPEG, WebP, GIF's first frame, BMP…); the size is read as
/// shown, so a JPEG's EXIF rotation is applied (the engine's decoder does it).
/// Throws a [MapImageException] with [notAnImageMessage] or [imageTooLargeMessage].
/// [keepBytes] and [maxStored] are lowered in tests.
Future<PreparedMapImage> prepareMapImage(Uint8List bytes, {int keepBytes = keepMaxBytes, int maxStored = maxStoredBytes}) async {
  if (bytes.length > maxPickBytes) throw const MapImageException(imageTooLargeMessage);
  final ui.ImageDescriptor descriptor;
  try {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    buffer.dispose();
  } catch (_) {
    throw const MapImageException(notAnImageMessage);
  }
  try {
    final w = descriptor.width, h = descriptor.height;
    if (w <= 0 || h <= 0) throw const MapImageException(notAnImageMessage);
    final longer = math.max(w, h);
    if (bytes.length <= keepBytes && longer <= keepMaxSide) {
      // Decoded once (small) to be sure the whole file opens, not just its header.
      final probe = _target(w, h, 64);
      final image = await _decode(descriptor, probe.$1, probe.$2);
      image.dispose();
      return (bytes: bytes, width: w, height: h);
    }
    final t = _target(w, h, shrinkSide);
    final image = await _decode(descriptor, t.$1, t.$2);
    final ByteData? png;
    try {
      png = await image.toByteData(format: ui.ImageByteFormat.png);
    } finally {
      image.dispose();
    }
    if (png == null) throw const MapImageException(notAnImageMessage);
    if (png.lengthInBytes > maxStored) throw const MapImageException(imageTooLargeMessage);
    return (bytes: png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes), width: t.$1, height: t.$2);
  } finally {
    descriptor.dispose();
  }
}

/// [w] × [h] scaled so the longer side is at most [max] (never up).
(int, int) _target(int w, int h, int max) {
  final longer = math.max(w, h);
  if (longer <= max) return (w, h);
  final s = max / longer;
  return (math.max(1, (w * s).round()), math.max(1, (h * s).round()));
}

Future<ui.Image> _decode(ui.ImageDescriptor d, int width, int height) async {
  try {
    final codec = await d.instantiateCodec(targetWidth: width, targetHeight: height);
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  } catch (_) {
    throw const MapImageException(notAnImageMessage);
  }
}

/// Decodes stored picture [bytes] for the screen, at most [displayMaxSide]
/// px on the longer side.
Future<ui.Image> decodeForDisplay(Uint8List bytes) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final d = await ui.ImageDescriptor.encoded(buffer);
  buffer.dispose();
  try {
    final t = _target(d.width, d.height, displayMaxSide);
    return await _decode(d, t.$1, t.$2);
  } finally {
    d.dispose();
  }
}

// ---------------------------------------------------------------- providers

/// The active encounter's uploaded picture (no bytes), if any.
final activeMapImageProvider = StreamProvider<MapImageInfo?>((ref) => ref.watch(databaseProvider).watchActiveMapImage().distinct());

/// An uploaded picture decoded for painting, per id (a replaced picture gets
/// a new id). autoDispose, like `sceneImageProvider`: freed once the map no
/// longer shows that id.
final mapImageProvider = FutureProvider.autoDispose.family<ui.Image?, int>((ref, id) async {
  final bytes = await ref.read(databaseProvider).mapImageBytes(id);
  if (bytes == null || bytes.isEmpty) return null;
  final image = await decodeForDisplay(bytes);
  if (!ref.mounted) {
    image.dispose();
    return null;
  }
  ref.onDispose(image.dispose);
  return image;
});

/// The background chosen for the active encounter's map.
final chosenBackgroundProvider = Provider<MapBackground>(
    (ref) => MapBackground.of(ref.watch(encounterProvider.select((s) => s.value?.encounter.mapBackground)) ?? 'online'));

/// Whether an online picture can be shown (the feature on, a picture there).
final onlineBackgroundAvailableProvider =
    Provider<bool>((ref) => ref.watch(onlineFeatureVisibleProvider) && ref.watch(activeSceneIdProvider) != null);

/// The background the map shows now ([shownBackground]).
final shownBackgroundProvider = Provider<MapBackground>((ref) => shownBackground(
      ref.watch(chosenBackgroundProvider),
      hasUpload: ref.watch(activeMapImageProvider.select((i) => i.value != null)),
      hasOnline: ref.watch(onlineBackgroundAvailableProvider),
    ));

/// The token size of the active encounter's map.
final tokenScaleProvider = Provider<double>((ref) => ref.watch(encounterProvider.select((s) => s.value?.encounter.tokenScale)) ?? 1.0);

/// The backgrounds that can be chosen now: none always, and each picture that exists.
List<MapBackground> backgroundChoices({required bool hasUpload, required bool hasOnline}) =>
    [MapBackground.none, if (hasUpload) MapBackground.upload, if (hasOnline) MapBackground.online];

/// Settings key: the hint about the picture's own grid was shown once.
const mapImageGridHintKey = 'mapImageGridHint';
const mapImageGridHint = 'Resimde ızgara varsa uygulamanın ızgarasını kapatabilirsin';

/// Checks and shrinks a picked file ([prepareMapImage]); faked in widget
/// tests, where `dart:ui` decoding does not finish inside the test clock.
final mapImagePreparerProvider = Provider<Future<PreparedMapImage> Function(Uint8List bytes)>((ref) => prepareMapImage);
