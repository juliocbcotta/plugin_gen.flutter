import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:counter_stream_plugin/counter_stream_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final plugin = CounterStreamPlugin.create();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var startCounter = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            startCounter ? buildStreamBuilder() : buildMessage(),
            Center(
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    startCounter = !startCounter;
                  });
                },
                child: Text(startCounter ? 'Stop counter' : 'Start counter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessage() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text('When we invalidate the view to stop the counter,'
                ' we stop the subscription, which will make the native side stop the timer'),
          ),
        ),
      ],
    );
  }

  StreamBuilder<int> buildStreamBuilder() {
    return StreamBuilder<int>(
      stream: widget.plugin.counter,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return buildCounter(snapshot.data);
      },
    );
  }

  Widget buildCounter(int data) {
    return Center(
      child: Text(
        data.toString(),
        style: Theme.of(context).textTheme.display1,
      ),
    );
  }
}
