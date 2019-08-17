#import "FlutterGenSamplePlugin.h"
#import <flutter_gen_sample_plugin/flutter_gen_sample_plugin-Swift.h>

@implementation FlutterGenSamplePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterGenSamplePlugin registerWithRegistrar:registrar];
}
@end
