import 'package:flutter/material.dart';
import '../model/message_request_model.dart';
import '../repository/network_repository.dart';

class MessageRequestViewModel extends ChangeNotifier {
  // Create service instance directly
  final MessageRequestService _service = MessageRequestService();

  List<MessageRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<MessageRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get pending requests only
  List<MessageRequest> get pendingRequests =>
      _requests.where((req) => req.status == RequestStatus.pending).toList();

  // Get processed (accepted or declined) requests
  List<MessageRequest> get processedRequests =>
      _requests.where((req) => req.status != RequestStatus.pending).toList();

  // Load message requests
  Future<void> loadMessageRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final requests = await _service.fetchMessageRequests();
      _requests = requests;
    } catch (e) {
      _error = 'Failed to load message requests: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept a request
  Future<void> acceptRequest(String requestId) async {
    await _updateRequestStatus(requestId, RequestStatus.accepted);
  }

  // Decline a request
  Future<void> declineRequest(String requestId) async {
    await _updateRequestStatus(requestId, RequestStatus.declined);
  }

  // Updated method to match the new service method signature
  Future<void> sendRequest(
    String recipientUserId,
    String message, {
    String? targetUserId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.sendMessageRequest(
        recipientUserId,
        message,
        targetUserId: targetUserId,
      );
      if (success) {
        // Optionally refresh the list after sending
        await loadMessageRequests();
      }
    } catch (e) {
      _error = 'Failed to send message request: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to update request status
  Future<void> _updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    // Set loading state for this specific request
    final index = _requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      // We could add a "processing" flag to the model if needed
      notifyListeners();
    }

    try {
      final success = await _service.updateRequestStatus(requestId, status);

      if (success) {
        // Update local state
        if (index != -1) {
          _requests[index] = _requests[index].copyWith(status: status);
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to update request: $e';
      notifyListeners();

      // Show error using a snackbar or other UI notification
      // This would be better handled via a callback or a separate error handling service
    }
  }
}
