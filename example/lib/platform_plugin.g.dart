// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_plugin.dart';

// **************************************************************************
// FlutterPluginGenerator
// **************************************************************************

class _$PlatformPlugin extends PlatformPlugin {
  _$PlatformPlugin();

  static const EventChannel _platformEventChannel =
      const EventChannel('my event channel');

  final Stream<dynamic> _platform =
      _platformEventChannel.receiveBroadcastStream();

  @override
  Stream<String> get platform {
    return _platform.map((result) {
      return result;
    });
  }
}
