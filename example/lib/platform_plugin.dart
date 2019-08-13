import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';

part 'platform_plugin.g.dart';

@MethodCallPlugin(channelName: 'platform_channel_with_id/{id}')
abstract class PlatformPlugin {
  Future<String> platform();

  static PlatformPlugin create(String id) {
    return _$PlatformPlugin(id: id);
  }
}
