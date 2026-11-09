import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/app_info.dart';

void main() {
  test('appVersion matches the pubspec version name', () {
    final line = File('pubspec.yaml').readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    final match = RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$').firstMatch(line);
    expect(match, isNotNull, reason: 'pubspec version must be <name>+<build>, e.g. 1.0.0+1');
    expect(appVersion, match!.group(1));
  });

  test('SRD 5.2.1 attribution is the verbatim license sentence', () {
    expect(
      srdAttribution,
      'This work includes material from the System Reference Document 5.2.1 (“SRD 5.2.1”) by '
      'Wizards of the Coast LLC, available at https://www.dndbeyond.com/srd. The SRD 5.2.1 is '
      'licensed under the Creative Commons Attribution 4.0 International License, available at '
      'https://creativecommons.org/licenses/by/4.0/legalcode.',
    );
    // The store listing must carry the same sentence.
    for (final f in ['docs/store/listing-tr.md', 'docs/store/listing-en.md']) {
      expect(File(f).readAsStringSync(), contains(srdAttribution), reason: f);
    }
  });
}
