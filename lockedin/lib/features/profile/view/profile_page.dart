import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:lockedin/features/profile/utils/picture_loader.dart';
import 'package:lockedin/features/profile/utils/profile_converters.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/features/profile/widgets/profile_buttons.dart';
import 'package:lockedin/features/profile/widgets/profile_data_component.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(profileViewModelProvider).fetchAllProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: UpperNavbar(
        leftIcon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
        leftOnPress: () {
          context.pop();
        },
      ),
      body: userState.when(
        data:
            (user) => RefreshIndicator(
              onRefresh:
                  () =>
                      ref.read(profileViewModelProvider).fetchAllProfileData(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
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
                              image: getUsercoverImage(userState),
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
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.gray,
                                  size: 20,
                                ),
                                onPressed: () {
                                  context.push('/edit-cover-photo');
                                },
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
                                context.push('/edit-profile-photo');
                              },
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: getUserProfileImage(userState),
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
                                  context.push('/edit-profile');
                                },
                                icon: Icon(Icons.edit, color: AppColors.gray),
                              ),
                            ],
                          ),
                          if (user.headline != null)
                            Text(
                              user.headline!,
                              style: theme.textTheme.bodyLarge,
                            ),
                          Text(
                            user.location ?? "Unknown location",
                            style: theme.textTheme.bodyLarge,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "${user.connectionList.length} connections",
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    ProfileButtons(isPremium: user.isPremium),
                    SizedBox(height: 10),
                    Divider(),

                    // About section with null check
                    if (user.about?.description != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("About", style: theme.textTheme.headlineSmall),
                            SizedBox(height: 5),
                            Text(
                              user.about!.description!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                    if (user.about?.description != null) Divider(),

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

                          // Check if workExperience exists and is not empty
                          if (user.workExperience.isNotEmpty)
                            ListTile(
                              leading: Icon(
                                Icons.question_answer,
                                color: theme.iconTheme.color,
                              ),
                              title: Text(
                                "Are you still working at ${user.workExperience[0].companyName}?",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(),

                    // Only show these components if the providers have data
                    Consumer(
                      builder: (context, ref, _) {
                        final experienceData = ref.watch(experienceProvider);
                        return experienceData.when(
                          data:
                              (data) =>
                                  data.isNotEmpty
                                      ? ProfileDataComponent(
                                        sectionTitle: "Experience",
                                        addRoute: '/add-position',
                                        editRoute: '/edit-experience',
                                        dataProvider: experienceData,
                                        itemConverter:
                                            (item) =>
                                                ProfileConverters.experienceToProfileItem(
                                                  item,
                                                ),
                                      )
                                      : SizedBox.shrink(),
                          loading:
                              () => Center(child: CircularProgressIndicator()),
                          error: (_, __) => SizedBox.shrink(),
                        );
                      },
                    ),

                    Consumer(
                      builder: (context, ref, _) {
                        final educationData = ref.watch(educationProvider);
                        return educationData.when(
                          data:
                              (data) =>
                                  data.isNotEmpty
                                      ? ProfileDataComponent(
                                        sectionTitle: "Education",
                                        addRoute: '/add-education',
                                        editRoute: '/edit-education',
                                        dataProvider: educationData,
                                        itemConverter:
                                            (item) =>
                                                ProfileConverters.educationToProfileItem(
                                                  item,
                                                ),
                                      )
                                      : SizedBox.shrink(),
                          loading:
                              () => Center(child: CircularProgressIndicator()),
                          error: (_, __) => SizedBox.shrink(),
                        );
                      },
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("An error occurred: $error")),
      ),
    );
  }
}
