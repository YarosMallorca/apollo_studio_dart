import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/offset.dart';

import 'device.dart';

class MoveDevice extends Device {
  final Offset offset;
  final GridType gridMode;
  final bool wrap;

  MoveDevice({
    required this.offset,
    this.gridMode = GridType.full,
    this.wrap = false,
    bool collapsed = false,
    bool enabled = true,
  }) : super('move', collapsed: collapsed, enabled: enabled);

  @override
  String toString() {
    return 'MoveDevice(offset: $offset, gridMode: $gridMode, wrap: $wrap)';
  }
}
