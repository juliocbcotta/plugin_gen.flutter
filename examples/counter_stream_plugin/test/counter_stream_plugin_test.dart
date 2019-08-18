import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:counter_stream_plugin/counter_stream_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('counter_stream_plugin');

  setUp(() {

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      defaultBinaryMessenger.handlePlatformMessage("counter_stream_plugin",
          const StandardMethodCodec().encodeSuccessEnvelope(42), (ByteData data) {});
    });

  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('counter', () async {
    final value = await CounterStreamPlugin.create().counter.first;
    expect(value, 42);
  });
}
