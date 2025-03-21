import 'package:lockedin/features/profile/model/profile_item_model.dart';

class ProfileComponentState {
  final List<ProfileItemModel> experienceList;
  final List<ProfileItemModel> educationList;
  final List<ProfileItemModel> licenseList;

  ProfileComponentState({
    required this.experienceList,
    required this.educationList,
    required this.licenseList,
  });

  ProfileComponentState copyWith({
    List<ProfileItemModel>? experienceList,
    List<ProfileItemModel>? educationList,
    List<ProfileItemModel>? licenseList,
  }) {
    return ProfileComponentState(
      experienceList: experienceList ?? this.experienceList,
      educationList: educationList ?? this.educationList,
      licenseList: licenseList ?? this.licenseList,
    );
  }
}
