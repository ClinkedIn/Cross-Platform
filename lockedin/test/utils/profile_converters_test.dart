import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/model/position_model.dart';
import 'package:lockedin/features/profile/utils/profile_converters.dart';

void main() {
  group('ProfileConverters', () {
    group('formatDate', () {
      test('returns formatted date for valid date string', () {
        final result = ProfileConverters.formatDate('2023-05-12');
        expect(result, 'May 2023');
      });

      test('returns empty string for null date string', () {
        final result = ProfileConverters.formatDate(null);
        expect(result, '');
      });

      test('returns original string for invalid date string', () {
        final result = ProfileConverters.formatDate('invalid-date');
        expect(result, 'invalid-date');
      });
    });

    group('educationToProfileItem', () {
      test('correctly converts Education to ProfileItemModel', () {
        final education = Education(
          degree: 'Bachelor of Science',
          school: 'University of Cairo',
          fieldOfStudy: 'Computer Science',
          startDate: '2020-09-01',
          endDate: '2024-06-30',
          media: 'assets/images/education_logo.png',
        );

        final result = ProfileConverters.educationToProfileItem(education);

        expect(result.title, 'Bachelor of Science');
        expect(result.subtitle, 'University of Cairo • Computer Science');
        expect(result.duration, 'Sep 2020 - Jun 2024');
        expect(result.logoUrl, 'assets/images/education_logo.png');
      });

      test('handles null or missing fields correctly', () {
        final education = Education(
          degree: null,
          school: 'University of Cairo',
          fieldOfStudy: null,
          startDate: null,
          endDate: null,
          media: null,
        );

        final result = ProfileConverters.educationToProfileItem(education);

        expect(result.title, 'Degree');
        expect(result.subtitle, 'University of Cairo • ');
        expect(result.duration, '');
        expect(result.logoUrl, 'assets/images/education_default.png');
      });

      test('correctly handles "Present" end date', () {
        final education = Education(
          degree: 'Bachelor of Science',
          school: 'University of Cairo',
          fieldOfStudy: 'Computer Science',
          startDate: '2020-09-01',
          endDate: null,
          media: 'assets/images/education_logo.png',
        );

        final result = ProfileConverters.educationToProfileItem(education);

        expect(result.title, 'Bachelor of Science');
        expect(result.subtitle, 'University of Cairo • Computer Science');
        expect(result.duration, 'Sep 2020 - Present');
        expect(result.logoUrl, 'assets/images/education_logo.png');
      });
    });

    group('experienceToProfileItem', () {
      test('correctly converts Position to ProfileItemModel', () {
        final position = Position(
          jobTitle: 'Software Engineer',
          companyName: 'Tech Corp',
          employmentType: 'Full-Time',
          fromDate: '2021-01-01',
          toDate: '2023-01-01',
          currentlyWorking: false,
          media: 'assets/images/company_logo.png',
        );

        final result = ProfileConverters.experienceToProfileItem(position);

        expect(result.title, 'Software Engineer');
        expect(result.subtitle, 'Tech Corp • Full-Time');
        expect(result.duration, 'Jan 2021 - Jan 2023');
        expect(result.logoUrl, 'assets/images/company_logo.png');
      });

      test('correctly handles "Present" for current position', () {
        final position = Position(
          jobTitle: 'Software Engineer',
          companyName: 'Tech Corp',
          employmentType: 'Full-Time',
          fromDate: '2021-01-01',
          toDate: null,
          currentlyWorking: true,
          media: 'assets/images/company_logo.png',
        );

        final result = ProfileConverters.experienceToProfileItem(position);

        expect(result.title, 'Software Engineer');
        expect(result.subtitle, 'Tech Corp • Full-Time');
        expect(result.duration, 'Jan 2021 - Present');
        expect(result.logoUrl, 'assets/images/company_logo.png');
      });

      test('handles null or missing fields correctly', () {
        final position = Position(
          jobTitle: "",
          companyName: 'Tech Corp',
          employmentType: null,
          fromDate: null,
          toDate: null,
          currentlyWorking: false,
          media: null,
        );

        final result = ProfileConverters.experienceToProfileItem(position);

        expect(result.title, '');
        expect(result.subtitle, 'Tech Corp • ');
        expect(result.duration, '');
        expect(result.logoUrl, 'assets/images/company_default.png');
      });
    });
  });
}
