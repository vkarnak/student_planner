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

      score += daysLeft * 20;
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

    for (var task in activeTasks) {
      final deadline = DateTime.parse(task.deadline!);
      final totalMinutes = task.duration ?? 60;
      final fullDuration = Duration(minutes: totalMinutes);

      List<Duration> chunks = [];

      final isOverdue = deadline.isBefore(now);

      if (totalMinutes <= 60) {
        chunks = [fullDuration];
      } else {
        int remaining = totalMinutes ~/ 60;

        while (remaining > 0) {
          int block = 1;

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
          final isOverdue = deadline.isBefore(now);

          final deadlineDay = DateTime(
            deadline.year,
            deadline.month,
            deadline.day,
          );

          if (!isOverdue && day.isAfter(deadlineDay)) break;

          final dayKey = DateTime(day.year, day.month, day.day);
          final usedHours = dayLoad[dayKey] ?? 0;

          //  if (usedHours + partDuration.inHours > 8) continue;

          for (int h = 8; h < 22; h++) {
            for (int m = 0; m < 60; m += 30) {
              final start = DateTime(day.year, day.month, day.day, h, m);
              final end = start.add(partDuration);

              if (end.hour > 22 || end.day != start.day) continue;
              if (start.isBefore(now)) continue;

              final isOverdue = deadline.isBefore(now);

              final deadlineEnd = DateTime(
                deadline.year,
                deadline.month,
                deadline.day,
                23,
                59,
              );

              if (!isOverdue && end.isAfter(deadlineEnd)) continue;
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
        }

        if (bestSlot == null) {
          result.add(
            Suggestion(
              id: "${task.id}_$i",
              taskId: task.id!,
              title: isOverdue
                  ? "!!! ${task.title} NO FREE TIME !!!"
                  : "${task.title} (No free time available)",
              start: deadline,
              end: deadline,
            ),
          );
          continue;
        }

        final slot = bestSlot;

        final dayKey = DateTime(slot.year, slot.month, slot.day);
        dayLoad[dayKey] = (dayLoad[dayKey] ?? 0) + partDuration.inHours;

        previousEnd = slot.add(partDuration);

        result.add(
          Suggestion(
            id: "${task.id}_$i",
            taskId: task.id!,
            title: chunks.length > 1
                ? (isOverdue
                      ? "!!! ${task.title} (part ${i + 1}) !!!"
                      : "${task.title} (part ${i + 1})")
                : (isOverdue ? "!!! ${task.title} !!!" : task.title),
            start: slot,
            end: slot.add(partDuration),
          ),
        );
      }
    }

    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }
}
