import 'package:flutter/foundation.dart';
import 'package:lockedin/features/networks/model/request_list_model.dart';
import 'package:lockedin/features/networks/repository/network_repository.dart';

enum RequestViewState { initial, loading, loaded, error }

class RequestViewModel extends ChangeNotifier {
  final RequestListService requestService;

  RequestViewState _state = RequestViewState.initial;
  RequestList? _requestList;
  String? _errorMessage;

  RequestViewModel({RequestListService? requestService})
    : requestService = requestService ?? RequestListService();

  // Getters
  RequestViewState get state => _state;
  RequestList? get requestList => _requestList;
  int get requestCount => _requestList?.requests.length ?? 0;
  List<Request> get requests => _requestList?.requests ?? [];
  String? get errorMessage => _errorMessage;

  Future<void> fetchRequests() async {
    _state = RequestViewState.loading;
    notifyListeners();

    try {
      _requestList = await requestService.getRequests();
      _state = RequestViewState.loaded;
    } catch (e) {
      _state = RequestViewState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await requestService.updateRequestStatus(requestId, 'accept');
      // Remove the request from local list after acceptance
      if (_requestList != null) {
        _requestList!.requests.removeWhere(
          (request) => request.id == requestId,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Re-throw to allow the UI to handle it
      throw e;
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await requestService.updateRequestStatus(requestId, 'decline');
      // Remove the request from local list after declining
      if (_requestList != null) {
        _requestList!.requests.removeWhere(
          (request) => request.id == requestId,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Re-throw to allow the UI to handle it
      throw e;
    }
  }
}
