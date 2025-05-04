import 'dart:convert';

ConnectionList connectionListFromJson(String str) =>
    ConnectionList.fromJson(json.decode(str));

String connectionListToJson(ConnectionList data) => json.encode(data.toJson());

class ConnectionList {
  List<ConnectionModel> connections;
  Pagination pagination;

  ConnectionList({required this.connections, required this.pagination});

  factory ConnectionList.fromJson(Map<String, dynamic> json) => ConnectionList(
    connections: List<ConnectionModel>.from(
      json["connections"].map((x) => ConnectionModel.fromJson(x)),
    ),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "connections": List<dynamic>.from(connections.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class ConnectionModel {
  String id;
  String firstName;
  String lastName;
  String profilePicture;
  String lastJobTitle;

  ConnectionModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.lastJobTitle,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) =>
      ConnectionModel(
        id: json["_id"] ?? '',
        firstName: json["firstName"] ?? '',
        lastName: json["lastName"] ?? '',
        profilePicture: json["profilePicture"] ?? '',
        lastJobTitle: json["lastJobTitle"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "profilePicture": profilePicture,
    "lastJobTitle": lastJobTitle,
  };
}

class Pagination {
  int total;
  int page;
  int pages;

  Pagination({required this.total, required this.page, required this.pages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    page: json["page"],
    pages: json["pages"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "pages": pages,
  };
}

enum SortOption { nameAsc, nameDesc, jobTitleAsc, jobTitleDesc }

class ConnectionFilter {
  SortOption sortOption;
  String? jobTitleFilter;

  ConnectionFilter({this.sortOption = SortOption.nameAsc, this.jobTitleFilter});
}
