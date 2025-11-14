import 'device.dart';

class KeyFilterDevice extends Device {
  final List<bool> filter; // 101 booleans representing which keys are enabled

  KeyFilterDevice({
    required this.filter,
    bool collapsed = false,
    bool enabled = true,
  }) : super('keyfilter', collapsed: collapsed, enabled: enabled) {
    // Ensure filter has exactly 101 elements
    assert(
      filter.length == 101,
      'KeyFilter must have exactly 101 filter values',
    );
  }

  @override
  String toString() =>
      'KeyFilterDevice(enabled keys: ${filter.where((f) => f).length}/101)';
}
