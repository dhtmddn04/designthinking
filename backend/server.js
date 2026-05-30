const db = require('./db');
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth.routes');
const reservationRoutes = require('./routes/reservation.routes');
const opinionRoutes = require('./routes/opinion.routes');
const scheduleRoutes = require('./routes/schedule.routes');
const busRoutes = require('./routes/bus.routes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/reservations', reservationRoutes);
app.use('/api/opinions', opinionRoutes);
app.use('/api/schedules', scheduleRoutes);
app.use('/api/bus', busRoutes);

app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Backend connected',
  });
});

app.get('/api/db-test', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT 1 + 1 AS result');

    res.json({
      status: 'ok',
      message: 'MySQL connected',
      result: rows[0].result,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      status: 'error',
      message: 'MySQL connection failed',
    });
  }
});

app.get('/api/home/stations', (req, res) => {
  res.json({
    stations: [
      {
        id: 'main_gate',
        name: '정문',
        recommend: '버스',
        bus: '1112번',
        arrival: '3분 후',
        arrivalMinute: 3,
        classTime: '15분',
        congestion: '보통',
        waiting: 5,
        isNearStation: true,
      },
      {
        id: 'foreign',
        name: '외대',
        recommend: '도보',
        bus: '1112번',
        arrival: '5분 후',
        arrivalMinute: 5,
        classTime: '12분',
        congestion: '혼잡',
        waiting: 18,
        isNearStation: false,
      },
      {
        id: 'engineering',
        name: '전정대',
        recommend: '버스',
        bus: '1112번',
        arrival: '7분 후',
        arrivalMinute: 7,
        classTime: '18분',
        congestion: '약간 혼잡',
        waiting: 10,
        isNearStation: false,
      },
    ],
  });
});

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});