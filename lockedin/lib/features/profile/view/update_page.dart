import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/features/profile/viewmodel/update_profile_viewmodel.dart';

class UpdateProfileView extends ConsumerStatefulWidget {
  const UpdateProfileView({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends ConsumerState<UpdateProfileView> {
  late UpdateProfileViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // ViewModel will be initialized in build because it depends on userState
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    final viewModel = UpdateProfileViewModel(userState.value!);

    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildExpansionTile(
              title: "Basic Information",
              children: viewModel.buildBasicInfoForm(),
              onSubmit: () {
                ref.read(profileViewModelProvider).fetchAllProfileData();
                viewModel.submitBasicInfo();
              },
            ),
            _buildExpansionTile(
              title: "Contact Information",
              children: viewModel.buildContactInfoForm(),
              onSubmit: viewModel.submitContactInfo,
            ),
            _buildExpansionTile(
              title: "About",
              children: viewModel.buildAboutInfoForm(),
              onSubmit: viewModel.submitAboutInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required List<Widget> children,
    required Function() onSubmit,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ...children,
                ElevatedButton(
                  onPressed: () async {
                    await onSubmit();
                    setState(() {});
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await ref
                          .read(profileViewModelProvider)
                          .fetchAllProfileData();
                    });
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
