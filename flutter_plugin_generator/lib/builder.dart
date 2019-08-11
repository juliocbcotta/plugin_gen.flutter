import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flutter_plugin_generator/src/flutter_plugin_generator.dart';


Builder flutterPluginBuilder(BuilderOptions options) =>
    SharedPartBuilder(const [FlutterPluginGenerator()], 'flutter_plugin_builder');
