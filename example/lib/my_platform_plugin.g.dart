// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_platform_plugin.dart';

// **************************************************************************
// FlutterPluginGenerator
// **************************************************************************

class _$MyPlatformPlugin extends MyPlatformPlugin {
  final MethodChannel _methodChannel;

  factory _$MyPlatformPlugin() {
    return _$MyPlatformPlugin.private(const MethodChannel('my channel name'));
  }

  _$MyPlatformPlugin.private(this._methodChannel);

  @override
  Future<String> receiveString() async {
    final result = await _methodChannel.invokeMethod<String>('receiveString');
    return result;
  }

  @override
  Future<void> receiveVoid() async {
    final result = await _methodChannel.invokeMethod<void>('receiveVoid');
    return result;
  }

  @override
  Future<Null> receiveNull() async {
    final result = await _methodChannel.invokeMethod<Null>('receiveNull');
    return result;
  }

  @override
  Future<int> receiveInt() async {
    final result = await _methodChannel.invokeMethod<int>('receiveInt');
    return result;
  }

  @override
  Future<double> receiveDouble() async {
    final result = await _methodChannel.invokeMethod<double>('receiveDouble');
    return result;
  }

  @override
  Future<MyData> receiveMyData() async {
    final result =
        await _methodChannel.invokeMapMethod<String, dynamic>('receiveMyData');
    return MyData.fromJson(result);
  }

  @override
  Future<List<String>> receiveSimpleStringList() async {
    final result = await _methodChannel
        .invokeListMethod<String>('receiveSimpleStringList');
    return result;
  }

  @override
  Future<List<int>> receiveSimpleIntList() async {
    final result =
        await _methodChannel.invokeListMethod<int>('receiveSimpleIntList');
    return result;
  }

  @override
  Future<List<MyData>> receiveMyDataList() async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('receiveMyDataList');
    return result
        .map((item) => Map<String, dynamic>.from(item))
        .map((item) => MyData.fromJson(item))
        .toList();
  }

  @override
  Future<String> sendString(
    String str,
  ) async {
    final result = await _methodChannel.invokeMethod<String>('sendString', str);
    return result;
  }

  @override
  Future<String> sendMultipleDartTypes(
    String str,
    int number,
    double floating,
  ) async {
    final result = await _methodChannel.invokeMethod<String>(
        'sendMultipleDartTypes',
        <String, dynamic>{'str': str, 'number': number, 'floating': floating});
    return result;
  }

  @override
  Future<MyData> sendMyData(
    MyData data,
  ) async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'sendMyData', data.toJson());
    return MyData.fromJson(result);
  }

  @override
  Future<List<String>> sendStringList(
    List<String> list,
  ) async {
    final result =
        await _methodChannel.invokeListMethod<String>('sendStringList', list);
    return result;
  }

  @override
  Future<List<MyData>> sendMyDataList(
    List<MyData> list,
  ) async {
    final result = await _methodChannel.invokeListMethod<dynamic>(
        'sendMyDataList', list.map((item) => item.toJson()).toList());
    return result
        .map((item) => Map<String, dynamic>.from(item))
        .map((item) => MyData.fromJson(item))
        .toList();
  }

  @override
  Future<String> sendMultipleMixedTypes({
    MyData data,
    String str,
    List<MyData> datas,
    List<int> number,
    double floating,
  }) async {
    final result = await _methodChannel
        .invokeMethod<String>('sendMultipleMixedTypes', <String, dynamic>{
      'data': data.toJson(),
      'str': str,
      'datas': datas.map((item) => item.toJson()).toList(),
      'number': number,
      'floating': floating
    });
    return result;
  }

  @override
  Future<Map<double, String>> receiveSimpleMap() async {
    final result = await _methodChannel
        .invokeMapMethod<double, String>('receiveSimpleMap');
    return Map<double, String>.from(result);
  }

  @override
  Future<Map<String, MyOtherData>> receiveSimpleKeyComplexValueMap() async {
    final result = await _methodChannel
        .invokeMapMethod<String, dynamic>('receiveSimpleKeyComplexValueMap');
    return result
        .map((key, value) => MapEntry(
              key,
              Map<String, dynamic>.from(value),
            ))
        .map((key, value) => MapEntry(
              key,
              MyOtherData.fromJson(value),
            ));
  }

  @override
  Future<Map<MyData, String>> receiveComplexKeySimpleValueMap() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, String>('receiveComplexKeySimpleValueMap');
    return result
        .map((key, value) => MapEntry(
              Map<String, dynamic>.from(key),
              value,
            ))
        .map((key, value) => MapEntry(
              MyData.fromJson(key),
              value,
            ));
  }

  @override
  Future<Map<MyData, MyOtherData>> receiveComplexMap() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, dynamic>('receiveComplexMap');
    return result
        .map((key, value) => MapEntry(
              Map<String, dynamic>.from(key),
              Map<String, dynamic>.from(value),
            ))
        .map((key, value) => MapEntry(
              MyData.fromJson(key),
              MyOtherData.fromJson(value),
            ));
  }

  @override
  Future<Map<String, String>> sendSimpleMap(
    Map<String, String> map,
  ) async {
    final result = await _methodChannel.invokeMapMethod<String, String>(
        'sendSimpleMap', map);
    return Map<String, String>.from(result);
  }

  @override
  Future<Map<String, MyOtherData>> sendSimpleKeyComplexValueMap(
    Map<String, MyOtherData> map,
  ) async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'sendSimpleKeyComplexValueMap',
        map.map((key, value) => MapEntry(key, value.toJson())));
    return result
        .map((key, value) => MapEntry(
              key,
              Map<String, dynamic>.from(value),
            ))
        .map((key, value) => MapEntry(
              key,
              MyOtherData.fromJson(value),
            ));
  }

  @override
  Future<Map<MyData, String>> sendComplexKeySimpleValueMap(
    Map<MyData, String> map,
  ) async {
    final result = await _methodChannel.invokeMapMethod<dynamic, String>(
        'sendComplexKeySimpleValueMap',
        map.map((key, value) => MapEntry(key.toJson(), value)));
    return result
        .map((key, value) => MapEntry(
              Map<String, dynamic>.from(key),
              value,
            ))
        .map((key, value) => MapEntry(
              MyData.fromJson(key),
              value,
            ));
  }

  @override
  Future<Map<MyData, MyOtherData>> sendComplexMap(
    Map<MyData, MyOtherData> map,
  ) async {
    final result = await _methodChannel.invokeMapMethod<dynamic, dynamic>(
        'sendComplexMap',
        map.map((key, value) => MapEntry(key.toJson(), value.toJson())));
    return result
        .map((key, value) => MapEntry(
              Map<String, dynamic>.from(key),
              Map<String, dynamic>.from(value),
            ))
        .map((key, value) => MapEntry(
              MyData.fromJson(key),
              MyOtherData.fromJson(value),
            ));
  }

  @override
  Future<String> sendMultipleMaps(
    Map<String, String> map1, {
    Map<String, MyData> map2,
    Map<MyData, String> map3,
    Map<MyData, MyOtherData> map4,
  }) async {
    final result = await _methodChannel
        .invokeMethod<String>('sendMultipleMaps', <String, dynamic>{
      'map1': map1,
      'map2': map2.map((key, value) => MapEntry(key, value.toJson())),
      'map3': map3.map((key, value) => MapEntry(key.toJson(), value)),
      'map4': map4.map((key, value) => MapEntry(key.toJson(), value.toJson()))
    });
    return result;
  }
}
