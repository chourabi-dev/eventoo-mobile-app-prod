class BusinessCard {
  final int id;
  final String fullName;
  final String photoUrl;  
  final DateTime requestDate;
  final BusinessCardRequestType type;
  final BusinessCardStatus? status;
  final String? email;
  final String? phone;
 
 
   

  BusinessCard({
    required this.id,
    required this.fullName,
    required this.photoUrl, 
    required this.requestDate,
    required this.type,
    this.status,
    this.email,
    this.phone,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      photoUrl: json['photoUrl'] as String, 
      requestDate: DateTime.parse(json['requestDate'] as String),
      type: json['type'] == 'incoming'
          ? BusinessCardRequestType.incoming
          : BusinessCardRequestType.outgoing,
      status: json['status'] != null
          ? _statusFromString(json['status'] as String)
          : null,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  static BusinessCardStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return BusinessCardStatus.accepted;
      case 'rejected':
        return BusinessCardStatus.rejected;
      case 'pending':
      default:
        return BusinessCardStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'photoUrl': photoUrl, 
      'requestDate': requestDate.toIso8601String(),
      'type': type == BusinessCardRequestType.incoming ? 'incoming' : 'outgoing',
      'status': status?.toString().split('.').last,
      'email': email,
      'phone': phone,
    };
  }
}

enum BusinessCardRequestType {
  incoming,
  outgoing,
}

enum BusinessCardStatus {
  pending,
  accepted,
  rejected,
}