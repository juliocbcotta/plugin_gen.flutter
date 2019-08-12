import 'package:meta/meta.dart';

/// This annotation allows the developer to specify which platforms
/// a given method supports.
/// If this annotation is not present all platforms are supported for a given method.
/// Any [SupportedPlatform] not listed in [only] field will
/// throw an [UnsupportedError] when calling in that platform.
/// Example:
///
/// ``` dart
/// @MethodCallPlugin(channelName: "my channel name")
/// abstract class PlatformPlugin {
///
///  @SupportedPlatforms(only: [SupportedPlatform.Android])
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
