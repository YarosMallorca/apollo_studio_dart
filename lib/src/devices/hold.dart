import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/length.dart';
import 'package:apollo_studio_dart/src/structures/time.dart';

import 'device.dart';

class HoldDevice extends Device {
  Time time;
  double gate;
  HoldType holdMode;
  bool release;

  HoldDevice({
    required this.time,
    required this.gate,
    required this.holdMode,
    required this.release,
    bool collapsed = false,
    bool enabled = true,
  }) : super('hold', collapsed: collapsed, enabled: enabled);

  HoldDevice clone() => HoldDevice(
    time: Time(
      mode: time.mode,
      length: Length(time.length.step),
      free: time.free,
    ),
    gate: gate,
    holdMode: holdMode,
    release: release,
  );

  bool get actualRelease => holdMode == HoldType.minimum ? false : release;

  @override
  String toString() {
    return 'HoldDevice(time: $time, gate: $gate, holdMode: $holdMode, release: $release, deviceType: $deviceType, collapsed: $collapsed, enabled: $enabled)';
  }
}
