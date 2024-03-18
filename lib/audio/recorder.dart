import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

class Recorder {
  final _recorder = AudioRecorder();

  List<InputDevice> _deviceList = [];

  bool _hasStartRecord = false;

  late Stream<Uint8List> recordStream;

  Recorder() {
    _recorder.listInputDevices().then(
          (deviceList) => _deviceList = deviceList,
        );
  }

  Future<List<String>> listDevices() async {
    return await _recorder.listInputDevices().then(
          (devices) => devices
              .map(
                (device) => device.label,
              )
              .toList(),
        );
  }
}
