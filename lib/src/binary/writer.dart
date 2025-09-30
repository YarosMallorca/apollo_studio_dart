import 'dart:convert';
import 'dart:typed_data';
import 'reader.dart';
import 'package:apollo_studio_dart/src/devices/choke.dart';
import 'package:apollo_studio_dart/src/devices/clear.dart';
import 'package:apollo_studio_dart/src/devices/color_filter.dart';
import 'package:apollo_studio_dart/src/devices/copy.dart';
import 'package:apollo_studio_dart/src/devices/delay.dart';
import 'package:apollo_studio_dart/src/devices/flip.dart';
import 'package:apollo_studio_dart/src/devices/group.dart';
import 'package:apollo_studio_dart/src/devices/key_filter.dart';
import 'package:apollo_studio_dart/src/devices/layer.dart';
import 'package:apollo_studio_dart/src/devices/layer_filter.dart';
import 'package:apollo_studio_dart/src/devices/loop.dart';
import 'package:apollo_studio_dart/src/devices/macro_filter.dart';
import 'package:apollo_studio_dart/src/devices/move.dart';
import 'package:apollo_studio_dart/src/devices/multi.dart';
import 'package:apollo_studio_dart/src/devices/output.dart';
import 'package:apollo_studio_dart/src/devices/pattern.dart';
import 'package:apollo_studio_dart/src/devices/preview.dart';
import 'package:apollo_studio_dart/src/devices/refresh.dart';
import 'package:apollo_studio_dart/src/devices/rotate.dart';
import 'package:apollo_studio_dart/src/devices/switch.dart';
import 'package:apollo_studio_dart/src/devices/tone.dart';
import 'package:apollo_studio_dart/src/elements/project_data.dart';
import 'package:apollo_studio_dart/src/structures/frame.dart';
import 'package:apollo_studio_dart/src/structures/offset.dart';
import 'package:apollo_studio_dart/src/devices/hold.dart';
import 'package:apollo_studio_dart/src/elements/track.dart';
import 'package:apollo_studio_dart/src/elements/chain.dart';
import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/devices/fade.dart';
import 'package:apollo_studio_dart/src/devices/paint.dart';
import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/color.dart';
import 'package:apollo_studio_dart/src/structures/length.dart';
import 'package:apollo_studio_dart/src/structures/time.dart';

class ApolloWriter {
  BytesBuilder builder = BytesBuilder();

  void writeHeader() {
    builder.add([0x41, 0x50, 0x4F, 0x4C]); // 'APOL'
    writeInt32(ApolloReader.currentVersion);
  }

  void writeInt32(int value) {
    final bytes = ByteData(4);
    bytes.setInt32(0, value, Endian.little);
    builder.add(bytes.buffer.asUint8List());
  }

  void writeInt64(int value) {
    final bytes = ByteData(8);
    bytes.setInt64(0, value, Endian.little);
    builder.add(bytes.buffer.asUint8List());
  }

  void writeDouble(double value) {
    final bytes = ByteData(8);
    bytes.setFloat64(0, value, Endian.little);
    builder.add(bytes.buffer.asUint8List());
  }

  void writeDecimal(double value) {
    bool isNegative = value < 0;
    double absValue = value.abs();

    // Find appropriate scale to preserve precision
    int scale = 0;
    double scaledValue = absValue;

    while (scale < 28 &&
        scaledValue != scaledValue.floor() &&
        scaledValue < (1 << 31)) {
      scaledValue *= 10;
      scale++;
    }

    // Convert to integer representation
    BigInt intValue = BigInt.from(scaledValue.floor());

    // Extract 96-bit components
    int lo = (intValue & BigInt.parse('0xFFFFFFFF')).toInt();
    int mid = ((intValue >> 32) & BigInt.parse('0xFFFFFFFF')).toInt();
    int hi = ((intValue >> 64) & BigInt.parse('0xFFFFFFFF')).toInt();

    // Create flags: scale (bits 16-23) and sign (bit 31)
    int flags = (scale << 16);
    if (isNegative) {
      flags |= (1 << 31);
    }

    // Write 128-bit Decimal structure
    writeInt32(lo);
    writeInt32(mid);
    writeInt32(hi);
    writeInt32(flags);
  }

  void writeBool(bool value) {
    builder.addByte(value ? 1 : 0);
  }

  void writeByte(int value) {
    builder.addByte(value);
  }

