// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_plugin.dart';

// **************************************************************************
// FlutterPluginGenerator
// **************************************************************************

class _$PlatformPlugin extends PlatformPlugin {
  static const MethodChannel _methodChannel =
      const MethodChannel('platform_plugin');

  _$PlatformPlugin();

  @override
  Future<String> get platformVersion async {
    final result = await _methodChannel.invokeMethod<String>('platformVersion');

    return result;
  }
}
