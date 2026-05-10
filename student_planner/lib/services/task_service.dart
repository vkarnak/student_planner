import 'api_service.dart';
import '../models/task.dart';

class TaskService {
  static Future<List<Task>> getTasks() async {
    final data = await ApiService.getTasks();

    return data.map((e) => Task.fromJson(e)).toList();
  }

  static Future<void> addTask(Task task) async {
    await ApiService.createTask(task.toJson());
  }

  static Future<void> updateTask(Task task) async {
    await ApiService.updateTask(task.toJson());
  }

  static Future<void> deleteTask(int id) async {
    await ApiService.deleteTask(id);
  }
}
