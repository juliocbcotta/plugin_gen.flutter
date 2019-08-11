import 'package:flutter_gen_sample_plugin/my_platform_plugin.dart';
import 'package:flutter/material.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('test app'),
      ),
      body: PluginControllerWdiget(),
    ));
  }
}

class PluginControllerWdiget extends StatefulWidget {
  final MyPlatformPlugin plugin = MyPlatformPlugin.create();

  @override
  _PluginControllerWdigetState createState() => _PluginControllerWdigetState();
}

class _PluginControllerWdigetState extends State<PluginControllerWdiget> {
  String text = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final plugin = widget.plugin;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Center(
            child: Text(text),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveString();
              setState(() {
                text = d.toString();
              });
            },
            child: Text('receive string'),
          ),
          RaisedButton(
            onPressed: () async {
              await plugin.receiveVoid();
              setState(() {
                text = 'void';
              });
            },
            child: Text('receive void'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveNull();
              setState(() {
                text = '$d';
              });
            },
            child: Text('receive null'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveInt();
              setState(() {
                text = d.toString();
              });
            },
            child: Text('receive int'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveDouble();
              setState(() {
                text = d.toString();
              });
            },
            child: Text('receive double'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveSimpleStringList();
              setState(() {
                text = d.join(',');
              });
            },
            child: Text('receive string list'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveSimpleIntList();
              setState(() {
                text = d.join(',');
              });
            },
            child: Text('receive int list'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveSimpleMap();
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('receive simple map'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveSimpleKeyComplexValueMap();
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('receive simple key, complex value map'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveComplexKeySimpleValueMap();
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('receive complex key, simple value map'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveComplexMap();
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('receive complex map'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveMyData();
              setState(() {
                text = d.toString();
              });
            },
            child: Text('receive MyData'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveMyDataList();
              setState(() {
                text = d.join(',\n');
              });
            },
            child: Text('receive MyData list'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendString('hello world');
              setState(() {
                text = d;
              });
            },
            child: Text('send String'),
          ),
          RaisedButton(
            onPressed: () async {
              final d =
                  await plugin.sendMultipleDartTypes('hello world', 42, 1.0);
              setState(() {
                text = d;
              });
            },
            child: Text('send multiple dart types'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendMultipleMixedTypes(
                  data: MyData(data: "some text", value: MyEnum.VALUE_1),
                  datas: [
                    MyData(data: "some text", value: MyEnum.VALUE_1),
                    MyData(data: "some text", value: MyEnum.VALUE_1),
                  ],
                  floating: 1.0,
                  number: [1, 2, 3, 4],
                  str: 'many different types of data, complex and simple data');
              setState(() {
                text = d;
              });
            },
            child: Text('send multiple mixed types'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendMyData(
                  MyData(data: 'my data string', value: MyEnum.VALUE_1));
              setState(() {
                text = d.toString();
              });
            },
            child: Text('send MyData'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendMyDataList([
                MyData(data: 'my data string1', value: MyEnum.VALUE_1),
                MyData(data: 'my data string2', value: MyEnum.VALUE_2),
              ]);
              setState(() {
                text = d.join(',\n');
              });
            },
            child: Text('send MyData list'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendSimpleMap({"key1": "value1"});
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('send simple map'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendSimpleKeyComplexValueMap(
                  {"key1": MyOtherData(otherData: "other data value")});
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('send simple key, complex value map'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendComplexKeySimpleValueMap({
                MyData(data: "my data", value: MyEnum.VALUE_1): "value1",
              });
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('send complex key, simple value map'),
          ),
          RaisedButton(
            onPressed: () async {
              final d = await plugin.sendComplexMap({
                MyData(data: "my data", value: MyEnum.VALUE_1):
                    MyOtherData(otherData: "other data value"),
              });
              setState(() {
                text = d.entries.map((entry) {
                  return entry.key.toString() + ': ' + entry.value.toString();
                }).toString();
              });
            },
            child: Text('send complex map'),
          ),
          RaisedButton(
            onPressed: () async {
              final other = MyOtherData(otherData: "other data value");
              final data = MyData(data: "my data", value: MyEnum.VALUE_1);
              final d = await plugin.sendMultipleMaps(
                {"map1Key": "value"},
                map2: {'map2Key1': data},
                map3: {data: 'map3Value1'},
                map4: {data: other},
              );
              setState(() {
                text = d;
              });
            },
            child: Text('send multiple maps'),
          ),
          Center(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
