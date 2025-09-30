import 'device.dart';
import 'package:apollo_studio_dart/src/structures/color.dart';

class PaintDevice extends Device {
  ApolloColor color;

  PaintDevice({ApolloColor? color})
    : color = color ?? ApolloColor(),
      super('paint');

  PaintDevice clone() => PaintDevice(color: color.clone());

  @override
  String toString() {
    return 'PaintDevice(color: $color, deviceType: $deviceType, collapsed: $collapsed, enabled: $enabled)';
  }
}
