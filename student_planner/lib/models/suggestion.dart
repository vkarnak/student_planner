class Suggestion {
  final int taskId;
  final String title;
  final DateTime start;
  final DateTime end;

  Suggestion({
    required this.taskId,
    required this.title,
    required this.start,
    required this.end,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      taskId: json['taskId'],
      title: json['title'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}
