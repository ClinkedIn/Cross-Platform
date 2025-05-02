import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/subscription_viewmodel.dart';


class PremiumSubscriptionPage extends StatelessWidget {
  const PremiumSubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Premium Subscription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             // Add this after the premium subtitle and before the features comparison
SizedBox(height: 3.h),

// Plan comparison heading
Text(
  'Choose the right plan for you',
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
  textAlign: TextAlign.center,
),

SizedBox(height: 2.h),

// Plan cards
Row(
  children: [
    Expanded(
      child: _buildPlanCard(
        theme,
        'Free (Basic)',
        [
          '✓ Create a profile',
          '✓ Connect with up to 50 people',
          '✓ Apply to 5 jobs per month',
          '✓ Send 5 messages per day',
        ],
        isHighlighted: false,
      ),
    ),
    SizedBox(width: 3.w),
    Expanded(
      child: _buildPlanCard(
        theme,
        'Premium',
        [
          '✓ All Basic features',
          '✓ Unlimited job applications',
          '✓ Connect with 500+ people',
          '✓ Message unlimited connections',
        ],
        isHighlighted: true,
      ),
    ),
  ],
),

SizedBox(height: 4.h),
              
              // Premium badge/logo
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: 15.w,
                  color: Colors.amber.shade800,
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Premium title
              Text(
                'Unlock Your Full Potential',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 1.h),
              
              // Premium subtitle
              Text(
                'Take your career to the next level with premium features',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 4.h),
              
              // Features comparison
              _buildComparisonTable(theme),
              
              SizedBox(height: 4.h),
              
              // Subscribe button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle subscription logic here
                    _showSubscriptionDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Subscribe Now',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Price information
              Text(
                '\$20.00/month',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Text(
                'Cancel anytime',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray,
                ),
              ),
              
              SizedBox(height: 4.h),
              
              // FAQ Section
              _buildFaqSection(theme),
              
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }
  
// Update the _showSubscriptionDialog method in subscription_view.dart
    // Update the _showSubscriptionDialog method in subscription_view.dart
void _showSubscriptionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => Consumer(
      builder: (dialogContext, ref, child) {
        final subState = ref.watch(subscriptionViewModelProvider);
        
        return AlertDialog(
          title: Text('Confirm Subscription'),
          content: Text(
            'You\'re about to subscribe to our Premium plan for \$19.99/month. Would you like to proceed with the payment?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: subState.isRedirecting
                ? null  // Disable button while redirecting
                : () async {
                    Navigator.of(dialogContext).pop();
                    
                    // Use the new initiateSubscription method instead
                    final message = await ref.read(subscriptionViewModelProvider.notifier)
                      .initiateSubscription(context);
                    
                    // Show SnackBar in the correct context
                    if (message != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message))
                      );
                    }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: subState.isRedirecting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Subscribe'),
            ),
          ],
        );
      }
    ),
  );
}

  Widget _buildComparisonTable(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 6, // Increased flex to give more space for feature names
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Text(
                      'Features',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4, // Adjusted for better space distribution
                  child: Center(
                    child: Text(
                      'Free',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4, // Adjusted for better space distribution
                  child: Center(
                    child: Text(
                      'Premium',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Basic account features
          _buildFeatureRow(
            theme,
            'Profile',
            'Basic info',
            'Full profile',
            isPremiumHighlight: true,
          ),
          
          _buildFeatureRow(
            theme,
            'Connections',
            'Up to 50',
            '500+',
            isPremiumHighlight: true,
          ),
          
          _buildFeatureRow(
            theme,
            'Job Applications',
            '5 per month',
            'Unlimited',
            isPremiumHighlight: true,
          ),
          
          _buildFeatureRow(
            theme,
            'Messaging',
            '5 per day',
            'Unlimited',
            isPremiumHighlight: true,
          ),
          
          _buildFeatureRow(
            theme,
            'Profile Views',
            'Limited Data',
            'Detailed Analytics',
            isPremiumHighlight: true,
          ),
          
          _buildFeatureRow(
            theme,
            'Featured Applications',
            'No',
            'Yes',
            isPremiumHighlight: true,
          ),
          
          _buildFeatureRow(
            theme,
            'Career Insights',
            'Basic',
            'Full Access',
            isPremiumHighlight: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureRow(
    ThemeData theme,
    String feature,
    String freeValue,
    String premiumValue, {
    bool isPremiumHighlight = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: !isLast ? Border(bottom: BorderSide(color: Colors.grey.shade300)) : null,
        borderRadius: isLast
            ? BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 6, // Increased flex to give more space for feature names
            child: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                feature,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis, // Prevent overflow with ellipsis
              ),
            ),
          ),
          Expanded(
            flex: 4, // Adjusted for better space distribution
            child: Center(
              child: Text(
                freeValue,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Prevent overflow with ellipsis
              ),
            ),
          ),
          Expanded(
            flex: 4, // Adjusted for better space distribution
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Keep row compact
                children: [
                  if (isPremiumHighlight)
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 3.w,
                    ),
                  SizedBox(width: 0.5.w), // Reduced spacing
                  Flexible(
                    child: Text(
                      premiumValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isPremiumHighlight ? FontWeight.bold : null,
                        color: isPremiumHighlight ? AppColors.primary : null,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // Prevent overflow with ellipsis
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFaqSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        _buildFaqItem(
          theme,
          'How will I be billed?',
          'You will be billed monthly. The subscription will automatically renew until you cancel.',
        ),
        _buildFaqItem(
          theme,
          'Can I cancel anytime?',
          'Yes, you can cancel your subscription at any time. Your premium benefits will continue until the end of your billing period.',
        ),
        _buildFaqItem(
          theme,
          'What happens to my connections if I cancel?',
          'You will keep all your existing connections, but you won\'t be able to add more beyond the free limit.',
        ),
      ],
    );
  }
  
  Widget _buildFaqItem(ThemeData theme, String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
  

// In your _showSubscriptionDialog method:


  Widget _buildPlanCard(ThemeData theme, String title, List<String> features, {bool isHighlighted = false}) {
  return Container(
    padding: EdgeInsets.all(3.w),
    decoration: BoxDecoration(
      color: isHighlighted ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isHighlighted ? AppColors.primary : Colors.grey.shade300,
        width: isHighlighted ? 2 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppColors.primary : null,
          ),
        ),
        SizedBox(height: 1.h),
        ...features.map((feature) => Padding(
          padding: EdgeInsets.only(bottom: 0.8.h),
          child: Text(
            feature,
            style: TextStyle(fontSize: 12.sp),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        )).toList(),
      ],
    ),
  );
}
}