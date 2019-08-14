import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';
import 'package:test/test.dart';

import 'asserts.dart';

void main() {
  group('Testing the creation of the EventChannelStream class', () {
    test('Creating an EventChannelStream with channelNamel', () {
      final annotation = EventChannelStream(channelName: 'some name');
      expect(annotation.channelName, 'some name');
    });
    test('Creating an EventChannelStream without channelNamel', () {
      expect(() => EventChannelStream(channelName: null), throwsAssertionError);
    });
  });
}
