import 'package:apollo_studio_dart/src/elements/chain.dart';
import 'package:apollo_studio_dart/src/enums.dart';

import 'device.dart';

class MultiDevice extends Device {
  final Chain preprocess;
  final List<Chain> chains;
  final int? expanded;
  final MultiType mode;

  MultiDevice({
    Chain? preprocess,
    required this.chains,
    this.expanded,
    this.mode = MultiType.forward,
    bool collapsed = false,
    bool enabled = true,
  }) : preprocess = preprocess ?? Chain.empty(),
       super('multi', collapsed: collapsed, enabled: enabled);

  @override
  String toString() =>
      'MultiDevice(chains: ${chains.length}, mode: $mode, expanded: $expanded)';
}
