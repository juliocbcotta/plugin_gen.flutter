import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong_plugin/ping_pong_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('ping_pong_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return 'pong';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('ping -> pong', () async {
    expect(await PingPongPlugin.create().ping2(), 'pong');
  });
}
