import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lockedin/presentation/viewmodels/profile_viewmodel.dart';

class EditProfilePhoto extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: profileState.when(
        data:
            (user) => SingleChildScrollView(
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
                  const SizedBox(height: 80), // Replaces Spacer()
                  // Profile image with circular border
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // White background circle
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 120,
                      backgroundImage: AssetImage(
                        user.profilePicture,
                      ), // Replace with actual image
                    ),
                  ),
                  const SizedBox(height: 80), // Replaces Spacer()
                  // Bottom bar with icons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _bottomIcon(Icons.remove_red_eye, "View"),
                        _bottomIcon(Icons.edit, "Edit"),
                        _bottomIcon(Icons.add_a_photo, "Add photo"),
                        _bottomIcon(FontAwesomeIcons.borderStyle, "Frames"),
                        _bottomIcon(Icons.delete, "Delete"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => const Center(
              child: Text(
                "Error loading profile",
                style: TextStyle(color: Colors.white),
              ),
            ),
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
