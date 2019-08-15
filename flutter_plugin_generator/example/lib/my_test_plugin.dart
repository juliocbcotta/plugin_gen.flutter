import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_plugin_annotations/flutter_plugin_annotations.dart';

part 'my_test_plugin.g.dart';

@FlutterPlugin()
@SupportedPlatforms(only: [
  SupportedPlatform.IOS,
  SupportedPlatform.Android,
])
@MethodChannelFutures(channelName: "my channel name")
abstract class MyTestPlugin {

  Future<MyEnum> receiveEnum(MyEnum e);

  /// This counter will emit a value every time the underlying platform do so.
  /// This is done using a static EventChannel.
  @EventChannelStream(channelName: 'my event channel')
  Stream<Map<int, MyData>> get counter;

  /// startCounter will trigger an action that will make counter start emitting
  Future<void> get startCounter;

  /// stopCounter will cancel any previous action and make counter stop emitting
  Future<void> get stopCounter;

  @SupportedPlatforms(only: [
    SupportedPlatform.IOS,
  ])
  Future<String> failToReceiveStringOnAnythingOtherThanIOS;

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

  Future<List<List<int>>> listOfListOfInt();

  Future<List<List<MyData>>> listOfListOfMyData();

  Future<List<Map<String, String>>> listOfMapStringString();

  Future<List<Map<MyData, String>>> listOfMapMyDataString();

  Future<List<Map<String, MyData>>> listOfMapStringMyData();

  Future<List<Map<MyData, MyData>>> listOfMapMyDataMyData();

  Future<Map<List<int>, String>> mapOfListIntAndString();

  Future<Map<List<int>, MyData>> mapOfListIntAndMyData();

  Future<Map<List<MyData>, String>> mapOfListMyDataAndString();

  Future<Map<List<MyData>, MyData>> mapOfListMyDataAndMyData();

  Future<Map<List<MyData>, List<MyData>>> mapOfListMyDataAndListOfMyData();

  Future<Map<Map<int, int>, Map<String, String>>>
      mapOfMapIntIntAndMapStringString();

  Future<Map<Map<MyData, MyOtherData>, Map<MyOtherData, MyData>>>
      mapOfMapMyDataMyOtherDataAndMapMyOtherDataMyData();

  Future<
      Map<Map<List<Map<MyData, MyOtherData>>, MyOtherData>,
          Map<MyOtherData, MyData>>> receiveSuperComplexData();

  Future<
      Map<Map<List<Map<MyData, MyOtherData>>, MyOtherData>,
          Map<MyOtherData, MyData>>> sendSuperComplexData(
      Map<Map<List<Map<MyData, MyOtherData>>, MyOtherData>,
              Map<MyOtherData, MyData>>
          map);

  static MyTestPlugin create() {
    return _$MyTestPlugin();
  }
}

enum MyEnum { VALUE_1, VALUE_2
}

class MyOtherData {
  final String otherData;

  MyOtherData({this.otherData});

  @override
  String toString() {
    return super.toString() + '\n other: $otherData';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'other': otherData};
  }

  factory MyOtherData.fromJson(Map<String, dynamic> map) {
    return MyOtherData(otherData: map['other']);
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