  void writeString(String value) {
    final bytes = utf8.encode(value);

    // Write length as 7-bit encoded integer (like C# BinaryWriter)
    _write7BitEncodedInt(bytes.length);

    // Write string bytes
    builder.add(bytes);
  }

  void _write7BitEncodedInt(int value) {
    while (value >= 0x80) {
      builder.addByte((value | 0x80) & 0xFF);
      value >>>= 7;
    }
    builder.addByte(value & 0xFF);
  }

  void writeTypeId(TypeId typeId) {
    writeByte(typeId.value);
  }

  void _writeColor(ApolloColor color) {
    writeTypeId(TypeId.color);
    writeByte(color.red);
    writeByte(color.green);
    writeByte(color.blue);
  }

  void _writeLength(Length length) {
    writeTypeId(TypeId.length);
    writeInt32(length.step);
  }

  void _writeOffset(Offset offset) {
    writeTypeId(TypeId.offset);
    writeInt32(offset.x);
    writeInt32(offset.y);
    writeBool(offset.isAbsolute);
    writeInt32(offset.absoluteX);
    writeInt32(offset.absoluteY);
  }

  void _writeTime(Time time) {
    writeTypeId(TypeId.time);
    writeBool(time.mode == TimeType.length);
    _writeLength(time.length);
    writeInt32(time.free);
  }

  void _writePaint(PaintDevice paint) {
    writeTypeId(TypeId.paint);
    _writeColor(paint.color);
  }

  void _writeFade(FadeDevice fade) {
    writeTypeId(TypeId.fade);
    _writeTime(fade.time);
    writeDouble(fade.gate);
    writeInt32(fade.playMode.index);

    writeInt32(fade.count);
    for (int i = 0; i < fade.count; i++) {
      _writeColor(fade.colors[i]);
    }

    for (int i = 0; i < fade.count; i++) {
      writeDouble(fade.positions[i]);
    }

    for (int i = 0; i < fade.count - 1; i++) {
      writeInt32(fade.fadeTypes[i].index);
    }

    writeBool(fade.expanded != null);
    if (fade.expanded != null) {
      writeInt32(fade.expanded!);
    }
  }

  void _writeHold(HoldDevice hold) {
    writeTypeId(TypeId.hold);
    _writeTime(hold.time);
    writeDouble(hold.gate);
    writeInt32(hold.holdMode.index);
    writeBool(hold.release);
  }

  void _writeClear(ClearDevice clear) {
    writeTypeId(TypeId.clear);
    writeInt32(clear.mode.index);
  }

  void _writeDelay(DelayDevice device) {
    writeTypeId(TypeId.delay);
    _writeTime(device.time);
    writeDouble(device.gate);
  }

  void _writeChoke(ChokeDevice device) {
    writeTypeId(TypeId.choke);
    writeInt32(device.target);
    _writeChain(device.chain);
  }

  void _writeLayer(LayerDevice device) {
    writeTypeId(TypeId.layer);
    writeInt32(device.target);
    writeInt32(device.blendingType.index);
    writeInt32(device.range);
  }

  void _writeFlip(FlipDevice device) {
    writeTypeId(TypeId.flip);
    writeInt32(device.flipType.index);
    writeBool(device.bypass);
  }

  void _writeMove(MoveDevice device) {
    writeTypeId(TypeId.move);
    _writeOffset(device.offset);
    writeInt32(device.gridMode.index);
    writeBool(device.wrap);
  }

  void _writeOutput(OutputDevice device) {
    writeTypeId(TypeId.output);
    writeInt32(device.channel);
  }

  void _writePreview(PreviewDevice device) {
    writeTypeId(TypeId.preview);
  }

  void _writeRotate(RotateDevice device) {
    writeTypeId(TypeId.rotate);
    writeInt32(device.rotateType.index);
    writeBool(device.bypass);
  }

  void _writeTone(ToneDevice device) {
    writeTypeId(TypeId.tone);
    writeDouble(device.hue);
    writeDouble(device.saturation);
    writeDouble(device.value);
    writeDouble(device.velocity);
    writeDouble(device.channel);
  }

  void _writeColorFilter(ColorFilterDevice device) {
    writeTypeId(TypeId.colorFilter);
    writeDouble(device.hue);
    writeDouble(device.saturation);
    writeDouble(device.value);
    writeDouble(device.hueTolerance);
    writeDouble(device.saturationTolerance);
    writeDouble(device.valueTolerance);
  }

