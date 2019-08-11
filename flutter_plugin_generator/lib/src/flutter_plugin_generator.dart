import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:base_plugin/base_plugin.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class FlutterPluginGenerator extends GeneratorForAnnotation<MethodCallPlugin> {
  const FlutterPluginGenerator();

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final channelName = annotation.read('channelName').stringValue;
    final className = element.displayName;

    final template = '''
    
    class _\$$className extends $className {
    
    final MethodChannel _methodChannel;
    
    factory _\$$className() {
    return _\$$className.private(const MethodChannel('$channelName'));
  }
    _\$$className.private(this._methodChannel);
    
    ${declareMethods(element)}
    
    }  
    ''';
    return template;
  }

  String declareMethods(Element element) {
    final methods = (element as ClassElement).methods.where((method) {
      return method.isAbstract &&
          method.isPublic &&
          method.returnType.isDartAsyncFuture;
    });
    final buffer = StringBuffer();
    methods.forEach((method) {
      final methodName = method.displayName;
      final returnType = method.returnType.displayName;
      final innerType =
          (method.returnType as ParameterizedType).typeArguments[0];

      final invokeMethod = selectInvokeMethod(innerType);
      final param = selectParamToInvokeMethod(method.parameters);

      buffer.writeln('@override ');
      buffer.writeln(returnType +
          ' ' +
          methodName +
          '(' +
          declareParams(method.parameters) +
          ') async {');

      buffer.writeln('''
      final result = await _methodChannel.$invokeMethod('$methodName'$param);
      ''');
      final resultMapped = mapResultToDart(innerType);
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
        buffer.write('{\n');
      }
      buffer.write(param.type.displayName + ' ' + param.displayName);
      buffer.write(', ');
    });
    if (firstNamed != null) {
      buffer.write('}\n');
    }
    return buffer.toString();
  }

  String selectInvokeMethod(DartType type) {
    if (isCoreDartType(type)) {
      return 'invokeMethod<${type.displayName}>';
    }

    if (isList(type)) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      if (isCoreDartType(innerType)) {
        return 'invokeListMethod<${innerType.displayName}>';
      } else {
        return 'invokeListMethod<dynamic>';
      }
    } else if (isMap(type)) {
      return 'invokeMapMethod<dynamic, dynamic>';
    }

    return 'invokeMapMethod<String, dynamic>';
  }

  bool isList(DartType type) {
    return type.displayName.startsWith("List<");
  }

  bool isMap(DartType type) {
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
    } else if (isList(type)) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      
      if (isCoreDartType(innerType)) {
        return 'return result;';
      } else {
        return 'return result.map((item) => ${innerType.displayName}.fromJson(Map<String, dynamic>.from(item))).toList();';
      }
    }
    if (isMap(type)) {
      final keyType = (type as ParameterizedType).typeArguments[0];
      final valueType = (type as ParameterizedType).typeArguments[1];
      
      if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
        return 'return Map<${keyType.displayName}, ${valueType.displayName}>.from(result);';
      } else if (isCoreDartType(keyType) && !isCoreDartType(valueType)) {
        return ''' return result
                            .map((key, value) => MapEntry(
                             key,
                              Map<String, dynamic>.from(value)
                            ))
                            .map((key, value) => MapEntry(
                              key, 
                              ${valueType.displayName}.fromJson(value)
                            ));''';
      } else if (!isCoreDartType(keyType) && isCoreDartType(valueType)) {
        return ''' return result
                            .map((key, value) => MapEntry(
                              Map<String, dynamic>.from(key),
                              value,
                            ))
                            .map((key, value) => MapEntry(
                              ${keyType.displayName}.fromJson(key),
                              value,
                            ));''';
      } else {
        return ''' return result
                            .map((key, value) => MapEntry(
                              Map<String, dynamic>.from(key),
                              Map<String, dynamic>.from(value),
                            ))
                            .map((key, value) => MapEntry(
                              ${keyType.displayName}.fromJson(key), 
                              ${valueType.displayName}.fromJson(value),
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
        return ', ' + param.displayName;
      } else if (isList(type)) {
        final innerType = (type as ParameterizedType).typeArguments[0];

        if (isCoreDartType(innerType)) {
          return ', ' + param.displayName;
        } else {
          return ', ${param.displayName}.map((item) => item.toJson()).toList()';
        }
      } else if (isMap(type)) {
        final keyType = (type as ParameterizedType).typeArguments[0];
        final valueType = (type as ParameterizedType).typeArguments[1];

        if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
          return ', ' + param.displayName;
        } else if (isCoreDartType(keyType) && !isCoreDartType(valueType)) {
          return ', ${param.displayName}.map((key, value) => MapEntry(key, value.toJson()))';
        } else if (!isCoreDartType(keyType) && isCoreDartType(valueType)) {
          return ', ${param.displayName}.map((key, value) => MapEntry(key.toJson(), value))';
        } else {
          return ', ${param.displayName}.map((key, value) => MapEntry(key.toJson(), value.toJson()))';
        }
      } else {
        return ', ${param.displayName}.toJson()';
      }
    } else {
      final map = params.map((param) {
        final type = param.type;

        if (isCoreDartType(type)) {
          return ''' '${param.displayName}': ${param.displayName}''';
        } else if (isList(type)) {
          final innerType = (type as ParameterizedType).typeArguments[0];

          if (isCoreDartType(innerType)) {
            return '\'${param.displayName}\' : ' + param.displayName;
          } else {
            return '\'${param.displayName}\' :  ${param.displayName}.map((item) => item.toJson()).toList()';
          }
          
        } else if (isMap(type)) {
          final keyType = (type as ParameterizedType).typeArguments[0];
          final valueType = (type as ParameterizedType).typeArguments[1];

          if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
            return '\'${param.displayName}\' : ' + param.displayName;
          } else if (isCoreDartType(keyType) && !isCoreDartType(valueType)) {
            return '\'${param.displayName}\' : ${param.displayName}.map((key, value) => MapEntry(key, value.toJson()))';
          } else if (!isCoreDartType(keyType) && isCoreDartType(valueType)) {
            return '\'${param.displayName}\' : ${param.displayName}.map((key, value) => MapEntry(key.toJson(), value))';
          } else {
            return '\'${param.displayName}\' : ${param.displayName}.map((key, value) => MapEntry(key.toJson(), value.toJson()))';
          }
        } else {
          return '\'${param.displayName}\' : ${param.displayName}.toJson()';
        }
      }).join(', ');

      return ''', <String, dynamic>{$map}''';
    }
  }
}
