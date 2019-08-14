import 'package:meta/meta.dart';

/// This annotation class is going to be used to generate a concrete implementation of a plugin that has
/// a [MethodChannel] instance.
/// It should be applied in an abstract class and a non empty [channelName] should be provided.

/// Example:
///
/// ``` dart
/// @FlutterPlugin()
/// @MethodChannelFutures(channelName: "my channel name")
/// abstract class PlatformPlugin {
///  Future<String> platform();
/// }
/// ```
/// See also:
///
///  * [https://pub.dev/packages/flutter_plugin_generator], counter part library to this one.

/// If the channelName has path replacements, i.e. '{id}', a factory with that path replacements will be generated.

/// ``` dart
/// @FlutterPlugin()
/// @MethodChannelFutures(channelName: "my_channel_name/{id}")
/// abstract class PlatformPlugin {
///
///  Future<String> platform();
///
/// }
/// ```
///
/// Will generate:
///
///```dart
/// class _$PlatformPlugin extends PlatformPlugin {
///
///   final MethodChannel _methodChannel;
///
///   factory _$PlatformPlugin({@required String id}) {
///
///     final channelName = 'platform_channel_with_id/{id}'.replaceAll('{id}', id);
///
///     return _$PlatformPlugin.private(MethodChannel(channelName));
///   }
///   _$PlatformPlugin.private(this._methodChannel);
///
///   @override
///   Future<String> platform() async {
///     final result = await _methodChannel.invokeMethod<String>('platform');
///     return result;
///   }
/// }
///```

class MethodChannelFutures {
  /// [MethodChannel] name.
  final String channelName;

  const MethodChannelFutures({
    @required this.channelName,
  });
}
