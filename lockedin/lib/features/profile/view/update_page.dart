import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/view/profile_page.dart';
import 'package:lockedin/shared/widgets/bottom_navbar.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/shared/widgets/custom_appbar.dart';

class UpdatePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppbar(leftIcon: Icon(Icons.close), leftOnPress: () {
              ref.read(navProvider.notifier).changeTab(0);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      PersonalInfo(),
                      ProfessionalInfo(),
                      ConnectionInfo(),
                    ],
                  ),
                ],
              ),
            ),
            Divider(thickness: 1, indent: 0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A66C2),
                minimumSize: Size(400, 20),
              ),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          ],
        ),
      ),
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

class PersonalInfo extends StatelessWidget {
  const PersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        TextField(
          maxLength: 50,
          decoration: InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          maxLength: 50,
          decoration: InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(),
          ),
        ),
        TextField(
          maxLength: 50,
          decoration: InputDecoration(
            labelText: 'Additional Name',
            border: OutlineInputBorder(),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.remove_red_eye, color: Color(0xFF0A66C2)),
          label: Text('All LockedIn Members'),
        ),
        SizedBox(height: 10),
        Text('Name pronunciation', style: TextStyle(fontSize: 16)),
        TextButton.icon(
          onPressed: () {},
          label: Text(
            'Add name pronunciation',
            style: TextStyle(color: Color(0xFF0A66C2)),
          ),
          icon: Icon(Icons.add, color: Color(0xFF0A66C2)),
        ),
        SizedBox(height: 10),
        TextField(
          maxLength: 220,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            label: Text('Headline'),
          ),
        ),
      ],
    );
  }
}

class ConnectionInfo extends StatelessWidget {
  const ConnectionInfo({super.key});

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
