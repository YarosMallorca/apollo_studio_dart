import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/color.dart';
import 'package:apollo_studio_dart/src/structures/time.dart';

class FadeDevice extends Device {
  Time time;
  double gate;
  FadePlaybackType playMode;
  List<ApolloColor> colors;
  List<double> positions;
  List<FadeType> fadeTypes;
  int? expanded;

  FadeDevice({
    required this.time,
    required this.gate,
    required this.playMode,
    required this.colors,
    required this.positions,
    required this.fadeTypes,
    this.expanded,
  }) : super('fade');

  int get count => colors.length;

  ApolloColor getColor(int index) => colors[index];
  void setColor(int index, ApolloColor color) {
    colors[index] = color;
  }

  double getPosition(int index) => positions[index];
  void setPosition(int index, double position) {
    positions[index] = position;
  }

  FadeType getFadeType(int index) => fadeTypes[index];
  void setFadeType(int index, FadeType fadeType) {
    fadeTypes[index] = fadeType;
  }

  @override
  String toString() {
    return 'FadeDevice(time: $time, gate: $gate, playMode: $playMode, colors: $colors, positions: $positions, fadeTypes: $fadeTypes, expanded: $expanded, deviceType: $deviceType, collapsed: $collapsed, enabled: $enabled)';
  }
}
