import 'dart:io';

import 'package:flutter/material.dart';
import 'package:udp/udp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tello Drone Connection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Tello Drone Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UDP _udpSocket;
  final String _droneIp = '192.168.10.1';
  final int _dronePort = 8889;
  String _response = 'No response yet';

  @override
  void initState() {
    super.initState();
    _initializeDroneConnection();
  }

  Future<void> _initializeDroneConnection() async {
    _udpSocket = await UDP.bind(Endpoint.any(port: Port(8889)));
    await _sendCommand("command");
  }

  Future<void> _sendCommand(String command) async {
    var data = command.codeUnits;
    await _udpSocket.send(data, Endpoint.unicast(InternetAddress(_droneIp), port: Port(_dronePort)));
    print("Sent command: $command");

    // Tello의 응답을 기다림
    _udpSocket.asStream().listen((datagram) {
      if (datagram != null) {
        String response = String.fromCharCodes(datagram.data);
        print("Received response: $response");

        // 화면에 응답 표시
        setState(() {
          _response = response;
        });
      }
    });
  }

  void _takeoff() async {
    await _sendCommand("takeoff");
  }

  void _land() async {
    await _sendCommand("land");
  }

  @override
  void dispose() {
    _udpSocket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Tello Drone Control', style: TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: _takeoff,
              child: const Text('Takeoff'),
            ),
            ElevatedButton(
              onPressed: _land,
              child: const Text('Land'),
            ),
            const SizedBox(height: 20),
            Text(
              'Response: $_response',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}