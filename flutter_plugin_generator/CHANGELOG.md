## [0.0.7]

- Updated analyzer to 0.37.1.


## [0.0.6]

- Added support to EventChannel using EventChannelStream annotation in fields and getters.
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