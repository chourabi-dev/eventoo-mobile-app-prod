// To parse this JSON data, do
//
//     final networkingInvitationDataModel = networkingInvitationDataModelFromJson(jsonString);

import 'dart:convert';

NetworkingInvitationDataModel networkingInvitationDataModelFromJson(String str) => NetworkingInvitationDataModel.fromJson(json.decode(str));

String networkingInvitationDataModelToJson(NetworkingInvitationDataModel data) => json.encode(data.toJson());

class NetworkingInvitationDataModel {
    int id;
    int senderId;
    int receiverId;
    int eventId;
    DateTime createdAt;
    int locationId;
    int status;
    int associatedDateId;
    String time;

    NetworkingInvitationDataModel({
        required this.id,
        required this.senderId,
        required this.receiverId,
        required this.eventId,
        required this.createdAt,
        required this.locationId,
        required this.status,
        required this.associatedDateId,
        required this.time,
    });

    factory NetworkingInvitationDataModel.fromJson(Map<String, dynamic> json) => NetworkingInvitationDataModel(
        id: json["id"],
        senderId: json["sender_id"],
        receiverId: json["receiver_id"],
        eventId: json["event_id"],
        createdAt: DateTime.parse(json["created_at"]),
        locationId: json["location_id"],
        status: json["status"],
        associatedDateId: json["associated_date_id"],
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "event_id": eventId,
        "created_at": createdAt.toIso8601String(),
        "location_id": locationId,
        "status": status,
        "associated_date_id": associatedDateId,
        "time": time,
    };
}
