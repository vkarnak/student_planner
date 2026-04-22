class Event {
  final int? id;
  final String title;
  final String date;

  Event({
    this.id,
    required this.title,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "date": date,
    };
  }
}