import 'dart:convert';

ConnectionList connectionListFromJson(String str) => ConnectionList.fromJson(json.decode(str));

String connectionListToJson(ConnectionList data) => json.encode(data.toJson());

class ConnectionList {
    List<Connection> connections;
    Pagination pagination;

    ConnectionList({
        required this.connections,
        required this.pagination,
    });

    factory ConnectionList.fromJson(Map<String, dynamic> json) => ConnectionList(
        connections: List<Connection>.from(json["connections"].map((x) => Connection.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "connections": List<dynamic>.from(connections.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
    };
}

class Connection {
    String id;
    String firstName;
    String lastName;
    String profilePicture;
    String lastJobTitle;

    Connection({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.profilePicture,
        required this.lastJobTitle,
    });

    factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json["_id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        profilePicture: json["profilePicture"],
        lastJobTitle: json["lastJobTitle"],
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

    Pagination({
        required this.total,
        required this.page,
        required this.pages,
    });

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
