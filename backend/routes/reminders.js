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

      const upcoming = tasks.filter(t => {
        const deadline = new Date(t.deadline);

        const diff =
          (deadline - now) / (1000 * 60 * 60 * 24);

        return diff >= 0 && diff <= 1;
      });

      res.json(upcoming);
    }
  );
});

module.exports = router;