import 'device.dart';

class MacroFilterDevice extends Device {
  final int target; // Which macro to filter (1-4)
  final List<bool> filter; // 100 booleans representing which keys are enabled

  MacroFilterDevice({
    required this.target,
    required this.filter,
    bool collapsed = false,
    bool enabled = true,
  }) : super('macrofilter', collapsed: collapsed, enabled: enabled) {
    // Ensure filter has exactly 100 elements
    assert(
      filter.length == 100,
      'MacroFilter must have exactly 100 filter values',
    );
    // Ensure target is valid (1-4)
    assert(
      target >= 1 && target <= 4,
      'MacroFilter target must be between 1 and 4',
    );
  }

  @override
  String toString() =>
      'MacroFilterDevice(target: $target, enabled keys: ${filter.where((f) => f).length}/100)';
}
