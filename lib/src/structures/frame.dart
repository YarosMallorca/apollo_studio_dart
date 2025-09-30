import 'color.dart';
import 'time.dart';

class Frame {
  final Time time;
  final List<ApolloColor> screen;

  Frame({required this.time, required this.screen}) {
    assert(screen.length == 101, 'Frame must have exactly 101 screen colors');
  }

  @override
  String toString() => 'Frame(time: $time, colors: ${screen.length})';
}
