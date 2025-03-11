import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/widgets/bottom_navbar.dart';
import 'package:lockedin/core/widgets/upper_navbar.dart';
import 'package:lockedin/presentation/pages/edit_profile_photo.dart';
import 'package:lockedin/presentation/pages/home_page.dart';
import 'package:lockedin/presentation/pages/main_page.dart';
import 'package:lockedin/presentation/pages/update_page.dart';
import 'package:lockedin/presentation/shared/profile_buttons.dart';
import 'package:lockedin/presentation/viewmodels/nav_viewmodel.dart';
import 'package:lockedin/presentation/viewmodels/profile_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: UpperNavbar(
        leftIcon: Icon(Icons.arrow_back, color: Colors.grey[700]),
        leftOnPress: () {
          ref.read(navProvider.notifier).changeTab(0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
      ),

      body: profileState.when(
        data:
            (user) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Photo
                  Stack(
                    clipBehavior: Clip.none, // Allows avatar to overflow
                    children: [
                      Stack(
                        clipBehavior: Clip.none, // Allows avatar to overflow
                        children: [
                          // Cover Photo
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(user.coverPicture),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                // Handle edit cover photo action here
                                print("Edit cover photo tapped!");
                              },
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(
                                    0.6,
                                  ), // Semi-transparent background
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Profile Picture (In Front)
                      Positioned(
                        bottom: -40,
                        left: 16,
                        child: Material(
                          elevation: 5, // Adds shadow effect
                          shape: CircleBorder(),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePhoto(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(3), // White border
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                  user.profilePicture,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdatePage(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                        Text(
                          user.headline,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          user.location,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "${user.connections}+ connections",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  ProfileButtons(),
                  SizedBox(height: 10),

                  Divider(),

                  // About Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(user.about, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),

                  Divider(),

                  // Suggested for You Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Suggested for you",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.remove_red_eye,
                            color: Colors.grey,
                          ),
                          title: Text("Private to you"),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.question_answer,
                            color: Colors.grey,
                          ),
                          title: Text("Are you still working at microsoft?"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error loading profile")),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: -1,
        onTap: (index) {
          ref.read(navProvider.notifier).changeTab(index);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
      ),
    );
  }
}
