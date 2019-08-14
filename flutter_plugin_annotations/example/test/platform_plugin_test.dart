import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_plugin/platform_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('platform_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('platformVersion', () async {
    expect(await PlatformPlugin.create().platformVersion, '42');
  });
}
