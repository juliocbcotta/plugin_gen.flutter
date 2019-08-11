import 'package:base_plugin/base_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'my_platform_plugin.g.dart';

@MethodCallPlugin(channelName: "my channel name")
abstract class MyPlatformPlugin {
  Future<String> receiveString();

  Future<void> receiveVoid();

  Future<Null> receiveNull();

  Future<int> receiveInt();

  Future<double> receiveDouble();

  Future<MyData> receiveMyData();

  Future<List<String>> receiveSimpleStringList();

  Future<List<int>> receiveSimpleIntList();

  Future<List<MyData>> receiveMyDataList();

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

  static MyPlatformPlugin create() {
    return _$MyPlatformPlugin();
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
