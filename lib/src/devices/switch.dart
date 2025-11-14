import 'device.dart';

class SwitchDevice extends Device {
  final int target;
  final int value;

  SwitchDevice({
    required this.target,
    required this.value,
    bool collapsed = false,
    bool enabled = true,
  }) : super('switch', collapsed: collapsed, enabled: enabled) {
    // Ensure target is valid (1-4)
    assert(target >= 1 && target <= 4, 'Switch target must be between 1 and 4');
  }

  @override
  String toString() => 'SwitchDevice(target: $target, value: $value)';
}
