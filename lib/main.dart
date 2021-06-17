import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'heatmap/heatmap_calendar.dart';
import 'heatmap/time_utils.dart';

// If Server is using SockJs
// final socketUrl = 'http://10.0.2.2:8080/ws-message';
// If Server is not using SockJs
final socketUrl = 'ws://10.0.2.2:8080/ws-message';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter WebSocket Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StompClient stompClient;
  String message = '';

  @override
  void initState() {
    super.initState();

    // // If Server is using SockJs
    // stompClient = StompClient(
    //   config: StompConfig.SockJS(
    //     url: socketUrl,
    //     onConnect: onConnect,
    //     onWebSocketError: (dynamic error) => print(error.toString()),
    //   ),
    // );

    // If Server is not using SockJs
    stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        onConnect: onConnect,
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );

    stompClient.activate();
  }

  onConnect(StompFrame frame) {
    stompClient.subscribe(
        destination: '/topic/message',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            Map<String, dynamic> result = json.decode(frame.body.toString());
            setState(() => message = result['message']);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your message from server:'),
            Text(
              '$message',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            HeatMapCalendar(
              input: {
                TimeUtils.removeTime(
                    DateTime.now().subtract(Duration(days: 3))): 5,
                TimeUtils.removeTime(
                    DateTime.now().subtract(Duration(days: 2))): 35,
                TimeUtils.removeTime(
                    DateTime.now().subtract(Duration(days: 1))): 14,
                TimeUtils.removeTime(DateTime.now()): 5,
              },
              colorThresholds: {
                1: Colors.green.shade100,
                10: Colors.green.shade300,
                30: Colors.green.shade500
              },
              weekDaysLabels: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
              monthsLabels: [
                "",
                "Jan",
                "Feb",
                "Mar",
                "Apr",
                "May",
                "Jun",
                "Jul",
                "Aug",
                "Sep",
                "Oct",
                "Nov",
                "Dec",
              ],
              squareSize: 16.0,
              textOpacity: 0.3,
              labelTextColor: Colors.blueGrey,
              dayTextColor: Colors.blue.shade500,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
  }
}
