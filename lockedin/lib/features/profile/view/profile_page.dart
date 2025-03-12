import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/widgets/bottom_navbar.dart';
import 'package:lockedin/features/profile/view/edit_profile_photo.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
import 'package:lockedin/features/profile/view/update_page.dart';
import 'package:lockedin/features/profile/widgets/profile_buttons.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
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
      body: profileState.when(
        data:
            (user) => SingleChildScrollView(
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
                            image: AssetImage(user.coverPicture),
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
                              backgroundImage: AssetImage(user.profilePicture),
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
                              style: theme.textTheme.headlineLarge,
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
                              icon: Icon(Icons.edit, color: AppColors.gray),
                            ),
                          ],
                        ),
                        Text(user.headline, style: theme.textTheme.bodyLarge),
                        Text(user.location, style: theme.textTheme.bodyLarge),
                        SizedBox(height: 10),
                        Text(
                          "${user.connections}+ connections",
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
                        Text(user.about, style: theme.textTheme.bodySmall),
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
                ],
              ),
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Text(
                "Error loading profile",
                style: theme.textTheme.bodyLarge,
              ),
            ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: -1,
        onTap: (index) {
          // ref.read(navProvider.notifier).changeTab(index);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
      ),
    );
  }
}
