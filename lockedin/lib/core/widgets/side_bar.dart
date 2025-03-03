import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/presentation/pages/profile_page.dart';
import 'package:lockedin/presentation/viewmodels/profile_viewmodel.dart';

class SidebarDrawer extends ConsumerWidget {
  SidebarDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(profileViewModelProvider);
    final currentUser = currentUserAsync.asData?.value;
    return Drawer(
      backgroundColor: Colors.black, // Dark background like LinkedIn
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle tap action here, e.g., navigate to the profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        currentUser != null
                            ? AssetImage(currentUser.profilePicture)
                            : AssetImage('assets/images/default_profile.png'),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Omar Refaat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Backend Intern @ Lab Digital Systems",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              "Profile viewers",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              "Post impressions",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          Divider(color: Colors.grey),
          ListTile(
            title: Text("Puzzle games", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            title: Text("Saved posts", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            title: Text("Groups", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.star, color: Colors.amber),
            title: Text(
              "Try Premium for EGP0",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text("Settings", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
