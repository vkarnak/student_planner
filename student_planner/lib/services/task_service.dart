import 'api_service.dart';
import '../models/task.dart';

class TaskService {

  // 📋 GET TASKS
  static Future<List<Task>> getTasks() async {
    final data = await ApiService.getTasks();

    return data.map((e) => Task.fromJson(e)).toList();
  }

  // ➕ ADD TASK
  static Future<void> addTask(Task task) async {
    await ApiService.createTask(task.toJson());
  }

  // ✏️ UPDATE TASK
  static Future<void> updateTask(Task task) async {
    await ApiService.updateTask(task.toJson());
  }

  // ❌ DELETE TASK
  static Future<void> deleteTask(int id) async {
    await ApiService.deleteTask(id);
  }
}