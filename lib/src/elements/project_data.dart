import 'track.dart';

class ProjectData {
  final int bpm;
  final List<int> macros;
  final List<Track> tracks;
  final String author;
  final int time;
  final DateTime started;

  ProjectData({
    required this.bpm,
    required this.macros,
    required this.tracks,
    required this.author,
    required this.time,
    required this.started,
  });
}
