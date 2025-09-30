enum TimeType { length, free }

enum ClearType { lights, multi, both }

enum CopyType { static, animate, interpolate, randomSingle, randomLoop }

enum GridType { full, square }

enum FadePlaybackType { mono, loop }

enum FlipType { horizontal, vertical, diagonal1, diagonal2 }

enum HoldType { trigger, minimum, infinite }

enum MultiType { forward, backward, random, randomPlus, key }

enum PlaybackType { mono, poly, loop }

enum RotateType { d90, d180, d270 }

enum InputType { xy, drumRack }

enum RotationType { d0, d90, d180, d270 }

enum BlendingType { normal, screen, multiply, mask }

extension BlendingTypeExtension on BlendingType {
  int get index {
    switch (this) {
      case BlendingType.normal:
        return 0;
      case BlendingType.screen:
        return 1;
      case BlendingType.multiply:
        return 2;
      case BlendingType.mask:
        return 3;
    }
  }

  static BlendingType fromIndex(int index) {
    switch (index) {
      case 0:
        return BlendingType.normal;
      case 1:
        return BlendingType.screen;
      case 2:
        return BlendingType.multiply;
      case 3:
        return BlendingType.mask;
      default:
        throw Exception('Invalid BlendingType index: $index');
    }
  }
}

enum FadeType { linear, smooth, sharp, fast, slow, hold, release }

extension FadeTypeExtension on FadeType {
  FadeType get opposite {
    switch (this) {
      case FadeType.fast:
        return FadeType.slow;
      case FadeType.slow:
        return FadeType.fast;
      case FadeType.hold:
        return FadeType.release;
      case FadeType.release:
        return FadeType.hold;
      default:
        return this;
    }
  }
}

enum TypeId {
  preferences(0),
  copyable(1),
  project(2),
  track(3),
  chain(4),
  device(5),
  launchpad(6),
  group(7),
  copy(8),
  delay(9),
  fade(10),
  flip(11),
  hold(12),
  keyFilter(13),
  layer(14),
  move(15),
  multi(16),
  output(17),
  macroFilter(18),
  switchDevice(19),
  paint(20),
  pattern(21),
  preview(22),
  rotate(23),
  tone(24),
  color(25),
  frame(26),
  length(27),
  offset(28),
  time(29),
  choke(30),
  colorFilter(31),
  clear(32),
  layerFilter(33),
  loop(34),
  refresh(35),
  undoManager(36);

  const TypeId(this.value);
  final int value;
}
