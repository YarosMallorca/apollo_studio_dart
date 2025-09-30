import 'dart:math' as math;

class Length {
  /// Available step values as strings
  static const List<String> steps = [
    "1/128",
    "1/64",
    "1/32",
    "1/16",
    "1/8",
    "1/4",
    "1/2",
    "1/1",
    "2/1",
    "4/1",
  ];

  int _value = 5;

  /// Gets or sets the step value (0-9)
  int get step => _value;

  set step(int value) {
    if (value >= 0 && value <= 9 && _value != value) {
      _value = value;
    }
  }

  /// Gets the calculated value based on the step
  double get value => math.pow(2, _value - 7).toDouble();

  /// Creates a new Length with the specified step (default: 5)
  Length([int step = 5]) {
    this.step = step;
  }

  /// Converts length to milliseconds (requires BPM from external source)
  /// Note: You'll need to provide the BPM value from your project context
  int toMilliseconds(double bpm) => (value * 240000 / bpm).round();

  /// Converts length to double milliseconds (requires BPM from external source)
  double toMillisecondsDouble(double bpm) => value * 240000 / bpm;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Length) return false;
    return step == other.step;
  }

  @override
  int get hashCode => step.hashCode;

  @override
  String toString() => steps[_value];
}
