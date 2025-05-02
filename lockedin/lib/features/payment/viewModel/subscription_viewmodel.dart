import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/subscription_api.dart';

// Define subscription status enum
enum SubscriptionStatus {
  initial,
  loading,
  subscribed,
  notSubscribed,
  error,
}

// Define subscription state class
class SubscriptionState {
  final bool isRedirecting;
  final String? error;
  final SubscriptionStatus status;

  SubscriptionState({
    this.isRedirecting = false,
    this.error,
    this.status = SubscriptionStatus.initial,
  });

  SubscriptionState copyWith({
    bool? isRedirecting,
    String? error,
    SubscriptionStatus? status,
  }) {
    return SubscriptionState(
      isRedirecting: isRedirecting ?? this.isRedirecting,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}

// Create a provider for the subscription API
final subscriptionApiProvider = Provider<SubscriptionApi>((ref) {
  return SubscriptionApi();
});

// Create a provider for the subscription view model
final subscriptionViewModelProvider = StateNotifierProvider<SubscriptionViewModel, SubscriptionState>((ref) {
  final api = ref.watch(subscriptionApiProvider);
  return SubscriptionViewModel(api);
});

// ViewModel that handles subscription logic
class SubscriptionViewModel extends StateNotifier<SubscriptionState> {
  final SubscriptionApi _subscriptionApi;

  SubscriptionViewModel(this._subscriptionApi) : super(SubscriptionState()) {
    // Check subscription status when initialized
    checkSubscriptionStatus();
  }

  // Method to handle subscription process
  Future<String?> subscribe() async {
    try {
      state = state.copyWith(
        isRedirecting: true, 
        status: SubscriptionStatus.loading
      );
      
      // Call the API to create a checkout session
      final result = await _subscriptionApi.createCheckoutSession();
      
      if (result.success && result.url != null) {
        // Launch the checkout URL
        // Enhanced debugging
        debugPrint('✅ Got checkout URL: ${result.url}');
        debugPrint('🔗 Attempting to launch URL...');
        
        // Launch the checkout URL
        final launched = await _subscriptionApi.launchCheckoutUrl(result.url!);
        
        debugPrint(launched ? '✅ URL launched successfully' : '❌ Failed to launch URL');
        
        if (launched) {
          state = state.copyWith(
            isRedirecting: false
            // Don't set status to subscribed yet - this happens after payment completes
          );
          return 'Redirecting to payment page...';
        } else {
          state = state.copyWith(
            isRedirecting: false,
            status: SubscriptionStatus.error,
            error: 'Could not open payment page'
          );
          return 'Could not open payment page. Please try again.';
        }
      } else if (result.isAlreadySubscribed) {
        state = state.copyWith(
          isRedirecting: false,
          status: SubscriptionStatus.subscribed
        );
        return result.errorMessage ?? 'You already have an active subscription';
      } else {
        state = state.copyWith(
          isRedirecting: false,
          status: SubscriptionStatus.error,
          error: result.errorMessage
        );
        return result.errorMessage ?? 'Failed to create subscription';
      }
    } catch (e) {
      state = state.copyWith(
        isRedirecting: false,
        status: SubscriptionStatus.error,
        error: 'Error: $e',
      );
      
      return 'An error occurred: ${e.toString()}';
    }
  }

  // New method that uses startSubscriptionPaymentSession
  Future<String?> initiateSubscription(BuildContext context) async {
    try {
      state = state.copyWith(
        isRedirecting: true, 
        status: SubscriptionStatus.loading
      );
      
      final result = await _subscriptionApi.startSubscriptionPaymentSession();
      
      if (result.success) {
        state = state.copyWith(isRedirecting: false);
        return 'Redirecting to payment page...';
      } else {
        // Handle various error cases based on result type
        switch (result.resultType) {
          case SubscriptionResultType.alreadySubscribed:
            state = state.copyWith(
              isRedirecting: false,
              status: SubscriptionStatus.subscribed,
            );
            return 'You already have an active subscription';
            
          case SubscriptionResultType.launchError:
            state = state.copyWith(
              isRedirecting: false,
              status: SubscriptionStatus.error,
              error: 'Could not open payment page'
            );
            return 'Could not open payment page. Please try again later.';
            
          default:
            state = state.copyWith(
              isRedirecting: false,
              status: SubscriptionStatus.error,
              error: result.errorMessage
            );
            return result.errorMessage ?? 'Failed to create subscription';
        }
      }
    } catch (e) {
      state = state.copyWith(
        isRedirecting: false,
        status: SubscriptionStatus.error,
        error: 'Error: $e',
      );
      
      return 'An error occurred: ${e.toString()}';
    }
  }
  
  // Check the user's subscription status
  Future<void> checkSubscriptionStatus() async {
    try {
      state = state.copyWith(status: SubscriptionStatus.loading);
      
      final isSubscribed = await _subscriptionApi.checkSubscriptionStatus();
      
      state = state.copyWith(
        status: isSubscribed ? SubscriptionStatus.subscribed : SubscriptionStatus.notSubscribed,
      );
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionStatus.error,
        error: 'Failed to check subscription status: $e',
      );
    }
  }
  
  // Handle when user returns from successful payment
  void handlePaymentSuccess() {
    state = state.copyWith(
      status: SubscriptionStatus.subscribed,
      isRedirecting: false,
    );
  }
  
  // Handle when user cancels payment
  void handlePaymentCancelled() {
    state = state.copyWith(
      status: SubscriptionStatus.notSubscribed,
      isRedirecting: false,
    );
  }
}