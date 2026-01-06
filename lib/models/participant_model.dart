// To parse this JSON data, do
//
//     final participant = participantFromJson(jsonString);

import 'dart:convert';

Participant participantFromJson(String str) => Participant.fromJson(json.decode(str));

String participantToJson(Participant data) => json.encode(data.toJson());

class Participant {
    int id;
    int valid;
    String photoUrl;
    String fullName;
    String email;
    String profileLabel;
    Country country;
    int sex;
    String phone;
    List<Feild> feilds;

    Participant({
        required this.id,
        required this.valid,
        required this.photoUrl,
        required this.fullName,
        required this.email,
        required this.profileLabel,
        required this.country,
        required this.sex,
        required this.phone,
        required this.feilds,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        valid: json["valid"],
        photoUrl: json["photoUrl"],
        fullName: json["fullName"],
        email: json["email"],
        profileLabel: json["profileLabel"],
        country: Country.fromJson(json["country"]),
        sex: json["sex"],
        phone: json["phone"],
        feilds: List<Feild>.from(json["feilds"].map((x) => Feild.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "valid": valid,
        "photoUrl": photoUrl,
        "fullName": fullName,
        "email": email,
        "profileLabel": profileLabel,
        "country": country.toJson(),
        "sex": sex,
        "phone": phone,
        "feilds": List<dynamic>.from(feilds.map((x) => x.toJson())),
    };
}

class Country {
    int id;
    String name;
    String icon;

    Country({
        required this.id,
        required this.name,
        required this.icon,
    });

    factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
    };
}

class Feild {
    int id;
    String label;
    String? value;
    String type;
    List<String> feildValues;
    List<String> multipleValuesSelected;
    bool showOnBadge;
    bool showOnParticipantListPage;
    bool showOnParticipantPage;
    String labelFicheParticipantEn;
    bool showOnNetworkingApp;
    bool showOnNetworkingExperienceAppFilters;

    Feild({
        required this.id,
        required this.label,
        required this.value,
        required this.type,
        required this.feildValues,
        required this.multipleValuesSelected,
        required this.showOnBadge,
        required this.showOnParticipantListPage,
        required this.showOnParticipantPage,
        required this.labelFicheParticipantEn,
        required this.showOnNetworkingApp,
        required this.showOnNetworkingExperienceAppFilters,
    });

    factory Feild.fromJson(Map<String, dynamic> json) => Feild(
        id: json["id"],
        label: json["label"],
        value: json["value"],
        type: json["type"],
        feildValues: List<String>.from(json["feild_values"].map((x) => x)),
        multipleValuesSelected: List<String>.from(json["multiple_values_selected"].map((x) => x)),
        showOnBadge: json["show_on_badge"],
        showOnParticipantListPage: json["show_on_participant_list_page"],
        showOnParticipantPage: json["show_on_participant_page"],
        labelFicheParticipantEn: json["label_fiche_participant_en"],
        showOnNetworkingApp: json["show_on_networking_app"],
        showOnNetworkingExperienceAppFilters: json["show_on_networking_experience_app_filters"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "value": value,
        "type": type,
        "feild_values": List<dynamic>.from(feildValues.map((x) => x)),
        "multiple_values_selected": List<dynamic>.from(multipleValuesSelected.map((x) => x)),
        "show_on_badge": showOnBadge,
        "show_on_participant_list_page": showOnParticipantListPage,
        "show_on_participant_page": showOnParticipantPage,
        "label_fiche_participant_en": labelFicheParticipantEn,
        "show_on_networking_app": showOnNetworkingApp,
        "show_on_networking_experience_app_filters": showOnNetworkingExperienceAppFilters,
    };
}
