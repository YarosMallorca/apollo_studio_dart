import 'package:apollo_studio_dart/src/devices/device.dart';

class ToneDevice extends Device {
  final double hue;
  final double saturation;
  final double value;
  final double velocity;
  final double channel;

  ToneDevice({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.velocity,
    required this.channel,
    bool collapsed = false,
    bool enabled = true,
  }) : super('tone', collapsed: collapsed, enabled: enabled);

  @override
  String toString() =>
      'ToneDevice(hue: $hue, sat: $saturation, val: $value, vel: $velocity, ch: $channel)';
}
