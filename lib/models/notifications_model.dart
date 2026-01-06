class NotificationItem {
  final int id;
  final String title;
  final String message;
  final bool seen;
  final DateTime date;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.seen,
    required this.date,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      seen: json['seen'] ?? false,
      date: DateTime.parse(json['date']),
    );
  }
}
