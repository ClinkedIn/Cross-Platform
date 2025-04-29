import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final jobSecureStorage = FlutterSecureStorage();

const _savedJobsKey = 'saved_jobs';

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

// ✅ Save Jobs Logic
Future<void> saveJobId(String jobId) async {
  final currentIds = await getSavedJobIds();
  if (!currentIds.contains(jobId)) {
    currentIds.add(jobId);
    await _persistSavedJobs(currentIds);
  }
}

Future<void> unsaveJobId(String jobId) async {
  final currentIds = await getSavedJobIds();
  currentIds.remove(jobId);
  await _persistSavedJobs(currentIds);
}

Future<List<String>> getSavedJobIds() async {
  final jobIdsString = await jobSecureStorage.read(key: _savedJobsKey);
  if (jobIdsString == null || jobIdsString.isEmpty) return [];
  return jobIdsString.split(',');
}

Future<void> clearSavedJobs() async {
  await jobSecureStorage.delete(key: _savedJobsKey);
}

Future<void> _persistSavedJobs(List<String> jobIds) async {
  await jobSecureStorage.write(key: _savedJobsKey, value: jobIds.join(','));
}
