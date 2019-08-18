import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';


part 'ping_pong_plugin.g.dart';

typedef Future<void> OnPong(String pong);

@FlutterPlugin()
@MethodChannelFutures(channelName: 'ping_pong_plugin')
abstract class PingPongPlugin {

  PingPongPlugin();

  // This will send a message to the native side, but the answer will come through listen(OnPong pong).
  Future<void> ping();

  @OnMethodCall()
  // This can be used to receive in the Dart side actions that happened while the app is in foreground without
  // the need to the Dart side start a query.
  void listen(OnPong pong);

  // This is just a simple call that sends ping2 and receive a direct answer in the return.
  Future<String> ping2();

  factory PingPongPlugin.create(){
    return _$PingPongPlugin();
  }
}
