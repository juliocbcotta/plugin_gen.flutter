import 'package:meta/meta.dart';

/// This annotation class is going to be used to generate a concrete implementation of
/// a [EventChannel] instance.
/// It should be applied in a field or getter and it should have a non empty [channelName] provided.
/// For instance:
///
///```dart
/// @MethodCallPlugin(channelName: 'platform channel')
/// abstract class PlatformPlugin {
///
///  @EventChannelStream('my event channel')
///  Stream<String> get platform;
///
///}
///```
///
/// Will generate:
///
///```dart
///  static const EventChannel _platformEventChannel =
///      const EventChannel('my event channel');
///
///  final _platform = _platformEventChannel.receiveBroadcastStream();
///
///  @override
///  Stream<String> get platform {
///    return _platform.map((result) {
///      return result;
///    });
///  }
///```
/// See also:
///
///  * [https://pub.dev/packages/flutter_plugin_generator], counter part library to this one.
class EventChannelStream {
  final String channelName;

  const EventChannelStream({@required this.channelName});
}
