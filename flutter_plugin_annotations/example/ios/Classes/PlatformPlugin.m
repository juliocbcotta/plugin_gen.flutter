#import "PlatformPlugin.h"
#import <platform_plugin/platform_plugin-Swift.h>

@implementation PlatformPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPlatformPlugin registerWithRegistrar:registrar];
}
@end
