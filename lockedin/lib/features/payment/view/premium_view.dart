import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class PremiumView extends ConsumerWidget {
  const PremiumView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider);
    
    return userState.when(
      data: (user) {
        // Safety check - redirect if somehow a non-premium user accesses this
        if (!user.isPremium) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.replace('/subscription');
          });
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Premium Membership',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 3.h),
                  
                  // Premium badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        Icons.workspace_premium,
                        size: 15.w,
                        color: Colors.amber.shade800,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Premium title
                  Text(
                    'You\'re a Premium Member',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  // User info
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Active status card
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 6.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Premium is Active',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                'Next billing: May 31, 2025',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Features section
                  Text(
                    'Your Premium Features',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Features grid
                  GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 2.h,
                    children: [
                      _buildFeatureCard(
                        theme,
                        Icons.visibility,
                        'Profile Insights',
                        'See who viewed your profile and how you rank',
                      ),
                      _buildFeatureCard(
                        theme,
                        Icons.message,
                        'Unlimited Messaging',
                        'Connect with anyone, anytime without restrictions',
                      ),
                      _buildFeatureCard(
                        theme,
                        Icons.people,
                        '500+ Connections',
                        'Expand your network beyond the standard limits',
                      ),
                      _buildFeatureCard(
                        theme,
                        Icons.insert_chart,
                        'Analytics',
                        'Get detailed stats on your content performance',
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Usage stats
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Premium Stats',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('${user.profileViews.length}', 'Profile Views', '+278%'),
                            _buildStatColumn('${user.followers.length}', 'Followers', '+164%'),
                            _buildStatColumn('Unlimited', 'Messages', ''),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Manage subscription button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: OutlinedButton(
                      onPressed: () {
                        _showManageSubscriptionDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Manage Subscription',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error loading user data: $error'),
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard(ThemeData theme, IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 8.w, color: AppColors.primary),
          SizedBox(height: 1.h),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(String value, String label, String growth) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        if (growth.isNotEmpty)
          Text(
            growth,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
  
  void _showManageSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Manage Your Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('View Billing History'),
              onTap: () {
                Navigator.pop(dialogContext);
                // Navigate to billing history
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Get Help'),
              onTap: () {
                Navigator.pop(dialogContext);
                // Navigate to help center
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: Colors.red),
              title: Text('Cancel Subscription'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showCancelConfirmationDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancel Premium?'),
        content: Text(
          'If you cancel, you\'ll still have premium access until the end of your current billing period. After that, your account will revert to the free plan.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Keep Premium'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Call API to cancel subscription
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Your subscription has been canceled'))
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Cancel Premium'),
          ),
        ],
      ),
    );
  }
}