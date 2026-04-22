import '../models/task.dart';

class AIScheduler {
  static List<Task> optimize(List<Task> tasks) {
    if (tasks.isEmpty) return [];

    final now = DateTime.now();
    final sorted = List<Task>.from(tasks);

    sorted.sort((a, b) {
      double scoreA = _score(a, now);
      double scoreB = _score(b, now);
      return scoreB.compareTo(scoreA);
    });

    return sorted;
  }

  static double _score(Task t, DateTime now) {
    double score = 0;

    // Deadline urgency (higher weight for urgent tasks)
    if (t.deadline != null && t.deadline!.isNotEmpty) {
      try {
        final deadline = DateTime.parse(t.deadline!);
        int hoursUntilDue = deadline.difference(now).inHours;

        if (hoursUntilDue <= 0) {
          score += 200; // Overdue
        } else if (hoursUntilDue <= 24) {
          score += 150; // Due today
        } else if (hoursUntilDue <= 72) {
          score += 100; // Due within 3 days
        } else if (hoursUntilDue <= 168) {
          score += 50; // Due within a week
        } else {
          score += 10; // Far away
        }
      } catch (e) {
        // Invalid date format
      }
    }

    // Priority weight (1-5, higher = more urgent)
    score += t.priority * 20;

    // Difficulty weight (1-5, higher difficulty = more important)
    if (t.difficulty != null) {
      score += t.difficulty! * 10;
    }

    // Duration weight (shorter tasks = higher priority for momentum)
    if (t.duration != null && t.duration! > 0) {
      score += (120 / t.duration!); // Shorter tasks get bonus
    }

    // Status weight
    if (t.status == 'in_progress') {
      score += 50;
    } else if (t.status == 'completed') {
      score -= 1000;
    }

    return score;
  }

  /// Get AI recommendation text for a task
  static String getRecommendation(Task task, int position) {
    if (position == 1) {
      return '🔥 Start with this!';
    } else if (position <= 3) {
      return '⚡ High Priority';
    } else if (position <= 5) {
      return '📌 Medium Priority';
    } else {
      return '✅ Lower Priority';
    }
  }
}