import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong_plugin/ping_pong_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('ping_pong_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PingPongPlugin.platformVersion, '42');
  });
}
