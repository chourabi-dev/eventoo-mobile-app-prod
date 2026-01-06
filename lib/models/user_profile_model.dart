// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

UserProfile userProfileFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
    String photoUrl;
    String fullName;
    String email;
    String phone; 
    String profileLabel;
    Country country;
    int sex;
    List<Feild> feilds;

    UserProfile({
        required this.photoUrl,
        required this.fullName,
        required this.email,
        required this.phone, 
        required this.profileLabel,
        required this.country,
        required this.sex,
        required this.feilds,
    });

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        photoUrl: json["photoUrl"],
        fullName: json["fullName"],
        email: json["email"],
        phone: json["phone"],
        
        profileLabel: json["profileLabel"],
        country: Country.fromJson(json["country"]),
        sex: json["sex"],
        feilds: List<Feild>.from(json["feilds"].map((x) => Feild.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "photoUrl": photoUrl,
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "profileLabel": profileLabel,
        "country": country.toJson(),
        "sex": sex,
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
