const express = require('express');
const router = express.Router();
const db = require('../db');
const auth = require('../middleware/authMiddleware');

// разумные часы
const START_HOUR = 9;
const END_HOUR = 22;

// утилита: свободные слоты на день
function getFreeSlotsForDay(day, events) {
  const dayStart = new Date(day);
  dayStart.setHours(START_HOUR, 0, 0, 0);

  const dayEnd = new Date(day);
  dayEnd.setHours(END_HOUR, 0, 0, 0);

  const sameDayEvents = events
    .filter(e => {
      const d = new Date(e.start);
      return d.toDateString() === day.toDateString();
    })
    .sort((a, b) => new Date(a.start) - new Date(b.start));

  let slots = [];
  let current = new Date(dayStart);

  for (let ev of sameDayEvents) {
    const evStart = new Date(ev.start);
    const evEnd = new Date(ev.end);

    if (current < evStart) {
      slots.push([new Date(current), evStart]);
    }
    current = new Date(Math.max(current, evEnd));
  }

  if (current < dayEnd) {
    slots.push([current, dayEnd]);
  }

  return slots;
}

// приоритет: срочность + приоритет + сложность
function taskScore(task) {
  const now = new Date();
  const deadline = new Date(task.deadline);
  const urgency = Math.max(1, (deadline - now) / (1000 * 60 * 60)); // часы

  return task.priority * 3 + task.difficulty * 2 + (1 / urgency) * 100;
}

router.get('/schedule', auth, (req, res) => {
  const now = new Date();

  db.all(
    "SELECT * FROM tasks WHERE user_id=? AND status != 'done'",
    [req.user.id],
    (err, tasks) => {
      if (err) return res.status(500).json([]);

      db.all(
        "SELECT * FROM events WHERE user_id=?",
        [req.user.id],
        (err2, events) => {
          if (err2) return res.status(500).json([]);

          // сортируем задачи
          tasks.sort((a, b) => taskScore(b) - taskScore(a));

          const suggestions = [];

          for (let task of tasks) {
            let remaining = Math.max(1, task.duration || 1); // часы

            for (let i = 0; i < 5; i++) {
              const day = new Date();
              day.setDate(now.getDate() + i);

              const slots = getFreeSlotsForDay(day, events);

              for (let [start, end] of slots) {
                const hours = (end - start) / (1000 * 60 * 60);
                if (hours <= 0) continue;

                const used = Math.min(hours, remaining);

                const s = new Date(start);
                const e = new Date(start);
                e.setHours(e.getHours() + used);

                suggestions.push({
                  taskId: task.id,
                  title: task.title,
                  start: s.toISOString(),
                  end: e.toISOString(),
                });

                remaining -= used;
                if (remaining <= 0) break;
              }

              if (remaining <= 0) break;
            }
          }

          res.json(suggestions);
        }
      );
    }
  );
});

module.exports = router;