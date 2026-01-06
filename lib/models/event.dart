class Event {
  final int id;
  final String name;
  final String? description;
  final String startDate;
  final String endDate;
  final String imageUrl;
  final int category;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.category,
  });

  // Convert Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  // Create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?, // nullable
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as int,
    );
  }

  // Copy with
  Event copyWith({
    int? id,
    String? name,
    String? description,
    String? startDate,
    String? endDate,
    String? imageUrl,
    int? category,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, name: $name, category: $category, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
