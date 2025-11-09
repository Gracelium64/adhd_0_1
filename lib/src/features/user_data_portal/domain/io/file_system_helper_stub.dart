Future<void> fsWriteBytes(String path, List<int> bytes) async {
  throw UnsupportedError(
    'Filesystem access is not available on this platform.',
  );
}

Future<String> fsReadString(String path) async {
  throw UnsupportedError(
    'Filesystem access is not available on this platform.',
  );
}
