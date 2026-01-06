class ApiDate {
  final String id;
  final String date; // e.g. "12 Jan 2026"

  ApiDate({required this.id, required this.date});

  factory ApiDate.fromJson(Map<String, dynamic> json) {
    return ApiDate(
      id: json['id'].toString(),    // ensure it's a String
      date: json['date'] ?? '',     // fallback empty string
    );
  }
}

class ApiLocation {
  final String id;
  final String location;
  final String moreInfo; 

  ApiLocation({required this.id, required this.location, required this.moreInfo});

  factory ApiLocation.fromJson(Map<String, dynamic> json) {
    return ApiLocation(
      id: json['id'].toString(),
      location: json['location'] ?? '',
      moreInfo: json['moreInfo'] ?? '',
      
    );
  }
}

class ApiTime {
  final String id;
  final String time;

  ApiTime({required this.id, required this.time});

  factory ApiTime.fromJson(Map<String, dynamic> json) {
    return ApiTime(
      id: json['id'].toString(),
      time: json['time'] ?? '',
    );
  }
}
