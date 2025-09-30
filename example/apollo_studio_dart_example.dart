import 'package:apollo_studio_dart/apollo_studio_dart.dart';

void main() {
  final chain = [
    ChokeDevice(target: 1, chain: Chain.empty()),
    ClearDevice(mode: ClearType.both),
    DelayDevice(
      time: Time(mode: TimeType.length, length: Length(4)),
      gate: 4,
    ),
  ];

  ApolloWriter writer = ApolloWriter();
  final content = writer.writeDevicesToClipboard(chain);
  print('Clipboard Content: $content');
}
