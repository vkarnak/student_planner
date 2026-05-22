import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../models/task.dart';
import '../models/event.dart';
import '../models/suggestion.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> requestPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.requestNotificationsPermission();
  }

  static Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const windows = WindowsInitializationSettings(
      appName: 'Student Planner',
      appUserModelId: 'student_planner_app',
      guid: '12345678-1234-1234-1234-123456789012',
    );

    const settings = InitializationSettings(android: android, windows: windows);

    await _notifications.initialize(settings: settings);
  }

  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    if (kIsWeb) return;
    if (date.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(
        DateTime.now().add(const Duration(seconds: 10)),
        tz.local,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'planner',
          'Planner',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> scheduleDailyPlan(
    List<Event> events,
    List<Suggestion> suggestions,
  ) async {
    if (kIsWeb) return;
    final now = DateTime.now();

    final todayItems = [
      ...events.where((e) => _isSameDay(e.start, now)),
      ...suggestions.where((s) => _isSameDay(s.start, now)),
    ];

    if (todayItems.isEmpty) return;

    todayItems.sort((a, b) {
      final aTime = (a is Event) ? a.start : (a as Suggestion).start;
      final bTime = (b is Event) ? b.start : (b as Suggestion).start;
      return aTime.compareTo(bTime);
    });

    String body = "Today:\n";

    for (var item in todayItems.take(3)) {
      final start = item is Event ? item.start : (item as Suggestion).start;
      final end = item is Event ? item.end : (item as Suggestion).end;
      final title = item is Event ? item.title : (item as Suggestion).title;

      body += "• ${_time(start)}-${_time(end)} $title\n";
    }

    final baseTime = DateTime(now.year, now.month, now.day, 8, 0);

    final notifyTime = baseTime.isBefore(now)
        ? now.add(const Duration(seconds: 5))
        : baseTime;

    await _schedule(id: 1, title: "Daily Plan", body: body, date: notifyTime);
  }

  static Future<void> scheduleDeadlines(List<Task> tasks) async {
    if (kIsWeb) return;
    int id = 100;

    for (var t in tasks) {
      if (t.status == "done") continue;
      if (t.deadlineDate == null) continue;

      final deadline = t.deadlineDate!;

      final now = DateTime.now();

      if (deadline.isBefore(now)) {
        await _schedule(
          id: id++,
          title: "Deadline passed",
          body: "${t.title} deadline has passed.",
          date: now.add(const Duration(seconds: 5)),
        );

        continue;
      }

      final notifyTime = deadline.subtract(const Duration(days: 1));

      if (notifyTime.isBefore(now)) continue;

      await _schedule(
        id: id++,
        title: "Deadline tomorrow",
        body: t.title,
        date: notifyTime,
      );
    }
  }

  static Future<void> scheduleAISuggestions(
    List<Suggestion> suggestions,
  ) async {
    if (kIsWeb) return;
    final now = DateTime.now();

    final next = suggestions.where((s) => s.start.isAfter(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    if (next.isEmpty) return;

    final s = next.first;

    final notifyTime = s.start.subtract(const Duration(minutes: 10));

    if (notifyTime.hour < 8 || notifyTime.hour > 21) return;

    if (notifyTime.isBefore(now)) return;

    await _schedule(
      id: 200,
      title: "Suggestion",
      body:
          "At ${_time(s.start)}, ${_date(s.start)} you can work on:\n${s.title}",
      date: notifyTime,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _time(DateTime d) {
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  static String _date(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }
}
