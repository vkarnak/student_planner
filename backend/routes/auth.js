const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../db');

const router = express.Router();
const SECRET = "supersecret";

const auth = require('../middleware/authMiddleware');

router.post('/register', async (req, res) => {
  const { email, password, name } = req.body;

  const hashed = await bcrypt.hash(password, 10);

  db.run(
    "INSERT INTO users (email, password, name) VALUES (?, ?, ?)",
    [email, hashed, name],
    function (err) {
      if (err) return res.status(400).send("User exists");
      res.json({ message: "User created" });
    }
  );
});

router.post('/login', (req, res) => {
  const { email, password } = req.body;

  db.get("SELECT * FROM users WHERE email=?", [email], async (err, user) => {

    if (!user) return res.status(404).send("User not found");

    const valid = await bcrypt.compare(password, user.password);

    if (!valid) return res.status(401).send("Wrong password");

    const token = jwt.sign({ id: user.id }, SECRET);

    res.json({ token });
  });
});

router.post('/forgot-password', async (req, res) => {
  const { email, password } = req.body;

  const hashed = await bcrypt.hash(password, 10);

  db.run(
    "UPDATE users SET password=? WHERE email=?",
    [hashed, email],
    function () {
      if (this.changes > 0) {
        res.json({ success: true });
      } else {
        res.json({ success: false });
      }
    }
  );
});

router.post('/change-password', auth, (req, res) => {
  const { oldPassword, newPassword } = req.body;

  db.get(
    "SELECT * FROM users WHERE id=?",
    [req.user.id],
    async (err, user) => {
      if (!user) {
        return res.json({ success: false });
      }

      // 🔥 сравниваем через bcrypt
      const valid = await bcrypt.compare(oldPassword, user.password);

      if (!valid) {
        return res.json({ success: false });
      }

      // 🔥 хешируем новый пароль
      const hashed = await bcrypt.hash(newPassword, 10);

      db.run(
        "UPDATE users SET password=? WHERE id=?",
        [hashed, req.user.id],
        function () {
          res.json({ success: true });
        }
      );
    }
  );
});

module.exports = router;