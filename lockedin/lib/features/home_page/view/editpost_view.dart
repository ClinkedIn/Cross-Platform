import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/viewModel/home_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';
import '../model/taggeduser_model.dart';
import '../repository/posts/comment_api.dart';
import '../viewModel/comment_viewmodel.dart';
import 'dart:async';

class EditPostPage extends ConsumerStatefulWidget {
  final PostModel post;
  
  const EditPostPage({required this.post, Key? key}) : super(key: key);

  @override
  ConsumerState<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends ConsumerState<EditPostPage> {
  late TextEditingController _contentController;
  bool _isSubmitting = false;
  // Add these variables for tagging functionality
  List<TaggedUser> _taggedUsers = [];
  List<TaggedUser> _userSearchResults = [];
  bool _showMentionSuggestions = false;
  String _mentionQuery = '';
  int _mentionStartIndex = -1;
  bool _isSearchingUsers = false;
  Timer? _debounce;
  late final CommentsApi _commentsApi;
  
  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _taggedUsers = List.from(widget.post.taggedUsers);
    _commentsApi = ref.read(commentsApiProvider);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _debounce?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _isSubmitting
              ? Padding(
                  padding: EdgeInsets.all(2.w),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 0.5.w,
                  ),
                )
              : FilledButton(
                  onPressed: _contentController.text.isNotEmpty
                      ? _updatePost
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _contentController.text.isNotEmpty
                        ? AppColors.primary
                        : AppColors.gray.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 6.w,
                    backgroundImage: NetworkImage(widget.post.profileImageUrl),
                    onBackgroundImageError: (_, __) {},
                    child: widget.post.profileImageUrl.isEmpty
                        ? Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        // Show whether this is a company or personal post
                        Text(
                          widget.post.companyId != null
                              ? 'Company Post'
                              : 'Personal Post',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 4.h),

              // Tagged users chips - add this section
              if (_taggedUsers.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Wrap(
                    spacing: 1.w,
                    runSpacing: 0.5.h,
                    children: _taggedUsers.map((user) {
                      return Chip(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        avatar: CircleAvatar(
                          backgroundImage: user.profilePicture != null && 
                                        user.profilePicture!.isNotEmpty
                              ? NetworkImage(user.profilePicture!)
                              : null,
                          child: (user.profilePicture == null || 
                                user.profilePicture!.isEmpty)
                              ? Icon(Icons.person, size: 1.5.h)
                              : null,
                        ),
                        label: Text(
                          '${user.firstName} ${user.lastName}',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        deleteIcon: Icon(Icons.close, size: 1.5.h),
                        onDeleted: () => _removeTaggedUser(user.userId),
                      );
                    }).toList(),
                  ),
                ),
              
              // Post content text field with mention suggestions
              Stack(
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'What do you want to talk about?',
                      hintStyle: TextStyle(color: AppColors.gray, fontSize: 16.sp),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 16.sp, height: 1.4),
                    onChanged: (text) {
                      setState(() {}); // Update state for the Save button
                      _checkForMentions(text); // Check for @ mentions
                    },
                  ),
                  
                  // User mention suggestions overlay
                  if (_showMentionSuggestions && _userSearchResults.isNotEmpty)
                    Positioned(
                      top: 40, // Adjust based on your layout
                      left: 0,
                      right: 0,
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 30.h),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isSearchingUsers
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _userSearchResults.length,
                              itemBuilder: (context, index) {
                                final user = _userSearchResults[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2.h,
                                    vertical: 0.5.h,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: user.profilePicture != null && 
                                                  user.profilePicture!.isNotEmpty
                                        ? NetworkImage(user.profilePicture!)
                                        : null,
                                    child: (user.profilePicture == null || 
                                          user.profilePicture!.isEmpty)
                                        ? Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: user.headline != null && user.headline!.isNotEmpty
                                      ? Text(
                                          user.headline!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  onTap: () => _onMentionSelected(user),
                                );
                              },
                            ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 2.h),
              
              // Show existing attachment if any (read-only)
              if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: Colors.yellow[700]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.yellow[800],
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Attachments cannot be edited. To change attachments, delete this post and create a new one.',
                          style: TextStyle(
                            color: Colors.yellow[900],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Show the current attachment (read-only)
                Container(
                  width: double.infinity,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: AppColors.gray.withOpacity(0.3)),
                    image: DecorationImage(
                      image: NetworkImage(widget.post.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updatePost() async {
    if (_contentController.text.isEmpty) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final success = await ref.read(homeViewModelProvider.notifier).editPost(
        widget.post.id,
        _contentController.text,
        taggedUsers: _taggedUsers,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated successfully')),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Check if text contains @ symbol and extract query
  void _checkForMentions(String text) {
    final selection = _contentController.selection;
    
    // If there's a text selection, don't show mentions
    if (selection.baseOffset != selection.extentOffset) {
      setState(() => _showMentionSuggestions = false);
      return;
    }
    
    final currentPosition = selection.baseOffset;
    
    // Find the last @ before the cursor
    int lastAtIndex = -1;
    for (int i = currentPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        lastAtIndex = i;
        break;
      } else if (text[i] == ' ' || text[i] == '\n') {
        // Stop at spaces or newlines
        break;
      }
    }
    
    if (lastAtIndex >= 0) {
      // Extract query text between @ and cursor
      final query = text.substring(lastAtIndex + 1, currentPosition);
      
      if (query.isNotEmpty) {
        setState(() {
          _mentionStartIndex = lastAtIndex;
          _mentionQuery = query;
          _showMentionSuggestions = true;
        });
        
        // Debounce search to avoid too many API calls
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          _searchUsers(query);
        });
        return;
      }
    }
    
    setState(() => _showMentionSuggestions = false);
  }

  // Search for users to tag
  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() {
        _userSearchResults = [];
        _isSearchingUsers = false;
      });
      return;
    }
    
    setState(() => _isSearchingUsers = true);
    
    try {
      // Using the existing PostApi
      final results = await _commentsApi.searchUsers(query);
      
      setState(() {
        _userSearchResults = results;
        _isSearchingUsers = false;
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
      setState(() {
        _userSearchResults = [];
        _isSearchingUsers = false;
      });
    }
  }

  // Handle when a user is selected from suggestions
  void _onMentionSelected(TaggedUser user) {
    final text = _contentController.text;
    final mentionText = "${user.firstName} ${user.lastName}";
    
    // Replace the @query with the selected username
    final newText = text.replaceRange(
      _mentionStartIndex, 
      _contentController.selection.baseOffset, 
      "@$mentionText "
    );
    
    // Add the user to tagged users list if not already there
    if (!_taggedUsers.any((u) => u.userId == user.userId)) {
      setState(() {
        _taggedUsers.add(user);
      });
    }
    
    // Update the text and cursor position
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: _mentionStartIndex + mentionText.length + 2, // +2 for @ and space
      ),
    );
    
    setState(() => _showMentionSuggestions = false);
  }

  // Remove a tagged user
  void _removeTaggedUser(String userId) {
    setState(() {
      _taggedUsers.removeWhere((user) => user.userId == userId);
    });
  }
}