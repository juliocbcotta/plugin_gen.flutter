flutter_plugin_annotations is part of the project [plugin_gen.flutter](https://github.com/BugsBunnyBR/plugin_gen.flutter/) and holds the annotations that should
be placed in the `dependencies` bloc of your `pubspec.yaml`

## @FlutterPlugin()
This annotation should be applied to abstract classes that represents a plugin.

- As the annotated class will generate a part file, you should add 
after the file imports `part '${MY_CLASS_FILE_NAME}.g.dart';` to make the project work.

For instance, a file `platform_plugin.dart`, should have something like:

```dart
part 'platform_plugin.g.dart';

@FlutterPlugin()
abstract class PlatformPlugin {
 
  PlatformPlugin();

}
```

## @MethodChannelFutures()
MethodChannelFutures` annotation should be placed at your plugin class together with `FlutterPlugin`, to enable the usage
of methods and getters that return a `Future<T>` to have it's calls mapped into a `MethodChannel`.

- As the annotated class will generate a part file that access flutter framework, you need to add the import
`import 'package:flutter/services.dart';` to the top of your class file.

You can see a class example [here](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_annotations/example/lib/platform_plugin.dart).

### MethodChannelFutures.channelName
 If `MethodChannelFutures.channelName` has no path replacements:  The plugin will have a `static const MethodChannel` that will be shared
 across all instances of the plugin.

If `MethodChannelFutures.channelName` has any String replacements, i.e `platform_channel_with_id/{id}`, the generated plugin will have a constructor with a String named parameter `id` that will be replaced
in the given String when creating a new instance of the class. This may be useful when allocating native resources.

For instance:

```dart
part 'platform_plugin.g.dart';

@FlutterPlugin()
@MethodChannelFutures(channelName: 'method_channel_with_id/{id}')
abstract class PlatformPlugin {

  PlatformPlugin();
  
  Future<String> platform();

  factory PlatformPlugin(String id) {
    return _$PlatformPlugin(id: id);
  }
}
```

## @EventChannelStream()
`EventChannelStream` should be applied to getters of type `Stream<T>`. 

- As the annotated class will generate a part file that access flutter framework, you need to add the import
`import 'package:flutter/services.dart';` to the top of your class file.

- **`EventChannelStream.channelName` does NOT support methods or path replacements**. 

Each getter annotated with `EventChannelStream` will generate a new `static const EventChannel` 
and a private `Stream<dynamic>` that will be reused for all readings done in a given getter.


For instance:

```dart
part 'platform_plugin.g.dart';

@FlutterPlugin()
abstract class PlatformPlugin {

  PlatformPlugin();
  
  @EventChannelStream('my event channel')
  Stream<String> get platform;

}
```

will generate:

```dart
part of 'platform_plugin.dart';

class _$PlatformPlugin extends PlatformPlugin {
  
  _$PlatformPlugin() : super();
  
  static const EventChannel _platformEventChannel =
      const EventChannel('my event channel');

  final Stream<dynamic> _platform = _platformEventChannel.receiveBroadcastStream();

  @override
  Stream<String> get platform {
    return _platform.map((result) {
      return retult;
    });
  }
}
```

## @SupportedPlatforms()
`SupportedPlatforms`, when applied to the same class as `FlutterPlugin` will work as a filter when declaring more restrict usage in a method or getter.

- As this annotation will generate code that relies in `dart:io`, you should add the import `import 'dart:io';` to the top of your class file.

Methods/getters annotated with `SupportedPlatforms` with a non empty list of `SupportedPlatforms.only` will generate code to raise exceptions for each platform not listed in the `only` field.

For instance:
```dart
part 'platform_plugin.g.dart';

@FlutterPlugin()
@SupportedPlatforms(
  only: [
    SupportedPlatform.IOS,
    SupportedPlatform.Android,
  ],
)
@MethodChannelFutures(channelName: 'platform_channel_with_id')
abstract class PlatformPlugin {
 
  PlatformPlugin();
 
  @SupportedPlatforms(
    only: [SupportedPlatform.Android],
  )
  Future<String> platform();
}
```

will generate:

```dart
part of 'platform_plugin.dart';
  
  @override
  Future<String> platform() async {
    if (Platform.isIOS)
      throw UnsupportedError('Functionality platform is not available on IOS.');

    final result = await _methodChannel.invokeMethod<String>('platform');
    return result;
  }
 
```

but if you remove the annotation from the class

```dart
part of 'platform_plugin.dart';

@FlutterPlugin()
@MethodChannelFutures(channelName: 'platform_channel_with_id')
abstract class PlatformPlugin {
  
  PlatformPlugin();
  
  @SupportedPlatforms(
    only: [SupportedPlatform.Android],
  )
  Future<String> platform();

}
```

will generate:

```dart
  @override
  Future<String> platform() async {
    if (Platform.isIOS)
      throw UnsupportedError('Functionality platform is not available on IOS.');

    if (Platform.isWindows)
      throw UnsupportedError(
          'Functionality platform is not available on Windows.');

    if (Platform.isFuchsia)
      throw UnsupportedError(
          'Functionality platform is not available on Fuchsia.');

    if (Platform.isLinux)
      throw UnsupportedError(
          'Functionality platform is not available on Linux.');

    if (Platform.isMacOS)
      throw UnsupportedError(
          'Functionality platform is not available on MacOS.');

    final result = await _methodChannel.invokeMethod<String>('platform');
    return result;
  }
```

If your plugin is meant to run just in Android and IOS and you want to have a cleaner code generated, use `SupportedPlatforms` in the class.
