import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// This class reads the [FlutterPlugin] annotation and the classes where it is applied.
/// If [MethodChannelFutures] is applied too, it will create a [MethodChannel] using the supplied
/// [MethodChannelFutures.channelName] and a class with the prefix `_$`that extends the class
/// where the annotation was used.
///
/// Example:
///
/// ```dart
///
/// part 'platform_plugin.g.dart';
///
/// @FlutterPlugin()
/// @MethodChannelFutures(channelName: "my channel name")
/// abstract class PlatformPlugin {
///
///  Future<String> platform();
///
/// }
/// ```
/// Will generate:
///
/// ```dart
/// part of 'flutter_plugin.dart';
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
///
/// ```
///
/// If [EventChannelStream] annotation is applied to a field or getter of a class annotated with [FlutterPlugin]
/// an static const [EventChannel] will be created.
///
/// Example:
/// '''dart
///
///  part 'platform_plugin.g.dart';
///
///  @FlutterPlugin()
///  abstract class PlatformPlugin {
///   Stream<String> get platform;
///
///   static PlatformPlugin create() {
///     return _$PlatformPlugin();
///   }
/// }
///
/// ```
///
/// ```dart
/// part of 'platform_plugin.dart';
///
/// **************************************************************************
/// FlutterPluginGenerator
/// **************************************************************************
///
/// class _$PlatformPlugin extends PlatformPlugin {
///  _$PlatformPlugin();
///
///  static const EventChannel _platformEventChannel =
///      const EventChannel('my event channel');
///
///  final Stream<dynamic> _platform =
///      _platformEventChannel.receiveBroadcastStream();
///
///  @override
///  Stream<String> get platform {
///    return _platform.map((result) {
///      return result;
///    });
///  }
/// }
///
/// ```
///
/// See also:
///
///  * [https://pub.dev/packages/flutter_plugin_annotations], counter part library to this one.
///
class FlutterPluginGenerator extends GeneratorForAnnotation<FlutterPlugin> {
  const FlutterPluginGenerator();

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final template = generatePluginTemplate(element as ClassElement);
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
    ClassElement rootElement,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    final buffer = StringBuffer();

    final futureMethods = rootElement.methods.where((method) {
      return method.isAbstract &&
          method.isPublic &&
          method.returnType.isDartAsyncFuture;
    }).toList();

    final futureFields = rootElement.fields
        .where((field) => field.isPublic && field.type.isDartAsyncFuture)
        .toList();

    futureFields.forEach((field) {
      buffer.write(declareFutureGetter(field, pluginPlatforms));
    });

    futureMethods.forEach((method) {
      buffer.write(declareFutureMethod(method, pluginPlatforms));
    });

