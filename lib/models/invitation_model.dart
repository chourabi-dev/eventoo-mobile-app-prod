enum InvitationType { incoming, outgoing }
enum InvitationStatus { pending, accepted, rejected }
enum InvitationAction { accept, reject, reschedule }

class Invitation {
  final int id;
  final String fullName;
  final String photoUrl;
  final DateTime dateTime;
  final String location;
  final InvitationType type;
  final InvitationStatus? status;

  Invitation({
    required this.id,
    required this.fullName,
    required this.photoUrl,
    required this.dateTime,
    required this.location,
    required this.type,
    this.status,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      photoUrl: json['photoUrl'] as String,
      dateTime: DateTime.parse(json['dateTime']).toLocal(),
      location: json['location'] as String,
      type: _parseInvitationType(json['type']),
      status: _parseInvitationStatus(json['status']),
    );
  }

  // ---------------- helpers ----------------

  static InvitationType _parseInvitationType(String value) {
    return InvitationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InvitationType.outgoing,
    );
  }

  static InvitationStatus? _parseInvitationStatus(String? value) {
    if (value == null) return null;
    return InvitationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}
