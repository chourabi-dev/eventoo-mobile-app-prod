// To parse this JSON data, do
//
//     final contact = contactFromJson(jsonString);

import 'dart:convert';

Contact contactFromJson(String str) => Contact.fromJson(json.decode(str));

String contactToJson(Contact data) => json.encode(data.toJson());

class Contact {
    int id;
    int participantId;
    String note;
    dynamic scannedAt;
    String fullname;
    String email;
    String phone;
    String avatarUrl;
    String eventName;

    Contact({
        required this.id,
        required this.participantId,
        required this.note,
        required this.scannedAt,
        required this.fullname,
        required this.email,
        required this.phone,
        required this.avatarUrl,
        required this.eventName,
    });

    factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json["id"],
        participantId: json["participant_id"],
        note: json["note"],
        scannedAt: json["scannedAt"],
        fullname: json["fullname"],
        email: json["email"],
        phone: json["phone"],
        avatarUrl: json["avatarUrl"],
        eventName: json["eventName"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "participant_id": participantId,
        "note": note,
        "scannedAt": scannedAt,
        "fullname": fullname,
        "email": email,
        "phone": phone,
        "avatarUrl": avatarUrl,
        "eventName": eventName,
    };
}
