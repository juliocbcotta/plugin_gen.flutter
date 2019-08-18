#import "PingPongPlugin.h"
#import <ping_pong_plugin/ping_pong_plugin-Swift.h>

@implementation PingPongPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPingPongPlugin registerWithRegistrar:registrar];
}
@end
