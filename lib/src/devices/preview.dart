import 'package:apollo_studio_dart/src/devices/device.dart';

class PreviewDevice extends Device {
  PreviewDevice({bool collapsed = false, bool enabled = true})
    : super('preview', collapsed: collapsed, enabled: enabled);

  @override
  String toString() {
    return 'PreviewDevice()';
  }
}
