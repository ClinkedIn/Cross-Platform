import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/profile/model/skill_model.dart';

class SkillService {
  static Future<http.Response> addSkill(Skill skill) async {
    try {
      final jsonString = jsonEncode(skill.toJson());
      print("Adding skill: ${skill.toJson()}");
      print("Sending to API: $jsonString");

      final response = await RequestService.post(
        "/user/skills",
        body: skill.toJson(),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      return response;
    } catch (e) {
      print("Exception in addSkill: $e");
      throw Exception("Error adding skill: $e");
    }
  }
}
