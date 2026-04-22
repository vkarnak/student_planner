const express = require('express');
const db = require('../db');
const auth = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', auth, (req, res) => {
  db.get(
    "SELECT id, email, name FROM users WHERE id=?",
    [req.user.id],
    (err, user) => res.json(user)
  );
});

router.put('/', auth, (req, res) => {
  const { name, email } = req.body;

  db.run(
    "UPDATE users SET name=?, email=? WHERE id=?",
    [name, email, req.user.id],
    function () {
      res.json({ success: true });
    }
  );
});

module.exports = router;