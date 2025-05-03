import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/features/home_page/viewModel/home_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';

final postLikesProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, postId) => ref.read(homeViewModelProvider.notifier).getPostLikes(postId),
);
class PostLikesPage extends ConsumerWidget {
  final String postId;

  const PostLikesPage({required this.postId, Key? key}) : super(key: key);

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final likesAsync = ref.watch(postLikesProvider(postId));
  
  return Scaffold(
    appBar: AppBar(
      title: Text('People who liked this'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    ),
    body: likesAsync.when(
      data: (data) {
        // Extract impressions from the response
        final impressions = List<Map<String, dynamic>>.from(data['impressions'] ?? []);
        final counts = data['counts'] as Map<String, dynamic>? ?? {};
        
        if (impressions.isEmpty) {
          return Center(
            child: Text(
              'No likes yet',
              style: TextStyle(
                color: AppColors.gray,
                fontSize: 16.sp,
              ),
            ),
          );
        }
        
        return ListView.builder(
          itemCount: impressions.length,
          itemBuilder: (context, index) {
            final user = impressions[index];
            
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user['profilePicture'] != null && user['profilePicture'].toString().isNotEmpty
                    ? NetworkImage(user['profilePicture'])
                    : null,
                radius: 3.h,
                child: user['profilePicture'] == null || user['profilePicture'].toString().isEmpty
                    ? Icon(Icons.person, size: 3.h)
                    : null,
              ),
              title: Text(
                '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              subtitle: user['headline'] != null && user['headline'].toString().isNotEmpty
                  ? Text(
                      user['headline'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () {
                if (user['userId'] != null) {
                  context.push('/other-profile/${user['userId']}');
                }
              },
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading likes: $error',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
}