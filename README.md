# plugin_gen.flutter
A library to generate the flutter code for your plugin.

## How to use

pubspec.yaml of your plugin

```yaml
dependencies:
  flutter_plugin_annotations: ^0.0.9
    
    
dev_dependencies:
  build_runner: ^1.0.0
  flutter_plugin_generator: ^0.0.9
```

In your plugin folder

`flutter pub run build_runner build --delete-conflicting-outputs`

This will generate the concrete implementation of your annotated class.
You can watch the changes in files with:

`flutter pub run build_runner watch --delete-conflicting-outputs`



```dart
part 'platform_plugin.g.dart';

@FlutterPlugin()
@MethodChannelFutures(channelName: 'my channel name')
abstract class MyAwesomePlugin {
  
  MyAwesomePlugin(); // We need at least the default constructor.
  
  Future<String> get platform;
  
  Future<void> sendData(MyData data);
  
  @EventChannelStream(channelName: 'my event channel name')
  Stream<MyData> get myDataStream;
}
```

[Read More about the annotations](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_annotations/README.md)

[Read More about the generator](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_generator/README.md)


## TODO
- annotation for EventChannel in methods
- support background execution
- tests
- annotation SupportedPlatforms except
- document code