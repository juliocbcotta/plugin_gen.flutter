## [0.0.10]

- Enabled parsing optional positional and default values.


## [0.0.9]

- Added support to serialize/deserialize enums and Sets.
- Included header in the generated code.
- Added support to `@OnMethodCall` annotation.

**Breaking changes**
- MethodChannels are no longer static in any case.
- The abstract plugin class will need to have a constructor, it can be as simple like `PlatformPlugin();`, but we need it. 
- Fields are no longer supported, always use getters instead.

## [0.0.8]

- Serialization and deserialization of pretty much any combination of Lists, Maps and Classes (without generics).

## [0.0.7+1]

- Removed example apk.

## [0.0.7]

- Updated analyzer to 0.37.1.
- Improved generated code formatting.
- Updated documentation.
- Included example.

- **Breaking Change**
  - New `@FlutterPlugin()` annotation should be placed at every plugin class, it is obligatory to write a plugin.
  - `MethodCallPlugin` was renamed to `MethodChannelFutures`, this annotation is no longer obligatory to write a plugin.
  This means you can have a plugin with only EventChannels.
  - Having a declared `Stream<T>` field without an annotation `EventChannelStream` no longer raise an exception.
  After thinking about flexibility I reached the conclusion that it could limit plugin developments.

## [0.0.6]

- Added support to EventChannel using `EventChannelStream` annotation in fields and getters.
- Added support to use fields and getters for MethodChannel calls.
- Included README.md.
- Updated documentation.


## [0.0.5]

- Added support to filter which platforms the plugin has support.
- Renamed build.dart to flutter_plugin_generator.dart to conform with pub.dev warning.
- **Breaking change** Now the generated plugin will have a static const MethodChannel shared across instances, unless
at least one path replacement is the in the [MethodCallPlugin.channelName] string.

## [0.0.4]

- Removed Flutter dependency.
- Added the ability to list in which platforms a given method will work.
- Better type matching for Map inner types.

## [0.0.3]

- Downgrade meta lib version.

## [0.0.2]

- Improved type matching for maps and lists.
- Included some documentation.

## [0.0.1] 

- Initial release.