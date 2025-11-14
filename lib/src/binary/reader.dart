import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:apollo_studio_dart/src/devices/choke.dart';
import 'package:apollo_studio_dart/src/devices/clear.dart';
import 'package:apollo_studio_dart/src/devices/color_filter.dart';
import 'package:apollo_studio_dart/src/devices/copy.dart';
import 'package:apollo_studio_dart/src/devices/delay.dart';
import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/devices/fade.dart';
import 'package:apollo_studio_dart/src/devices/flip.dart';
import 'package:apollo_studio_dart/src/devices/group.dart';
import 'package:apollo_studio_dart/src/devices/hold.dart';
import 'package:apollo_studio_dart/src/devices/key_filter.dart';
import 'package:apollo_studio_dart/src/devices/layer.dart';
import 'package:apollo_studio_dart/src/devices/layer_filter.dart';
import 'package:apollo_studio_dart/src/devices/loop.dart';
import 'package:apollo_studio_dart/src/devices/macro_filter.dart';
import 'package:apollo_studio_dart/src/devices/move.dart';
import 'package:apollo_studio_dart/src/devices/multi.dart';
import 'package:apollo_studio_dart/src/devices/output.dart';
import 'package:apollo_studio_dart/src/devices/paint.dart';
import 'package:apollo_studio_dart/src/devices/pattern.dart';
import 'package:apollo_studio_dart/src/devices/preview.dart';
import 'package:apollo_studio_dart/src/devices/refresh.dart';
import 'package:apollo_studio_dart/src/devices/rotate.dart';
import 'package:apollo_studio_dart/src/devices/switch.dart';
import 'package:apollo_studio_dart/src/devices/tone.dart';
import 'package:apollo_studio_dart/src/elements/chain.dart';
import 'package:apollo_studio_dart/src/elements/project_data.dart';
import 'package:apollo_studio_dart/src/elements/track.dart';
import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/color.dart';
import 'package:apollo_studio_dart/src/structures/frame.dart';
import 'package:apollo_studio_dart/src/structures/length.dart';
import 'package:apollo_studio_dart/src/structures/offset.dart';
import 'package:apollo_studio_dart/src/structures/time.dart';

class ApolloReader {
  static const List<int> magicBytes = [0x41, 0x50, 0x4F, 0x4C]; // 'APOL'
  static const int currentVersion = 32;

  final ByteData _data;
  int offset = 0;

  ApolloReader(Uint8List bytes) : _data = ByteData.sublistView(bytes);

  bool readHeader() {
    for (int i = 0; i < 4; i++) {
      if (_data.getUint8(offset + i) != magicBytes[i]) {
        return false;
      }
    }
    offset += 4;
    return true;
  }

  int readInt32() {
    final value = _data.getInt32(offset, Endian.little);
    offset += 4;
    return value;
  }

  int readInt64() {
    final value = _data.getInt64(offset, Endian.little);
    offset += 8;
    return value;
  }

  double readDouble() {
    final value = _data.getFloat64(offset, Endian.little);
    offset += 8;
    return value;
  }

  bool readBool() {
    final value = _data.getUint8(offset) != 0;
    offset += 1;
    return value;
  }

  int readByte() {
    final value = _data.getUint8(offset);
    offset += 1;
    return value;
  }

  double readDecimal() {
    // C# Decimal format: 128 bits total
    // - 32 bits: lo (bits 0-31 of the 96-bit integer)
    // - 32 bits: mid (bits 32-63 of the 96-bit integer)
    // - 32 bits: hi (bits 64-95 of the 96-bit integer)
    // - 32 bits: flags (sign bit 31, scale bits 16-23)

    int lo = readInt32();
    int mid = readInt32();
    int hi = readInt32();
    int flags = readInt32();

    // Extract scale factor (how many decimal places)
    int scale = (flags >> 16) & 0xFF;

    // Extract sign bit
    bool isNegative = (flags >> 31) != 0;

    // Build the 96-bit integer value using BigInt
    BigInt value =
        BigInt.from(lo & 0xFFFFFFFF) +
        (BigInt.from(mid & 0xFFFFFFFF) << 32) +
        (BigInt.from(hi & 0xFFFFFFFF) << 64);

    // Convert to double and apply scale
    double result = value.toDouble();
    if (scale > 0) {
      result = result / math.pow(10, scale);
    }

    // Apply sign
    return isNegative ? -result : result;
  }

