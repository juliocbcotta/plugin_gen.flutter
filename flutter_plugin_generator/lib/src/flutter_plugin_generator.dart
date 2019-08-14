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

    final resultMapped = mapFromDynamic(innerType, 'result', false);

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
    final invokeParams = mapToDynamic(method.parameters);
    final separator = invokeParams.isEmpty ? '' : ',';

    final resultMapped = mapFromDynamic(innerType, 'result', false);

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

  String mapFromDynamic(DartType type, String variableName, bool needsMapping) {
    if (isCoreDartType(type)) {
      return variableName;
    }
    if (type.isDartCoreList) {
      final innerType = (type as ParameterizedType).typeArguments[0];

      final mapping =
          needsMapping ? 'List.castFrom($variableName)' : variableName;
      if (isCoreDartType(innerType)) {
        return mapping;
      }
      return '''
                  $mapping
                    .map((item) => ${mapFromDynamic(innerType, 'item', true)}).toList()        
        ''';
    }

    if (type.isDartCoreMap) {
      final keyType = (type as ParameterizedType).typeArguments[0];
      final valueType = (type as ParameterizedType).typeArguments[1];

      if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
        return 'Map<${keyType.displayName}, ${valueType.displayName}>.from($variableName)';
      } else {
        final key = mapFromDynamic(keyType, 'key', true);
        final value = mapFromDynamic(valueType, 'value', true);

        final kk = isCoreDartType(keyType) ? keyType.displayName : 'dynamic';
        final vk =
            isCoreDartType(valueType) ? valueType.displayName : 'dynamic';

        final mapping =
            needsMapping ? 'Map<$kk, $vk>.from($variableName)' : variableName;

        return '''
                   $mapping
                          .map((key, value) => MapEntry(
                              $key,
                              $value,
                            ),
                          ) 
             ''';
      }
    }
    final mapping = needsMapping
        ? 'Map<String, dynamic>.from($variableName)'
        : variableName;
    return '''
        ${type.displayName}.fromJson($mapping)
        ''';
  }

  /// 0 -> ''
  /// 1 ->
  ///     dartCore  -> param
  ///     List<T>   -> param.map((item) => item.toJson()).toList()
  ///     Map<T, U> ->
  ///                 <dartCore, dartCore> -> param
  ///                 <dartCore, Class>    -> param.map((key, value) => MapEntry(key, value.toJson()))
  ///     Class     -> param.toJson()
  ///
  /// 2..N ->
  ///       param[i]
  ///           dartCore -> param : param
  ///           List<T>  -> param : param.map((item) => item.toJson()).toList()
  ///           Map<T, U> ->
  ///                 <dartCore, dartCore> -> param : param
  ///                 <dartCore, Class>    -> param : param.map((key, value) => MapEntry(key, value.toJson()))
  ///           Class     -> param : param.toJson()

  String mapDartTypeToDynamic(DartType type, String param, bool needsPrefix) {
    final prefixedParam = needsPrefix ? '\'$param\' : $param' : param;

    if (isCoreDartType(type)) {
      return prefixedParam;
    }
    if (type.isDartCoreList) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      if (isCoreDartType(innerType)) {
        return prefixedParam;
      }
      return '$prefixedParam.map((item) => ${mapDartTypeToDynamic(innerType, 'item', false)}).toList()';
    }
    if (type.isDartCoreMap) {
      final keyType = (type as ParameterizedType).typeArguments[0];
      final valueType = (type as ParameterizedType).typeArguments[1];
      if (isCoreDartType(keyType) && isCoreDartType(valueType)) {
        return prefixedParam;
      }
      return ''' 
               $prefixedParam.map((key, value) => 
                    MapEntry(
                      ${mapDartTypeToDynamic(keyType, 'key', false)}, 
                      ${mapDartTypeToDynamic(valueType, 'value', false)},
                    ),
               )
      ''';
    }

    return '$prefixedParam.toJson()';
  }

  String mapToDynamic(List<ParameterElement> params) {
    if (params.isEmpty) {
      return '';
    }
    if (params.length == 1) {
      final param = params[0];
      final type = param.type;
      return mapDartTypeToDynamic(type, param.displayName, false);
    } else {
      final map = params.map((param) {
        final type = param.type;
        return mapDartTypeToDynamic(type, param.displayName, true);
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

      final result = mapFromDynamic(innerType, 'item', true);

      if (eventChannelName != null) {
        return '''
        
        static const EventChannel _${field.displayName}EventChannel = const EventChannel('$eventChannelName');
        
        final Stream<dynamic> _${field.displayName} = _${field.displayName}EventChannel.receiveBroadcastStream();
        
        @override
        ${field.type.displayName} get ${field.displayName} {
          
            $platformOnly
          
          return  _${field.displayName}.map((item){  return $result; });
        }
        
      ''';
      } else {
        return '';
      }
    }).join('\n');
  }
}
