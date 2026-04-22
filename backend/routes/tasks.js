const express = require('express');
const db = require('../db');
const auth = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', auth, (req, res) => {
  db.all(
    "SELECT * FROM tasks WHERE user_id=?",
    [req.user.id],
    (err, rows) => res.json(rows)
  );
});

router.post('/', auth, (req, res) => {
  const t = req.body;

  db.run(`
    INSERT INTO tasks (title, description, deadline, duration, priority, difficulty, status, user_id)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      t.title,
      t.description,
      t.deadline,
      t.duration,
      t.priority,
      t.difficulty,
      t.status,
      req.user.id
    ],
    function () {
      res.json({ id: this.lastID });
    }
  );
});

router.delete('/:id', auth, (req, res) => {
  db.run(
    "DELETE FROM tasks WHERE id=? AND user_id=?",
    [req.params.id, req.user.id],
    function () {
      res.json({ changes: this.changes });
    }
  );
});

module.exports = router;