  void _writeCopy(CopyDevice device) {
    writeTypeId(TypeId.copy);

    _writeTime(device.time);

    writeDouble(device.gate);

    writeDouble(device.pinch);

    writeBool(device.bilateral);

    writeBool(device.reverse);
    writeBool(device.infinite);

    writeInt32(device.copyType.index);
    writeInt32(device.gridType.index);
    writeBool(device.wrap);

    writeInt32(device.offsets.length);

    for (Offset offset in device.offsets) {
      _writeOffset(offset);
    }

    for (int angle in device.angles) {
      writeInt32(angle);
    }
  }

  void _writeGroup(GroupDevice device) {
    writeTypeId(TypeId.group);
    // Write chain count and chains
    writeInt32(device.chains.length);

    for (Chain chain in device.chains) {
      _writeChain(chain);
    }

    // Write expanded state (nullable)
    if (device.expanded != null) {
      writeBool(true);
      writeInt32(device.expanded!);
    } else {
      writeBool(false);
    }
  }

  void _writeKeyFilter(KeyFilterDevice device) {
    writeTypeId(TypeId.keyFilter);
    // Always write 101 booleans for latest version
    for (int i = 0; i < 101; i++) {
      writeBool(device.filter[i]);
    }
  }

  void _writeLayerFilter(LayerFilterDevice device) {
    writeTypeId(TypeId.layerFilter);
    writeInt32(device.target);
    writeInt32(device.range);
  }

  void _writeLoop(LoopDevice device) {
    writeTypeId(TypeId.loop);
    _writeTime(device.time);
    writeDouble(device.gate);
    writeInt32(device.repeats);
    writeBool(device.hold);
  }

  void _writeMacroFilter(MacroFilterDevice device) {
    writeTypeId(TypeId.macroFilter);
    // Always write target for latest version
    writeInt32(device.target);

    // Write 100 boolean values
    for (int i = 0; i < 100; i++) {
      writeBool(device.filter[i]);
    }
  }

  void _writeMulti(MultiDevice device) {
    writeTypeId(TypeId.multi);
    // Write preprocess chain
    _writeChain(device.preprocess);

    // Write chains
    writeInt32(device.chains.length);
    for (Chain chain in device.chains) {
      _writeChain(chain);
    }

    // Write expanded state (nullable)
    if (device.expanded != null) {
      writeBool(true);
      writeInt32(device.expanded!);
    } else {
      writeBool(false);
    }

    // Write mode
    writeInt32(device.mode.index);
  }

  void _writeSwitch(SwitchDevice device) {
    writeTypeId(TypeId.switchDevice);
    writeInt32(device.target);
    writeInt32(device.value);
  }

  void _writeRefresh(RefreshDevice device) {
    writeTypeId(TypeId.refresh);
    for (int i = 0; i < 4; i++) {
      writeBool(device.targets[i]);
    }
  }

  void _writePattern(PatternDevice device) {
    writeTypeId(TypeId.pattern);
    // Write repeats (v11+)
    writeInt32(device.repeats);

    // Write gate
    writeDouble(device.gate);

    // Write pinch (v24+)
    writeDouble(device.pinch);

    // Write bilateral (v28+)
    writeBool(device.bilateral);

    // Write frames
    writeInt32(device.frames.length);
    for (Frame frame in device.frames) {
      _writeFrame(frame);
    }

    // Write mode
    writeInt32(device.mode.index);

    // Don't write old choke data for latest version

    // Write infinite (v4+)
    writeBool(device.infinite);

    // Write rootKey (v12+)
    if (device.rootKey != null) {
      writeBool(true);
      writeInt32(device.rootKey!);
    } else {
      writeBool(false);
    }

    // Write wrap (v13+)
    writeBool(device.wrap);

    // Write expanded
    writeInt32(device.expanded);
  }

  void _writeFrame(Frame frame) {
    writeTypeId(TypeId.frame);
    _writeTime(frame.time);

    // Write 101 colors for latest version
    for (ApolloColor color in frame.screen) {
      _writeColor(color);
    }
  }

