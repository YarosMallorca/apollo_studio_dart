import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/structures/time.dart';

class LoopDevice extends Device {
  final Time time;
  final double gate;
  final int repeats;
  final bool hold;

  LoopDevice({
    required this.time,
    required this.gate,
    required this.repeats,
    required this.hold,
    bool collapsed = false,
    bool enabled = true,
  }) : super('loop', collapsed: collapsed, enabled: enabled);

  @override
  String toString() =>
      'LoopDevice(time: $time, gate: $gate, repeats: $repeats, hold: $hold)';
}
