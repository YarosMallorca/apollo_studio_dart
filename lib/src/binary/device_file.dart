import 'dart:io';
import 'dart:typed_data';
import 'package:apollo_studio_dart/src/binary/reader.dart';
import 'package:apollo_studio_dart/src/binary/writer.dart';
import 'package:apollo_studio_dart/src/devices/device.dart';
import 'package:apollo_studio_dart/src/enums.dart';

extension DeviceFileReader on ApolloReader {
  List<Device> readDeviceFile(Uint8List bytes) {
    // Read header
    if (!readHeader()) {
      throw Exception('Invalid Apollo device file format');
    }

    // Read version
    int version = readInt32();
    print('Device file version: $version');

    // Check what type of content this is
    final typeId = readTypeId();

    switch (typeId) {
      case TypeId.device:
        // Single device - return as list with one element
        return [_readSingleDeviceFromFile(version)];

      case TypeId.copyable:
        // Multiple devices - return the list directly
        return _readCopyableContents(version);

      default:
        throw FormatException(
          'Expected Device or Copyable type in .apdev file, got $typeId',
        );
    }
  }

  Device _readSingleDeviceFromFile(int version) {
    // For single device files, we can just use the existing readDevice method
    // which already handles the Device TypeId and properties
    return readDevice(version);
  }

  List<Device> _readCopyableContents(int version) {
    final count = readInt32();
    final devices = <Device>[];

    for (int i = 0; i < count; i++) {
      final device = readDevice(version);
      devices.add(device);
    }

    return devices;
  }
}

extension DeviceFileWriter on ApolloWriter {
  void writeDeviceFile(List<Device> devices, String filePath) {
    final writer = ApolloWriter();

    // Write header
    writer.writeHeader();
    writer.writeInt32(32); // Current version

    if (devices.length == 1) {
      // Single device format
      writer.writeDevice(devices.first);
    } else {
      // Multiple devices format (Copyable)
      writer.writeTypeId(TypeId.copyable);
      writer.writeInt32(devices.length);

      for (Device device in devices) {
        writer.writeDevice(device);
      }
    }

    // Save to file
    File(filePath).writeAsBytesSync(writer.toBytes());
  }

  /// Writes a single device as .apdev file data
  Uint8List writeDeviceFileData(Device device) {
    // Clear any previous data
    builder = BytesBuilder();

    writeHeader();
    writeInt32(32); // Current version
    writeDevice(device);

    return builder.takeBytes();
  }

  /// Writes multiple devices as .apdev file data
  Uint8List writeDevicesFileData(List<Device> devices) {
    // Clear any previous data
    builder = BytesBuilder();

    writeHeader();
    writeInt32(32); // Current version

    if (devices.length == 1) {
      // Single device format
      writeDevice(devices.first);
    } else {
      // Multiple devices format (Copyable)
      writeTypeId(TypeId.copyable);
      writeInt32(devices.length);

      for (Device device in devices) {
        writeDevice(device);
      }
    }

    return builder.takeBytes();
  }
}
