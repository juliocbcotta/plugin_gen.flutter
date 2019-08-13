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

In your plugins folder

`flutter pub run build_runner build --delete-conflicting-outputs`

This will generate the concrete implementation of your annotated class.
You can watch the changes with:

`flutter pub run build_runner watch --delete-conflicting-outputs`


In the snipshot below we have a simple plugin declararion and the generated code.


``` dart
part 'platform_plugin.g.dart';

@MethodCallPlugin(channelName: "my channel name")
abstract class PlatformPlugin {
  Future<String> get platform;
  
  static PlatformPlugin create() {
    return _$PlatformPlugin();
  }
}

###################### platform_plugin.g.dart ################################

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
  static PlatformPlugin create() {
    return _$PlatformPlugin();
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
- annotation for EventChannel in methods
- tests
- annotation SupportedPlatforms except
