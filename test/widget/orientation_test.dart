import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gm_cebi/app.dart';

import 'harness.dart';

void main() {
  test('phones (shortest side under 600 dp) are portrait only; tablets take every orientation', () {
    const portrait = [DeviceOrientation.portraitUp];
    const all = <DeviceOrientation>[]; // what SystemChrome takes for "every orientation"
    expect(orientationsFor(const Size(360, 640)), portrait);
    expect(orientationsFor(const Size(412, 915)), portrait);
    expect(orientationsFor(const Size(440, 956)), portrait, reason: 'the largest iPhone');
    expect(orientationsFor(const Size(915, 412)), portrait, reason: 'a phone started in landscape is still a phone');
    expect(orientationsFor(const Size(599.9, 1000)), portrait);
    expect(orientationsFor(const Size(600, 960)), all, reason: 'a 7" tablet');
    expect(orientationsFor(const Size(744, 1133)), all, reason: 'iPad mini');
    expect(orientationsFor(const Size(1280, 800)), all);
    expect(orientationsFor(const Size(673, 841)), all, reason: 'an open foldable');
    expect(orientationsFor(Size.zero), isNull, reason: 'before the first frame the size is not known: nothing is locked yet');
  });

  test('iOS: the iPhone is portrait only and the iPad takes every orientation, as the app asks at start', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    List<String> orientations(String key) {
      final m = RegExp('<key>${RegExp.escape(key)}</key>\\s*<array>(.*?)</array>', dotAll: true).firstMatch(plist)!;
      return [for (final s in RegExp('<string>(.*?)</string>').allMatches(m.group(1)!)) s.group(1)!];
    }

    expect(orientations('UISupportedInterfaceOrientations'), ['UIInterfaceOrientationPortrait']);
    expect(orientations('UISupportedInterfaceOrientations~ipad'), unorderedEquals([
      'UIInterfaceOrientationPortrait',
      'UIInterfaceOrientationPortraitUpsideDown',
      'UIInterfaceOrientationLandscapeLeft',
      'UIInterfaceOrientationLandscapeRight',
    ]));
  });

  testWidgets('the app asks for portrait on a phone after the first frame, and frees the orientation on a tablet', (tester) async {
    final asked = <List<String>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemChrome.setPreferredOrientations') asked.add([...call.arguments as List].cast<String>());
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    // The size of the device's view, in dp (the test surface is not what the app reads).
    void device(Size dp) => tester.view.physicalSize = dp * tester.view.devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    device(const Size(412, 915));
    await tester.pumpWidget(const PhonePortrait(child: SizedBox.expand()));
    await tester.pump();
    expect(asked, [
      ['DeviceOrientation.portraitUp'],
    ]);

    // The same answer is not sent again (the keyboard opening also changes the metrics).
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    expect(asked, hasLength(1));

    // An opened foldable, or the app moved to a tablet-size window.
    device(const Size(1280, 800));
    await tester.pump();
    expect(asked.last, isEmpty, reason: 'an empty list frees every orientation');
    device(const Size(640, 360)); // a phone, however it is held
    await tester.pump();
    expect(asked, hasLength(3));
    expect(asked.last, ['DeviceOrientation.portraitUp']);
  });

  appTest('the app is wrapped in the portrait lock', (tester, db) async {
    expect(find.ancestor(of: find.byType(HomeShell), matching: find.byType(PhonePortrait)), findsOneWidget);
  });
}
