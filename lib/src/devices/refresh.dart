import 'device.dart';

class RefreshDevice extends Device {
  final List<bool> targets;

  RefreshDevice({
    required this.targets,
    bool collapsed = false,
    bool enabled = true,
  }) : super('refresh', collapsed: collapsed, enabled: enabled) {
    // Ensure targets has exactly 4 elements
    assert(targets.length == 4, 'Refresh must have exactly 4 target values');
  }

  @override
  String toString() =>
      'RefreshDevice(targets: [${targets.map((t) => t ? '1' : '0').join(', ')}])';
}
