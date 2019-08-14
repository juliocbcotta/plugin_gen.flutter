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
///
///  Future<String> platform();
///
/// }
/// ```
/// Will generate:
///
///``` dart
/// part of 'platform_plugin.dart';
///
/// **************************************************************************
/// FlutterPluginGenerator
/// **************************************************************************
/// class _$PlatformPlugin extends PlatformPlugin {
///   static const MethodChannel _methodChannel =
///       const MethodChannel('my channel channel');
///
///   _$PlatformPlugin();
///
///   @override
///   Future<String> platform() async {
///
///     final result = await _methodChannel.invokeMethod<String>('platform');
///
///     return result;
///   }
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

  List<SupportedPlatform> findSupportedPlatforms(
      List<ElementAnnotation> metadata) {
    final annotation = metadata.firstWhere(
        (annotation) =>
            annotation.computeConstantValue().type.displayName ==
            'SupportedPlatforms',
        orElse: () => null);

    return annotation == null
        ? SupportedPlatform.values
        : annotation.constantValue
            .getField('only')
            .toListValue()
            .map((only) => SupportedPlatform.values.firstWhere(
                (platform) => only.getField(platformName(platform)) != null))
            .toList();
  }

  String platformName(SupportedPlatform platform) {
    return platform.toString().split('.').last;
  }

  String declareMethods(
    ClassElement element,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    final buffer = StringBuffer();

    final methods = element.methods.where((method) {
      return method.isAbstract &&
          method.isPublic &&
          method.returnType.isDartAsyncFuture;
    }).toList();

    final fields = element.fields
        .where((field) => field.isPublic && field.type.isDartAsyncFuture)
        .toList();

    fields.forEach((field) {
      buffer.write(declareGetter(field, pluginPlatforms));
    });

    methods.forEach((method) {
      buffer.write(declareMethod(method, pluginPlatforms));
    });

    return buffer.toString();
  }

  String declareGetter(
    FieldElement field,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    final buffer = StringBuffer();
    final fieldPlatforms =
        findSupportedPlatforms(field.metadata + field.getter.metadata);

    final fieldName = field.displayName;
    final fieldType = field.type.displayName;

    buffer.writeln('@override');
    buffer.writeln('$fieldType get $fieldName async {');

    buffer.writeln(
        processSupportedPlatforms(fieldName, pluginPlatforms, fieldPlatforms));

    final innerType = (field.type as ParameterizedType).typeArguments[0];
    final invokeMethod = selectInvokeMethod(innerType);

    final resultMapped = mapResultToDart(innerType, false);

    buffer.writeln(
        'final result = await _methodChannel.$invokeMethod(\'$fieldName\');');
    buffer.writeln('$resultMapped');
    buffer.writeln('}');

    return buffer.toString();
  }

  String declareMethod(
    MethodElement method,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    final buffer = StringBuffer();
    final methodPlatforms = findSupportedPlatforms(method.metadata);

    final methodName = method.displayName;

    final methodParams = declareParams(method.parameters);
    final methodReturnType = method.returnType.displayName;
    buffer.writeln('@override');
    buffer.writeln('$methodReturnType $methodName($methodParams) async {');

    buffer.writeln(processSupportedPlatforms(
        methodName, pluginPlatforms, methodPlatforms));

    final innerType = (method.returnType as ParameterizedType).typeArguments[0];
    final invokeMethod = selectInvokeMethod(innerType);
    final invokeParams = selectParamToInvokeMethod(method.parameters);
    final separator = invokeParams.isEmpty ? '' : ',';

    final resultMapped = mapResultToDart(innerType, false);

    buffer.writeln(
        'final result = await _methodChannel.$invokeMethod(\'$methodName\'$separator $invokeParams);');
    buffer.writeln('$resultMapped');
    buffer.writeln('}');

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
    } else if (type.isDartCoreList) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      final inner =
          isCoreDartType(innerType) ? '${innerType.displayName}' : 'dynamic';

      return 'invokeListMethod<$inner>';
    } else if (type.isDartCoreMap) {
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


  bool isCoreDartType(DartType type) {
    return type.isDartCoreString ||
        type.isDartCoreBool ||
        type.isDartCoreDouble ||
        type.isDartCoreInt ||
        type.isVoid ||
        type.isDartCoreNull;
  }

  /// NOTE : When this method is used from EventChannel is need to set includeExtraCasting = true,
  /// as receiveBroadcastStream() only emits dynamic and we need to change that to something
  /// like a list, or map.
  /// TODO : make this type mapping recursive to add support to things like List<List<MyData>> and Map<List<MyData>, List<MyOtherData>>
  String mapResultToDart(DartType type, bool includeExtraCasting) {
    if (isCoreDartType(type)) {
      return 'return result;';
    } else if (type.isDartCoreList) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      final extraCasting =
          includeExtraCasting ? 'List.castFrom(result)' : 'result';
      if (isCoreDartType(innerType)) {
        return 'return $extraCasting;';
      } else {
        return 'return $extraCasting' +
            '.map((item) => Map<String, dynamic>.from(item))' +
            '.map((item) => ${innerType.displayName}.fromJson(item)).toList();';
      }
    }
    if (type.isDartCoreMap) {
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
        final kk = isCoreDartType(keyType) ? keyType.displayName : 'dynamic';
        final vk =
            isCoreDartType(valueType) ? valueType.displayName : 'dynamic';
        final extraCasting =
            includeExtraCasting ? 'Map<$kk, $vk>.from(result)' : 'result';
        return ''' return $extraCasting
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
      if (includeExtraCasting) {
        return '''
        final item = Map<String, dynamic>.from(result);
        return ${type.displayName}.fromJson(item);''';
      } else {
        return '''
        return ${type.displayName}.fromJson(result);''';
      }
    }
  }

  /// TODO : make this type mapping recursive to add support to things like List<List<MyData>> and Map<List<MyData>, List<MyOtherData>>
  String selectParamToInvokeMethod(List<ParameterElement> params) {
    if (params.isEmpty) {
      return '';
    } else if (params.length == 1) {
      final param = params[0];
      final type = param.type;

      if (isCoreDartType(type)) {
        return param.displayName;
      } else if (type.isDartCoreList) {
        final innerType = (type as ParameterizedType).typeArguments[0];
        final mapping = isCoreDartType(innerType)
            ? ''
            : '.map((item) => item.toJson()).toList()';

        return '${param.displayName}$mapping';
      } else if (type.isDartCoreMap) {
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
        } else if (type.isDartCoreList) {
          final innerType = (type as ParameterizedType).typeArguments[0];

          final mapping = isCoreDartType(innerType)
              ? ''
              : '.map((item) => item.toJson()).toList()';

          return '\'${param.displayName}\' :  ${param.displayName}$mapping';
        } else if (type.isDartCoreMap) {
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

  String findStreamChannelName(List<ElementAnnotation> metadata) {
    final annotation = metadata.firstWhere(
        (annotation) =>
            annotation.computeConstantValue().type.displayName ==
            'EventChannelStream',
        orElse: () => null);

    return annotation == null
        ? null
        : annotation.constantValue.getField('channelName').toStringValue();
  }

  bool isDartStream(DartType type) {
    return type.displayName.startsWith('Stream<');
  }

  String generatePluginTemplate(Element element, ConstantReader annotation) {
    final rootElement = (element as ClassElement);
    final channelName = annotation.read('channelName').stringValue;
    final className = element.displayName;

    final pluginPlatforms = findSupportedPlatforms(element.metadata);

    final factory = createFactory(rootElement, className, channelName);

    final streamGetters = createStreamGetters(rootElement, pluginPlatforms);

    final methods = declareMethods(rootElement, pluginPlatforms);

    return '''
    
    class _\$$className extends $className {
        
      $factory
    
      $streamGetters
    
      $methods
    
    }  
    ''';
  }

  String createFactory(
      ClassElement element, String className, String channelName) {
    final pathRegexp = RegExp('(\{.*?\})');
    final groups =
        pathRegexp.allMatches(channelName).map((match) => match.group(0));

    final constructorParameters = groups
        .map((group) => group.replaceAll('{', '').replaceAll('}', ''))
        .map((variable) => '@required String $variable')
        .join(', ');

    final replacements = groups.map((group) {
      final variable = group.replaceAll('{', '').replaceAll('}', '');
      return 'replaceAll(\'$group\', $variable)';
    }).join('.');

    final oneChannelByInstance = constructorParameters.isNotEmpty;
    final factory = oneChannelByInstance
        ? '''
      
       final MethodChannel _methodChannel;
       
      factory _\$$className({$constructorParameters}) {
       
          final channelName = \'$channelName\'.$replacements;
          
          return _\$$className.private(MethodChannel(channelName));
      }
      _\$$className.private(this._methodChannel);
    '''
        : '''
        
        static const MethodChannel _methodChannel = const MethodChannel('$channelName');
        
        _\$$className();
      ''';
    return factory;
  }

  String processSupportedPlatforms(
      String elementName,
      List<SupportedPlatform> pluginSupportedPlatforms,
      List<SupportedPlatform> methodSupportedPlatforms) {
    final buffer = StringBuffer();

    pluginSupportedPlatforms.forEach((platform) {
      if (!methodSupportedPlatforms.contains(platform)) {
        final name = platformName(platform);
        buffer.writeln('''
        if (Platform.is$name)
            throw UnsupportedError('Functionality $elementName is not available on $name.');
        ''');
      }
    });
    return buffer.toString();
  }

  String createStreamGetters(
    ClassElement element,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    return element.fields
        .where((field) => isDartStream(field.type))
        .map((field) {
      final channelName =
          findStreamChannelName(field.metadata + field.getter.metadata);

      final fieldPlatforms =
          findSupportedPlatforms(field.metadata + field.getter.metadata);
      final platformOnly = processSupportedPlatforms(
          field.displayName, pluginPlatforms, fieldPlatforms);
      final innerType = (field.type as ParameterizedType).typeArguments[0];
      final result = mapResultToDart(innerType, true);

      if (channelName != null && channelName.isNotEmpty) {
        return '''
        static const EventChannel _${field.displayName}EventChannel = const EventChannel('$channelName');
        
        final _${field.displayName} = _${field.displayName}EventChannel.receiveBroadcastStream();
        
        @override
        ${field.type.displayName} get ${field.displayName} {
            $platformOnly
        return  _${field.displayName}.map((result){  $result });
        }
      ''';
      } else {
        throw UnsupportedError(
            'No @EventChannelStream annotation found for ${field.displayName}');
      }
    }).join('\n');
  }
}
