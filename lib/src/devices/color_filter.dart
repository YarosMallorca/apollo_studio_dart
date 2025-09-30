import 'package:apollo_studio_dart/src/devices/device.dart';

class ColorFilterDevice extends Device {
  final double hue;
  final double saturation;
  final double value;
  final double hueTolerance;
  final double saturationTolerance;
  final double valueTolerance;

  ColorFilterDevice({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.hueTolerance,
    required this.saturationTolerance,
    required this.valueTolerance,
    bool collapsed = false,
    bool enabled = true,
  }) : super('color_filter');

  @override
  String toString() =>
      'ColorFilterDevice(hue: $hue, sat: $saturation, val: $value, '
      'hTol: $hueTolerance, sTol: $saturationTolerance, vTol: $valueTolerance)';
}
