import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';

part 'platform_plugin.g.dart';

@FlutterPlugin()
@MethodChannelFutures(channelName: 'platform_plugin')
abstract class PlatformPlugin {
  Future<String> get platformVersion;

  factory PlatformPlugin() {
    return _$PlatformPlugin();
  }
}
