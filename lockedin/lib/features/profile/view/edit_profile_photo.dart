import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/profile/state/user_state.dart';
import 'package:lockedin/features/profile/viewmodel/edit_profile_photo_viewmodel.dart';

class EditProfilePhoto extends ConsumerStatefulWidget {
  const EditProfilePhoto({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePhoto> createState() => _EditProfilePhotoState();
}

class _EditProfilePhotoState extends ConsumerState<EditProfilePhoto> {
  bool _isLoading = false;

  Future<void> _handleEditPhoto() async {
    // Show a dialog to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pick image
      final File? imageFile = await ref
          .read(editProfilePhotoProvider.notifier)
          .pickImage(source);

      if (imageFile != null) {
        // Upload image
        final success = await ref
            .read(editProfilePhotoProvider.notifier)
            .updateProfilePhoto(imageFile, context);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDeletePhoto() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Profile Photo'),
            content: const Text(
              'Are you sure you want to delete your profile photo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(editProfilePhotoProvider.notifier)
          .deleteProfilePhoto(context);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete profile photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : user != null
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Top bar with close button and title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Profile Photo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 40), // Placeholder for spacing
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                    // Profile image with circular border
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // White background circle
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 120,
                        backgroundImage:
                            user.profilePicture != null &&
                                    user.profilePicture.isNotEmpty
                                ? NetworkImage(user.profilePicture)
                                : AssetImage(
                                      'assets/images/default_profile_photo.png',
                                    )
                                    as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 80),
                    // Bottom bar with icons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: _handleEditPhoto,
                            child: _bottomIcon(Icons.edit, "Edit"),
                          ),
                          GestureDetector(
                            onTap:
                                () => _pickAndUploadImage(ImageSource.gallery),
                            child: _bottomIcon(Icons.add_a_photo, "Add photo"),
                          ),
                          _bottomIcon(FontAwesomeIcons.borderStyle, "Frames"),
                          GestureDetector(
                            onTap: _handleDeletePhoto,
                            child: _bottomIcon(Icons.delete, "Delete"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
    );
  }

  Widget _bottomIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
