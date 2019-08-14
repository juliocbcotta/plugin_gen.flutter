import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';
import 'package:test/test.dart';

import 'asserts.dart';

void main() {
  group('Testing the creation of the SupportedPlatforms class', () {
    test('Creating an SupportedPlatforms with a list of only SupportedPlatform',
        () {
      final annotation = SupportedPlatforms(only: [SupportedPlatform.Android]);
      expect(annotation.only, [SupportedPlatform.Android]);
    });
    test('Creating an SupportedPlatforms without a only list', () {
      expect(() => SupportedPlatforms(only: null), throwsAssertionError);
    });
  });
}
