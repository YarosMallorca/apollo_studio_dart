import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';

class FlipDevice extends Device {
  final FlipType flipType;
  final bool bypass;

  FlipDevice({
    required this.flipType,
    this.bypass = false,
    bool collapsed = false,
    bool enabled = true,
  }) : super('flip', collapsed: collapsed, enabled: enabled);

  @override
  String toString() {
    return 'FlipDevice(flipType: $flipType, bypass: $bypass)';
  }
}
