class Task {
  final int? id;
  final String title;
  final String? description;
  final String? deadline;
  final int? duration;
  final int priority;
  final int? difficulty;
  final String status;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    this.deadline,
    this.duration,
    required this.priority,
    this.difficulty,
    this.status = 'pending',
    this.createdAt,
  });

  // 📥 FROM JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'],
      duration: json['duration'],
      priority: json['priority'] ?? 1,
      difficulty: json['difficulty'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // 📤 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline,
      'duration': duration,
      'priority': priority,
      'difficulty': difficulty,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // 🔁 COPY
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? deadline,
    int? duration,
    int? priority,
    int? difficulty,
    String? status,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      duration: duration ?? this.duration,
      priority: priority ?? this.priority,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // =========================
  // 💡 УДОБНЫЕ ГЕТТЕРЫ
  // =========================

  /// 📅 Преобразует строку в DateTime
  DateTime? get deadlineDate {
    if (deadline == null) return null;
    return DateTime.tryParse(deadline!);
  }

  /// 📅 Формат dd.MM.yyyy
  String get formattedDeadline {
    if (deadlineDate == null) return "No deadline";

    final d = deadlineDate!;
    return "${d.day.toString().padLeft(2, '0')}."
        "${d.month.toString().padLeft(2, '0')}."
        "${d.year}";
  }

  /// ⏱ Часы и минуты
  String get formattedDuration {
    if (duration == null) return "-";

    final h = duration! ~/ 60;
    final m = duration! % 60;

    return "${h}h ${m}m";
  }

  int get daysLeft {
    if (deadlineDate == null) return 999;
    return deadlineDate!.difference(DateTime.now()).inDays;
  }

  /// ✅ Проверка статуса
  bool get isDone => status == "done";
}
