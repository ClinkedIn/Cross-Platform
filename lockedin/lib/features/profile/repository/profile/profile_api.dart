import 'dart:convert';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/profile/model/position_model.dart';
import 'package:lockedin/features/profile/model/user_model.dart';

class ProfileService {
  Future<UserModel> fetchUserData() async {
    final response = await RequestService.get(Constants.getUserDataEndpoint);
    print("User data:📀📀 ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data["user"]);
    } else {
      throw Exception("Failed to fetch user data: ${response.body}");
    }
  }

  Future<List<Education>> fetchEducation() async {
    try {
      // Using RequestService instead of direct http calls
      final response = await RequestService.get('/user/education');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['educations'] ?? [];
        final List<Education> educationList =
            data.map((item) => Education.fromJson(item)).toList();
        return educationList;
      } else {
        throw Exception('Failed to load education data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching education: $e');
      throw e;
    }
  }

  Future<List<Position>> fetchExperience() async {
    try {
      // Using RequestService instead of direct http calls
      final response = await RequestService.get('/user/experience');
      print("experience body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['experiences'] ?? [];
        final List<Position> educationList =
            data.map((item) => Position.fromJson(item)).toList();
        return educationList;
      } else {
        throw Exception('Failed to load experience data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching education: $e');
      throw e;
    }
  }
}
