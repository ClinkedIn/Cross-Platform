import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/state/user_state.dart';

class SidebarDrawer extends ConsumerWidget {
  const SidebarDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider);

    return Drawer(
      backgroundColor: Color(0xFF1D1E20), // Dark background
      child: Column(
        children: [
          SizedBox(height: 60), // Top padding to avoid notch
          /// Profile Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push("/profile"),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        currentUser != null
                            ? NetworkImage(currentUser.profilePicture)
                            : AssetImage(
                                  'assets/images/default_profile_photo.png',
                                )
                                as ImageProvider,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentUser != null
                        ? "${currentUser.firstName} ${currentUser.lastName}"
                        : "Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Bio and location
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser?.bio ??
                      "Senior 1 Biomedical and healthcare Data Engineering Student @ Cairo University",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 3,
                ),
                SizedBox(height: 4),
                Text(
                  currentUser?.location ?? "Cairo, Cairo, Egypt",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          /// Career Center
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/aman_logo.jpg',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8),
                Text(
                  currentUser?.lastJobTitle ?? "Career Center",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),
          Divider(color: Colors.grey.shade700),

          /// View counts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildStatRow("27", "profile viewers"),
                SizedBox(height: 8),
                _buildStatRow("3", "post impressions"),
              ],
            ),
          ),

          SizedBox(height: 12),
          Divider(color: Colors.grey.shade700),

          /// Menu Items
          _buildMenuItem("Puzzle games"),
          _buildMenuItem("Saved posts"),
          _buildMenuItem("Groups"),

          SizedBox(height: 12),
          Divider(color: Colors.grey.shade700),

          /// Premium Promo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF8B5700), // Golden brown
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "4x",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Premium members get 4x more profile views on average.",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "🔶 Try Premium for EGP0",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          Spacer(),

          /// Settings
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text(
              "Settings",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            onTap: () {},
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatRow(String number, String label) {
    return Row(
      children: [
        Text(number, style: TextStyle(color: Colors.blue, fontSize: 14)),
        SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildMenuItem(String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: () {},
    );
  }
}
