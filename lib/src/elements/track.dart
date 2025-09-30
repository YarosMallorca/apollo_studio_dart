import 'package:apollo_studio_dart/src/elements/chain.dart';

class Track {
  final Chain chain;
  final String launchpadName;
  final String name;
  final bool enabled;

  Track({
    required this.chain,
    this.launchpadName = "",
    required this.name,
    this.enabled = true,
  });
}
