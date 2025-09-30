import 'dart:io';
import 'dart:typed_data';

import 'package:apollo_studio_dart/src/binary/writer.dart';
import 'package:apollo_studio_dart/src/elements/project_data.dart';

import 'reader.dart';

Future<ProjectData> readProjectFile(String filePath) async {
  try {
    File file = File(filePath);
    Uint8List bytes = await file.readAsBytes();
    ApolloReader reader = ApolloReader(bytes);
    return reader.readProject();
  } catch (e) {
    print('Error reading project file: $e');
    rethrow;
  }
}

ProjectData readProjectFromBytes(Uint8List bytes) {
  try {
    ApolloReader reader = ApolloReader(bytes);
    return reader.readProject();
  } catch (e) {
    print('Error reading project from bytes: $e');
    rethrow;
  }
}

Future<void> writeProjectFile(String filePath, ProjectData project) async {
  try {
    ApolloWriter writer = ApolloWriter();
    writer.writeProject(project);
    File file = File(filePath);
    await file.writeAsBytes(writer.builder.toBytes());
  } catch (e) {
    print('Error writing project file: $e');
    rethrow;
  }
}

Uint8List writeProjectToBytes(ProjectData project) {
  try {
    ApolloWriter writer = ApolloWriter();
    writer.writeProject(project);
    return writer.builder.toBytes();
  } catch (e) {
    print('Error writing project to bytes: $e');
    rethrow;
  }
}
