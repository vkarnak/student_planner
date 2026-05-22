class Suggestion {
  final String id;
  final int taskId;
  final String title;
  final DateTime start;
  final DateTime end;

  Suggestion({
    required this.id,
    required this.taskId,
    required this.title,
    required this.start,
    required this.end,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'],
      taskId: json['taskId'],
      title: json['title'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}
