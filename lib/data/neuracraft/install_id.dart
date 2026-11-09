/// The install id sent as `X-End-User`: random, made once, no personal data.
library;

import 'dart:math';

/// 1–64 characters of `A-Z a-z 0-9 . _ : @ -` (the service's rule).
final installIdPattern = RegExp(r'^[A-Za-z0-9._:@-]{1,64}$');

/// A random UUID v4 (36 characters, matches [installIdPattern]).
String newInstallId([Random? random]) {
  final r = random ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40; // version 4
  b[8] = (b[8] & 0x3f) | 0x80; // variant 10
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}
