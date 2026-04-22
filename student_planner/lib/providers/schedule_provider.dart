import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/schedule_service.dart';
import '../services/notification_service.dart';
import '../services/ai_service.dart';

class ScheduleProvider extends ChangeNotifier {

  List<Task> items = [];
  bool isLoading = false;

  // 📅 LOAD SCHEDULE
  Future<void> loadSchedule() async {
    isLoading = true;
    notifyListeners();

    try {
      items = await ScheduleService.getSchedule();
    } catch (e) {
      items = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // 🔔 REMINDERS
  Future<void> checkReminders() async {
    for (var task in items) {
      if (task.deadline != null &&
          task.deadline!.difference(DateTime.now()).inHours <= 1) {

        await NotificationService.show(
          "Upcoming task",
          task.title,
        );
      }
    }
  }

  // 🤖 AI OPTIMIZE (локально через AIScheduler или API)
  Future<void> optimize() async {
    isLoading = true;
    notifyListeners();

    try {
      items = await AiService.optimize(); // если backend
    } catch (e) {}

    isLoading = false;
    notifyListeners();
  }

  // 🧠 AUTO DISTRIBUTE
  Future<void> autoDistribute() async {
    isLoading = true;
    notifyListeners();

    try {
      await AiService.autoDistribute();
      await loadSchedule(); // 🔥 обновляем после
    } catch (e) {}

    isLoading = false;
    notifyListeners();
  }
}