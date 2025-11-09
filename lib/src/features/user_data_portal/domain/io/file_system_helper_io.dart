import 'dart:io';

Future<void> fsWriteBytes(String path, List<int> bytes) async {
  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}

Future<String> fsReadString(String path) async {
  final file = File(path);
  return file.readAsString();
}
