class Event {
  final int? id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;

  Event({
    this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "start": start.toIso8601String(),
      "end": end.toIso8601String(),
      "description": description,
    };
  }
}
