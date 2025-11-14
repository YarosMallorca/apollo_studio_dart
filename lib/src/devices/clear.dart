import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';

class ClearDevice extends Device {
  ClearType mode;

  ClearDevice({required this.mode, bool collapsed = false, bool enabled = true})
    : super('clear', collapsed: collapsed, enabled: enabled);

  @override
  String toString() {
    return 'Clear(mode: $mode, deviceType: $deviceType, collapsed: $collapsed, enabled: $enabled)';
  }
}
