const express = require('express');
const db = require('../db');
const auth = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', auth, (req, res) => {

  db.all(
    "SELECT * FROM tasks WHERE user_id=?",
    [req.user.id],
    (err, tasks) => {

      const now = new Date();

      const result = tasks
        .map(t => {
          const deadline = new Date(t.deadline);

          const daysLeft = Math.ceil(
            (deadline - now) / (1000 * 60 * 60 * 24)
          );

          return { ...t, daysLeft };
        })
        .filter(t => t.daysLeft >= 0)
        .sort((a, b) => a.daysLeft - b.daysLeft);

      res.json(result);
    }
  );
});

module.exports = router;