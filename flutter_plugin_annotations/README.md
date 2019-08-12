flutter_plugin_annotations is part of the project plugin_gen.flutter and holds the annotations that should
be placed in the `dependencies` bloc of your `pubspec.yaml`

## TLDR
| Annotation  | Class | Method| Imports |
| ------------- | ------------- | ------------- | ------------- |
| `MethodCallPlugin`  | Used to indicate that the abstract class represents a plugin. | NOT APPLICABLE | `import 'package:flutter/services.dart';` |
| `SupportedPlatforms` | When applied together with `MethodCallPlugin` will limit which platforms the plugin supports.  | When applied to a method will limit which platforms the method supports. | `import 'dart:io';`|



## MethodCallPlugin
This annotation should be applied to abstract classes that represents a plugin.

- As the annotated class will generate a part file that access flutter framework, you need to add the import
`import 'package:flutter/services.dart';` to the top of your class file.

- As the annotated class will generate a part file, you should add after the file imports `part '${MY_CLASS_FILE_NAME}.g.dart';` to make the project work.

- The class should have abstract methods that return `Future<*>`s. Each method will be translated to a `channelMethod` invoke call.

You can see a class example [here](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/example/lib/platform_plugin.dart).

### channelName
This value will dictate if the generated plugin will have a `static const MethodChannel` or one `MethodChannel` per instance.

If `channelName` has any String replacements, i.e `platform_channel_with_id/{id}`, the generated code will have a constructor with a String named parameter `id` that will be replaced 
in the given `channelName` when creating a new instance of the class. It may be useful when allocating native resources.

For instance:
```dart
@MethodCallPlugin(channelName: 'platform_channel_with_id/{id}')
abstract class PlatformPlugin {
  
  Future<String> platform();

  static PlatformPlugin create(String id) {
    return _$PlatformPlugin(id: id);
  }
}

```

## SupportedPlatforms
`SupportedPlatforms`, when applied to the same class as `MethodCallPlugin` will work as a filter when declaring more restrict usage in a method.

- As this annotation will generate code that relies in `dart:io`, you should add the import `import 'dart:io';` to the top of your class file.

Methods annotated with `SupportedPlatforms` with a non empty list of `SupportedPlatforms.only` will generate code to raise exceptions for each platform not listed in the `only` field.

For instance:
```dart
@SupportedPlatforms(
  only: [
    SupportedPlatform.IOS,
    SupportedPlatform.Android,
  ],
)
@MethodCallPlugin(channelName: 'platform_channel_with_id')
abstract class PlatformPlugin {
  @SupportedPlatforms(
    only: [SupportedPlatform.Android],
  )
  Future<String> platform();
}
```

will generate

```dart
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
@MethodCallPlugin(channelName: 'platform_channel_with_id')
abstract class PlatformPlugin {
  @SupportedPlatforms(
    only: [SupportedPlatform.Android],
  )
  Future<String> platform();

}
```

will generate

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

