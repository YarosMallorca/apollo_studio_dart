import 'device.dart';

class LayerFilterDevice extends Device {
  final int target;
  final int range;

  LayerFilterDevice({
    required this.target,
    required this.range,
    bool collapsed = false,
    bool enabled = true,
  }) : super('layer_filter');

  @override
  String toString() => 'LayerFilterDevice(target: $target, range: $range)';
}
