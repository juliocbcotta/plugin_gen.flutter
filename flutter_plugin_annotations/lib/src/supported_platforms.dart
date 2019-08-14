import 'package:meta/meta.dart';

/// This annotation allows the developer to specify which platforms a method supports.
/// When applied to a class together with [FlutterPlugin], it will limit to which platforms this plugin
/// will work. If applied to the class, but not to a method, it will not have any effect.
/// If [SupportedPlatforms] is applied in the class and in it's methods, the [SupportedPlatforms.only]
/// list in the class will work as filter for [SupportedPlatform.values] for the [only] list in the method.
/// If this annotation is not present in the class, all [SupportedPlatform.values] are considered supported.
/// Any [SupportedPlatform] not listed in [only] field will
/// throw an [UnsupportedError] when calling in that platform.
/// Example:
///
/// ```dart
/// part 'platform_plugin.g.dart';
///
/// @FlutterPlugin()
/// @SupportedPlatforms(only: [
///   SupportedPlatform.IOS,
///   SupportedPlatform.Android,
/// ])
/// @MethodChannelFutures(channelName: "my channel name")
/// abstract class PlatformPlugin {
///
///  @SupportedPlatforms(only: [
///   SupportedPlatform.Android,
///  ])
///  Future<String> platform();
/// }
/// ```
class SupportedPlatforms {
  final List<SupportedPlatform> only;

  const SupportedPlatforms({@required this.only});
}

/// These names need to match Flutter Platform.is$
enum SupportedPlatform {
  IOS,
  Android,
  Windows,
  Fuchsia,
  Linux,
  MacOS,
}
