import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/services/secure_storage_service.dart';

final userCredentialsProvider = FutureProvider<Map<String, String?>>((
  ref,
) async {
  final storage = SecureStorageService();
  final credentials = await storage.loadCredentials();
  return credentials;
});
