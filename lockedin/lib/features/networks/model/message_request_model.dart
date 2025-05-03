import 'dart:convert';

class MessageRequest {
  final String id;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final RequestStatus status;

  // Computed property for full name
  String get senderName => '$firstName $lastName';

  // For backward compatibility with your existing code
  String get senderAvatar => profilePicture;
  String get message =>
      "Wants to connect with you"; // Default message if none provided
  DateTime get timestamp => DateTime.now(); // Default if none provided

  MessageRequest({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    this.status = RequestStatus.pending,
  });

  MessageRequest copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? profilePicture,
    RequestStatus? status,
  }) {
    return MessageRequest(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      status: status ?? this.status,
    );
  }

  // Convert RequestStatus enum to string for API
  String get statusString {
    switch (status) {
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.declined:
        return 'declined';
      case RequestStatus.pending:
      default:
        return 'pending';
    }
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'profilePicture': profilePicture,
    'status': statusString,
  };

  // Create from JSON for API responses
  factory MessageRequest.fromJson(Map<String, dynamic> json) {
    return MessageRequest(
      id: json['_id'] ?? '', // Note: API uses _id instead of id
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      status:
          json['status'] != null
              ? _parseStatus(json['status'])
              : RequestStatus.pending,
    );
  }

  static RequestStatus _parseStatus(String status) {
    switch (status) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'declined':
        return RequestStatus.declined;
      default:
        return RequestStatus.pending;
    }
  }
}

enum RequestStatus { pending, accepted, declined }

class MessageRequestList {
  final List<MessageRequest> requests;
  final Pagination? pagination;

  MessageRequestList({required this.requests, this.pagination});

  factory MessageRequestList.fromJson(Map<String, dynamic> json) {
    // Check if 'messageRequests' key exists and is not null (note the key name!)
    if (!json.containsKey('messageRequests') ||
        json['messageRequests'] == null) {
      return MessageRequestList(requests: []);
    }

    // Make sure we're working with a List before mapping
    var requestsList = json['messageRequests'];
    if (requestsList is! List) {
      return MessageRequestList(requests: []);
    }

    // Parse pagination if available
    Pagination? pagination;
    if (json.containsKey('pagination') && json['pagination'] != null) {
      pagination = Pagination.fromJson(json['pagination']);
    }

    try {
      List<MessageRequest> parsedRequests =
          requestsList
              .map<MessageRequest>((req) => MessageRequest.fromJson(req))
              .toList();

      return MessageRequestList(
        requests: parsedRequests,
        pagination: pagination,
      );
    } catch (e) {
      // If there's any error during parsing, return empty list
      print('Error parsing message requests: $e');
      return MessageRequestList(requests: []);
    }
  }
}

class Pagination {
  final int total;
  final int page;
  final int pages;

  Pagination({required this.total, required this.page, required this.pages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

MessageRequestList messageRequestListFromJson(String str) {
  try {
    // Handle empty string case
    if (str.isEmpty) {
      return MessageRequestList(requests: []);
    }

    final decoded = json.decode(str);

    // Make sure we have a Map to work with
    if (decoded is! Map<String, dynamic>) {
      print('Decoded JSON is not a Map: $decoded');
      return MessageRequestList(requests: []);
    }

    return MessageRequestList.fromJson(decoded);
  } catch (e) {
    print('Error decoding message request JSON: $e');
    return MessageRequestList(requests: []);
  }
}
