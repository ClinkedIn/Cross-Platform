// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lockedin/features/profile/model/profile_item_model.dart';

// class ProfileComponentViewModel extends Notifier<List<ProfileItemModel>> {
//   @override
//   List<ProfileItemModel> build() {
//     return [];
//   }

//   List<ProfileItemModel> get experienceList => [
//     ProfileItemModel(
//       title: "Engineer Intern",
//       subtitle: "AMAN Holding",
//       duration: "Jul 2024 - Present · 9 mos",
//       logoUrl: "assets/images/experience.jpg",
//     ),
//   ];

//   List<ProfileItemModel> get educationList => [
//     ProfileItemModel(
//       title: "Bachelor of Engineering",
//       subtitle: "XYZ University",
//       duration: "2019 - 2023",
//       logoUrl: "assets/images/graduation.jpg",
//     ),
//   ];

//   List<ProfileItemModel> get licenseList => [
//     ProfileItemModel(
//       title: "AWS Certified Developer",
//       subtitle: "Amazon Web Services",
//       duration: "Valid until 2026",
//       logoUrl: "assets/images/certification.jpg",
//     ),
//   ];
// }

// final profileComponentViewModelProvider =
//     NotifierProvider<ProfileComponentViewModel, List<ProfileItemModel>>(
//       () => ProfileComponentViewModel(),
//     );
