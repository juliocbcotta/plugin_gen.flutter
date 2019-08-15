import 'package:flutter_gen_sample_plugin/my_test_plugin.dart';
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
      body: PluginControllerWidget(),
    ));
  }
}

class PluginControllerWidget extends StatefulWidget {
  final MyTestPlugin plugin = MyTestPlugin();

  @override
  _PluginControllerWidgetState createState() => _PluginControllerWidgetState();
}

class _PluginControllerWidgetState extends State<PluginControllerWidget> {
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
          RaisedButton(
            onPressed: () async {
              final d = await plugin.receiveSuperComplexData();
              setState(() {
                text = d.toString() + '\n\n from native';
              });
            },
            child: Text('receive my super complex map of map...'),
          ),
          RaisedButton(
            onPressed: () async {
              final data1 = MyData(data: "text1", value: MyEnum.VALUE_1);
              final other = MyOtherData(otherData: "other text");
              final map = {
                {
                  [
                    {
                      data1: other,
                    }
                  ]: other
                }: {
                  other: data1,
                }
              };
              final d = await plugin.sendSuperComplexData(map);
              setState(() {
                text = d.toString() + '\n\nto native and back again';
              });
            },
            child: Text('send my super complex map of map...'),
          ),
          StreamBuilder<Map<int, MyData>>(
              stream: plugin.counter,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (!snapshot.hasData) {
                  return Text('counter not initialized');
                }
                return Text(snapshot.data.toString());
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  await plugin.startCounter;
                },
                child: Text('start counter'),
              ),
              RaisedButton(
                onPressed: () async {
                  await plugin.stopCounter;
                },
                child: Text('stop counter'),
              ),
            ],
          ),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(text),
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveString;
                    setState(() {
                      text = d.toString();
                    });
                  },
                  child: Text('receive string'),
                ),
                RaisedButton(
                  onPressed: () async {
                    try {
                      final d = await plugin
                          .failToReceiveStringOnAnythingOtherThanIOS;
                      setState(() {
                        text = d.toString();
                      });
                    } catch (e) {
                      setState(() {
                        text = 'ATTENTION: \n\n' +
                            e.toString() +
                            '\n\n This was defined in the plugin declarion, this is not a bug!';
                      });
                    }
                  },
                  child: Text('should work only in IOS'),
                ),
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  await plugin.receiveVoid;
                  setState(() {
                    text = 'void';
                  });
                },
                child: Text('receive void'),
              ),
              RaisedButton(
                onPressed: () async {
                  final d = await plugin.receiveNull;
                  setState(() {
                    text = '$d';
                  });
                },
                child: Text('receive null'),
              ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveInt;
                    setState(() {
                      text = d.toString();
                    });
                  },
                  child: Text('receive int'),
                ),
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveDouble;
                    setState(() {
                      text = d.toString();
                    });
                  },
                  child: Text('receive double'),
                ),
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveSimpleStringList;
                    setState(() {
                      text = d.join(',');
                    });
                  },
                  child: Text('receive string list'),
                ),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveSimpleIntList;
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
                        return entry.key.toString() +
                            ': ' +
                            entry.value.toString();
                      }).toString();
                    });
                  },
                  child: Text('receive simple map'),
                ),
              ]),
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
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveComplexMap();
                    setState(() {
                      text = d.entries.map((entry) {
                        return entry.key.toString() +
                            ': ' +
                            entry.value.toString();
                      }).toString();
                    });
                  },
                  child: Text('receive complex map'),
                ),
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveMyData;
                    setState(() {
                      text = d.toString();
                    });
                  },
                  child: Text('receive MyData'),
                ),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.receiveMyDataList;
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
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final d = await plugin.sendMultipleDartTypes(
                        'hello world', 42, 1.0);
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
                        str:
                            'many different types of data, complex and simple data');
                    setState(() {
                      text = d;
                    });
                  },
                  child: Text('send multiple mixed types'),
                ),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
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
                        return entry.key.toString() +
                            ': ' +
                            entry.value.toString();
                      }).toString();
                    });
                  },
                  child: Text('send simple map'),
                ),
              ]),
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
          SizedBox(
            height: 200,
            child: Center(
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
