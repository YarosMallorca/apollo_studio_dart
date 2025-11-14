import 'package:apollo_studio_dart/apollo_studio_dart.dart';

class Chain {
  final String name;
  final List<Device> devices;
  bool enabled;
  List<bool>? filter; // 101 boolean values for key filter

  Chain({
    required this.devices,
    required this.name,
    this.enabled = true,
    this.filter,
  });

  Chain.empty() : devices = [], name = 'Chain', enabled = true;

  @override
  String toString() {
    return 'Chain(name: $name, devices: $devices)';
  }
}