  String readString() {
    // Read length as 7-bit encoded integer (like C# BinaryReader)
    final length = _read7BitEncodedInt();

    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _data.getUint8(offset + i);
    }
    offset += length;
    return utf8.decode(bytes);
  }

  int _read7BitEncodedInt() {
    int result = 0;
    int shift = 0;

    while (true) {
      int byte = readByte();
      result |= (byte & 0x7F) << shift;

      if ((byte & 0x80) == 0) {
        break;
      }

      shift += 7;
      if (shift >= 32) {
        throw FormatException('Invalid 7-bit encoded integer');
      }
    }

    return result;
  }

  TypeId readTypeId() => TypeId.values[readByte()];

  ApolloColor _readColor(int version) {
    final typeId = readTypeId();
    if (typeId != TypeId.color) {
      throw FormatException('Expected Color type, got $typeId');
    }

    return ApolloColor(red: readByte(), green: readByte(), blue: readByte());
  }

  Length _readLength(int version) {
    final typeId = readTypeId();
    if (typeId != TypeId.length) {
      throw FormatException('Expected Length type, got $typeId');
    }

    return Length(readInt32());
  }

  Offset _readOffset(int version) {
    // Read Offset type ID first
    final typeId = readTypeId();
    if (typeId != TypeId.offset) {
      throw FormatException('Expected Offset type, got $typeId');
    }

    int x = readInt32();
    int y = readInt32();

    bool absolute = false;
    int absoluteX = 5;
    int absoluteY = 5;

    if (version >= 25) {
      absolute = readBool();
      absoluteX = readInt32();
      absoluteY = readInt32();
    }

    return Offset(
      x: x,
      y: y,
      isAbsolute: absolute,
      absoluteX: absoluteX,
      absoluteY: absoluteY,
    );
  }

  Time _readTime(int version) {
    final typeId = readTypeId();
    if (typeId != TypeId.time) {
      throw FormatException('Expected Time type, got $typeId');
    }

    final modeAsBool = readBool();
    final mode = modeAsBool ? TimeType.length : TimeType.free;
    final length = _readLength(version);
    final free = readInt32();

    return Time(mode: mode, length: length, free: free);
  }

  PaintDevice _readPaint(int version) {
    final color = _readColor(version);
    return PaintDevice(color: color);
  }

  FadeDevice _readFade(int version) {
    // Read time - with version handling
    Time time;
    if (version <= 2) {
      // Legacy format
      final modeAsBool = readBool();
      final mode = modeAsBool ? TimeType.length : TimeType.free;
      final length = _readLength(version);
      final free = readInt32();
      time = Time(mode: mode, length: length, free: free);
    } else {
      time = _readTime(version);
    }

    // Read gate with version handling
    double gate;
    if (version <= 13) {
      gate = readDouble();
    } else {
      gate = readDouble();
    }

    final playMode = FadePlaybackType.values[readInt32()];

    // Read colors
    final count = readInt32();
    final colors = <ApolloColor>[];
    for (int i = 0; i < count; i++) {
      colors.add(_readColor(version));
    }

    // Read positions
    final positions = <double>[];
    for (int i = 0; i < count; i++) {
      if (version <= 13) {
        positions.add(readDouble());
      } else {
        positions.add(readDouble());
      }
    }

    // Read fade types
    final fadeTypes = <FadeType>[];
    for (int i = 0; i < count - 1; i++) {
      if (version <= 24) {
        fadeTypes.add(FadeType.linear);
      } else {
        fadeTypes.add(FadeType.values[readInt32()]);
      }
    }

    // Read expanded state (version >= 23)
    int? expanded;
    if (version >= 23) {
      if (readBool()) {
        expanded = readInt32();
      }
    }

    return FadeDevice(
      time: time,
      gate: gate,
      playMode: playMode,
      colors: colors,
      positions: positions,
      fadeTypes: fadeTypes,
      expanded: expanded,
    );
  }

  HoldDevice _readHold(int version) {
    // Read time - with version handling
    Time time;
    if (version <= 2) {
      final modeAsBool = readBool();
      final mode = modeAsBool ? TimeType.length : TimeType.free;
      final length = _readLength(version);
      final free = readInt32();
      time = Time(mode: mode, length: length, free: free);
    } else {
      time = _readTime(version);
    }

    // Read gate with version handling
    double gate;
    if (version <= 13) {
      gate = readDouble();
    } else {
      gate = readDouble();
    }

    // Read hold mode with version handling
    HoldType holdMode;
    if (version <= 31) {
      final isInfinite = readBool();
      holdMode = isInfinite ? HoldType.infinite : HoldType.trigger;
    } else {
      holdMode = HoldType.values[readInt32()];
    }

    final release = readBool();

    return HoldDevice(
      time: time,
      gate: gate,
      holdMode: holdMode,
      release: release,
    );
  }

  ClearDevice _readClear(int version) {
    final mode = ClearType.values[readInt32()];
    return ClearDevice(mode: mode);
  }

  DelayDevice _readDelay(int version) {
    // Read Time (with version-specific handling)
    Time time;
    if (version <= 2) {
      // Old format: boolean mode, Length, int free
      bool useLength = readBool(); // true = use Length, false = use free
      Length length = _readLength(version); // Read the Length structure
      int free = readInt32(); // Read the free value

      time = Time(
        mode: useLength ? TimeType.length : TimeType.free,
        length: length,
        free: free,
      );
    } else {
      // New format: read Time as a complete structure
      time = _readTime(version);
    }

    // Read gate (with version-specific handling)
    double gate;
    if (version <= 13) {
      // Old format used Decimal (C# ReadDecimal)
      // Since Dart doesn't have Decimal, we read as double
      // but the binary format is different - C# Decimal is 16 bytes
      gate = readDecimal(); // You'll need to implement this
    } else {
      gate = readDouble();
    }

    return DelayDevice(time: time, gate: gate);
  }

  ChokeDevice _readChoke(int version) {
    int target = readInt32();
    Chain chain = _readChain(version);

    return ChokeDevice(target: target, chain: chain);
  }

  LayerDevice _readLayer(int version) {
    int target = readInt32();

    BlendingType blending = BlendingType.normal;
    if (version >= 5) {
      if (version == 5) {
        blending = BlendingTypeExtension.fromIndex(readInt32());
        // Special handling for version 5: if value was 2, it should be Mask (3)
        if (blending == BlendingType.multiply) {
          blending = BlendingType.mask;
        }
      } else {
        blending = BlendingTypeExtension.fromIndex(readInt32());
      }
    }

    int range = 200; // default value
    if (version >= 21) {
      range = readInt32();
    }

    return LayerDevice(target: target, blendingType: blending, range: range);
  }

  FlipDevice _readFlip(int version) {
    final mode = FlipType.values[readInt32()];
    bool bypass = readBool();

    return FlipDevice(flipType: mode, bypass: bypass);
  }

  MoveDevice _readMove(int version) {
    Offset offset = _readOffset(version);
    GridType gridType = GridType.values[readInt32()];
    bool wrap = readBool();

    return MoveDevice(offset: offset, gridMode: gridType, wrap: wrap);
  }

  OutputDevice _readOutput(int version) {
    final channel = readInt32();

    return OutputDevice(channel: channel);
  }

  PreviewDevice _readPreview(int version) {
    return PreviewDevice();
  }

  RotateDevice _readRotate(int version) {
    final mode = RotateType.values[readInt32()];
    bool bypass = readBool();

    return RotateDevice(rotateType: mode, bypass: bypass);
  }

  ToneDevice _readTone(int version) {
    double hue = readDouble();
    double saturation = readDouble();
    double value = readDouble();
    double velocity = readDouble();
    double channel = readDouble();

    return ToneDevice(
      hue: hue,
      saturation: saturation,
      value: value,
      velocity: velocity,
      channel: channel,
    );
  }

  ColorFilterDevice _readColorFilter(int version) {
    double hue = readDouble();
    double saturation = readDouble();
    double value = readDouble();
    double hueTolerance = readDouble();
    double saturationTolerance = readDouble();
    double valueTolerance = readDouble();

    return ColorFilterDevice(
      hue: hue,
      saturation: saturation,
      value: value,
      hueTolerance: hueTolerance,
      saturationTolerance: saturationTolerance,
      valueTolerance: valueTolerance,
    );
  }

  CopyDevice _readCopy(int version) {
    Time time;
    if (version <= 2) {
      bool useLength = readBool();
      Length length = _readLength(version);
      int free = readInt32();

      time = Time(
        mode: useLength ? TimeType.length : TimeType.free,
        length: length,
        free: free,
      );
    } else {
      time = _readTime(version);
    }

    // Read gate (with version-specific handling)
    double gate;
    if (version <= 13) {
      gate = readDecimal();
    } else {
      gate = readDouble();
    }

    // Read pinch (added in version 26)
    double pinch = 0.0;
    if (version >= 26) {
      pinch = readDouble();
    }

    // Read bilateral (added in version 28)
    bool bilateral = false;
    if (version >= 28) {
      bilateral = readBool();
    }

    // Read reverse (added in version 26)
    bool reverse = false;
    if (version >= 26) {
      reverse = readBool();
    }

    // Read infinite (added in version 27)
    bool infinite = false;
    if (version >= 27) {
      infinite = readBool();
    }

    // Read copy type, grid type, and wrap
    CopyType copyType = CopyType.values[readInt32()];
    GridType gridType = GridType.values[readInt32()];
    bool wrap = readBool();

    // Read count first, then offsets, then angles
    int count = readInt32();
    List<Offset> offsets = [];
    List<int> angles = [];

    // Read all offsets first
    for (int i = 0; i < count; i++) {
      offsets.add(_readOffset(version));
    }

    // Then read all angles (version >= 25 only)
    for (int i = 0; i < count; i++) {
      angles.add((version >= 25) ? readInt32() : 0);
    }

    return CopyDevice(
      time: time,
      gate: gate,
      pinch: pinch,
      bilateral: bilateral,
      reverse: reverse,
      infinite: infinite,
      copyType: copyType,
      gridType: gridType,
      wrap: wrap,
      offsets: offsets,
      angles: angles,
    );
  }

  GroupDevice _readGroup(int version) {
    // Read list of chains
    int chainCount = readInt32();
    List<Chain> chains = [];

    for (int i = 0; i < chainCount; i++) {
      chains.add(_readChain(version));
    }

    // Read expanded state (nullable int)
    int? expanded;
    if (readBool()) {
      expanded = readInt32();
    }

    return GroupDevice(chains: chains, expanded: expanded);
  }

  KeyFilterDevice _readKeyFilter(int version) {
    List<bool> filter;
    if (version <= 18) {
      // Old format: 100 booleans, then insert false at index 99
      List<bool> oldFilter = [];
      for (int i = 0; i < 100; i++) {
        oldFilter.add(readBool());
      }
      oldFilter.insert(99, false); // Insert false at position 99
      filter = oldFilter;
    } else {
      // New format: 101 booleans directly
      filter = [];
      for (int i = 0; i < 101; i++) {
        filter.add(readBool());
      }
    }

    return KeyFilterDevice(filter: filter);
  }

  LayerFilterDevice _readLayerFilter(int version) {
    int target = readInt32();
    int range = readInt32();

    return LayerFilterDevice(target: target, range: range);
  }

  LoopDevice _readLoop(int version) {
    Time time = _readTime(version);
    double gate = readDouble();
    int repeats = readInt32();
    bool hold = readBool();

    return LoopDevice(time: time, gate: gate, repeats: repeats, hold: hold);
  }

  MacroFilterDevice _readMacroFilter(int version) {
    int target;
    if (version >= 25) {
      target = readInt32();
    } else {
      target = 1; // Default to macro 1 for older versions
    }

    // Read 100 boolean values for the filter
    List<bool> filter = [];
    for (int i = 0; i < 100; i++) {
      filter.add(readBool());
    }

    return MacroFilterDevice(target: target, filter: filter);
  }

  MultiDevice _readMulti(int version) {
    // Read preprocess chain
    Chain preprocess = _readChain(version);

    // Read chains
    int count = readInt32();
    List<Chain> chains = [];
    for (int i = 0; i < count; i++) {
      chains.add(_readChain(version));
    }

    // Skip the secret filters for version 28 (deprecated feature)
    if (version == 28) {
      for (int i = 0; i < count; i++) {
        // Skip 101 booleans per chain
        for (int j = 0; j < 101; j++) {
          readBool(); // Read and discard
        }
      }
    }

    // Read expanded state
    int? expanded;
    if (readBool()) {
      expanded = readInt32();
    }

    // Read mode
    MultiType mode = MultiType.values[readInt32()];

    return MultiDevice(
      preprocess: preprocess,
      chains: chains,
      expanded: expanded,
      mode: mode,
    );
  }

  Device _readSwitch(int version) {
    // Read target (version >= 25)
    int target = (version >= 25) ? readInt32() : 1;

    // Read value
    int value = readInt32();

    // Handle special case for versions 18-21 with reset functionality
    if (18 <= version && version <= 21 && readBool()) {
      // Return a Group device with Switch + Clear for backwards compatibility
      Chain resetChain = Chain(
        devices: [
          SwitchDevice(target: 1, value: value),
          ClearDevice(mode: ClearType.multi),
        ],
        name: "Switch Reset",
        enabled: true,
        filter: List.filled(101, true),
      );

      return GroupDevice(chains: [resetChain], expanded: null);
    }

    return SwitchDevice(target: target, value: value);
  }

  RefreshDevice _readRefresh(int version) {
    // No TypeID read here - it was already consumed by the caller

    // Read 4 boolean values for the refresh targets
    List<bool> targets = [];
    for (int i = 0; i < 4; i++) {
      targets.add(readBool());
    }

    return RefreshDevice(targets: targets);
  }

  Device _readPattern(int version) {
    int repeats = 1;
    if (version >= 11) {
      repeats = readInt32();
    }

    double gate;
    if (version <= 13) {
      gate = readDecimal();
    } else {
      gate = readDouble();
    }

    double pinch = 0.0;
    if (version >= 24) {
      pinch = readDouble();
    }

    bool bilateral = false;
    if (version >= 28) {
      bilateral = readBool();
    }

    // Read frames
    int frameCount = readInt32();
    List<Frame> frames = [];
    for (int i = 0; i < frameCount; i++) {
      frames.add(_readFrame(version));
    }

    PlaybackType mode = PlaybackType.values[readInt32()];

    // Handle old choke system (version <= 10)
    bool chokeEnabled = false;
    int choke = 8;

    if (version <= 10) {
      chokeEnabled = readBool();

      if (version <= 0) {
        if (chokeEnabled) {
          choke = readInt32();
        }
      } else {
        choke = readInt32();
      }
    }

    bool infinite = false;
    if (version >= 4) {
      infinite = readBool();
    }

    int? rootKey;
    if (version >= 12) {
      if (readBool()) {
        rootKey = readInt32();
      } else {
        rootKey = null;
      }
    } else {
      rootKey = null;
    }

    bool wrap = false;
    if (version >= 13) {
      wrap = readBool();
    }

    int expanded = readInt32();

    PatternDevice pattern = PatternDevice(
      repeats: repeats,
      gate: gate,
      pinch: pinch,
      bilateral: bilateral,
      frames: frames,
      mode: mode,
      infinite: infinite,
      rootKey: rootKey,
      wrap: wrap,
      expanded: expanded,
    );

    // Handle old choke system - wrap Pattern in Choke device
    if (chokeEnabled) {
      Chain patternChain = Chain(
        devices: [pattern],
        name: "Pattern Chain",
        enabled: true,
        filter: List.filled(101, true),
      );

      return ChokeDevice(target: choke, chain: patternChain);
    }

    return pattern;
  }

  Frame _readFrame(int version) {
    final typeId = readTypeId();
    if (typeId != TypeId.frame) {
      throw FormatException('Expected Frame type, got $typeId');
    }

    // Read Time (with version handling)
    Time time;
    if (version <= 2) {
      bool useLength = readBool();
      Length length = _readLength(version);
      int free = readInt32();

      time = Time(
        mode: useLength ? TimeType.length : TimeType.free,
        length: length,
        free: free,
      );
    } else {
      time = _readTime(version);
    }

    // Read screen colors (with version handling)
    List<ApolloColor> screen;
    if (version <= 19) {
      // Old format: 100 colors, then insert black at index 99
      List<ApolloColor> oldScreen = [];
      for (int i = 0; i < 100; i++) {
        oldScreen.add(_readColor(version));
      }
      oldScreen.insert(
        99,
        ApolloColor(red: 0, green: 0, blue: 0),
      ); // Insert black
      screen = oldScreen;
    } else {
      // New format: 101 colors directly
      screen = [];
      for (int i = 0; i < 101; i++) {
        screen.add(_readColor(version));
      }
    }

    return Frame(time: time, screen: screen);
  }

  Device readDevice(int version) {
    final typeId = readTypeId();
    if (typeId != TypeId.device) {
      throw FormatException('Expected Device type, got $typeId');
    }

    // Read device properties (version >= 5)
    bool collapsed = false;
    bool enabled = true;
    if (version >= 5) {
      collapsed = readBool();
      enabled = readBool();
    }

    // Read the actual device type
    final deviceTypeId = readTypeId();

    Device device;
    switch (deviceTypeId) {
      case TypeId.choke:
        device = _readChoke(version);
        break;
      case TypeId.clear:
        device = _readClear(version);
        break;
      case TypeId.colorFilter:
        device = _readColorFilter(version);
        break;
      case TypeId.copy:
        device = _readCopy(version);
        break;
      case TypeId.delay:
        device = _readDelay(version);
        break;
      case TypeId.fade:
        device = _readFade(version);
        break;
      case TypeId.flip:
        device = _readFlip(version);
        break;
      case TypeId.group:
        device = _readGroup(version);
        break;
      case TypeId.hold:
        device = _readHold(version);
        break;
      case TypeId.keyFilter:
        device = _readKeyFilter(version);
        break;
      case TypeId.layerFilter:
        device = _readLayerFilter(version);
        break;
      case TypeId.layer:
        device = _readLayer(version);
        break;
      case TypeId.loop:
        device = _readLoop(version);
        break;
      case TypeId.macroFilter:
        device = _readMacroFilter(version);
        break;
      case TypeId.move:
        device = _readMove(version);
        break;
      case TypeId.multi:
        device = _readMulti(version);
        break;
      case TypeId.output:
        device = _readOutput(version);
        break;
      case TypeId.paint:
        device = _readPaint(version);
        break;
      case TypeId.pattern:
        device = _readPattern(version);
        break;
      case TypeId.preview:
        device = _readPreview(version);
        break;
      case TypeId.refresh:
        device = _readRefresh(version);
        break;
      case TypeId.rotate:
        device = _readRotate(version);
        break;
      case TypeId.switchDevice:
        device = _readSwitch(version);
        break;
      case TypeId.tone:
        device = _readTone(version);
        break;
      default:
        throw FormatException('Unsupported device type: $deviceTypeId');
    }

    device.collapsed = collapsed;
    device.enabled = enabled;

    return device;
  }

  ProjectData readProject() {
    // Read header and version
    if (!readHeader()) {
      throw Exception('Invalid Apollo project file format');
    }

    int version = readInt32();
    print('Project version: $version');

    // Read project type ID
    final typeId = readTypeId();
    if (typeId != TypeId.project) {
      throw Exception('Expected Project type, got $typeId');
    }

    // Read BPM
    int bpm = readInt32();

    // Read macros (4 values, version >= 25)
    List<int> macros = [];
    if (version >= 25) {
      for (int i = 0; i < 4; i++) {
        macros.add(readInt32());
      }
    } else {
      // Old format: only first macro
      macros.add(readInt32());
      macros.addAll([1, 1, 1]); // Default values for other macros
    }

    // Read tracks
    int trackCount = readInt32();
    List<Track> tracks = [];

    for (int i = 0; i < trackCount; i++) {
      tracks.add(_readTrack(version));
    }

    // Read metadata (version >= 17)
    String author = "";
    int time = 0;
    DateTime started = DateTime.now(); // Default to current time

    if (version >= 17) {
      author = readString();
      time = readInt64();

      // Read started timestamp and convert from Unix seconds to DateTime
      int startedSeconds = readInt64();
      if (startedSeconds > 0) {
        started = DateTime.fromMillisecondsSinceEpoch(startedSeconds * 1000);
      }
      // If startedSeconds is 0, keep the default DateTime.now() value
    }

    // Skip undo manager (version >= 30)
    if (version >= 30) {
      _skipUndoManager(version);
    }

    return ProjectData(
      bpm: bpm,
      macros: macros,
      tracks: tracks,
      author: author,
      timeSpent: Duration(seconds: time),
      started: started,
    );
  }

  Track _readTrack(int version) {
    // Read Track type ID
    final trackTypeId = readTypeId();
    if (trackTypeId != TypeId.track) {
      throw Exception('Expected Track type, got $trackTypeId');
    }

    // Read chain
    Chain chain = _readChain(version);

    // Read launchpad
    String launchpadName = _readLaunchpad(version);

    // Read track name
    String name = readString();

    // Read enabled flag (version >= 8)
    bool enabled = true;
    if (version >= 8) {
      enabled = readBool();
    }

    return Track(
      chain: chain,
      launchpadName: launchpadName,
      name: name,
      enabled: enabled,
    );
  }

  Chain _readChain(int version) {
    // Read Chain type ID
    final chainTypeId = readTypeId();
    if (chainTypeId != TypeId.chain) {
      throw Exception('Expected Chain type, got $chainTypeId');
    }

    // Read devices
    int deviceCount = readInt32();
    List<Device> devices = [];

    for (int i = 0; i < deviceCount; i++) {
      devices.add(readDevice(version));
    }

    // Read chain name
    String name = readString();

    // Read enabled flag (version >= 6)
    bool enabled = true;
    if (version >= 6) {
      enabled = readBool();
    }

    // Read filter (version >= 29) - 101 boolean values
    List<bool> filter = [];
    if (version >= 29) {
      for (int i = 0; i < 101; i++) {
        filter.add(readBool());
      }
    } else {
      // Default filter (all keys enabled)
      filter = List.filled(101, true);
    }

    return Chain(
      devices: devices,
      name: name,
      enabled: enabled,
      filter: filter,
    );
  }

  String _readLaunchpad(int version) {
    // Read Launchpad type ID
    final launchpadTypeId = readTypeId();
    if (launchpadTypeId != TypeId.launchpad) {
      throw Exception('Expected Launchpad type, got $launchpadTypeId');
    }

    // Read launchpad name
    String name = readString();

    if (name.isNotEmpty) {
      // If launchpad has a name, read additional format and rotation data
      if (version >= 2) {
        readInt32(); // InputType enum
      }
      if (version >= 9) {
        readInt32(); // RotationType enum
      }
    }

    return name; // Empty string means no MIDI output
  }

  void _skipUndoManager(int version) {
    // Read UndoManager type ID
    final undoTypeId = readTypeId();
    if (undoTypeId != TypeId.undoManager) {
      throw Exception('Expected UndoManager type, got $undoTypeId');
    }

    // Read undo version and size, then skip the data
    readInt32();
    int dataSize = readInt32();

    // Skip the undo data
    for (int i = 0; i < dataSize; i++) {
      readByte();
    }
  }

  T readObject<T>() {
    if (!readHeader()) {
      throw FormatException('Invalid Apollo file header');
    }

    final version = readInt32();
    if (version > currentVersion) {
      throw FormatException('Unsupported file version: $version');
    }

    final mainTypeId = readTypeId();

    // Handle different main object types
    switch (mainTypeId) {
      case TypeId.device:
        offset -= 1; // Back up to re-read the type ID
        return readDevice(version) as T;
      default:
        throw FormatException('Unsupported main type: $mainTypeId');
    }
  }
}
