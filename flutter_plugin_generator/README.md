flutter_plugin_generator is part of the project [plugin_gen.flutter](https://github.com/BugsBunnyBR/plugin_gen.flutter/) 
and holds the annotations that should be placed in the `dev_dependencies` block of your `pubspec.yaml`


This package is responsible for generating the plugin code for you.
It works together with [flutter_plugin_annotations](https://pub.dev/packages/flutter_plugin_annotations), 
you can read more about the annotations in the project [README](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_annotations/README.md). 

In the code below we have a simple plugin declaration and the generated code.


```dart
part 'platform_plugin.g.dart';

@FlutterPlugin()
@MethodChannelFutures(channelName: "my channel name")
abstract class PlatformPlugin {
  
  PlatformPlugin();
  
  Future<String> get platform;
  
  factory PlatformPlugin() {
    return _$PlatformPlugin();
  }
}
```

will generate `platform_plugin.g.dart` : 


```dart
 part of 'platform_plugin.dart';

 class _$PlatformPlugin extends PlatformPlugin {
   final MethodChannel _methodChannel = const MethodChannel('platform_plugin');

   _$PlatformPlugin() : super();

   @override
   Future<String> get platformVersion async {
     final result = await _methodChannel.invokeMethod<String>('platformVersion');

     return result;
   }
 }
```

The sample above may look silly, but it can save a lot of code when dealing with parameters and return types.
Refer to the [example](https://github.com/BugsBunnyBR/plugin_gen.flutter/tree/master/example/) folder, 
there you will find a plugin project with the generated code for more complex usages.

# FAQ

## Why ?

Because it is a mindless job to write this kind of code.
Lazy developer rule #1 : Write once by hand, automate, have a beer.

## What plugin_gen.flutter can do for you?

It can use an abstract class and its methods/getters to generate a concrete implementation for your plugin.
This project tries to find a good compromise between free modeling of your plugins and patterns that enables code generation
while keeping the code simple and clean to read.

## Can I create EventChannel streams?

Yes, you can! Annotate a getter of type `Stream<T>` with `EventChannelStream`, 
give the annotation a `channelName` and run the build runner command.


Example: 
```dart
part 'platform_plugin.g.dart';

@FlutterPlugin()
abstract class PlatformPlugin {
  
  PlatformPlugin();
  
  @EventChannelStream(channelName: 'my event channel')
  Stream<String> get platform;

  factory PlatformPlugin() {
    return _$PlatformPlugin();
  }
}

```

## Why `MethodChannelFutures` is applied to a class and `EventChannelStream` to a getter?

It is a common pattern to have multiple methods writing and reading from the same `MethodChannel`, but
not the same can be said to an `EventChannel` stream.


## What are the restrictions?

### Plugin class

* Plugin class should be `abstract` and have the annotation `@FlutterPlugin()` applied.
* Only one `MethodChannel` per class or one instance if path replacements are used. 
[Read More](https://github.com/BugsBunnyBR/plugin_gen.flutter/blob/master/flutter_plugin_annotations/README.md)

### Models (for return and for parameters)

Your models will need to have a factory `fromJson(Map<String, dynamic> map)` and a method `Map<String, dynamic> toJson()`.
They will be used in the serialization/deserialization of your data.

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

Sample of allowed data types:

`int`

`double`

`String`

`void`

`Null`

`MyData`

`MyEnum`

`Set<int>`

`List<int>`

`List<double>`

`List<String>`

`List<MyData>`

`Map<String, int>`

`Map<String, MyData>`

`Map<MyData, MyOtherData>`

`Map<Map<List<Map<MyData, MyOtherData>>, MyOtherData>, Map<MyOtherData, MyData>>` // Tested!



### Classes with generics are **NOT** supported

:exclamation: `MyGenericData<T>`


PRs are welcome!