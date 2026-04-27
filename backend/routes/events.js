const express = require('express');
const db = require('../db');
const auth = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', auth, (req, res) => {
  db.all(
    "SELECT * FROM events WHERE user_id=?",
    [req.user.id],
    (err, rows) => res.json(rows)
  );
});

router.post('/', auth, (req, res) => {
  const e = req.body;

  db.run(
    "INSERT INTO events (title, start, end, description, user_id) VALUES (?, ?, ?, ?, ?)",
    [e.title, e.start, e.end, e.description, req.user.id],
    function (err) {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
      }

      res.json({ id: this.lastID });
    }
  );
});

router.put('/:id', auth, (req, res) => {
  const e = req.body;

  db.run(
    "UPDATE events SET title=?, start=?, end=?, description=? WHERE id=? AND user_id=?",
    [e.title, e.start, e.end, e.description, req.params.id, req.user.id],
    function (err) {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
      }

      res.json({ changes: this.changes });
    }
  );
});

router.delete('/:id', auth, (req, res) => {
  db.run(
    "DELETE FROM events WHERE id=? AND user_id=?",
    [req.params.id, req.user.id],
    function () {
      res.json({ changes: this.changes });
    }
  );
});

module.exports = router;