const express = require('express');
const db = require('../db');
const auth = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', auth, (req, res) => {
  const now = new Date().toISOString();
  const tomorrow = new Date(
    Date.now() + 24 * 60 * 60 * 1000
  ).toISOString();

  db.all(
    `
    SELECT * FROM tasks
    WHERE user_id = ?
    AND deadline IS NOT NULL
    AND deadline BETWEEN ? AND ?
    `,
    [req.user.id, now, tomorrow],
    (err, tasks) => {
      if (err) {
        return res.status(500).json({
          error: "Database error",
        });
      }

      res.json(tasks);
    }
  );
});

module.exports = router;