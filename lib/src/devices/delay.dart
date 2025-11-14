import 'package:apollo_studio_dart/src/structures/time.dart';

import 'device.dart';

class DelayDevice extends Device {
  final Time time;
  final double gate;

  DelayDevice({
    required this.time,
    this.gate = 1,
    bool collapsed = false,
    bool enabled = true,
  }) : assert(gate >= 0.1 && gate <= 4, 'Gate must be between 0.1 and 4'),
       super('delay', collapsed: collapsed, enabled: enabled);

  @override
  String toString() {
    return 'DelayDevice(time: $time, gate: $gate)';
  }
}
