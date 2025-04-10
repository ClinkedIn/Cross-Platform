import 'dart:convert';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/profile/model/user_model.dart';

class ProfileService {
  Future<UserModel> fetchUserData() async {
    final response = await RequestService.get(Constants.getUserDataEndpoint);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data["user"]);
    } else {
      throw Exception("Failed to fetch user data: ${response.body}");
    }
  }
}
