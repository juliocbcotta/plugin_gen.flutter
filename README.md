# plugin_gen.flutter
A library to generate the flutter code for your plugin.

## How to use

pubspec.yaml of your plugin

``` yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_plugin_annotations: ^0.0.1
    
    
dev_dependencies:
  flutter_test:
    sdk: flutter
    
  build_runner: ^1.0.0

  flutter_plugin_generator: ^0.0.1
```

In your plugins folder

`flutter pub run build_runner build --delete-conflicting-outputs`

This will generate the concrete implementation of your annotated class.
You can watch the changes with:

`flutter pub run build_runner watch --delete-conflicting-outputs`



``` dart
part 'my_platform_plugin.g.dart';

@MethodCallPlugin(channelName: "my channel name")
abstract class MyPlatformPlugin {
  Future<String> receiveString();
  
  static MyPlatformPlugin create() {
    return _$MyPlatformPlugin();
  }
}

###################### my_platform_plugin.g.dart ################################

class _$MyPlatformPlugin extends MyPlatformPlugin {
  final MethodChannel _methodChannel;

  factory _$MyPlatformPlugin() {
    return _$MyPlatformPlugin.private(const MethodChannel('my channel name'));
  }
  _$MyPlatformPlugin.private(this._methodChannel);

  @override
  Future<String> receiveString() async {
    final result = await _methodChannel.invokeMethod<String>('receiveString');

    return result;
  }
}
```

The sample above may look silly, but it can save a lot of code when dealing with parameters and return types.
Refer to the example folder, there you will find a plugin project.

# FAQ

## What plugin_gen.flutter can do for you?

It can use an abstract class and its methods to generate a concrete implementation for your plugin.

## What are the restrictions?

### Plugin class
* Plugin class should be `abstract`.
* Only methods with return type `Future<*>` will have an implementation generated.
* Only one `MethodChannel` per class.
* `MethodChannel` instanted in the constructor of the generated class.
* A factory for the concrete implementation is not allowed at the moment.
#### NOTE: Use an static method in the abstract plugin class to encapsulate the instantiation.

``` dart
  static MyPlatformPlugin create() {
    return _$MyPlatformPlugin();
  }
```

### Models (for return and for parameters)
Your models will need to have a factory `fromJson(Map<String, dynamic> map)` and a method `Map<String, dynamic> toJson()`. They will be used in the serialization/deserialization of your data.

Something like : 

``` dart

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


### Lists of list or lists of map or maps of list are **NOT** supported
:exclamation: `List<List<*>>` 

:exclamation: `List<Map<*,*>>`

:exclamation: `Map<List<*>,*>`

:exclamation: `Map<*,List<*>>`

:exclamation: `Map<Map<*,*>,*>`

:exclamation: `Map<*,Map<>>`

### Classes with generics are **NOT** supported

:exclamation: `MyGenericData<T>`


PRs are welcome!


## TODO
- document code
- annotation for AndroidOnly and IOSOnly methods
- annotation for EventChannel in methods
- allow static channel
- allow singleton
- tests
