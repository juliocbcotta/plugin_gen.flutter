import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';

part 'platform_plugin.g.dart';

@FlutterPlugin()
@MethodChannelFutures(channelName: 'platform_plugin')
abstract class PlatformPlugin {

   Future<String> get platformVersion;

   static PlatformPlugin create(){
     return _$PlatformPlugin();
   }
}
