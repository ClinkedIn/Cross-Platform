import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/view/profile_page.dart';
import 'package:lockedin/features/profile/viewmodel/update_profile_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/widgets/bottom_navbar.dart';

class UpdatePage extends ConsumerStatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends ConsumerState<UpdatePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController additionalNameController;
  late TextEditingController headlineController;
  late TextEditingController linkController;

  @override
  void initState() {
    super.initState();

    final userState = ref.read(userProvider);

    if (userState is AsyncData<UserModel>) {
      final user = userState.value;
      firstNameController = TextEditingController(text: user.firstName);
      lastNameController = TextEditingController(text: user.lastName);
      additionalNameController = TextEditingController(
        text: user.additionalName ?? '',
      );
      headlineController = TextEditingController(text: user.headline ?? '');
      linkController = TextEditingController(
        text: user.contactInfo?.website?.url ?? '',
      );
    } else {
      firstNameController = TextEditingController();
      lastNameController = TextEditingController();
      additionalNameController = TextEditingController();
      headlineController = TextEditingController();
      linkController = TextEditingController();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    additionalNameController.dispose();
    headlineController.dispose();
    linkController.dispose();
    // Reset the update state when leaving the page
    ref.read(updateProfileProvider.notifier).resetState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the update state
    final updateState = ref.watch(updateProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "update profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Show success message if update was successful
                if (updateState.isSuccess)
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Profile updated successfully!',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Show error message if there was an error
                if (updateState.errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            updateState.errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      PersonalInfo(
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        additionalNameController: additionalNameController,
                        headlineController: headlineController,
                      ),
                      const SizedBox(height: 20),
                      const ProfessionalInfo(),
                      const SizedBox(height: 20),
                      const ConnectionInfo(),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                ElevatedButton(
                  onPressed:
                      updateState.isLoading
                          ? null // Disable button when loading
                          : () async {
                            // Gather form data
                            Map<String, String> userInput = {
                              "firstName": firstNameController.text,
                              "lastName": lastNameController.text,
                              "additionalName": additionalNameController.text,
                              "headline": headlineController.text,
                              "link": linkController.text,
                            };

                            print("Submitting profile update: $userInput");

                            // Call the update method through the ViewModel
                            final success = await ref
                                .read(updateProfileProvider.notifier)
                                .updateProfile(userInput);

                            if (success && mounted) {
                              // Show success and navigate back after a short delay
                              Future.delayed(Duration(seconds: 2), () {
                                if (mounted) {
                                  ref.read(navProvider.notifier).changeTab(0);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(),
                                    ),
                                  );
                                }
                              });
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    minimumSize: const Size(400, 20),
                  ),
                  child:
                      updateState.isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                ),
              ],
            ),
          ),

          // Overlay loading indicator
          if (updateState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class PersonalInfo extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController additionalNameController;
  final TextEditingController headlineController;

  const PersonalInfo({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.additionalNameController,
    required this.headlineController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: firstNameController,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: lastNameController,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: additionalNameController,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: 'Additional Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.remove_red_eye, color: Color(0xFF0A66C2)),
          label: const Text('All LockedIn Members'),
        ),
        const SizedBox(height: 10),
        const Text('Name pronunciation', style: TextStyle(fontSize: 16)),
        TextButton.icon(
          onPressed: () {},
          label: const Text(
            'Add name pronunciation',
            style: TextStyle(color: Color(0xFF0A66C2)),
          ),
          icon: const Icon(Icons.add, color: Color(0xFF0A66C2)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: headlineController,
          maxLength: 220,
          maxLines: null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            label: Text('Headline'),
          ),
        ),
      ],
    );
  }
}

class ProfessionalInfo extends StatelessWidget {
  const ProfessionalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          'Current position',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        TextButton.icon(
          onPressed: () {},
          label: Text(
            'Add new position',
            style: TextStyle(fontSize: 16, color: Color(0xFF0A66C2)),
          ),
          icon: Icon(Icons.add, color: Color(0xFF0A66C2)),
        ),
        DropdownMenu(
          width: 380,
          enableFilter: true,
          enableSearch: true,
          menuHeight: 200,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 1, label: 'Test1'),
            DropdownMenuEntry(value: 2, label: 'Test2'),
            DropdownMenuEntry(value: 3, label: 'Test3'),
            DropdownMenuEntry(value: 4, label: 'Test4'),
          ],
          label: Text('Industry'),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Learn more about ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'industry options',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A66C2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 35),
        Text(
          'Education',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        DropdownMenu(
          width: 380,
          enableFilter: true,
          enableSearch: true,
          menuHeight: 200,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 1, label: 'Test1'),
            DropdownMenuEntry(value: 2, label: 'Test2'),
            DropdownMenuEntry(value: 3, label: 'Test3'),
            DropdownMenuEntry(value: 4, label: 'Test4'),
          ],
          label: Text('School'),
        ),
        TextButton.icon(
          onPressed: () {},
          label: Text(
            'Add new education',
            style: TextStyle(fontSize: 16, color: Color(0xFF0A66C2)),
          ),
          icon: Icon(Icons.add, color: Color(0xFF0A66C2)),
        ),
      ],
    );
  }
}

class ConnectionInfo extends StatefulWidget {
  const ConnectionInfo({super.key});

  @override
  State<ConnectionInfo> createState() => _ConnectionInfoState();
}

class _ConnectionInfoState extends State<ConnectionInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(
          'Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        DropdownMenu(
          width: 380,
          enableFilter: true,
          enableSearch: true,
          menuHeight: 200,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 1, label: 'Test1'),
            DropdownMenuEntry(value: 2, label: 'Test2'),
            DropdownMenuEntry(value: 3, label: 'Test3'),
            DropdownMenuEntry(value: 4, label: 'Test4'),
          ],
          label: Text('Country/Region'),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Use current location',
            style: TextStyle(fontSize: 16, color: Color(0xFF0A66C2)),
          ),
        ),
        DropdownMenu(
          width: 380,
          enableFilter: true,
          enableSearch: true,
          menuHeight: 200,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 1, label: 'Test1'),
            DropdownMenuEntry(value: 2, label: 'Test2'),
            DropdownMenuEntry(value: 3, label: 'Test3'),
            DropdownMenuEntry(value: 4, label: 'Test4'),
          ],
          label: Text('City'),
        ),
        SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact info',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              'Add or edit your profile URL, email and more',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Edit contact info',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF0A66C2),
                ),
              ),
            ),
            Text(
              'Website',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              'Add a link that will appear at the top of your profile',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            TextField(
              maxLength: 262,
              decoration: InputDecoration(
                label: Text('Link'),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
