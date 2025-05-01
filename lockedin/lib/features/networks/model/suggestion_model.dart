import 'dart:convert';

SuggestionList suggestionListFromJson(String str) =>
    SuggestionList.fromJson(json.decode(str));

String suggestionListToJson(SuggestionList data) => json.encode(data.toJson());

class SuggestionList {
  List<Suggestion> suggestions;

  SuggestionList({required this.suggestions});

  factory SuggestionList.fromJson(Map<String, dynamic> json) => SuggestionList(
    suggestions: List<Suggestion>.from(
      json["relatedUsers"].map((x) => Suggestion.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "suggestions": List<dynamic>.from(suggestions.map((x) => x.toJson())),
  };

  // Add a convenient getter for length
  int get length => suggestions.length;
}

class Suggestion {
  String id;
  String firstName;
  String lastName;
  String profilePicture;
  String coverPhoto;
  String headline;
  int mutualConnections;
  bool isOpenToWork;

  Suggestion({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    this.coverPhoto = 'assets/images/default_cover_photo.jpeg',
    required this.headline,
    this.mutualConnections = 0,
    this.isOpenToWork = false,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profilePicture:
        json["profilePicture"] ?? "assets/images/default_profile_photo.png",
    coverPhoto: json["coverPhoto"] ?? "assets/images/default_cover_photo.jpeg",
    headline: json["lastJobTitle"] ?? "",
    mutualConnections: json["commonConnectionsCount"] ?? 0,
    isOpenToWork: false,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "profilePicture": profilePicture,
    "coverPhoto": coverPhoto,
    "headline": headline,
    "mutualConnections": mutualConnections,
    "isOpenToWork": isOpenToWork,
  };
}
