import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('Testing the creation of the MethodCallPlugin class', () {
    test('Creating an MethodCallPlugin with channelNamel', () {
      final plugin = MethodCallPlugin(channelName: 'some name');
      expect(plugin.channelName, 'some name');
    });
  });
}
