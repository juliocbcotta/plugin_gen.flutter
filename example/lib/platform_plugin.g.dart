// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_plugin.dart';

// **************************************************************************
// FlutterPluginGenerator
// **************************************************************************

class _$PlatformPlugin extends PlatformPlugin {
  final MethodChannel _methodChannel;

  factory _$PlatformPlugin({@required String id}) {
    final channelName = 'platform_channel_with_id/{id}'.replaceAll('{id}', id);

    return _$PlatformPlugin.private(MethodChannel(channelName));
  }
  _$PlatformPlugin.private(this._methodChannel);

  @override
  Future<String> platform() async {
    final result = await _methodChannel.invokeMethod<String>('platform');
    return result;
  }
}
