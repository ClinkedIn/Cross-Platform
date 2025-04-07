import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveCredentials(String email, String password) async {
    Future.microtask(() async {
      //write to store
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
      print('✅ Credentials saved securely!');
    });
  }

  Future<Map<String, String?>> loadCredentials() async {
    //read to retrieve enctrypted data
    String? email = await _secureStorage.read(key: 'email');
    String? password = await _secureStorage.read(key: 'password');
    return {'email': email, 'password': password};
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
  }
}
