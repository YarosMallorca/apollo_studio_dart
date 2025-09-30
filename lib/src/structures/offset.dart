class Offset {
  int x;
  int y;
  int absoluteX;
  int absoluteY;
  bool isAbsolute;

  Offset({
    this.x = 0,
    this.y = 0,
    this.absoluteX = 0,
    this.absoluteY = 0,
    this.isAbsolute = false,
  });

  Offset clone() => Offset(
    x: x,
    y: y,
    absoluteX: absoluteX,
    absoluteY: absoluteY,
    isAbsolute: isAbsolute,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Offset) return false;
    return x == other.x &&
        y == other.y &&
        absoluteX == other.absoluteX &&
        absoluteY == other.absoluteY &&
        isAbsolute == other.isAbsolute;
  }

  @override
  int get hashCode => Object.hash(x, y, absoluteX, absoluteY, isAbsolute);

  @override
  String toString() {
    return 'Offset(x: $x, y: $y, absoluteX: $absoluteX, absoluteY: $absoluteY, isAbsolute: $isAbsolute)';
  }
}