    return buffer.toString();
  }

  String declareFutureGetter(
    FieldElement field,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    final fieldPlatforms =
        findSupportedPlatforms(field.metadata + field.getter.metadata);

    final fieldName = field.displayName;
    final fieldType = field.type.displayName;

    final platformsOnly = processSupportedPlatforms(
      fieldName,
      pluginPlatforms: pluginPlatforms,
      elementPlatforms: fieldPlatforms,
    );

    final innerType = (field.type as ParameterizedType).typeArguments[0];
    final invokeMethod = selectInvokeMethod(innerType);

    final resultMapped = mapResultToDart(innerType, false);

    return '''
    
          @override
          $fieldType get $fieldName async {
            
              $platformsOnly
              
              final result = await _methodChannel.$invokeMethod(\'$fieldName\');
              
              return $resultMapped;
              
           }
    
    ''';
  }

  String declareFutureMethod(
    MethodElement method,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    final methodPlatforms = findSupportedPlatforms(method.metadata);

    final methodName = method.displayName;

    final methodParams = declareParams(method.parameters);
    final methodReturnType = method.returnType.displayName;

    final platformsOnly = processSupportedPlatforms(
      methodName,
      pluginPlatforms: pluginPlatforms,
      elementPlatforms: methodPlatforms,
    );

    final innerType = (method.returnType as ParameterizedType).typeArguments[0];
    final invokeMethod = selectInvokeMethod(innerType);
    final invokeParams = selectParamToInvokeMethod(method.parameters);
    final separator = invokeParams.isEmpty ? '' : ',';

    final resultMapped = mapResultToDart(innerType, false);

    return '''
            @override
            $methodReturnType $methodName($methodParams) async {

                $platformsOnly
                
                final result = await _methodChannel.$invokeMethod(\'$methodName\'$separator $invokeParams);
                
                return $resultMapped;
            }
    ''';
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
      buffer.write(' ${param.type.displayName}  ${param.displayName}, ');
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
      return 'result';
    } else if (type.isDartCoreList) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      final extraCasting =
          includeExtraCasting ? 'List.castFrom(result)' : 'result';
      if (isCoreDartType(innerType)) {
        return '$extraCasting';
      } else {
        return '''
              $extraCasting
                          .map((item) => Map<String, dynamic>.from(item))
                          .map((item) => ${innerType.displayName}.fromJson(item)).toList()
        
        ''';
      }
    }
    if (type.isDartCoreMap) {
      final keyType = (type as ParameterizedType).typeArguments[0];
      final valueType = (type as ParameterizedType).typeArguments[1];

      if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
        return 'Map<${keyType.displayName}, ${valueType.displayName}>.from(result)';
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
        return '''
                  $extraCasting
                            .map((key, value) => MapEntry(
                                $key,
                                $value,
                              ),
                            )
                            .map((key, value) => MapEntry(
                                $key2, 
                                $value2,
                              ),
                            )
                            
             ''';
      }
    } else {
      if (includeExtraCasting) {
        return '''
        final item = Map<String, dynamic>.from(result);
        ${type.displayName}.fromJson(item)''';
      } else {
        return '''
        ${type.displayName}.fromJson(result)''';
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
          return '${param.displayName}.map((key, value) => MapEntry($key, $value,),)';
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
            return '\'${param.displayName}\' : ${param.displayName}.map((key, value) => MapEntry($key, $value,),)';
          }
        } else {
          return '\'${param.displayName}\' : ${param.displayName}.toJson()';
        }
      }).join(', ');

      return '<String, dynamic>{$map}';
    }
  }

  String findChannelName(
      List<ElementAnnotation> metadata, String annotationName) {
    final annotation = metadata.firstWhere(
        (annotation) =>
            annotation.computeConstantValue().type.displayName ==
            annotationName,
        orElse: () => null);

    return annotation == null
        ? null
        : annotation.constantValue.getField('channelName').toStringValue();
  }

  bool isDartStream(DartType type) {
    return type.displayName.startsWith('Stream<');
  }

  String generatePluginTemplate(ClassElement rootElement) {
    final channelName =
        findChannelName(rootElement.metadata, 'MethodChannelFutures');
    final className = rootElement.displayName;

    final factory = createFactory(rootElement,
        className: className, methodChannelName: channelName);

    final pluginPlatforms = findSupportedPlatforms(rootElement.metadata);

    final streamGetters = createStreamGetters(rootElement, pluginPlatforms);

    final methods =
        channelName != null ? declareMethods(rootElement, pluginPlatforms) : '';

    return '''
    
    class _\$$className extends $className {
        
      $factory
    
      $streamGetters
    
      $methods
    
    }  
    ''';
  }

  String createFactory(ClassElement rootElement,
      {String className, String methodChannelName}) {
    if (methodChannelName == null) {
      return '''
        _\$$className();
      ''';
    }

    final pathRegexp = RegExp('(\{.*?\})');
    final groups =
        pathRegexp.allMatches(methodChannelName).map((match) => match.group(0));

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
       
            final channelName = \'$methodChannelName\'.$replacements;
          
            return _\$$className.private(MethodChannel(channelName));
        }
        
        _\$$className.private(this._methodChannel);
    '''
        : '''
        
         static const MethodChannel _methodChannel = const MethodChannel('$methodChannelName');
        
         _\$$className();
        
      ''';
    return factory;
  }

  String processSupportedPlatforms(String elementName,
      {List<SupportedPlatform> pluginPlatforms,
      List<SupportedPlatform> elementPlatforms}) {
    final buffer = StringBuffer();

    pluginPlatforms.forEach((platform) {
      if (!elementPlatforms.contains(platform)) {
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
    ClassElement rootElement,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    return rootElement.fields
        .where((field) => isDartStream(field.type))
        .map((field) {
      final eventChannelName = findChannelName(
          field.metadata + field.getter.metadata, 'EventChannelStream');

      final fieldPlatforms =
          findSupportedPlatforms(field.metadata + field.getter.metadata);

      final platformOnly = processSupportedPlatforms(
        field.displayName,
        pluginPlatforms: pluginPlatforms,
        elementPlatforms: fieldPlatforms,
      );

      final innerType = (field.type as ParameterizedType).typeArguments[0];

      final result = mapResultToDart(innerType, true);

      if (eventChannelName != null) {
        return '''
        
        static const EventChannel _${field.displayName}EventChannel = const EventChannel('$eventChannelName');
        
        final Stream<dynamic> _${field.displayName} = _${field.displayName}EventChannel.receiveBroadcastStream();
        
        @override
        ${field.type.displayName} get ${field.displayName} {
          
            $platformOnly
          
          return  _${field.displayName}.map((result){  return $result; });
        }
        
      ''';
      } else {
        return '';
      }
    }).join('\n');
  }
}
