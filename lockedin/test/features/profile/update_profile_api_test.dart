import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUpdateProfileApi extends Mock {
  Future<void> updateProfile(Map<String, String> userInput);
}

void main() {
  group('Update Profile API Tests', () {
    test('Should call updateProfile with correct parameters', () async {
      final mockApi = MockUpdateProfileApi();

      final userInput = {
        "firstName": "John",
        "lastName": "Doe",
        "additionalName": "JD",
        "headline": "Developer",
        "link": "www.example.com",
      };

      await mockApi.updateProfile(userInput);

      verify(mockApi.updateProfile(userInput)).called(1);
    });
  });
}
