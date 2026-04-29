class Event {
  final int? id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;
  final String color;

  Event({
    this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.color = "blue",
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      description: json['description'],
      color: json['color'] ?? "blue",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "start": start.toIso8601String(),
      "end": end.toIso8601String(),
      "description": description,
      "color": color,
    };
  }
}
