import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';

part 'my_test_plugin.g.dart';

@SupportedPlatforms(only: [
  SupportedPlatform.IOS,
  SupportedPlatform.Android,
])
@MethodCallPlugin(channelName: "my channel name")
abstract class MyTestPlugin {
  /// This counter will emit a value every time the underlying platform do so.
  /// This is done using a static EventChannel.
  @EventChannelStream(channelName: 'my event channel')
  @SupportedPlatforms(only: [
    SupportedPlatform.Android,
  ])
  Stream<int> get counter;

  /// startCounter will trigger an action that will make counter start emitting
  Future<void> get startCounter;

  /// stopCounter will cancel any previous action and make counter stop emitting
  Future<void> get stopCounter;

  @SupportedPlatforms(only: [
    SupportedPlatform.IOS,
  ])
  Future<String> get failToReceiveStringOnAnythingOtherThanIOS;

  Future<String> get receiveString;

  Future<void> get receiveVoid;

  Future<Null> get receiveNull;

  Future<int> get receiveInt;

  Future<double> get receiveDouble;

  Future<MyData> get receiveMyData;

  Future<List<String>> get receiveSimpleStringList;

  Future<List<int>> get receiveSimpleIntList;

  Future<List<MyData>> get receiveMyDataList;

  Future<String> sendString(String str);

  Future<String> sendMultipleDartTypes(String str, int number, double floating);

  Future<MyData> sendMyData(MyData data);

  Future<List<String>> sendStringList(List<String> list);

  Future<List<MyData>> sendMyDataList(List<MyData> list);

  Future<String> sendMultipleMixedTypes({
    MyData data,
    String str,
    List<MyData> datas,
    List<int> number,
    double floating,
  });

  Future<Map<double, String>> receiveSimpleMap();

  Future<Map<String, MyOtherData>> receiveSimpleKeyComplexValueMap();

  Future<Map<MyData, String>> receiveComplexKeySimpleValueMap();

  Future<Map<MyData, MyOtherData>> receiveComplexMap();

  Future<Map<String, String>> sendSimpleMap(Map<String, String> map);

  Future<Map<String, MyOtherData>> sendSimpleKeyComplexValueMap(
      Map<String, MyOtherData> map);

  Future<Map<MyData, String>> sendComplexKeySimpleValueMap(
      Map<MyData, String> map);

  Future<Map<MyData, MyOtherData>> sendComplexMap(Map<MyData, MyOtherData> map);

  Future<String> sendMultipleMaps(
    Map<String, String> map1, {
    Map<String, MyData> map2,
    Map<MyData, String> map3,
    Map<MyData, MyOtherData> map4,
  });

  static MyTestPlugin create() {
    return _$MyTestPlugin();
  }
}

enum MyEnum { VALUE_1, VALUE_2 }

class MyOtherData {
  final String otherData;

  MyOtherData({this.otherData});

  @override
  String toString() {
    return super.toString() + '\n otherData: $otherData';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'otherData': otherData};
  }

  factory MyOtherData.fromJson(Map<String, dynamic> map) {
    return MyOtherData(otherData: map['otherData']);
  }
}

class MyData {
  final String data;
  final MyEnum value;

  MyData({@required this.data, @required this.value});

  @override
  String toString() {
    return super.toString() + '\n data: $data \n value: $value';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'data': data, 'value': describeEnum(value)};
  }

  factory MyData.fromJson(Map<String, dynamic> map) {
    return MyData(
        data: map['data'],
        value: MyEnum.values
            .firstWhere((entry) => describeEnum(entry) == map['value']));
  }
}
