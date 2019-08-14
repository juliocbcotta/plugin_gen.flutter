import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';
import 'package:test/test.dart';

void main() {
  group('Testing the creation of the MethodChannelFutures class', () {
    test('Creating an MethodChannelFutures with channelNamel', () {
      final plugin = MethodChannelFutures(channelName: 'some name');
      expect(plugin.channelName, 'some name');
    });
  });
}
