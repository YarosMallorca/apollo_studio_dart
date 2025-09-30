import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/offset.dart';
import 'package:apollo_studio_dart/src/structures/time.dart';

import 'device.dart';

class CopyDevice extends Device {
  final Time time;
  final double gate;
  final double pinch;
  final bool bilateral;
  final bool reverse;
  final bool infinite;
  final CopyType copyType;
  final GridType gridType;
  final bool wrap;
  final List<Offset> offsets;
  final List<int> angles;

  CopyDevice({
    required this.time,
    required this.gate,
    this.pinch = 0.0,
    this.bilateral = false,
    this.reverse = false,
    this.infinite = false,
    required this.copyType,
    required this.gridType,
    required this.wrap,
    required this.offsets,
    required this.angles,
    bool collapsed = false,
    bool enabled = true,
  }) : super('copy');

  @override
  String toString() =>
      'CopyDevice(time: $time, gate: $gate, type: $copyType, offsets: $offsets, angles: $angles)';
}
