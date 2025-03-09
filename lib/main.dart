import 'dart:async';
import 'package:ble_dating_app/ble_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:uuid/uuid.dart' as uuid_package;

final flutterBle = FlutterReactiveBle();
const uuid = uuid_package.Uuid();
final String myUUID = uuid.v4();

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final BLEManager bleManager = BLEManager();
  List<String> detectedUUIDs = [];

  @override
  void initState() {
    super.initState();
    _setupBLE();
  }

  Future<void> _setupBLE() async {
    await bleManager.requestPermissions();
    bleManager.startAdvertising();
    bleManager.startScanning((uuid) {
      setState(() => detectedUUIDs.add(uuid));
    });
  }

  @override
  void dispose() {
    bleManager.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("BLE UUID PoC")),
        body: Column(
          children: [
            Text("My UUID: $myUUID"),
            Expanded(
              child: ListView(
                children: detectedUUIDs
                    .map((uuid) => ListTile(title: Text(uuid)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
