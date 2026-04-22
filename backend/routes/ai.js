const express = require('express');
const db = require('../db');
const auth = require('../middleware/authMiddleware');

const router = express.Router();

// optimize
router.get('/optimize', auth, (req, res) => {

  db.all(
    "SELECT * FROM tasks WHERE user_id=?",
    [req.user.id],
    (err, tasks) => {

      const now = new Date();

      const result = tasks.map(t => {

        const deadline = new Date(t.deadline);
        const days = (deadline - now) / (1000 * 60 * 60 * 24);

        const urgency = days <= 1 ? 5 : days <= 3 ? 3 : 1;

        const score =
          (t.priority || 1) * 2 +
          (t.difficulty || 1) +
          urgency;

        return { ...t, score };
      });

      result.sort((a, b) => b.score - a.score);

      res.json(result);
    }
  );
});

// suggestions
router.get('/suggestions', auth, (req, res) => {

  db.all(
    "SELECT * FROM tasks WHERE user_id=?",
    [req.user.id],
    (err, tasks) => {

      let suggestions = [];

      tasks.forEach(t => {

        if (t.priority >= 3) {
          suggestions.push({
            title: `Focus on: ${t.title}`,
            description: "High priority task"
          });
        }

      });

      res.json(suggestions);
    }
  );
});

module.exports = router;