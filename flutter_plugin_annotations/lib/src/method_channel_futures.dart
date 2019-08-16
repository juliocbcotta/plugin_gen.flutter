import 'package:meta/meta.dart';

/// This annotation class is going to be used to generate instances of [MethodChannel] when applied in the same
/// class as [FlutterPlugin] and have a non empty [MethodChannelFutures.channelName].
///
/// Example:
///
/// ``` dart
/// part 'platform_plugin.g.dart';
///
/// @FlutterPlugin()
/// @MethodChannelFutures(channelName: "my channel name")
/// abstract class PlatformPlugin {
///  Future<String> platform();
/// }
/// ```
/// See also:
///
///  * [https://pub.dev/packages/flutter_plugin_generator], counter part library to this one.
///
/// If the channelName has path replacements, i.e. '{id}', a factory with that path replacements will be generated.
///
/// ```dart
/// part 'platform_plugin.g.dart';
///
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
/// part of 'platform_plugin.dart';
///
/// class _$PlatformPlugin extends PlatformPlugin {
///   final MethodChannel _methodChannel = const MethodChannel('platform_plugin');
///
///   _$PlatformPlugin() : super();
///
///   @override
///   Future<String> get platformVersion async {
///     final result = await _methodChannel.invokeMethod<String>('platformVersion');
///
///     return result;
///   }
/// }
///
///```

class MethodChannelFutures {
  /// [MethodChannel] name.
  final String channelName;

  const MethodChannelFutures({
    @required this.channelName,
  }) : assert(channelName != null);
}
