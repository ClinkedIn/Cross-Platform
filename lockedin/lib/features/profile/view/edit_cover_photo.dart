import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:lockedin/features/profile/utils/picture_loader.dart';
import 'package:lockedin/features/profile/viewmodel/edit_cover_photo_viewmodel.dart';
import 'package:lockedin/features/profile/viewmodel/edit_profile_photo_viewmodel.dart';

class EditCoverPhoto extends ConsumerStatefulWidget {
  const EditCoverPhoto({Key? key}) : super(key: key);

  @override
  ConsumerState<EditCoverPhoto> createState() => _EditCoverPhotoState();
}

class _EditCoverPhotoState extends ConsumerState<EditCoverPhoto> {
  bool _isLoading = false;

  Future<void> _handleEditPhoto() async {
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
      final File? imageFile = await ref
          .read(editProfilePhotoProvider.notifier)
          .pickImage(source);

      if (imageFile != null) {
        final success = await ref
            .read(editCoverPhotoProvider.notifier)
            .updateCoverPhoto(imageFile, context); // <-- Update cover photo

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover photo updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cover photo: $e')),
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
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Cover Photo'),
            content: const Text(
              'Are you sure you want to delete your cover photo?',
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
          .read(editCoverPhotoProvider.notifier)
          .deleteCoverPhoto(context); // <-- Delete cover photo

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cover photo deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete cover photo: $e')),
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
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : user != null
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
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
                            "Cover Photo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          image: DecorationImage(
                            image: getUsercoverImage(user),
                            fit: BoxFit.cover,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                            child: _bottomIcon(Icons.add_a_photo, "Add"),
                          ),
                          _bottomIcon(Icons.crop, "Crop"),
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
