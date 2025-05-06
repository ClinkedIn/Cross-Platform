import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/features/profile/viewmodel/update_profile_viewmodel.dart';

final updateProfileViewModelProvider =
    ChangeNotifierProvider.autoDispose<UpdateProfileViewModel>((ref) {
      final userState = ref.watch(userProvider);
      if (userState.value == null) {
        throw Exception("User data not available");
      }
      return UpdateProfileViewModel(userState.value!);
    });

class UpdateProfileView extends ConsumerStatefulWidget {
  const UpdateProfileView({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends ConsumerState<UpdateProfileView> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(updateProfileViewModelProvider);

    // Setup UI status listener
    ref.listen<UpdateProfileViewModel>(updateProfileViewModelProvider, (
      previous,
      current,
    ) {
      if (current.status == UpdateStatus.success) {
        _showSnackBar(
          current.message,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );

        // Fetch updated profile data
        ref.read(profileViewModelProvider).fetchAllProfileData();

        // Reset status after showing success message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ref.read(updateProfileViewModelProvider).resetStatus();
          }
        });
      } else if (current.status == UpdateStatus.error) {
        _showSnackBar(
          current.message,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    });

    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Update Profile'), elevation: 2),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpansionTile(
                title: "Basic Information",
                subtitle: "Update your name, headline, and other basic details",
                icon: Icons.person,
                children: viewModel.buildBasicInfoForm(),
                isLoading: viewModel.status == UpdateStatus.loading,
                onSubmit: () async {
                  final success = await viewModel.submitBasicInfo();
                  if (success) {
                    await ref
                        .read(profileViewModelProvider)
                        .fetchAllProfileData();
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildExpansionTile(
                title: "Contact Information",
                subtitle:
                    "Update your phone number, address and other contact details",
                icon: Icons.contact_phone,
                children: viewModel.buildContactInfoForm(),
                isLoading: viewModel.status == UpdateStatus.loading,
                onSubmit: () async {
                  final success = await viewModel.submitContactInfo();
                  if (success) {
                    await ref
                        .read(profileViewModelProvider)
                        .fetchAllProfileData();
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildExpansionTile(
                title: "About",
                subtitle: "Update your bio and skills",
                icon: Icons.info_outline,
                children: viewModel.buildAboutInfoForm(),
                isLoading: viewModel.status == UpdateStatus.loading,
                onSubmit: () async {
                  final success = await viewModel.submitAboutInfo();
                  if (success) {
                    await ref
                        .read(profileViewModelProvider)
                        .fetchAllProfileData();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
    required Function() onSubmit,
    bool isLoading = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      isLoading
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Updating...'),
                            ],
                          )
                          : const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
}
