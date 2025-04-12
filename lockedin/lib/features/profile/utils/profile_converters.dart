import 'package:lockedin/features/profile/model/education_model.dart';
import 'package:lockedin/features/profile/model/position_model.dart';
// import 'package:lockedin/features/profile/model/license_model.dart';
import 'package:lockedin/features/profile/model/profile_item_model.dart';

class ProfileConverters {
  static ProfileItemModel educationToProfileItem(Education education) {
    final duration =
        education.startDate != null
            ? "${formatDate(education.startDate)} - ${education.endDate != null ? formatDate(education.endDate) : 'Present'}"
            : "";

    return ProfileItemModel(
      title: education.degree ?? "Degree",
      subtitle: "${education.school} • ${education.fieldOfStudy ?? ''}",
      duration: duration,
      logoUrl: education.media ?? "assets/images/education_default.png",
    );
  }

  static ProfileItemModel experienceToProfileItem(Position position) {
    final duration =
        position.fromDate != null
            ? "${formatDate(position.fromDate)} - ${position.currentlyWorking
                ? 'Present'
                : position.toDate != null
                ? formatDate(position.toDate)
                : ''}"
            : "";

    return ProfileItemModel(
      title: position.jobTitle,
      subtitle: "${position.companyName} • ${position.employmentType ?? ''}",
      duration: duration,
      logoUrl: position.media ?? "assets/images/company_default.png",
    );
  }

  // static ProfileItemModel licenseToProfileItem(License license) {
  //   final duration = license.issueDate != null ?
  //     "${formatDate(license.issueDate)} - ${license.hasExpiration && license.expirationDate != null ? formatDate(license.expirationDate) : 'No Expiration'}" :
  //     "";

  //   return ProfileItemModel(
  //     title: license.name,
  //     subtitle: license.organization,
  //     duration: duration,
  //     logoUrl: license.media ?? "assets/images/certificate_default.png",
  //   );
  // }

  static String formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final month =
          [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ][date.month - 1];
      return '$month ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
