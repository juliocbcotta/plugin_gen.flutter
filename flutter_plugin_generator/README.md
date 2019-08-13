flutter_plugin_generator is part of the project [plugin_gen.flutter](https://github.com/BugsBunnyBR/plugin_gen.flutter/) and holds the annotations that should
be placed in the `dev_dependencies` bloc of your `pubspec.yaml`


This package is responsible for generating the plugin code for you.
It works together with [flutter_plugin_annotations](https://pub.dev/packages/flutter_plugin_annotations), you can read more about
the annotations in the project [README](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_annotations/README.md). 

In the code below we have a simple plugin declaration and the generated code.


```dart
part 'platform_plugin.g.dart';

@MethodCallPlugin(channelName: "my channel name")
abstract class PlatformPlugin {
  Future<String> get platform;
  
  static PlatformPlugin create() {
    return _$PlatformPlugin();
  }
}
```

will generate `platform_plugin.g.dart` : 


```dart

class _$PlatformPlugin extends PlatformPlugin {
  static const MethodChannel _methodChannel =
      const MethodChannel('my channel channel');

  _$PlatformPlugin();

  @override
  Future<String> get platform async {
    
    final result = await _methodChannel.invokeMethod<String>('platform');
    
    return result;
  }
}

```

The sample above may look silly, but it can save a lot of code when dealing with parameters and return types.
Refer to the [example](https://github.com/BugsBunnyBR/plugin_gen.flutter/tree/master/example/) folder, there you will find a plugin project
with the generated code for more complex usages.

# FAQ

## Why ?

Because it is a mindless job to write this kind of code.
Lazy developer rule #1 : Write once by hand, automate, drink a beer.

## What plugin_gen.flutter can do for you?

It can use an abstract class and its methods to generate a concrete implementation for your plugin.

## What are the restrictions?

### Plugin class
* Plugin class should be `abstract`.
* Only methods/fields/getters with return type `Future<*>` will have an implementation generated.
* Only one `MethodChannel` per class or instance if path replacements are used. [Read More](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_annotations/README.md)
* A factory for the concrete implementation is not allowed at the moment.
#### NOTE: Use an static method in the abstract plugin class to encapsulate the instantiation.

```dart
  static PlatformPlugin create() {
    return _$PlatformPlugin();
  }
```

### Models (for return and for parameters)
Your models will need to have a factory `fromJson(Map<String, dynamic> map)` and a method `Map<String, dynamic> toJson()`. They will be used in the serialization/deserialization of your data.

Something like : 

```dart

class MyData {
  final String data;

  MyOtherData({this.data});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'data': data};
  }

  factory MyData.fromJson(Map<String, dynamic> map) {
    return MyData(data: map['data']);
  }
}

```

## What are the supported data types?
Maps and lists of primitive types and of classes that don't use generics are allowed.

Sample of llowed data types:

`int`

`double`

`String`

`void`

`Null`

`MyData`

`List<int>`

`List<double>`

`List<String>`

`List<MyData>`

`Map<String, int>`

`Map<String, MyData>`


### Lists of list or lists of map or maps of list... are **NOT** supported
:exclamation: `List<List<*>>` 

:exclamation: `List<Map<*,*>>`

:exclamation: `Map<List<*>,*>`

:exclamation: `Map<*,List<*>>`

:exclamation: `Map<Map<*,*>,*>`

:exclamation: `Map<*,Map<>>`

...

### Classes with generics are **NOT** supported

:exclamation: `MyGenericData<T>`


PRs are welcome!