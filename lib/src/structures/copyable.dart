import '../devices/device.dart';

class Copyable {
  final List<Device> contents;

  Copyable(this.contents);

  // Add a device to the copyable
  void add(Device device) {
    contents.add(device);
  }

  // Check if empty
  bool get isEmpty => contents.isEmpty;

  // Get count
  int get length => contents.length;

  @override
  String toString() => 'Copyable(${contents.length} devices)';
}
