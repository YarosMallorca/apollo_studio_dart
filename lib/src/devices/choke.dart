import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/elements/chain.dart';

class ChokeDevice extends Device {
  final int target;
  final Chain chain;

  ChokeDevice({required this.target, required this.chain})
    : assert(target >= 1 && target <= 16, 'Target must be between 1 and 16'),
      super('choke');

  @override
  String toString() {
    return 'ChokeDevice(target: $target, chain: $chain)';
  }
}
