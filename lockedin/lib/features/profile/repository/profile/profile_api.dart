import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/profile/model/user_model.dart';

class ProfileService {
  final String url =
      "https://39824696-46ba-4401-89d7-26ca4a77d541.mock.pstmn.io/me";
  final Map<String, String> headers = {"Content-Type": "application/json"};

  Future<UserModel> fetchUserData() async {
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw Exception("Failed to load user: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user: $e");
      throw Exception("Network error: $e");
    }
  }
}
