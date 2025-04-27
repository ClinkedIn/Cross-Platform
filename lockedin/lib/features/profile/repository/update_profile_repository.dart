import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class UpdateProfileRepository {
  Future<void> updateBasicInfo(Map<String, dynamic> data) async {
    final response = await RequestService.patch("/user/profile", body: data);
    _handleResponse(response);
  }

  Future<void> updateContactInfo(Map<String, dynamic> data) async {
    final response = await RequestService.patch(
      "/user/contact-info",
      body: data,
    );
    _handleResponse(response);
  }

  Future<void> updateAboutInfo(Map<String, dynamic> data) async {
    final response = await RequestService.patch("/user/about", body: data);
    _handleResponse(response);
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      print('Success: ${response.body}');
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }
}
