import 'dart:convert';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/admin/models/report_model.dart';

class ReportRepository {
  Future<List<Report>> fetchReports() async {
    final response = await RequestService.get('/admin/reports');
    print('Respongixdewkcdwse: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final decodedJson = jsonDecode(response.body);
      List<Report> reports = parseReports(decodedJson);
      print('Decoded JSON: $decodedJson');
      return reports;
    } else {
      throw Exception("Failed to load reports");
    }
  }

  Future<void> takeActionOnReport(
    String id,
    String action,
    String reason,
  ) async {
    final response = await RequestService.patch(
      '/admin/reports/$id',
      body: {'action': action, 'reason': reason},
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to take action on report");
    }
  }

  Future<void> dismissReport(String id) async {
    final response = await RequestService.delete('/admin/reports/$id');
    if (response.statusCode != 200) {
      throw Exception("Failed to dismiss report");
    }
  }
}
