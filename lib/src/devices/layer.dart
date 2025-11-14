import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';

class LayerDevice extends Device {
  final BlendingType blendingType;
  final int range;
  final int target;

  LayerDevice({
    required this.blendingType,
    this.range = 200,
    required this.target,
    bool collapsed = false,
    bool enabled = true,
  }) : super('layer', collapsed: collapsed, enabled: enabled);

  @override
  String toString() {
    return 'LayerDevice(blendingType: $blendingType, range: $range, target: $target)';
  }
}
