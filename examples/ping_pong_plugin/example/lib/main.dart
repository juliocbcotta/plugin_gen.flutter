import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ping_pong_plugin/ping_pong_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final plugin = PingPongPlugin.create();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> pings = [];
  List<String> pings2 = [];

  @override
  void initState() {
    widget.plugin.listen(pong);
    super.initState();
  }

  @override
  void dispose() {
    widget.plugin.listen(null);
    super.dispose();
  }

  Future<void> pong(String pong) {
    setState(() {
      pings.add('pong');
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  setState(() {
                    pings.clear();
                    pings2.clear();
                  });
                },
                child: Text('clear'))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async {
                      await widget.plugin.ping();
                      pings.add('ping');
                    },
                    child: Text('Send ping'),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      pings2.add('ping2');
                      final pong = await widget.plugin.ping2();
                      setState(() {
                        pings2.add(pong);
                      });
                    },
                    child: Text('Send ping2'),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: pings.length,
                        itemBuilder: (context, index) => ListTile(
                          dense: true,
                          title: Text(pings[index]),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: pings2.length,
                        itemBuilder: (context, index) => ListTile(
                          dense: true,
                          title: Text(pings2[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
