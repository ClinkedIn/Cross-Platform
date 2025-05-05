import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/networks/model/connection_model.dart';
import 'package:lockedin/features/networks/model/suggestion_model.dart';
import '../model/company_list_model.dart';
import '../model/message_request_model.dart';
import 'package:lockedin/core/services/request_services.dart';
import '../model/request_list_model.dart';

class RequestListService {
  static const String baseUrl = 'localhost:3000';
  final http.Client _httpClient;

  RequestListService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<RequestList> getRequests() async {
    try {
      final response = await RequestService.get("/user/connections/requests");

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return requestListFromJson(response.body);
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  Future<void> updateRequestStatus(String requestId, String action) async {
    print('Updating request status for ID: $requestId with action: $action');
    try {
      final body = {"action": action};
      // Using PATCH with the specified JSON format
      final response = await RequestService.patch(
        "/user/connections/requests/$requestId",
        body: body,
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update request status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updating request status: $e');
      throw Exception('Error updating request status: $e');
    }
  }
}

class SuggestionService {
  static const String baseUrl = 'localhost:3000';
  final http.Client _httpClient;

  SuggestionService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<SuggestionList> getSuggestions({int limit = 10}) async {
    // API call to get connection suggestions
    try {
      final response = await RequestService.get(
        'user/connections/related-users',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return suggestionListFromJson(response.body);
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  Future<void> sendConnectionRequest(String userId) async {
    try {
      final body = {"targetUserId": userId};
      // Using PATCH with the specified JSON format
      final response = await RequestService.post(
        "/user/connections/request/$userId",
        body: body,
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send connect request status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error sending connect request status: $e');
      throw Exception('Error sending connect request status: $e');
    }
  }
}

class ConnectionListService {
  static const String baseUrl = 'localhost:3000';
  final http.Client _httpClient;

  ConnectionListService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<ConnectionList> getConnections({int page = 1}) async {
    try {
      final response = await RequestService.get("/user/connections");

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return connectionListFromJson(response.body);
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  // Future<ConnectionList> searchConnections(String query, {int page = 1}) async {
  //   try {
  //     final response = await RequestService.get(
  //       "/user/search/search",
  //       queryParams: {
  //         'query': query,
  //         'page': page.toString(),
  //       },
  //     );

  //     print('Search connections status: ${response.statusCode}');
  //     print('Search connections body: ${response.body}');
  //     if (response.statusCode == 200) {
  //       return connectionListFromJson(response.body);
  //     } else {
  //       throw Exception('Failed to search connections: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error searching connections: $e');
  //   }
  // }

  Future<bool> removeConnection(String connectionId) async {
    try {
      final response = await RequestService.delete(
        '/user/connections/$connectionId',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing connection: $e');
      return false;
    }
  }
}

class CompanyService {
  // static const String baseUrl = 'localhost:3000';
  final http.Client _httpClient;

  CompanyService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  // Get companies from API with improved error handling
  Future<CompanyList> getCompanies({int limit = 10}) async {
    try {
      final response = await RequestService.get('/companies');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle empty response case
        if (response.body.isEmpty) {
          return CompanyList(companies: []);
        }

        try {
          // Try to parse the JSON
          final List<dynamic> jsonData = json.decode(response.body);
          return CompanyList.fromJson(jsonData);
        } catch (parseError) {
          print('JSON parsing error: $parseError');
          print('Response body that failed to parse: ${response.body}');
          throw Exception('Error parsing company data: $parseError');
        }
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching companies: $e');
      throw Exception('Error fetching companies: $e');
    }
  }

  // Follow a company with improved error handling
  Future<bool> followCompany(String companyId) async {
    try {
      if (companyId.isEmpty) {
        throw Exception('Company ID cannot be empty');
      }

      final body = {"companyId": companyId};
      final response = await RequestService.post(
        "/companies/$companyId/follow",
        body: body,
      );

      print('Follow company response status: ${response.statusCode}');
      print('Follow company response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error following company: $e');
      throw Exception('Error following company: $e');
    }
  }

  // Unfollow a company with improved error handling
  Future<bool> unfollowCompany(String companyId) async {
    try {
      if (companyId.isEmpty) {
        throw Exception('Company ID cannot be empty');
      }

      final response = await RequestService.delete(
        '/companies/$companyId/follow',
      );

      print('Unfollow company response status: ${response.statusCode}');
      print('Unfollow company response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error unfollowing company: $e');
      return false;
    }
  }

  // Helper method to safely parse JSON
  dynamic _safeParseJson(String text) {
    try {
      return json.decode(text);
    } catch (e) {
      print('Error parsing JSON: $e');
      print('JSON text that failed to parse: $text');
      return null;
    }
  }
}

class MessageRequestService {
  final http.Client _httpClient;

  MessageRequestService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<List<MessageRequest>> fetchMessageRequests() async {
    try {
      final response = await RequestService.get("/user/message-requests");

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Parse and return the messageRequests array
        final MessageRequestList requestList = messageRequestListFromJson(
          response.body,
        );
        return requestList.requests;
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in fetchMessageRequests: $e');
      }
      throw Exception('Error fetching requests: $e');
    }
  }

  Future<bool> sendMessageRequest(
    String recipientUserId,
    String message, {
    String? targetUserId,
  }) async {
    try {
      if (kDebugMode) {
        print('Sending message request to user ID: $recipientUserId');
      }

      // Create the request body with the correct structure
      final Map<String, dynamic> requestBody = {
        "recipientUserId": recipientUserId,
        "message": message,
      };

      // Add targetUserId if provided
      if (targetUserId != null) {
        requestBody["targetUserId"] = targetUserId;
      }

      final response = await RequestService.post(
        "/user/message-requests",
        body: requestBody,
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to send message request: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message request: $e');
      }
      throw Exception('Error sending message request: $e');
    }
  }

  // Update request status - using same action format as your example
  Future<bool> updateRequestStatus(
    String requestId,
    RequestStatus status,
  ) async {
    final String action =
        status == RequestStatus.accepted ? 'accept' : 'decline';

    if (kDebugMode) {
      print('Updating request status for ID: $requestId with action: $action');
    }

    try {
      final body = {"action": action};
      final response = await RequestService.patch(
        "/user/message-requests/$requestId",
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update request status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating request status: $e');
      }
      throw Exception('Error updating request status: $e');
    }
  }
}
