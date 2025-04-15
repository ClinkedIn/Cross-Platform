import 'dart:convert';

ConnectionList connectionListFromJson(String str) => ConnectionList.fromJson(json.decode(str));

String connectionListToJson(ConnectionList data) => json.encode(data.toJson());

class ConnectionList {
    List<Request> requests;

    ConnectionList({
        required this.requests,
    });

    factory ConnectionList.fromJson(Map<String, dynamic> json) => ConnectionList(
        requests: List<Request>.from(json["requests"].map((x) => Request.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "requests": List<dynamic>.from(requests.map((x) => x.toJson())),
    };
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
        headline: json["headline"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "profilePicture": profilePicture,
        "headline": headline,
    };
}
