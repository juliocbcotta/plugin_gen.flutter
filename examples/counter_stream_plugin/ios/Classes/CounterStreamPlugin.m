#import "CounterStreamPlugin.h"
#import <counter_stream_plugin/counter_stream_plugin-Swift.h>

@implementation CounterStreamPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCounterStreamPlugin registerWithRegistrar:registrar];
    FlutterEventSink _sink;
}
@end
