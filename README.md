# plugin_gen.flutter
A library to generate the flutter code for your plugin.

## How to use

pubspec.yaml of your plugin

``` yaml
dependencies:
  flutter_plugin_annotations: ^0.0.5
    
    
dev_dependencies:
  build_runner: ^1.0.0
  flutter_plugin_generator: ^0.0.5
```

In your plugin folder

`flutter pub run build_runner build --delete-conflicting-outputs`

This will generate the concrete implementation of your annotated class.
You can watch the changes with:

`flutter pub run build_runner watch --delete-conflicting-outputs`



```dart
part 'platform_plugin.g.dart';

@MethodCallPlugin(channelName: 'my channel name')
abstract class PlatformPlugin {
  
  Future<String> get platform;
  
  @EventChannelStream(channelName: 'my event channel name')
  Stream<MyData> get myDataStream;
}
```

(Read More about the annotations)[https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_annotations/README.md]

(Read More about the generator)[https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_generator/README.md]


## TODO
- document code
- annotation for EventChannel in methods
- tests
- annotation SupportedPlatforms except
