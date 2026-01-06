// To parse this JSON data, do
//
//     final advancedFeildFiler = advancedFeildFilerFromJson(jsonString);

import 'dart:convert';

AdvancedFeildFiler advancedFeildFilerFromJson(String str) => AdvancedFeildFiler.fromJson(json.decode(str));

String advancedFeildFilerToJson(AdvancedFeildFiler data) => json.encode(data.toJson());

class AdvancedFeildFiler {
    int id;
    String label;
    String type;
    List<dynamic> values;

    AdvancedFeildFiler({
        required this.id,
        required this.label,
        required this.type,
        required this.values,
    });

    factory AdvancedFeildFiler.fromJson(Map<String, dynamic> json) => AdvancedFeildFiler(
        id: json["id"],
        label: json["label"],
        type: json["type"],
        values: List<dynamic>.from(json["values"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "type": type,
        "values": List<dynamic>.from(values.map((x) => x)),
    };
}
