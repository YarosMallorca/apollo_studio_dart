import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';

class ClearDevice extends Device {
  ClearType mode;

  ClearDevice({required this.mode}) : super('clear');

  @override
  String toString() {
    return 'Clear(mode: $mode, deviceType: $deviceType, collapsed: $collapsed, enabled: $enabled)';
  }
}
