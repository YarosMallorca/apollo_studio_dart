import 'package:apollo_studio_dart/src/devices/device.dart';

class OutputDevice extends Device {
  final int channel;

  OutputDevice({required this.channel}) : super('output');

  @override
  String toString() {
    return 'OutputDevice(channel: $channel)';
  }
}
