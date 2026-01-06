import 'dart:convert';

NetworkingRole networkingRoleFromJson(String str) => NetworkingRole.fromJson(json.decode(str));

String networkingRoleToJson(NetworkingRole data) => json.encode(data.toJson());

class NetworkingRole {
    String module;
    List<String> action;

    NetworkingRole({
        required this.module,
        required this.action,
    });

    factory NetworkingRole.fromJson(Map<String, dynamic> json) => NetworkingRole(
        module: json["module"],
        action: List<String>.from(json["action"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "module": module,
        "action": List<dynamic>.from(action.map((x) => x)),
    };
}
