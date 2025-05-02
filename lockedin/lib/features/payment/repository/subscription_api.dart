import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum for different subscription result types
enum SubscriptionResultType {
  redirected,
  alreadySubscribed,
  launchError,
  sessionCreationError,
  unexpectedError,
}

/// Result class for subscription session operations
class SubscriptionSessionResult {
  final bool success;
  final SubscriptionResultType resultType;
  final String? errorMessage;
  final DateTime? expiryDate;

  SubscriptionSessionResult({
    required this.success,
    required this.resultType,
    this.errorMessage,
    this.expiryDate,
  });
}

class SubscriptionResult {
  final bool success;
  final String? url;
  final String? sessionId;
  final String? errorMessage;
  final bool isAlreadySubscribed;
  final DateTime? expiryDate;

  SubscriptionResult({
    required this.success,
    this.url,
    this.sessionId,
    this.errorMessage,
    this.isAlreadySubscribed = false,
    this.expiryDate,
  });
}

class SubscriptionApi {
  /// Create a checkout session and return the URL to redirect the user to
  Future<SubscriptionResult> createCheckoutSession() async {
    try {
      // Create the checkout session
      final response = await RequestService.post(
        '/stripe/create-checkout-session',
        body: {
          // You can customize these URLs based on your app's routes
          'successUrl': 'http://link-up-mobile/home',
          'cancelUrl': 'http://link-up-mobile/home',
        },
      );

      // Debug info
      debugPrint('Checkout session response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionResult(
          success: true,
          url: data['url'],
          sessionId: data['sessionId'],
        );
      } else if (response.statusCode == 400) {
        // Check if the error is due to an already active subscription
        final data = jsonDecode(response.body);
        if (data['status'] == 'already_subscribed') {
          return SubscriptionResult(
            success: false,
            isAlreadySubscribed: true,
            errorMessage: data['message'],
            expiryDate: data['subscription'] != null && data['subscription']['expiryDate'] != null
                ? DateTime.parse(data['subscription']['expiryDate'])
                : null,
          );
        }
        
        return SubscriptionResult(
          success: false,
          errorMessage: 'Failed to create checkout session: ${response.body}',
        );
      } else {
        return SubscriptionResult(
          success: false,
          errorMessage: 'Failed to create checkout session: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error creating checkout session: $e');
      return SubscriptionResult(
        success: false,
        errorMessage: 'Error: $e',
      );
    }
  }

  /// Launch the Stripe checkout URL with robust fallback options
  Future<bool> launchCheckoutUrl(String url) async {
    try {
      debugPrint('🔗 First attempt: Direct URL launch with external browser');
      final Uri uri = Uri.parse(url);
      
      // First attempt - standard launch
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ First launch attempt failed: $e');
      
      try {
        debugPrint('🔗 Second attempt: Using in-app browser');
        final Uri uri = Uri.parse(url);
        return await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      } catch (secondError) {
        debugPrint('⚠️ Second launch attempt failed: $secondError');
        
        try {
          debugPrint('🔗 Third attempt: Using platform default');
          final Uri uri = Uri.parse(url);
          return await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (thirdError) {
          debugPrint('❌ All launch attempts failed: $thirdError');
          return false;
        }
      }
    }
  }

  /// Check the user's subscription status
  Future<bool> checkSubscriptionStatus() async {
    try {
      final response = await RequestService.get('/subscription/status');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isSubscribed'] ?? false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return false;
    }
  }
  
  /// Start a subscription payment session and handle the result
  Future<SubscriptionSessionResult> startSubscriptionPaymentSession() async {
    try {
      debugPrint('🔄 Starting subscription payment session');
      
      // Create checkout session
      final result = await createCheckoutSession();

      if (result.success && result.url != null) {
        // Try to launch the checkout URL
        final launched = await launchCheckoutUrl(result.url!);
        
        if (!launched) {
          debugPrint('❌ Failed to launch checkout URL');
          return SubscriptionSessionResult(
            success: false,
            errorMessage: 'Could not open payment page',
            resultType: SubscriptionResultType.launchError,
          );
        }
        
        // Successfully launched the URL
        return SubscriptionSessionResult(
          success: true,
          resultType: SubscriptionResultType.redirected,
        );
      } else if (result.isAlreadySubscribed) {
        debugPrint('⚠️ User is already subscribed. Expiry: ${result.expiryDate}');
        return SubscriptionSessionResult(
          success: false,
          resultType: SubscriptionResultType.alreadySubscribed,
          expiryDate: result.expiryDate,
        );
      } else {
        debugPrint('❌ Failed to create subscription session: ${result.errorMessage}');
        return SubscriptionSessionResult(
          success: false,
          errorMessage: result.errorMessage,
          resultType: SubscriptionResultType.sessionCreationError,
        );
      }
    } catch (e) {
      debugPrint('❌ Error redirecting to subscription payment session: $e');
      return SubscriptionSessionResult(
        success: false,
        errorMessage: 'Error: $e',
        resultType: SubscriptionResultType.unexpectedError,
      );
    }
  }
  
  /// Show a dialog with the URL for manual testing
  void showManualUrlDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open Payment URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to automatically open the payment URL on this device. '
              'Please copy and paste the URL in a browser:',
            ),
            SizedBox(height: 12),
            SelectableText(
              url,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('URL copied to clipboard')),
              );
              Navigator.of(context).pop();
            },
            child: Text('Copy URL'),
          ),
        ],
      ),
    );
  }
}