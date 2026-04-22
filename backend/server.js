const express = require('express');
const cors = require('cors');

const app = express();

app.use(express.json());
app.use(cors());

// 🔥 routes
app.use('/auth', require('./routes/auth'));
app.use('/tasks', require('./routes/tasks'));
app.use('/events', require('./routes/events'));
app.use('/profile', require('./routes/profile'));
app.use('/schedule', require('./routes/schedule'));
app.use('/deadlines', require('./routes/deadlines'));
app.use('/reminders', require('./routes/reminders'));
app.use('/ai', require('./routes/ai'));
const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});