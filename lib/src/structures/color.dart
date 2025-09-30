import 'package:apollo_studio_dart/src/binary/reader.dart';
import 'package:apollo_studio_dart/src/binary/writer.dart';

class ApolloColor {
  int _red = 0;
  int _green = 0;
  int _blue = 0;

  bool _isValid(int value) => value >= 0 && value <= 63;

  int get red => _red;
  set red(int value) {
    if (_isValid(value)) _red = value;
  }

  int get green => _green;
  set green(int value) {
    if (_isValid(value)) _green = value;
  }

  int get blue => _blue;
  set blue(int value) {
    if (_isValid(value)) _blue = value;
  }

  bool get isLit => _red != 0 || _green != 0 || _blue != 0;

  ApolloColor({int red = 0, int green = 0, int blue = 0})
    : assert(red >= 0 && red <= 63, 'Red must be between 0 and 63'),
      assert(green >= 0 && green <= 63, 'Green must be between 0 and 63'),
      assert(blue >= 0 && blue <= 63, 'Blue must be between 0 and 63') {
    this.red = red;
    this.green = green;
    this.blue = blue;
  }

  void writeTo(ApolloWriter writer, int version) {
    writer.writeByte(red);
    writer.writeByte(green);
    writer.writeByte(blue);
  }

  // Keep existing fromBinary constructor
  ApolloColor.fromBinary(ApolloReader reader, int version)
    : _red = reader.readByte(),
      _green = reader.readByte(),
      _blue = reader.readByte();

  ApolloColor.bright([int brightness = 63]) {
    red = green = blue = brightness;
  }

  ApolloColor clone() => ApolloColor(red: red, green: green, blue: blue);

  String toHex() =>
      '#${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  @override
  String toString() => 'ApolloColor(red: $red, green: $green, blue: $blue)';
}
