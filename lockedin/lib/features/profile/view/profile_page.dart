import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/state/user_state.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/widgets/bottom_navbar.dart';
import 'package:lockedin/features/profile/view/edit_profile_photo.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
import 'package:lockedin/features/profile/view/update_page.dart';
import 'package:lockedin/features/profile/widgets/profile_buttons.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';
import 'package:lockedin/features/profile/viewmodel/profile_component_viewmodel.dart';
import 'package:lockedin/features/profile/widgets/profile_component.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: UpperNavbar(
        leftIcon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
        leftOnPress: () {
          ref.read(navProvider.notifier).changeTab(0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
      ),
      body:
          user == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(user.coverPicture),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: AppColors.gray,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: 16,
                          child: Material(
                            elevation: 5,
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
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  user.profilePicture,
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
                                "${user.firstName}  ${user.lastName}",
                                style: theme.textTheme.headlineLarge,
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  ref.read(userProvider.notifier).setUser(user);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdatePage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit, color: AppColors.gray),
                              ),
                            ],
                          ),
                          Text(user.bio, style: theme.textTheme.bodyLarge),
                          Text(user.location, style: theme.textTheme.bodyLarge),
                          SizedBox(height: 10),
                          Text(
                            "${user.connectionList.length}+ connections",
                            style: TextStyle(
                              color: AppColors.secondary,
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("About", style: theme.textTheme.headlineSmall),
                          SizedBox(height: 5),
                          Text(user.bio, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Suggested for you",
                            style: theme.textTheme.headlineLarge,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.remove_red_eye,
                              color: theme.iconTheme.color,
                            ),
                            title: Text(
                              "Private to you",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.question_answer,
                              color: theme.iconTheme.color,
                            ),
                            title: Text(
                              "Are you still working at Microsoft?",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    // Profile Component Sections
                    ProfileComponent(
                      sectionTitle: "Experience",
                      items:
                          ref
                              .watch(profileComponentViewModelProvider.notifier)
                              .experienceList,
                      onAdd: () {
                        print("Add button clicked");
                      },
                      onEdit: () {
                        print("Edit button clicked");
                      },
                    ),
                    ProfileComponent(
                      sectionTitle: "Education",
                      items:
                          ref
                              .watch(profileComponentViewModelProvider.notifier)
                              .educationList,
                      onAdd: () {
                        print("Add button clicked");
                      },
                      onEdit: () {
                        print("Edit button clicked");
                      },
                    ),
                    ProfileComponent(
                      sectionTitle: "Licenses & Certifications",
                      items:
                          ref
                              .watch(profileComponentViewModelProvider.notifier)
                              .licenseList,
                      onAdd: () {
                        print("Add button clicked");
                      },
                      onEdit: () {
                        print("Edit button clicked");
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: -1,
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
      ),
    );
  }
}
