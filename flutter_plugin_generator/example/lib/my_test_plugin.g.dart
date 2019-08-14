// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_test_plugin.dart';

// **************************************************************************
// FlutterPluginGenerator
// **************************************************************************

class _$MyTestPlugin extends MyTestPlugin {
  static const MethodChannel _methodChannel =
      const MethodChannel('my channel name');

  _$MyTestPlugin();

  static const EventChannel _counterEventChannel =
      const EventChannel('my event channel');

  final Stream<dynamic> _counter =
      _counterEventChannel.receiveBroadcastStream();

  @override
  Stream<Map<int, MyData>> get counter {
    return _counter.map((item) {
      return Map<int, dynamic>.from(item).map(
        (key, value) => MapEntry(
          key,
          MyData.fromJson(Map<String, dynamic>.from(value)),
        ),
      );
    });
  }

  @override
  Future<String> get failToReceiveStringOnAnythingOtherThanIOS async {
    if (Platform.isAndroid)
      throw UnsupportedError(
          'Functionality failToReceiveStringOnAnythingOtherThanIOS is not available on Android.');

    final result = await _methodChannel
        .invokeMethod<String>('failToReceiveStringOnAnythingOtherThanIOS');

    return result;
  }

  @override
  Future<void> get startCounter async {
    final result = await _methodChannel.invokeMethod<void>('startCounter');

    return result;
  }

  @override
  Future<void> get stopCounter async {
    final result = await _methodChannel.invokeMethod<void>('stopCounter');

    return result;
  }

  @override
  Future<String> get receiveString async {
    final result = await _methodChannel.invokeMethod<String>('receiveString');

    return result;
  }

  @override
  Future<void> get receiveVoid async {
    final result = await _methodChannel.invokeMethod<void>('receiveVoid');

    return result;
  }

  @override
  Future<Null> get receiveNull async {
    final result = await _methodChannel.invokeMethod<Null>('receiveNull');

    return result;
  }

  @override
  Future<int> get receiveInt async {
    final result = await _methodChannel.invokeMethod<int>('receiveInt');

    return result;
  }

  @override
  Future<double> get receiveDouble async {
    final result = await _methodChannel.invokeMethod<double>('receiveDouble');

    return result;
  }

  @override
  Future<MyData> get receiveMyData async {
    final result =
        await _methodChannel.invokeMapMethod<String, dynamic>('receiveMyData');

    return MyData.fromJson(result);
  }

  @override
  Future<List<String>> get receiveSimpleStringList async {
    final result = await _methodChannel
        .invokeListMethod<String>('receiveSimpleStringList');

    return result;
  }

  @override
  Future<List<int>> get receiveSimpleIntList async {
    final result =
        await _methodChannel.invokeListMethod<int>('receiveSimpleIntList');

    return result;
  }

  @override
  Future<List<MyData>> get receiveMyDataList async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('receiveMyDataList');

    return result
        .map((item) => MyData.fromJson(Map<String, dynamic>.from(item)))
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
        .map((item) => MyData.fromJson(Map<String, dynamic>.from(item)))
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

