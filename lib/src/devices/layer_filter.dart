import 'device.dart';

class LayerFilterDevice extends Device {
  final int target;
  final int range;

  LayerFilterDevice({
    required this.target,
    required this.range,
    bool collapsed = false,
    bool enabled = true,
  }) : super('layerfilter', collapsed: collapsed, enabled: enabled);

  @override
  String toString() => 'LayerFilterDevice(target: $target, range: $range)';
}
