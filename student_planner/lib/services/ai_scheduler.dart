import '../models/task.dart';
import '../models/event.dart';
import '../models/suggestion.dart';

class AiScheduler {
  static List<Suggestion> generate(List<Task> tasks, List<Event> events) {
    final now = DateTime.now();

    final activeTasks = tasks
        .where((t) => t.status != "done" && t.deadline != null)
        .toList();

    activeTasks.sort((a, b) {
      final da = DateTime.parse(a.deadline!);
      final db = DateTime.parse(b.deadline!);

      final cmpDeadline = da.compareTo(db);
      if (cmpDeadline != 0) return cmpDeadline;

      final cmpPriority = b.priority.compareTo(a.priority);
      if (cmpPriority != 0) return cmpPriority;

      return (b.difficulty ?? 1).compareTo(a.difficulty ?? 1);
    });

    final List<Suggestion> result = [];
    final Map<DateTime, int> dayLoad = {};

    bool isFree(DateTime start, DateTime end) {
      final busyEvents = events.any(
        (e) => start.isBefore(e.end) && end.isAfter(e.start),
      );

      final busyTasks = result.any(
        (r) => start.isBefore(r.end) && end.isAfter(r.start),
      );

      return !busyEvents && !busyTasks;
    }

    int scoreSlot({
      required DateTime start,
      required DateTime deadline,
      required Task task,
      required int dayLoadHours,
    }) {
      final daysLeft = deadline.difference(start).inDays;

      int score = 0;

      score += daysLeft * 10;
      score -= task.priority * 5;
      score -= dayLoadHours * 8;

      if (start.hour >= 10 && start.hour <= 18) {
        score += 5;
      }

      if ((task.difficulty ?? 1) >= 4) {
        if (start.hour < 11 || start.hour > 18) {
          score -= 20;
        }
      }

      return score;
    }

    DateTime? tryPlace({
      required Duration duration,
      required DateTime deadline,
      required Task task,
    }) {
      DateTime? bestSlot;
      int bestScore = -999999;

      for (int d = 0; d < 14; d++) {
        final day = DateTime(now.year, now.month, now.day + d);

        if (day.isAfter(deadline)) break;

        final dayKey = DateTime(day.year, day.month, day.day);
        final usedHours = dayLoad[dayKey] ?? 0;

        if (usedHours + duration.inHours > 8) continue;

        for (int h = 8; h < 22; h++) {
          final start = DateTime(day.year, day.month, day.day, h);
          final end = start.add(duration);

          if (start.isBefore(now)) continue;
          if (end.isAfter(deadline)) continue;
          if (!isFree(start, end)) continue;

          final score = scoreSlot(
            start: start,
            deadline: deadline,
            task: task,
            dayLoadHours: usedHours,
          );

          if (score > bestScore) {
            bestScore = score;
            bestSlot = start;
          }
        }
      }

      return bestSlot;
    }

    for (var task in activeTasks) {
      final deadline = DateTime.parse(task.deadline!);
      final totalMinutes = task.duration ?? 60;
      final fullDuration = Duration(minutes: totalMinutes);
      final singleSlot = tryPlace(
        duration: fullDuration,
        deadline: deadline,
        task: task,
      );

      List<Duration> chunks = [];

      final isOverdue = deadline.isBefore(now);

      if (singleSlot != null || totalMinutes <= 3 || isOverdue) {
        chunks = [fullDuration];
      } else {
        int remaining = totalMinutes ~/ 60;

        while (remaining > 0) {
          int block = remaining >= 3 ? 2 : remaining;

          if (block > remaining) block = remaining;

          chunks.add(Duration(hours: block));
          remaining -= block;
        }
      }
      DateTime? previousEnd;

      for (int i = 0; i < chunks.length; i++) {
        final partDuration = chunks[i];

        DateTime? bestSlot;
        int bestScore = -999999;

        for (int d = 0; d < 14; d++) {
          final day = DateTime(now.year, now.month, now.day + d);

          if (day.isAfter(deadline)) break;

          final dayKey = DateTime(day.year, day.month, day.day);
          final usedHours = dayLoad[dayKey] ?? 0;

          if (usedHours + partDuration.inHours > 8) continue;

          for (int h = 8; h < 22; h++) {
            final start = DateTime(day.year, day.month, day.day, h);
            final end = start.add(partDuration);

            if (start.isBefore(now)) continue;
            if (end.isAfter(deadline)) continue;
            if (!isFree(start, end)) continue;

            if (previousEnd != null && start.isBefore(previousEnd)) {
              continue;
            }

            final score = scoreSlot(
              start: start,
              deadline: deadline,
              task: task,
              dayLoadHours: usedHours,
            );

            if (score > bestScore) {
              bestScore = score;
              bestSlot = start;
            }
          }
        }

        final slot = bestSlot ?? DateTime(now.year, now.month, now.day + i, 9);

        final dayKey = DateTime(slot.year, slot.month, slot.day);
        dayLoad[dayKey] = (dayLoad[dayKey] ?? 0) + partDuration.inHours;

        previousEnd = slot.add(partDuration);

        result.add(
          Suggestion(
            taskId: task.id!,
            title: chunks.length > 1
                ? "${task.title} (часть ${i + 1})"
                : task.title,
            start: slot,
            end: slot.add(partDuration),
          ),
        );
      }
    }

    return result;
  }
}
