import 'dart:convert';

ConnectAction connectActionFromJson(String str) => ConnectAction.fromJson(json.decode(str));

String connectActionToJson(ConnectAction data) => json.encode(data.toJson());

class ConnectAction {
    String action;

    ConnectAction({
        required this.action,
    });

    factory ConnectAction.fromJson(Map<String, dynamic> json) => ConnectAction(
        action: json["action"],
    );

    Map<String, dynamic> toJson() => {
        "action": action,
    };
}