import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';

class RotateDevice extends Device {
  final RotateType rotateType;
  final bool bypass;

  RotateDevice({required this.rotateType, this.bypass = false})
    : super('rotate');

  @override
  String toString() {
    return 'RotateDevice(rotateType: $rotateType, bypass: $bypass)';
  }
}