    return result.map(
      (key, value) => MapEntry(
        key,
        MyOtherData.fromJson(Map<String, dynamic>.from(value)),
      ),
    );
  }

  @override
  Future<Map<MyData, String>> receiveComplexKeySimpleValueMap() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, String>('receiveComplexKeySimpleValueMap');

    return result.map(
      (key, value) => MapEntry(
        MyData.fromJson(Map<String, dynamic>.from(key)),
        value,
      ),
    );
  }

  @override
  Future<Map<MyData, MyOtherData>> receiveComplexMap() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, dynamic>('receiveComplexMap');

    return result.map(
      (key, value) => MapEntry(
        MyData.fromJson(Map<String, dynamic>.from(key)),
        MyOtherData.fromJson(Map<String, dynamic>.from(value)),
      ),
    );
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
        map.map(
          (key, value) => MapEntry(
            key,
            value.toJson(),
          ),
        ));

    return result.map(
      (key, value) => MapEntry(
        key,
        MyOtherData.fromJson(Map<String, dynamic>.from(value)),
      ),
    );
  }

  @override
  Future<Map<MyData, String>> sendComplexKeySimpleValueMap(
    Map<MyData, String> map,
  ) async {
    final result = await _methodChannel.invokeMapMethod<dynamic, String>(
        'sendComplexKeySimpleValueMap',
        map.map(
          (key, value) => MapEntry(
            key.toJson(),
            value,
          ),
        ));

    return result.map(
      (key, value) => MapEntry(
        MyData.fromJson(Map<String, dynamic>.from(key)),
        value,
      ),
    );
  }

  @override
  Future<Map<MyData, MyOtherData>> sendComplexMap(
    Map<MyData, MyOtherData> map,
  ) async {
    final result = await _methodChannel.invokeMapMethod<dynamic, dynamic>(
        'sendComplexMap',
        map.map(
          (key, value) => MapEntry(
            key.toJson(),
            value.toJson(),
          ),
        ));

    return result.map(
      (key, value) => MapEntry(
        MyData.fromJson(Map<String, dynamic>.from(key)),
        MyOtherData.fromJson(Map<String, dynamic>.from(value)),
      ),
    );
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
      'map2': map2.map(
        (key, value) => MapEntry(
          key,
          value.toJson(),
        ),
      ),
      'map3': map3.map(
        (key, value) => MapEntry(
          key.toJson(),
          value,
        ),
      ),
      'map4': map4.map(
        (key, value) => MapEntry(
          key.toJson(),
          value.toJson(),
        ),
      )
    });

    return result;
  }

  @override
  Future<List<List<int>>> listOfListOfInt() async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('listOfListOfInt');

    return result.map((item) => List.castFrom(item)).toList();
  }

  @override
  Future<List<List<MyData>>> listOfListOfMyData() async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('listOfListOfMyData');

    return result
        .map((item) => List.castFrom(item)
            .map((item) => MyData.fromJson(Map<String, dynamic>.from(item)))
            .toList())
        .toList();
  }

  @override
  Future<List<Map<String, String>>> listOfMapStringString() async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('listOfMapStringString');

    return result.map((item) => Map<String, String>.from(item)).toList();
  }

  @override
  Future<List<Map<MyData, String>>> listOfMapMyDataString() async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('listOfMapMyDataString');

    return result
        .map((item) => Map<dynamic, String>.from(item).map(
              (key, value) => MapEntry(
                MyData.fromJson(Map<String, dynamic>.from(key)),
                value,
              ),
            ))
        .toList();
  }

  @override
  Future<List<Map<String, MyData>>> listOfMapStringMyData() async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('listOfMapStringMyData');

    return result
        .map((item) => Map<String, dynamic>.from(item).map(
              (key, value) => MapEntry(
                key,
                MyData.fromJson(Map<String, dynamic>.from(value)),
              ),
            ))
        .toList();
  }

  @override
  Future<List<Map<MyData, MyData>>> listOfMapMyDataMyData() async {
    final result =
        await _methodChannel.invokeListMethod<dynamic>('listOfMapMyDataMyData');

    return result
        .map((item) => Map<dynamic, dynamic>.from(item).map(
              (key, value) => MapEntry(
                MyData.fromJson(Map<String, dynamic>.from(key)),
                MyData.fromJson(Map<String, dynamic>.from(value)),
              ),
            ))
        .toList();
  }

  @override
  Future<Map<List<int>, String>> mapOfListIntAndString() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, String>('mapOfListIntAndString');

    return result.map(
      (key, value) => MapEntry(
        List.castFrom(key),
        value,
      ),
    );
  }

  @override
  Future<Map<List<int>, MyData>> mapOfListIntAndMyData() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, dynamic>('mapOfListIntAndMyData');

    return result.map(
      (key, value) => MapEntry(
        List.castFrom(key),
        MyData.fromJson(Map<String, dynamic>.from(value)),
      ),
    );
  }

  @override
  Future<Map<List<MyData>, String>> mapOfListMyDataAndString() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, String>('mapOfListMyDataAndString');

    return result.map(
      (key, value) => MapEntry(
        List.castFrom(key)
            .map((item) => MyData.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        value,
      ),
    );
  }

  @override
  Future<Map<List<MyData>, MyData>> mapOfListMyDataAndMyData() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, dynamic>('mapOfListMyDataAndMyData');

    return result.map(
      (key, value) => MapEntry(
        List.castFrom(key)
            .map((item) => MyData.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        MyData.fromJson(Map<String, dynamic>.from(value)),
      ),
    );
  }

  @override
  Future<Map<List<MyData>, List<MyData>>>
      mapOfListMyDataAndListOfMyData() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, dynamic>('mapOfListMyDataAndListOfMyData');

    return result.map(
      (key, value) => MapEntry(
        List.castFrom(key)
            .map((item) => MyData.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        List.castFrom(value)
            .map((item) => MyData.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      ),
    );
  }

  @override
  Future<Map<Map<int, int>, Map<String, String>>>
      mapOfMapIntIntAndMapStringString() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, dynamic>('mapOfMapIntIntAndMapStringString');

    return result.map(
      (key, value) => MapEntry(
        Map<int, int>.from(key),
        Map<String, String>.from(value),
      ),
    );
  }

  @override
  Future<Map<Map<MyData, MyOtherData>, Map<MyOtherData, MyData>>>
      mapOfMapMyDataMyOtherDataAndMapMyOtherDataMyData() async {
    final result = await _methodChannel.invokeMapMethod<dynamic, dynamic>(
        'mapOfMapMyDataMyOtherDataAndMapMyOtherDataMyData');

    return result.map(
      (key, value) => MapEntry(
        Map<dynamic, dynamic>.from(key).map(
          (key, value) => MapEntry(
            MyData.fromJson(Map<String, dynamic>.from(key)),
            MyOtherData.fromJson(Map<String, dynamic>.from(value)),
          ),
        ),
        Map<dynamic, dynamic>.from(value).map(
          (key, value) => MapEntry(
            MyOtherData.fromJson(Map<String, dynamic>.from(key)),
            MyData.fromJson(Map<String, dynamic>.from(value)),
          ),
        ),
      ),
    );
  }

  @override
  Future<
      Map<Map<List<Map<MyData, MyOtherData>>, MyOtherData>,
          Map<MyOtherData, MyData>>> receiveSuperComplexData() async {
    final result = await _methodChannel
        .invokeMapMethod<dynamic, dynamic>('receiveSuperComplexData');

    return result.map(
      (key, value) => MapEntry(
        Map<dynamic, dynamic>.from(key).map(
          (key, value) => MapEntry(
            List.castFrom(key)
                .map((item) => Map<dynamic, dynamic>.from(item).map(
                      (key, value) => MapEntry(
                        MyData.fromJson(Map<String, dynamic>.from(key)),
                        MyOtherData.fromJson(Map<String, dynamic>.from(value)),
                      ),
                    ))
                .toList(),
            MyOtherData.fromJson(Map<String, dynamic>.from(value)),
          ),
        ),
        Map<dynamic, dynamic>.from(value).map(
          (key, value) => MapEntry(
            MyOtherData.fromJson(Map<String, dynamic>.from(key)),
            MyData.fromJson(Map<String, dynamic>.from(value)),
          ),
        ),
      ),
    );
  }

  @override
  Future<
      Map<Map<List<Map<MyData, MyOtherData>>, MyOtherData>,
          Map<MyOtherData, MyData>>> sendSuperComplexData(
    Map<Map<List<Map<MyData, MyOtherData>>, MyOtherData>,
            Map<MyOtherData, MyData>>
        map,
  ) async {
    final result = await _methodChannel.invokeMapMethod<dynamic, dynamic>(
        'sendSuperComplexData',
        map.map(
          (key, value) => MapEntry(
            key.map(
              (key, value) => MapEntry(
                key
                    .map((item) => item.map(
                          (key, value) => MapEntry(
                            key.toJson(),
                            value.toJson(),
                          ),
                        ))
                    .toList(),
                value.toJson(),
              ),
            ),
            value.map(
              (key, value) => MapEntry(
                key.toJson(),
                value.toJson(),
              ),
            ),
          ),
        ));

    return result.map(
      (key, value) => MapEntry(
        Map<dynamic, dynamic>.from(key).map(
          (key, value) => MapEntry(
            List.castFrom(key)
                .map((item) => Map<dynamic, dynamic>.from(item).map(
                      (key, value) => MapEntry(
                        MyData.fromJson(Map<String, dynamic>.from(key)),
                        MyOtherData.fromJson(Map<String, dynamic>.from(value)),
                      ),
                    ))
                .toList(),
            MyOtherData.fromJson(Map<String, dynamic>.from(value)),
          ),
        ),
        Map<dynamic, dynamic>.from(value).map(
          (key, value) => MapEntry(
            MyOtherData.fromJson(Map<String, dynamic>.from(key)),
            MyData.fromJson(Map<String, dynamic>.from(value)),
          ),
        ),
      ),
    );
  }
}
