import 'dart:convert';
import 'dart:typed_data';
import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';
import 'package:apollo_studio_dart/src/structures/copyable.dart';
import 'reader.dart';
import 'writer.dart';

extension ApolloClipboardReader on ApolloReader {
  /// Creates a reader from Apollo clipboard data (Base64)
  static ApolloReader fromClipboard(String clipboardData) {
    try {
      final bytes = base64Decode(clipboardData);
      return ApolloReader(Uint8List.fromList(bytes));
    } catch (e) {
      throw FormatException('Invalid clipboard data: $e');
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
      // Each item in copyable should be a device
      final device = readDevice(version);
      devices.add(device);
    }

    return Copyable(devices);
  }

  /// Convenience method to read devices directly from clipboard
  List<Device> readDevicesFromClipboard() {
    final copyable = readCopyable();
    return copyable.contents;
  }
}

extension ApolloClipboard on ApolloWriter {
  /// Writes multiple devices in Apollo's clipboard format (Base64 encoded)
  String writeDevicesToClipboard(List<Device> devices) {
    final copyable = Copyable(devices);
    return writeCopyableToClipboard(copyable);
  }

  /// Writes a single device in Apollo's clipboard format (Base64 encoded)
  String writeDeviceToClipboard(Device device) {
    return writeDevicesToClipboard([device]);
  }

  /// Writes a copyable in Apollo's clipboard format (Base64 encoded)
  String writeCopyableToClipboard(Copyable copyable) {
    // Clear any previous data
    builder = BytesBuilder();

    // Write the copyable to binary
    writeHeader();
    writeTypeId(TypeId.copyable);
    _writeCopyable(copyable);

    final bytes = builder.takeBytes();

    // Convert to Base64 for clipboard
    return base64Encode(bytes);
  }

  void _writeCopyable(Copyable copyable) {
    writeInt32(copyable.contents.length);
    for (final device in copyable.contents) {
      writeDevice(device);
    }
  }
}
