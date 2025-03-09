import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart' as uuid_package;

final flutterBle = FlutterReactiveBle();
final flutterBlePeripheral = FlutterBlePeripheral();
const uuid = uuid_package.Uuid();
final String myUUID = uuid.v4();

class BLEManager {
  StreamSubscription? _scanSubscription;
  final List<String> detectedUUIDs = [];

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
  }

  void startAdvertising() {
    final advertisementData = AdvertiseData(
      serviceUuid: "12345678-1234-5678-1234-56789abcdef0", // Fixed UUID
      includeDeviceName: true,
    );

    flutterBlePeripheral.start(advertiseData: advertisementData).then((_) {
      print("Advertising my UUID: $myUUID");
    });
  }

  void startScanning(Function(String) onUUIDDetected) {
    _scanSubscription = flutterBle.scanForDevices(
      withServices: [Uuid.parse("12345678-1234-5678-1234-56789abcdef0")],
    ).listen((device) {
      String detectedUUID = String.fromCharCodes(device.manufacturerData);
      if (!detectedUUIDs.contains(detectedUUID)) {
        detectedUUIDs.add(detectedUUID);
        onUUIDDetected(detectedUUID);
        print("Detected UUID: $detectedUUID");
      }
    });
  }

  void stopScanning() => _scanSubscription?.cancel();
}
