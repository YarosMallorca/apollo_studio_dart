import 'device.dart';
import 'package:apollo_studio_dart/src/structures/color.dart';

class PaintDevice extends Device {
  ApolloColor color;

  PaintDevice({ApolloColor? color, bool collapsed = false, bool enabled = true})
    : color = color ?? ApolloColor(),
      super('paint', collapsed: collapsed, enabled: enabled);

  PaintDevice clone() => PaintDevice(color: color.clone());

  @override
  String toString() {
    return 'PaintDevice(color: $color, deviceType: $deviceType, collapsed: $collapsed, enabled: $enabled)';
  }
}
