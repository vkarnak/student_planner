const express = require('express');
const db = require('../db');
const auth = require('../middleware/authMiddleware');

const router = express.Router();

// 🔥 получить календарь (tasks + events)
router.get('/', auth, (req, res) => {

  const userId = req.user.id;

  db.all(
    "SELECT * FROM tasks WHERE user_id=?",
    [userId],
    (err, tasks) => {

      db.all(
        "SELECT * FROM events WHERE user_id=?",
        [userId],
        (err2, events) => {

          const schedule = [
            ...tasks.map(t => ({
              type: "task",
              title: t.title,
              date: t.deadline
            })),
            ...events.map(e => ({
              type: "event",
              title: e.title,
              date: e.date
            }))
          ];

          res.json(schedule);
        }
      );
    }
  );
});

module.exports = router;