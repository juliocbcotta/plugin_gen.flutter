import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';
import 'package:test/test.dart';

import 'asserts.dart';

void main() {
  group('Testing the creation of the MethodChannelFutures class', () {
    test('Creating an MethodChannelFutures with channelNamel', () {
      final annotation = MethodChannelFutures(channelName: 'some name');
      expect(annotation.channelName, 'some name');
    });
    test('Creating an MethodChannelFutures without channelNamel', () {
      expect(
          () => MethodChannelFutures(channelName: null), throwsAssertionError);
    });
  });
}
