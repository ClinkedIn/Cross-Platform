import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String url =
      "https://26c771aa-ae37-4fa8-b97f-085d46883af3.mock.pstmn.io/login2";
  final Map<String, String> headers = {"Content-Type": "application/json"};

  Future<String> login(String email, String password) async {
    final Map<String, String> body = {"email": email, "password": password};
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    print("Response: $data");

    if (response.statusCode == 200) {
      return data["token"];
    } else {
      throw Exception("Invalid email or password");
    }
  }
}
