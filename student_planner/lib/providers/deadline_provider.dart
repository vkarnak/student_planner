import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class DeadlineProvider extends ChangeNotifier {
  List<Task> tasks = [];
  bool isLoading = false;

  // 📦 Загрузка задач
  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    try {
      tasks = await TaskService.getTasks();
    } catch (e) {
      tasks = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ➕ Добавить
  Future<void> addTask(Task task) async {
    await TaskService.addTask(task);
    await loadTasks();
  }

  // ✏️ Обновить
  Future<void> updateTask(Task task) async {
    await TaskService.updateTask(task);
    await loadTasks();
  }

  // ❌ Удалить
  Future<void> deleteTask(int id) async {
    await TaskService.deleteTask(id);
    await loadTasks();
  }

  // ✅ Переключить статус (done / pending)
  Future<void> toggleStatus(Task task) async {
    final updated = task.copyWith(
      status: task.status == "done" ? "pending" : "done",
    );

    await updateTask(updated);
  }

  // =========================
  // 📊 ЛОГИКА ДЕДЛАЙНОВ
  // =========================

  // 📅 Сегодня
  List<Task> get today {
    final now = DateTime.now();

    return tasks.where((t) {
      if (t.deadlineDate == null) return false;

      final d = t.deadlineDate!;

      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  // ⏳ Ближайшие
  List<Task> get upcoming {
    final now = DateTime.now();

    return tasks
        .where((t) => t.deadlineDate != null && t.deadlineDate!.isAfter(now))
        .toList()
      ..sort((a, b) => a.deadlineDate!.compareTo(b.deadlineDate!));
  }

  // 🚨 Просроченные
  List<Task> get overdue {
    final now = DateTime.now();

    return tasks
        .where(
          (t) =>
              t.deadlineDate != null &&
              t.deadlineDate!.isBefore(now) &&
              t.status != "done",
        )
        .toList()
      ..sort((a, b) => a.deadlineDate!.compareTo(b.deadlineDate!));
  }
}
