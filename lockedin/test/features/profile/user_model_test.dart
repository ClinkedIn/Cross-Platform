import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/profile/model/user_model.dart';

void main() {
  group('Education Model', () {
    test('fromJson constructs correct Education instance', () {
      // Arrange
      final Map<String, dynamic> json = {
        'school': 'Stanford University',
        'degree': 'Bachelor of Science',
        'fieldOfStudy': 'Computer Science',
        'startDate': '2018-09-01',
        'endDate': '2022-06-01',
        'grade': 'A',
        'activities': 'Coding Club, Chess Club',
        'description': 'Studied algorithms and data structures',
        'skills': ['Programming', 'Machine Learning'],
        'media': 'https://example.com/diploma.pdf',
      };

      // Act
      final result = Education.fromJson(json);

      // Assert
      expect(result.school, 'Stanford University');
      expect(result.degree, 'Bachelor of Science');
      expect(result.fieldOfStudy, 'Computer Science');
      expect(result.startDate, '2018-09-01');
      expect(result.endDate, '2022-06-01');
      expect(result.grade, 'A');
      expect(result.activities, 'Coding Club, Chess Club');
      expect(result.description, 'Studied algorithms and data structures');
      expect(result.skills, ['Programming', 'Machine Learning']);
      expect(result.media, 'https://example.com/diploma.pdf');
    });

    test('toJson produces correct JSON map', () {
      // Arrange
      final education = Education(
        school: 'Stanford University',
        degree: 'Bachelor of Science',
        fieldOfStudy: 'Computer Science',
        startDate: '2018-09-01',
        endDate: '2022-06-01',
        grade: 'A',
        activities: 'Coding Club, Chess Club',
        description: 'Studied algorithms and data structures',
        skills: ['Programming', 'Machine Learning'],
        media: 'https://example.com/diploma.pdf',
      );

      // Act
      final json = education.toJson();

      // Assert
      expect(json['school'], 'Stanford University');
      expect(json['degree'], 'Bachelor of Science');
      expect(json['fieldOfStudy'], 'Computer Science');
      expect(json['startDate'], '2018-09-01');
      expect(json['endDate'], '2022-06-01');
      expect(json['grade'], 'A');
      expect(json['activities'], 'Coding Club, Chess Club');
      expect(json['description'], 'Studied algorithms and data structures');
      expect(json['skills'], ['Programming', 'Machine Learning']);
      expect(json['media'], 'https://example.com/diploma.pdf');
    });

    test('handles null optional fields correctly in toJson', () {
      // Arrange
      final education = Education(
        school: 'Harvard University',
        // All other fields null
      );

      // Act
      final json = education.toJson();

      // Assert
      expect(json['school'], 'Harvard University');
      expect(json.containsKey('degree'), false);
      expect(json.containsKey('fieldOfStudy'), false);
      expect(json.containsKey('media'), false);
    });
  });

  group('ContactInfo Model', () {
    test('fromJson constructs correct ContactInfo instance', () {
      // Arrange
      final Map<String, dynamic> json = {
        'phone': '123-456-7890',
        'phoneType': 'Mobile',
        'address': '123 Main St',
        'birthDay': {'day': 15, 'month': 'March'},
        'website': {'url': 'https://example.com', 'type': 'personal'},
      };

      // Act
      final result = ContactInfo.fromJson(json);

      // Assert
      expect(result.phone, '123-456-7890');
      expect(result.phoneType, 'Mobile');
      expect(result.address, '123 Main St');
      expect(result.birthDay.day, 15);
      expect(result.birthDay.month, 'March');
      expect(result.website?.url, 'https://example.com');
      expect(result.website?.type, 'personal');
    });

    // Need to implement toJson in ContactInfo first
    // test('toJson produces correct JSON map', () {...});
  });

  group('UserModel', () {
    test(
      'fromJson constructs correct UserModel instance with minimal data',
      () {
        // Arrange
        final Map<String, dynamic> json = {
          '_id': '123456',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@example.com',
          'createdAt': '2023-01-01T00:00:00.000Z',
          'updatedAt': '2023-01-02T00:00:00.000Z',
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.id, '123456');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.email, 'john.doe@example.com');
        expect(result.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
        expect(result.updatedAt, DateTime.parse('2023-01-02T00:00:00.000Z'));
      },
    );

    test('fromJson handles complex nested objects correctly', () {
      // Arrange
      final Map<String, dynamic> json = {
        '_id': '123456',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john.doe@example.com',
        'headline': 'Software Engineer',
        'contactInfo': {
          'phone': '123-456-7890',
          'phoneType': 'Mobile',
          'address': '123 Main St',
          'birthDay': {'day': 15, 'month': 'March'},
        },
        'about': {
          'description': 'Passionate developer',
          'skills': ['JavaScript', 'Flutter'],
        },
        'education': [
          {
            'school': 'MIT',
            'degree': 'Masters',
            'fieldOfStudy': 'Computer Science',
          },
        ],
        'workExperience': [
          {
            'jobTitle': 'Software Engineer',
            'companyName': 'Google',
            'fromDate': '2020-01-01',
            'employmentType': 'Full-time',
            'skills': ['React', 'Node.js'],
          },
        ],
        'createdAt': '2023-01-01T00:00:00.000Z',
        'updatedAt': '2023-01-02T00:00:00.000Z',
      };

      // Act
      final result = UserModel.fromJson(json);

      // Assert
      expect(result.id, '123456');
      expect(result.headline, 'Software Engineer');
      expect(result.contactInfo?.phone, '123-456-7890');
      expect(result.about?.description, 'Passionate developer');
      expect(result.about?.skills, ['JavaScript', 'Flutter']);
      expect(result.education.length, 1);
      expect(result.education[0].school, 'MIT');
      expect(result.workExperience.length, 1);
      expect(result.workExperience[0].jobTitle, 'Software Engineer');
      expect(result.workExperience[0].companyName, 'Google');
    });
  });

  group('UserModel toJson serialization', () {
    test('toJson produces correct minimal JSON', () {
      // Arrange - create a minimal user model
      final user = UserModel(
        id: '123456',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        createdAt: DateTime.parse('2023-01-01T12:00:00Z'),
        updatedAt: DateTime.parse('2023-01-02T12:00:00Z'),
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['_id'], '123456');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['email'], 'john.doe@example.com');
      expect(json['skills'], isEmpty);
      expect(json['education'], isEmpty);
      expect(json['workExperience'], isEmpty);
      expect(json['connectionList'], isEmpty);
      expect(json['createdAt'], '2023-01-01T12:00:00.000Z');
      expect(json['updatedAt'], '2023-01-02T12:00:00.000Z');

      // Check that optional fields aren't included when null
      expect(json.containsKey('additionalName'), false);
      expect(json.containsKey('headline'), false);
      expect(json.containsKey('profilePicture'), false);
    });

    test('toJson includes optional fields when present', () {
      // Arrange - create user model with optional fields
      final user = UserModel(
        id: '123456',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        additionalName: 'Johnny',
        headline: 'Software Engineer',
        profilePicture: 'https://example.com/profile.jpg',
        location: 'New York',
        createdAt: DateTime.parse('2023-01-01T12:00:00Z'),
        updatedAt: DateTime.parse('2023-01-02T12:00:00Z'),
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['additionalName'], 'Johnny');
      expect(json['headline'], 'Software Engineer');
      expect(json['profilePicture'], 'https://example.com/profile.jpg');
      expect(json['location'], 'New York');
    });

    test('toJson correctly handles nested objects', () {
      // Arrange - create user with nested objects
      final contactInfo = ContactInfo(
        phone: '123-456-7890',
        phoneType: 'Mobile',
        address: '123 Main St',
        birthDay: Birthday(day: 15, month: 'March'),
        website: ContactWebsite(url: 'https://example.com', type: 'personal'),
      );

      final about = About(
        description: 'Passionate developer',
        skills: ['JavaScript', 'Flutter'],
      );

      final education = [
        Education(school: 'Harvard', degree: 'MBA', startDate: '2020-01-01'),
      ];

      final user = UserModel(
        id: '123456',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        contactInfo: contactInfo,
        about: about,
        education: education,
        createdAt: DateTime.parse('2023-01-01T12:00:00Z'),
        updatedAt: DateTime.parse('2023-01-02T12:00:00Z'),
      );

      // Act
      final json = user.toJson();

      // Assert - check nested objects
      expect(json['contactInfo']['phone'], '123-456-7890');
      expect(json['contactInfo']['phoneType'], 'Mobile');
      expect(json['contactInfo']['birthDay']['day'], 15);
      expect(json['contactInfo']['birthDay']['month'], 'March');
      expect(json['contactInfo']['website']['url'], 'https://example.com');

      expect(json['about']['description'], 'Passionate developer');
      expect(json['about']['skills'], ['JavaScript', 'Flutter']);

      expect(json['education'][0]['school'], 'Harvard');
      expect(json['education'][0]['degree'], 'MBA');
      expect(json['education'][0]['startDate'], '2020-01-01');
    });
  });

  group('ContactInfo serialization', () {
    test('toJson produces correct JSON for ContactInfo', () {
      // Arrange
      final contactInfo = ContactInfo(
        phone: '123-456-7890',
        phoneType: 'Mobile',
        address: '123 Main St',
        birthDay: Birthday(day: 15, month: 'March'),
        website: ContactWebsite(url: 'https://example.com', type: 'personal'),
      );

      // Act
      final json = contactInfo.toJson();

      // Assert
      expect(json['phone'], '123-456-7890');
      expect(json['phoneType'], 'Mobile');
      expect(json['address'], '123 Main St');
      expect(json['birthDay']['day'], 15);
      expect(json['birthDay']['month'], 'March');
      expect(json['website']['url'], 'https://example.com');
      expect(json['website']['type'], 'personal');
    });

    test('toJson omits website when null in ContactInfo', () {
      // Arrange
      final contactInfo = ContactInfo(
        phone: '123-456-7890',
        phoneType: 'Mobile',
        address: '123 Main St',
        birthDay: Birthday(day: 15, month: 'March'),
        // No website
      );

      // Act
      final json = contactInfo.toJson();

      // Assert
      expect(json.containsKey('website'), false);
    });
  });

  group('WorkExperience serialization', () {
    test('toJson produces correct JSON for complete WorkExperience', () {
      // Arrange
      final experience = WorkExperience(
        jobTitle: 'Software Engineer',
        companyName: 'Google',
        fromDate: '2020-01-01',
        toDate: '2022-12-31',
        currentlyWorking: false,
        employmentType: 'Full-time',
        location: 'Mountain View, CA',
        locationType: 'On-site',
        description: 'Developed web applications',
        foundVia: 'LinkedIn',
        skills: ['JavaScript', 'React', 'Node.js'],
        media: 'https://example.com/certificate.pdf',
      );

      // Act
      final json = experience.toJson();

      // Assert
      expect(json['jobTitle'], 'Software Engineer');
      expect(json['companyName'], 'Google');
      expect(json['fromDate'], '2020-01-01');
      expect(json['toDate'], '2022-12-31');
      expect(json['currentlyWorking'], false);
      expect(json['employmentType'], 'Full-time');
      expect(json['location'], 'Mountain View, CA');
      expect(json['locationType'], 'On-site');
      expect(json['description'], 'Developed web applications');
      expect(json['foundVia'], 'LinkedIn');
      expect(json['skills'], ['JavaScript', 'React', 'Node.js']);
      expect(json['media'], 'https://example.com/certificate.pdf');
    });

    test('toJson omits null fields in WorkExperience', () {
      // Arrange - minimal work experience
      final experience = WorkExperience(
        jobTitle: 'Software Engineer',
        companyName: 'Google',
        fromDate: '2020-01-01',
        employmentType: 'Full-time',
        // All other fields are null
      );

      // Act
      final json = experience.toJson();

      // Assert
      expect(json['jobTitle'], 'Software Engineer');
      expect(json['companyName'], 'Google');
      expect(json['fromDate'], '2020-01-01');
      expect(json['employmentType'], 'Full-time');
      expect(json.containsKey('toDate'), false);
      expect(json.containsKey('currentlyWorking'), false);
      expect(json.containsKey('location'), false);
      expect(json.containsKey('description'), false);
    });
  });

  group('Round-trip serialization', () {
    test('Education can be serialized and deserialized without data loss', () {
      // Arrange - create education object
      final original = Education(
        school: 'MIT',
        degree: 'PhD',
        fieldOfStudy: 'Computer Science',
        startDate: '2020-01-01',
        skills: ['AI', 'Machine Learning'],
      );

      // Act - convert to JSON and back
      final json = original.toJson();
      final reconstructed = Education.fromJson(json);

      // Assert
      expect(reconstructed.school, original.school);
      expect(reconstructed.degree, original.degree);
      expect(reconstructed.fieldOfStudy, original.fieldOfStudy);
      expect(reconstructed.startDate, original.startDate);
      expect(reconstructed.skills, original.skills);
    });

    test('ContactInfo can be serialized and deserialized', () {
      // Arrange
      final original = ContactInfo(
        phone: '555-1234',
        phoneType: 'Work',
        address: '1 Infinite Loop',
        birthDay: Birthday(day: 1, month: 'April'),
      );

      // Act
      final json = original.toJson();
      final reconstructed = ContactInfo.fromJson(json);

      // Assert
      expect(reconstructed.phone, original.phone);
      expect(reconstructed.phoneType, original.phoneType);
      expect(reconstructed.address, original.address);
      expect(reconstructed.birthDay.day, original.birthDay.day);
      expect(reconstructed.birthDay.month, original.birthDay.month);
    });
  });
}
