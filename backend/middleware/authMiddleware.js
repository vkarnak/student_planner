const jwt = require('jsonwebtoken');

const SECRET = "supersecret";

module.exports = function (req, res, next) {

  const header = req.headers.authorization;

  if (!header) return res.status(401).send("No token");

  const token = header.split(" ")[1];

  try {
    req.user = jwt.verify(token, SECRET);
    next();
  } catch {
    res.status(401).send("Invalid token");
  }
};