  void writeDevice(Device device) {
    writeTypeId(TypeId.device);
    writeBool(device.collapsed);
    writeBool(device.enabled);

    switch (device.runtimeType) {
      case const (ChokeDevice):
        _writeChoke(device as ChokeDevice);
        break;
      case const (ClearDevice):
        _writeClear(device as ClearDevice);
        break;
      case const (ColorFilterDevice):
        _writeColorFilter(device as ColorFilterDevice);
        break;
      case const (CopyDevice):
        _writeCopy(device as CopyDevice);
      case const (DelayDevice):
        _writeDelay(device as DelayDevice);
        break;
      case const (FadeDevice):
        _writeFade(device as FadeDevice);
        break;
      case const (FlipDevice):
        _writeFlip(device as FlipDevice);
        break;
      case const (GroupDevice):
        _writeGroup(device as GroupDevice);
        break;
      case const (HoldDevice):
        _writeHold(device as HoldDevice);
        break;
      case const (KeyFilterDevice):
        _writeKeyFilter(device as KeyFilterDevice);
        break;
      case const (LayerFilterDevice):
        _writeLayerFilter(device as LayerFilterDevice);
        break;
      case const (LayerDevice):
        _writeLayer(device as LayerDevice);
        break;
      case const (LoopDevice):
        _writeLoop(device as LoopDevice);
        break;
      case const (MacroFilterDevice):
        _writeMacroFilter(device as MacroFilterDevice);
        break;
      case const (MoveDevice):
        _writeMove(device as MoveDevice);
        break;
      case const (MultiDevice):
        _writeMulti(device as MultiDevice);
        break;
      case const (OutputDevice):
        _writeOutput(device as OutputDevice);
        break;
      case const (PaintDevice):
        _writePaint(device as PaintDevice);
        break;
      case const (PatternDevice):
        _writePattern(device as PatternDevice);
        break;
      case const (PreviewDevice):
        _writePreview(device as PreviewDevice);
        break;
      case const (RefreshDevice):
        _writeRefresh(device as RefreshDevice);
        break;
      case const (RotateDevice):
        _writeRotate(device as RotateDevice);
        break;
      case const (SwitchDevice):
        _writeSwitch(device as SwitchDevice);
        break;
      case const (ToneDevice):
        _writeTone(device as ToneDevice);
        break;
      default:
        throw ArgumentError('Unsupported device type: ${device.runtimeType}');
    }
  }

  void _writeChain(Chain chain) {
    // Remove writer parameter - use this
    writeTypeId(TypeId.chain);

    // Write device count
    writeInt32(chain.devices.length);

    // Write devices
    for (Device device in chain.devices) {
      writeDevice(device); // Use this instead of writer
    }

    // Write chain name
    writeString(chain.name);

    // Write enabled flag
    writeBool(chain.enabled);

    // Write filter (101 boolean values)
    for (int i = 0; i < 101; i++) {
      if (chain.filter != null && i < chain.filter!.length) {
        writeBool(chain.filter![i]);
      } else {
        writeBool(true); // Default: all keys enabled
      }
    }
  }

  void _writeTrack(Track track) {
    // Remove writer parameter - use this
    writeTypeId(TypeId.track);

    // Write chain
    _writeChain(track.chain);

    // Write launchpad
    writeTypeId(TypeId.launchpad);
    writeString(""); // Empty = MIDI.NoOutput

    // Write track name
    writeString(track.name);

    // Write enabled flag
    writeBool(track.enabled);
  }

  // NEW: Write a complete project
  void writeProject(ProjectData project) {
    writeHeader();

    // Write Project type ID
    writeTypeId(TypeId.project);

    // Write BPM
    writeInt32(project.bpm);

    // Write macros (4 values)
    for (int macro in project.macros) {
      writeInt32(macro);
    }

    // Write tracks
    writeInt32(project.tracks.length);
    for (Track track in project.tracks) {
      _writeTrack(track);
    }

    // Write metadata
    writeString(project.author);
    writeInt64(project.time);
    writeInt64(project.started.millisecondsSinceEpoch ~/ 1000);

    // Write undo manager
    writeTypeId(TypeId.undoManager);
    writeInt32(2); // UndoBinary.Version = 2
    writeInt32(8); // Size of undo data
    writeInt32(0); // No undo entries
    writeInt32(0); // Position 0
  }

  Uint8List writeObject(dynamic object) {
    writeHeader();

    if (object is Device) {
      writeDevice(object);
    } else {
      throw ArgumentError('Unsupported object type: ${object.runtimeType}');
    }

    return builder.takeBytes();
  }

  Uint8List toBytes() {
    return builder.takeBytes();
  }
}
