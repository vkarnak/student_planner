import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/schedule_service.dart';
import '../services/notification_service.dart';
import '../services/ai_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Task> items = [];
  bool isLoading = false;

  Future<void> loadSchedule() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await ScheduleService.getSchedule();
      items = data
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      items = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> checkReminders() async {
    for (var task in items) {
      if (task.deadline != null && task.deadline!.isNotEmpty) {
        final deadline = DateTime.parse(task.deadline!);

        if (deadline.difference(DateTime.now()).inHours <= 1) {
          await NotificationService.show("Upcoming task", task.title);
        }
      }
    }
  }

  Future<void> optimize() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await AiService.optimize();
      items = data
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> autoDistribute() async {
    isLoading = true;
    notifyListeners();

    try {
      await AiService.autoDistribute();
      await loadSchedule();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
