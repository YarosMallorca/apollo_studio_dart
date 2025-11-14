abstract class Device {
  bool collapsed;
  bool enabled;
  final String deviceType;

  Device(this.deviceType, {this.collapsed = false, this.enabled = true});
}
