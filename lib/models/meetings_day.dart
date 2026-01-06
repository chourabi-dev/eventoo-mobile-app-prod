// To parse this JSON data, do
//
//     final networkingDayPlanning = networkingDayPlanningFromJson(jsonString);

import 'dart:convert';

NetworkingDayPlanning networkingDayPlanningFromJson(String str) => NetworkingDayPlanning.fromJson(json.decode(str));

String networkingDayPlanningToJson(NetworkingDayPlanning data) => json.encode(data.toJson());

class NetworkingDayPlanning {
    String date;
    List<Meeting> meetings;

    NetworkingDayPlanning({
        required this.date,
        required this.meetings,
    });

    factory NetworkingDayPlanning.fromJson(Map<String, dynamic> json) => NetworkingDayPlanning(
        date: json["date"],
        meetings: List<Meeting>.from(json["meetings"].map((x) => Meeting.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "date": date,
        "meetings": List<dynamic>.from(meetings.map((x) => x.toJson())),
    };
}

class Meeting {
    int id;
    String status;
    String fullName;
    String photoUrl;
    DateTime dateTime;
    String location;
    String type;
    String time;

    Meeting({
        required this.id,
        required this.status,
        required this.fullName,
        required this.photoUrl,
        required this.dateTime,
        required this.location,
        required this.type,
        required this.time,
    });

    factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        id: json["id"],
        status: json["status"],
        fullName: json["fullName"],
        photoUrl: json["photoUrl"],
        dateTime: DateTime.parse(json["dateTime"]),
        location: json["location"],
        type: json["type"],
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "fullName": fullName,
        "photoUrl": photoUrl,
        "dateTime": dateTime.toIso8601String(),
        "location": location,
        "type": type,
        "time": time,
    };
}
