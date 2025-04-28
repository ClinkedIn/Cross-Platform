import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/profile/model/user_model.dart'; // Where your HTTP logic is
import 'dart:convert';

class OtherProfileRepository {
  Future<UserModel> getUserProfile(String userId) async {
    print("Fetching user data for  ⚠️  ⚠️  ⚠️  ⚠️  ⚠️ : $userId");
    final response = await RequestService.get("/user/$userId");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("User data:📀📀 ${data}");
      return UserModel.fromJson(data["user"]);
    } else {
      print("Error fetching user data:📀📀 ${response.body}");
      throw Exception("Failed to fetch user data: ${response.body}");
    }
  }
}
