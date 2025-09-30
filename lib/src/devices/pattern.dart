import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/frame.dart';

import 'device.dart';

class PatternDevice extends Device {
  final int repeats;
  final double gate;
  final double pinch;
  final bool bilateral;
  final List<Frame> frames;
  final PlaybackType mode;
  final bool infinite;
  final int? rootKey;
  final bool wrap;
  final int expanded;

  PatternDevice({
    required this.repeats,
    required this.gate,
    this.pinch = 0.0,
    this.bilateral = false,
    required this.frames,
    required this.mode,
    this.infinite = false,
    this.rootKey,
    this.wrap = false,
    required this.expanded,
    bool collapsed = false,
    bool enabled = true,
  }) : super('pattern');

  @override
  String toString() =>
      'PatternDevice(frames: ${frames.length}, mode: $mode, repeats: $repeats)';
}
