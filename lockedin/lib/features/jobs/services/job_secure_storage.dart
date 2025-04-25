import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final jobSecureStorage = FlutterSecureStorage();

Future<void> storeApplicationStatus(String jobId, bool hasApplied) async {
  await jobSecureStorage.write(
    key: jobId,
    value: hasApplied ? 'true' : 'false',
  );
}

Future<bool> getApplicationStatus(String jobId) async {
  final status = await jobSecureStorage.read(key: jobId);
  return status == 'true';
}
