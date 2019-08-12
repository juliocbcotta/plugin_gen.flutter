import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flutter_plugin_generator/src/flutter_plugin_generator.dart';

/// Builder used to generate plugin classes.
/// [source_gen] based : https://github.com/dart-lang/source_gen/
Builder flutterPluginBuilder(BuilderOptions options) =>
    SharedPartBuilder(const [FlutterPluginGenerator()], 'flutter_plugin_builder');
