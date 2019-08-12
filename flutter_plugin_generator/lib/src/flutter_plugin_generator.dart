import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// This class reads the [MethodCallPlugin] annotation and the classes where it is applied.
/// It will create a [MethodChannel] using the supplied [MethodCallPlugin.channelName] and
/// a class with the prefix `_$`that implements the class where the annotation was used.
/// Example:
///
/// ``` dart
/// @MethodCallPlugin(channelName: "my channel name")
/// abstract class PlatformPlugin {
///  Future<String> platform();
/// }
/// ```
/// Will generate:
///
///``` dart
/// part of 'my_platform_plugin.dart';
///
/// **************************************************************************
/// FlutterPluginGenerator
/// **************************************************************************
///
///class _$PlatformPlugin extends PlatformPlugin {
///  final MethodChannel _methodChannel;
///
///  factory _$PlatformPlugin() {
///    return _$PlatformPlugin.private(const MethodChannel('my channel name'));
///  }
///
///  _$PlatformPlugin.private(this._methodChannel);
///
///  @override
///  Future<String> platform() async {
///    final result = await _methodChannel.invokeMethod<String>('platform');
///    return result;
///  }
/// }
///```
///
/// /// See also:
///
///  * [https://pub.dev/packages/flutter_plugin_annotations], counter part library to this one.
class FlutterPluginGenerator extends GeneratorForAnnotation<MethodCallPlugin> {
  const FlutterPluginGenerator();

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final template = generatePluginTemplate(element, annotation);
    return template;
  }

  String declareMethods(ClassElement element) {
    final methods = element.methods.where((method) {
      return method.isAbstract &&
          method.isPublic &&
          method.returnType.isDartAsyncFuture;
    });
    final buffer = StringBuffer();
    methods.forEach((method) {
      final methodName = method.displayName;

      final methodParams = declareParams(method.parameters);
      final methodReturnType = method.returnType.displayName;

      buffer.writeln('@override');
      buffer.writeln('$methodReturnType $methodName($methodParams) async {');

      final innerType =
          (method.returnType as ParameterizedType).typeArguments[0];
      final invokeMethod = selectInvokeMethod(innerType);
      final invokeParams = selectParamToInvokeMethod(method.parameters);
      final separator = invokeParams.isEmpty ? '' : ',';

      final resultMapped = mapResultToDart(innerType);

      buffer.writeln(
          'final result = await _methodChannel.$invokeMethod(\'$methodName\'$separator $invokeParams);');
      buffer.writeln('$resultMapped');
      buffer.writeln('}');
    });
    return buffer.toString();
  }

  String declareParams(List<ParameterElement> parameters) {
    final buffer = StringBuffer();
    final firstNamed =
        parameters.firstWhere((param) => param.isNamed, orElse: () {
      return null;
    });
    parameters.forEach((param) {
      if (firstNamed == param) {
        buffer.writeln('{');
      }
      buffer.write(param.type.displayName + ' ' + param.displayName);
      buffer.write(', ');
    });
    if (firstNamed != null) {
      buffer.writeln('}');
    }
    return buffer.toString();
  }

  String selectInvokeMethod(DartType type) {
    if (isCoreDartType(type)) {
      return 'invokeMethod<${type.displayName}>';
    } else if (isDartList(type)) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      final inner =
          isCoreDartType(innerType) ? '${innerType.displayName}' : 'dynamic';

      return 'invokeListMethod<$inner>';
    } else if (isDartMap(type)) {
      final keyType = (type as ParameterizedType).typeArguments[0];
      final valueType = (type as ParameterizedType).typeArguments[1];

      final key =
          isCoreDartType(keyType) ? '${keyType.displayName}' : 'dynamic';

      final value =
          isCoreDartType(valueType) ? '${valueType.displayName}' : 'dynamic';

      return 'invokeMapMethod<$key, $value>';
    }

    return 'invokeMapMethod<String, dynamic>';
  }

  bool isDartList(DartType type) {
    return type.displayName.startsWith("List<");
  }

  bool isDartMap(DartType type) {
    return type.displayName.startsWith("Map<");
  }

  bool isCoreDartType(DartType type) {
    return type.isDartCoreString ||
        type.isDartCoreBool ||
        type.isDartCoreDouble ||
        type.isDartCoreInt ||
        type.isVoid ||
        type.isDartCoreNull;
  }

  String mapResultToDart(DartType type) {
    if (isCoreDartType(type)) {
      return 'return result;';
    } else if (isDartList(type)) {
      final innerType = (type as ParameterizedType).typeArguments[0];

      if (isCoreDartType(innerType)) {
        return 'return result;';
      } else {
        return 'return result' +
            '.map((item) => Map<String, dynamic>.from(item))' +
            '.map((item) => ${innerType.displayName}.fromJson(item)).toList();';
      }
    }
    if (isDartMap(type)) {
      final keyType = (type as ParameterizedType).typeArguments[0];
      final valueType = (type as ParameterizedType).typeArguments[1];

      if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
        return 'return Map<${keyType.displayName}, ${valueType.displayName}>.from(result);';
      } else {
        final key =
            isCoreDartType(keyType) ? 'key' : 'Map<String, dynamic>.from(key)';
        final value = isCoreDartType(valueType)
            ? 'value'
            : 'Map<String, dynamic>.from(value)';

        final key2 = isCoreDartType(keyType)
            ? 'key'
            : '${keyType.displayName}.fromJson(key)';
        final value2 = isCoreDartType(valueType)
            ? 'value'
            : '${valueType.displayName}.fromJson(value)';

        return ''' return result
                            .map((key, value) => MapEntry(
                              $key,
                              $value,
                            ))
                            .map((key, value) => MapEntry(
                              $key2, 
                              $value2,
                            ));''';
      }
    } else {
      return 'return ${type.displayName}.fromJson(result);';
    }
  }

  String selectParamToInvokeMethod(List<ParameterElement> params) {
    if (params.length == 0) {
      return '';
    } else if (params.length == 1) {
      final param = params[0];
      final type = param.type;

      if (isCoreDartType(type)) {
        return param.displayName;
      } else if (isDartList(type)) {
        final innerType = (type as ParameterizedType).typeArguments[0];
        final mapping = isCoreDartType(innerType)
            ? ''
            : '.map((item) => item.toJson()).toList()';

        return '${param.displayName}$mapping';
      } else if (isDartMap(type)) {
        final keyType = (type as ParameterizedType).typeArguments[0];
        final valueType = (type as ParameterizedType).typeArguments[1];

        if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
          return param.displayName;
        } else {
          final key = isCoreDartType(keyType) ? 'key' : 'key.toJson()';
          final value = isCoreDartType(valueType) ? 'value' : 'value.toJson()';
          return '${param.displayName}.map((key, value) => MapEntry($key, $value))';
        }
      } else {
        return '${param.displayName}.toJson()';
      }
    } else {
      final map = params.map((param) {
        final type = param.type;

        if (isCoreDartType(type)) {
          return '\'${param.displayName}\': ${param.displayName}';
        } else if (isDartList(type)) {
          final innerType = (type as ParameterizedType).typeArguments[0];

          final mapping = isCoreDartType(innerType)
              ? ''
              : '.map((item) => item.toJson()).toList()';

          return '\'${param.displayName}\' :  ${param.displayName}$mapping';
        } else if (isDartMap(type)) {
          final keyType = (type as ParameterizedType).typeArguments[0];
          final valueType = (type as ParameterizedType).typeArguments[1];

          if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
            return '\'${param.displayName}\' : ' + param.displayName;
          } else {
            final key = isCoreDartType(keyType) ? 'key' : 'key.toJson()';
            final value =
                isCoreDartType(valueType) ? 'value' : 'value.toJson()';
            return '\'${param.displayName}\' : ${param.displayName}.map((key, value) => MapEntry($key, $value))';
          }
        } else {
          return '\'${param.displayName}\' : ${param.displayName}.toJson()';
        }
      }).join(', ');

      return '<String, dynamic>{$map}';
    }
  }

  String generatePluginTemplate(Element element, ConstantReader annotation) {
    final channelName = annotation.read('channelName').stringValue;
    final className = element.displayName;

    return '''
    
    class _\$$className extends $className {
    
      final MethodChannel _methodChannel;
    
      factory _\$$className() {
        return _\$$className.private(const MethodChannel('$channelName'));
      }
      
      _\$$className.private(this._methodChannel);
    
      ${declareMethods(element)}
    
    }  
    ''';
  }
}
