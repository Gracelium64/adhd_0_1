import 'file_system_helper_stub.dart'
    if (dart.library.io) 'file_system_helper_io.dart';

Future<void> writeBytesToPath(String path, List<int> bytes) =>
    fsWriteBytes(path, bytes);

Future<String> readStringFromPath(String path) => fsReadString(path);
