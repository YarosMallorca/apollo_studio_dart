import 'package:apollo_studio_dart/apollo_studio_dart.dart';

class Chain {
  final List<Device> devices;
  final String name;
  bool enabled;
  List<bool>? filter; // 101 boolean values for key filter

  Chain({
    required this.devices,
    required this.name,
    this.enabled = true,
    this.filter,
  });

  Chain.empty() : devices = [], name = 'Chain #', enabled = true, filter = null;

  @override
  String toString() {
    return 'Chain(name: $name, devices: $devices)';
  }
}
