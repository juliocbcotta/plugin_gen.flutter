import 'package:meta/meta.dart';

/// This annotation class is going to be used to generate a concrete implementation of a plugin that has
/// a [MethodChannel] instance.
/// It should be applied in an abstract class and a non empty [channelName] should be provided.

/// Example:
///
/// ``` dart
/// @MethodCallPlugin(channelName: "my channel name")
/// abstract class PlatformPlugin {
///  Future<String> platform();
/// }
/// ```
/// /// See also:
///
///  * [https://pub.dev/packages/flutter_plugin_generator], counter part library to this one.
class MethodCallPlugin {
  /// [MethodChannel] name.
  final String channelName;

  const MethodCallPlugin({@required this.channelName});
}
