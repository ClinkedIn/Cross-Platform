import 'package:flutter/material.dart';
import '../model/company_list_model.dart';

class CompanyProfileCard extends StatefulWidget {
  final Company company;
  final String userRelationship;
  final Function(bool) onFollowChanged;

  const CompanyProfileCard({
    super.key,
    required this.company,
    required this.userRelationship,
    required this.onFollowChanged,
  });

  @override
  State<CompanyProfileCard> createState() => _CompanyProfileCardState();
}

class _CompanyProfileCardState extends State<CompanyProfileCard> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    // Initialize following state based on the relationship
    _isFollowing = widget.userRelationship == "follower";
  }

  @override
  void didUpdateWidget(CompanyProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state if the relationship changes
    if (oldWidget.userRelationship != widget.userRelationship) {
      setState(() {
        _isFollowing = widget.userRelationship == "follower";
      });
    }
  }

  // Show confirmation dialog when unfollowing
  void _showUnfollowConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unfollow ${widget.company.name}?'),
          content: Text(
            'You will no longer receive updates from ${widget.company.name}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _isFollowing = false;
                });
                widget.onFollowChanged(false); // Call the callback with false
              },
              child: const Text(
                'Unfollow',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  // Handle follow button press
  void _handleFollowPress() {
    if (_isFollowing) {
      // If already following, show confirmation dialog
      _showUnfollowConfirmation();
    } else {
      // If not following, follow immediately
      setState(() {
        _isFollowing = true;
      });
      widget.onFollowChanged(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a placeholder background if none is provided
    final theme = Theme.of(context);
    final backgroundImage = 'default_cover_photo.jpeg';

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
              // Background Image - using a placeholder
              Image.network(
                backgroundImage,
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
              // Company Logo - positioned to overlap
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
                    backgroundImage: NetworkImage(widget.company.logo),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Handle profile image loading error
                    },
                    backgroundColor: Colors.grey[200],
                    child:
                        widget.company.logo.isEmpty
                            ? const Icon(
                              Icons.business,
                              size: 36,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                ),
              ),
            ],
          ),

          // Content section with padding for company logo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Name and Follow Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.company.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _handleFollowPress,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          _isFollowing
                              ? theme.scaffoldBackgroundColor
                              : const Color(0xFF0A66C2),
                        ),
                        side: MaterialStateProperty.all(
                          _isFollowing
                              ? const BorderSide(color: Color(0xFF0A66C2))
                              : BorderSide.none,
                        ),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        minimumSize: MaterialStateProperty.all(
                          const Size(0, 36),
                        ),
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

                // Tagline as headline
                Text(
                  widget.company.tagLine,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Company details
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.company.location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Industry and org size
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.company.industry} · ${widget.company.organizationSize}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Follower count
                if (widget.company.followersCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.company.followersCount.toString()} followers',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
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
