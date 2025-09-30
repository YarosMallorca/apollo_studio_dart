import 'package:apollo_studio_dart/src/elements/chain.dart';

import 'device.dart';

class GroupDevice extends Device {
  final List<Chain> chains;
  final int? expanded;

  GroupDevice({
    required this.chains,
    this.expanded,
    bool collapsed = false,
    bool enabled = true,
  }) : super('group');

  @override
  String toString() =>
      'GroupDevice(chains: ${chains.length}, expanded: $expanded)';
}
