import 'dart:convert';
import 'dart:typed_data';
import 'package:apollo_studio_dart/src/binary/base64.dart';
import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/copyable.dart';
import 'reader.dart';
import 'writer.dart';

extension ApolloClipboardReader on ApolloReader {
  /// Creates a reader from Apollo compressed clipboard data
  static ApolloReader fromClipboard(String clipboardData) {
    try {
      // First decompress the RLE Apollo format
      final decodedBytes = fromCompressedBase64(clipboardData);
      return ApolloReader(decodedBytes);
    } catch (e) {
      throw FormatException('Invalid Apollo clipboard data: $e');
    }
  }

  /// Reads a copyable object from clipboard format
  Copyable readCopyable() {
    if (!readHeader()) {
      throw FormatException('Invalid Apollo clipboard header');
    }

    final version = readInt32();
    if (version > ApolloReader.currentVersion) {
      throw FormatException('Unsupported clipboard version: $version');
    }

    final typeId = readTypeId();
    if (typeId != TypeId.copyable) {
      throw FormatException('Expected Copyable type, got $typeId');
    }

    return _readCopyableContents(version);
  }

  Copyable _readCopyableContents(int version) {
    final count = readInt32();
    final devices = <Device>[];

    for (int i = 0; i < count; i++) {
      final device = readDevice(version); // Your existing reader logic
      devices.add(device);
    }

    return Copyable(devices);
  }

  List<Device> readDevicesFromClipboard() {
    return readCopyable().contents;
  }
}

extension ApolloClipboard on ApolloWriter {
  /// Writes multiple devices in Apollo's clipboard format (Compressed Base64)
  String writeDevicesToClipboard(List<Device> devices) {
    final copyable = Copyable(devices);
    return writeCopyableToClipboard(copyable);
  }

  /// Writes a single device
  String writeDeviceToClipboard(Device device) {
    return writeDevicesToClipboard([device]);
  }

  /// Writes a copyable in Apollo's clipboard format (Compressed Base64)
  String writeCopyableToClipboard(Copyable copyable) {
    builder = BytesBuilder();

    writeHeader();
    writeTypeId(TypeId.copyable);
    _writeCopyable(copyable);

    final bytes = builder.takeBytes();

    // Convert to Base64, then compress per Apollo’s logic
    final b64 = base64Encode(bytes);
    return toCompressedBase64(b64);
  }

  void _writeCopyable(Copyable copyable) {
    writeInt32(copyable.contents.length);
    for (final device in copyable.contents) {
      writeDevice(device);
    }
  }
}
