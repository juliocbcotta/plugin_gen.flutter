import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';

part 'platform_plugin.g.dart';

@FlutterPlugin()
abstract class PlatformPlugin {
  @EventChannelStream(channelName: 'my event channel')
  Stream<String> get platform;

  static PlatformPlugin create() {
    return _$PlatformPlugin();
  }
}
