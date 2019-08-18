import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';


part 'counter_stream_plugin.g.dart';

@FlutterPlugin()
abstract class CounterStreamPlugin {

  CounterStreamPlugin();

  @EventChannelStream(channelName: 'counter_stream_plugin')
  Stream<int> get counter;

  factory CounterStreamPlugin.create(){
    return _$CounterStreamPlugin();
  }
}
