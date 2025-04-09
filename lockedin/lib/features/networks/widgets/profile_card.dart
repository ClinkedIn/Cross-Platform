import 'package:flutter/material.dart';

class ProfileCard extends StatefulWidget {
  final String name;
  final String headline;
  final String profileImage;
  final String backgroundImage;
  final int followerCount;
  final List<String> mutualConnections;
  final Function(bool) onFollowChanged;

  const ProfileCard({
    super.key,
    required this.name,
    required this.headline,
    required this.profileImage,
    required this.backgroundImage,
    this.followerCount = 0,
    this.mutualConnections = const [],
    required this.onFollowChanged,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Background Image
          Stack(
            clipBehavior: Clip.none, // Allow profile picture to overflow
            children: [
              // Background Image
              Image.network(
                widget.backgroundImage,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                // Add error handling for network images
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  );
                },
              ),
              // Profile Image - positioned to overlap
              Positioned(
                bottom: -24,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(widget.profileImage),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Handle profile image loading error
                    },
                    backgroundColor: Colors.grey[200],
                    child:
                        widget.profileImage.isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                ),
              ),
            ],
          ),

          // Content section with padding for profile image
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Follow Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                        widget.onFollowChanged(_isFollowing);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          _isFollowing ? Colors.white : const Color(0xFF0A66C2),
                        ),
                        side: WidgetStateProperty.all(
                          _isFollowing
                              ? const BorderSide(color: Color(0xFF0A66C2))
                              : BorderSide.none,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        minimumSize: WidgetStateProperty.all(const Size(0, 36)),
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : '+ Follow',
                        style: TextStyle(
                          color:
                              _isFollowing
                                  ? const Color(0xFF0A66C2)
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Headline
                Text(
                  widget.headline,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Follower count
                if (widget.followerCount > 0)
                  Text(
                    '${widget.followerCount.toString()} followers',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                // Mutual connections
                if (widget.mutualConnections.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.mutualConnections.length == 1
                                ? '${widget.mutualConnections[0]} is a mutual connection'
                                : '${widget.mutualConnections.length} mutual connections',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
