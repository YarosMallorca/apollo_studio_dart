import 'package:apollo_studio_dart/src/devices/device.dart';

class OutputDevice extends Device {
  final int channel;

  OutputDevice({
    required this.channel,
    bool collapsed = false,
    bool enabled = true,
  }) : super('output', collapsed: collapsed, enabled: enabled);

  @override
  String toString() {
    return 'OutputDevice(channel: $channel)';
  }
}
