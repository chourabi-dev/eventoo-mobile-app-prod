// To parse this JSON data, do
//
//     final discussion = discussionFromJson(jsonString);

import 'dart:convert';

Discussion discussionFromJson(String str) => Discussion.fromJson(json.decode(str));

String discussionToJson(Discussion data) => json.encode(data.toJson());

class Discussion {
    int lastMessageId;
    String message;
    String type;
    dynamic audioAssetUrl;
    DateTime messageDate;
    int userId;
    String firstname;
    String lastname;
    String photoUrl;
    int unreadCount;

    Discussion({
        required this.lastMessageId,
        required this.message,
        required this.type,
        required this.audioAssetUrl,
        required this.messageDate,
        required this.userId,
        required this.firstname,
        required this.lastname,
        required this.photoUrl,
        required this.unreadCount,
    });

    factory Discussion.fromJson(Map<String, dynamic> json) => Discussion(
        lastMessageId: json["last_message_id"],
        message: json["message"],
        type: json["type"],
        audioAssetUrl: json["audio_asset_url"],
        messageDate: DateTime.parse(json["message_date"]),
        userId: json["user_id"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        photoUrl: json["photo_url"],
        unreadCount: int.parse(json["unread_count"]),
    );

    Map<String, dynamic> toJson() => {
        "last_message_id": lastMessageId,
        "message": message,
        "type": type,
        "audio_asset_url": audioAssetUrl,
        "message_date": messageDate.toIso8601String(),
        "user_id": userId,
        "firstname": firstname,
        "lastname": lastname,
        "photo_url": photoUrl,
        "unread_count": unreadCount
    };
}
