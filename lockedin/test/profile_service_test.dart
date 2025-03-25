import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/profile/repository/profile/profile_api.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'dart:convert';

import 'profile_service_test.mocks.dart'; // Auto-generated file

@GenerateMocks([http.Client])
void main() {
  late ProfileService profileService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    profileService = ProfileService();
  });

  test(
    'fetchUserData returns a valid UserModel when response is 200',
    () async {
      final mockResponse = jsonEncode({
        "firstName": "John",
        "lastName": "Doe",
        "email": "johndoe@email.com",
        "profilePicture": "https://example.com/profile.jpg",
        "coverPicture": "https://example.com/cover.jpg",
        "resume": "https://example.com/resume.pdf",
        "bio": "Passionate software engineer with 5 years of experience.",
        "location": "San Francisco, CA, USA",
        "lastJobTitle": "Software Engineer",
        "workExperience": [
          {
            "jobTitle": "Software Engineer",
            "companyName": "Google",
            "from": "2020-06-01",
            "to": "2023-06-01",
            "employmentType": "full-time",
            "location": "San Francisco, CA, USA",
            "locationType": "hybrid",
            "description": "Worked on backend services and APIs.",
            "jobSource": "LinkedIn",
            "skills": ["JavaScript", "Node.js", "MongoDB"],
            "media": "https://example.com/certificate.pdf",
          },
        ],
        "following": ["userId1", "userId2"],
        "followers": ["userId1"],
        "connectionList": ["userId2"],
        "blockedUsers": ["userId3"],
        "profileViews": ["userId4", "userId5"],
        "savedPosts": ["postId1", "postId2"],
        "savedJobs": ["jobId1", "jobId2"],
        "appliedJobs": [
          {"jobId": "jobId123", "status": "pending"},
        ],
        "jobListings": ["jobId123", "jobId456"],
        "defaultMode": "dark",
        "isActive": true,
      });

      when(
        mockClient.get(
          Uri.parse(profileService.url),
          headers: profileService.headers,
        ),
      ).thenAnswer((_) async => http.Response(mockResponse, 200));

      final result = await profileService.fetchUserData();

      expect(result, isA<UserModel>());
      expect(result.firstName, "John");
      expect(result.lastName, "Doe");
      expect(result.workExperience.first.companyName, "Google");
      expect(result.isActive, true);
    },
  );
}
