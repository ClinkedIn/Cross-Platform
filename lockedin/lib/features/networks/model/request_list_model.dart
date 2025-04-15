import 'dart:convert';

RequestList requestListFromJson(String str) =>
    RequestList.fromJson(json.decode(str));

String requestListToJson(RequestList data) => json.encode(data.toJson());

class RequestList {
  List<Request> requests;

  RequestList({required this.requests});

  factory RequestList.fromJson(Map<String, dynamic> json) => RequestList(
    requests: List<Request>.from(
      json["pendingRequests"].map((x) => Request.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "requests": List<dynamic>.from(requests.map((x) => x.toJson())),
  };

  // Add a convenient getter for length
  int get length => requests.length;
}

class Request {
  String id;
  String firstName;
  String lastName;
  String profilePicture;
  String headline;

  Request({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.headline,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profilePicture: json["profilePicture"],
    headline: json["headline"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "profilePicture": profilePicture,
    "headline": headline,
  };
}
