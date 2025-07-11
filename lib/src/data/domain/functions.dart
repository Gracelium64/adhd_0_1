  import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
  
  Future<String?> loadUserId() async {
    String? storedValue = await storage.read(key: 'userId');
    return storedValue;
  }