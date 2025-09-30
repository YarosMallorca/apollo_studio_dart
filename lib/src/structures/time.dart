import 'length.dart';
import '../enums.dart';

class Time {
  int _min = 0;
  int _max = 0x7FFFFFFF;
  int _free = 1000;
  TimeType _mode = TimeType.length;

  late Length length;

  /// Gets or sets the minimum value
  int get minimum => _min;

  set minimum(int value) {
    _min = value;
    if (_free < _min) {
      free = _min;
    }
  }

  /// Gets or sets the maximum value
  int get maximum => _max;

  set maximum(int value) {
    _max = value;
    if (_max < _free) {
      free = _max;
    }
  }

  /// Gets or sets the free value (with bounds checking)
  int get free => _free;

  set free(int value) {
    if (minimum <= value && value <= maximum && _free != value) {
      _free = value;
    }
  }

  /// Gets or sets the mode (TimeMode.length uses Length, TimeMode.free uses free value)
  TimeType get mode => _mode;

  set mode(TimeType value) {
    if (_mode != value) {
      _mode = value;
    }
  }

  /// Creates a new Time with the specified parameters
  Time({TimeType mode = TimeType.length, Length? length, int free = 1000}) {
    _free = free;
    _mode = mode;
    this.length = length ?? Length();
  }

  /// Creates a copy of this Time
  Time clone() => copyWith();

  /// Creates a copy with optional parameter overrides
  Time copyWith({TimeType? mode, Length? length, int? free}) {
    final newTime = Time(
      mode: mode ?? _mode,
      length: length ?? Length(this.length.step),
      free: free ?? _free,
    );
    newTime.minimum = minimum;
    newTime.maximum = maximum;
    return newTime;
  }

  /// Converts to integer value based on current mode
  int toInt(double bpm) =>
      mode == TimeType.length ? length.toMilliseconds(bpm) : free;

  /// Converts to double value based on current mode
  double toDouble(double bpm) => mode == TimeType.length
      ? length.toMillisecondsDouble(bpm)
      : free.toDouble();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Time) return false;
    return mode == other.mode && length == other.length && free == other.free;
  }

  @override
  int get hashCode => Object.hash(mode, length, free);

  @override
  String toString() =>
      mode == TimeType.length ? length.toString() : "${free}ms";
}
