import 'package:apollo_studio_dart/apollo_studio_dart.dart';

void main() {
  final macro = MacroFilterDevice(
    target: 2,
    filter: List.generate(100, (index) => index % 2 == 0),
    collapsed: true,
    enabled: true,
  );
  print(macro.collapsed);

  ProjectData project = ProjectData(
    bpm: 120,
    macros: [0, 1, 2, 3],
    tracks: [
      Track(
        chain: Chain(name: "", devices: [macro]),
        name: "Test",
      ),
    ],
    author: "Test Author",
    timeSpent: Duration(minutes: 42),
    started: DateTime.now(),
  );

  writeProjectFile("test.approj", project);
}
