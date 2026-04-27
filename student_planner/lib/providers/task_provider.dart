import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];

  bool isLoading = false;

  Object? get upcoming => null;

  // 🔥 загрузка задач
  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    tasks = await TaskService.getTasks();

    isLoading = false;
    notifyListeners();
  }

  // ➕ добавить
  Future<void> addTask(Task task) async {
    await TaskService.addTask(task);
    await loadTasks(); // 🔥 refresh
  }

  // ✏️ обновить
  Future<void> updateTask(Task task) async {
    await TaskService.updateTask(task);
    await loadTasks();
  }

  // ❌ удалить
  Future<void> deleteTask(int id) async {
    await TaskService.deleteTask(id);
    await loadTasks();
  }
}
