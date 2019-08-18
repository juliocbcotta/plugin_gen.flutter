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
/// part of 'platform_plugin.dart';
///
/// class _$PlatformPlugin extends PlatformPlugin {
///   final MethodChannel _methodChannel = const MethodChannel('platform_plugin');
///
///   _$PlatformPlugin() : super();
///
///   @override
///   Future<String> get platformVersion async {
///     final result = await _methodChannel.invokeMethod<String>('platformVersion');
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
///   factory PlatformPlugin() {
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
            .map((only) => SupportedPlatform.values.firstWhere((platform) =>
                only.getField(describePlatform(platform)) != null))
            .toList();
  }

  String describePlatform(SupportedPlatform platform) {
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
    });

    final futureFields = rootElement.fields
        .where((field) => field.isPublic && field.type.isDartAsyncFuture);

    final onMethodCalls = rootElement.methods.where((method) {
      return method.isAbstract &&
          method.isPublic &&
          method.returnType.isVoid &&
          findAnnotation(method.metadata, 'OnMethodCall') != null;
    });

    futureFields.forEach((field) {
      buffer.write(declareFutureGetter(field, pluginPlatforms));
    });

    futureMethods.forEach((method) {
      buffer.write(declareFutureMethod(method, pluginPlatforms));
    });

    onMethodCalls.forEach((method) {
      buffer.write(declareOnMethodCall(method));
    });

    return buffer.toString();
  }

  String declareOnMethodCall(MethodElement method) {
    final methodName = method.displayName;

    final methodParams = declareMethodParams(method.parameters);
    final nullCheckParams = method.parameters.map((param) {
      return ' ${param.displayName} == null ';
    }).join(' && ');

    final calls = method.parameters.map((param) {
      final func = param.type as FunctionType;
      final returnType =
          (func.returnType as ParameterizedType).typeArguments[0];
      final args =
          mapFromDynamic(func.parameters[0].type, 'call.arguments', true);
      final resultMapped = mapDartTypeToDynamic(returnType, 'result', false);

      return '''
      
       if(call.method == '${param.displayName}'){
         final arguments = $args;
         final result = await ${param.displayName}(arguments);
         return $resultMapped;
       }
       
      ''';
    }).join('\n');

    return '''
           
            @override
            void $methodName($methodParams) {
                  if($nullCheckParams){
                    _methodChannel.setMethodCallHandler(null);
                  } else {
                      _methodChannel.setMethodCallHandler((call) async {
                         $calls
                         
                         return null;
                        }
                     );
                   }
            }
    ''';
  }

  String declareFutureGetter(
    FieldElement field,
    List<SupportedPlatform> pluginPlatforms,
  ) {
    final fieldPlatforms = findSupportedPlatforms(field.getter.metadata);

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

    final methodParams = declareMethodParams(method.parameters);
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

  String declareMethodParams(List<ParameterElement> parameters) {
    final buffer = StringBuffer();
    final firstNamed =
        parameters.firstWhere((param) => param.isNamed, orElse: () {
      return null;
    });
    final firstOptional = parameters
        .firstWhere((param) => param.isOptionalPositional, orElse: () {
      return null;
    });
    ParameterElement previous = null;
    parameters.forEach((param) {
      if (previous != null && !param.isNamed && previous.isNamed) {
        buffer.writeln('}');
      }
      if (previous != null &&
          !param.isOptionalPositional &&
          previous.isOptionalPositional) {
        buffer.writeln(']');
      }

      if (firstNamed == param) {
        buffer.writeln('{');
      }
      if (firstOptional == param) {
        buffer.writeln('[');
      }

      if (findAnnotation(param.metadata, 'Required') != null) {
        buffer.writeln('@required ');
      }
      buffer.write(' ${param.type.displayName}  ${param.displayName} ');
      if (param.defaultValueCode != null) {
        buffer.write(' = ' + param.defaultValueCode);
      }
      if (param != parameters.last) {
        buffer.write(', ');
      }
      previous = param;
    });
    if (previous != null && previous.isNamed) {
      buffer.writeln('}');
    }
    if (previous != null && previous.isOptionalPositional) {
      buffer.writeln(']');
    }

    return buffer.toString();
  }

  String selectInvokeMethod(DartType type) {
    if (isCoreDartType(type)) {
      return 'invokeMethod<${type.displayName}>';
    }
    if (type.isDartCoreList || type.isDartCoreSet) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      final inner =
          isCoreDartType(innerType) ? '${innerType.displayName}' : 'dynamic';

      return 'invokeListMethod<$inner>';
    }
    if (type.isDartCoreMap) {
      final keyType = (type as ParameterizedType).typeArguments[0];
      final valueType = (type as ParameterizedType).typeArguments[1];

      final key =
          isCoreDartType(keyType) ? '${keyType.displayName}' : 'dynamic';

      final value =
          isCoreDartType(valueType) ? '${valueType.displayName}' : 'dynamic';

      return 'invokeMapMethod<$key, $value>';
    }
    if (isEnum(type)) {
      return 'invokeMethod<String>';
    }
    return 'invokeMapMethod<String, dynamic>';
  }

  bool isEnum(DartType type) {
    if (type.element is ClassElement) {
      final classElement = type.element as ClassElement;
      return classElement.isEnum;
    }
    return false;
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
    if (type.isDartCoreList || type.isDartCoreSet) {
      final innerType = (type as ParameterizedType).typeArguments[0];

      final mapping =
          needsMapping ? 'List.castFrom($variableName)' : variableName;
      if (isCoreDartType(innerType)) {
        if (type.isDartCoreSet) {
          return '$mapping.toSet()';
        }
        return mapping;
      }
      return '''
                  $mapping
                    .map((item) => ${mapFromDynamic(innerType, 'item', true)}).to${type.name}()
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
    if (isEnum(type)) {
      return '${type.displayName}.values.firstWhere((item) => describeEnum(item) == $variableName)';
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
    if (type.isDartCoreList || type.isDartCoreSet) {
      final innerType = (type as ParameterizedType).typeArguments[0];
      if (isCoreDartType(innerType)) {
        if (type.isDartCoreSet) {
          return '$prefixedParam.toList()';
        }
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
    if (isEnum(type)) {
      final prefixedParam = needsPrefix ? '\'$param\' : ' : '';
      return '${prefixedParam} describeEnum($param)';
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

  ElementAnnotation findAnnotation(
      List<ElementAnnotation> metadata, String annotationName) {
    return metadata.firstWhere(
        (annotation) =>
            annotation.computeConstantValue().type.displayName ==
            annotationName,
        orElse: () => null);
  }

  String findChannelName(
      List<ElementAnnotation> metadata, String annotationName) {
    final annotation = findAnnotation(metadata, annotationName);

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
    
    $header
    
    class _\$$className extends $className {
        
      $factory
    
      $streamGetters
    
      $methods
    
    }  
    ''';
  }

  String createFactory(ClassElement rootElement,
      {String className, String methodChannelName}) {
    final superConstructorParams =
        declareMethodParams(rootElement.constructors.first.parameters);

    final superConstructorArguments =
        rootElement.constructors.first.parameters.map((param) {
      return param.isNamed ? '${param.name} : ${param.name}' : param.name;
    }).join(', ');

    if (methodChannelName == null) {
      return '''
         _\$$className($superConstructorParams) : 
 
              super($superConstructorArguments);
      ''';
    }

    final pathRegexp = RegExp('(\{.*?\})');
    final groups =
        pathRegexp.allMatches(methodChannelName).map((match) => match.group(0));

    final constructorParameters = groups
        .map((group) => group.replaceAll('{', '').replaceAll('}', ''))
        .map((variable) => 'String $variable')
        .join(', ');

    final replacements = groups.map((group) {
      final variable = group.replaceAll('{', '').replaceAll('}', '');
      return 'replaceAll(\'$group\', $variable)';
    }).join('.');

    final comma = superConstructorParams.isNotEmpty ? ',' : '';
    final dot = replacements.isNotEmpty ? '.' : '';

    final factory = replacements.isNotEmpty
        ? '''
      
        final MethodChannel _methodChannel;

        _\$$className($constructorParameters $comma $superConstructorParams) : 
              _methodChannel = MethodChannel(\'$methodChannelName\' $dot $replacements), 
              super($superConstructorArguments);
       
    '''
        : '''
      
        final MethodChannel _methodChannel = const MethodChannel(\'$methodChannelName\');

        _\$$className($superConstructorParams) : 
 
              super($superConstructorArguments);
       
    ''';

    return factory;
  }

  String processSupportedPlatforms(String elementName,
      {List<SupportedPlatform> pluginPlatforms,
      List<SupportedPlatform> elementPlatforms}) {
    final buffer = StringBuffer();

    pluginPlatforms.forEach((platform) {
      if (!elementPlatforms.contains(platform)) {
        final platformName = describePlatform(platform);
        buffer.writeln('''
        if (Platform.is$platformName)
            throw UnsupportedError('Functionality $elementName is not available on $platformName.');
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
      final eventChannelName =
          findChannelName(field.getter.metadata, 'EventChannelStream');

      final fieldPlatforms = findSupportedPlatforms(field.getter.metadata);

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
        
        // To be able to share this stream across multiple subscribers we should call EventChannel.receiveBroadcastStream() only once.
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

  String get header {
    return ''' 
    /// **************************************************************************
    /// This code is autogenerated for you by the flutter_plugin_generator package.
    ///
    /// For all inquiry, please read the documentation or file an issue:
    /// Project Github : https://github.com/BugsBunnyBR/plugin_gen.flutter/
    ///
    /// Annotations :https://github.com/BugsBunnyBR/plugin_gen.flutter/tree/master/flutter_plugin_annotations
    /// Generator : https://github.com/BugsBunnyBR/plugin_gen.flutter/tree/master/flutter_plugin_generator
    ///
    /// This file can be recreated running the command below in the plugin directory.
    /// ```
    ///  flutter pub run build_runner build --delete-conflicting-outputs
    /// ```
    /// **************************************************************************
    ''';
  }
}
