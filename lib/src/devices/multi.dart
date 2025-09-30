import 'package:apollo_studio_dart/src/elements/chain.dart';
import 'package:apollo_studio_dart/src/enums.dart';

import 'device.dart';

class MultiDevice extends Device {
  final Chain preprocess;
  final List<Chain> chains;
  final int? expanded;
  final MultiType mode;

  MultiDevice({
    required this.preprocess,
    required this.chains,
    this.expanded,
    required this.mode,
    bool collapsed = false,
    bool enabled = true,
  }) : super('multi');

  @override
  String toString() =>
      'MultiDevice(chains: ${chains.length}, mode: $mode, expanded: $expanded)';
}
