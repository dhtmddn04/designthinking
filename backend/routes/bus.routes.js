const express = require('express');
const db = require('../db');

const router = express.Router();

const allowedStations = ['전정대'];
const allowedBusNumbers = ['9', '1112', '5100', '7000'];

const dayMap = ['일', '월', '화', '수', '목', '금', '토'];

const timeToMinute = (time) => {
  const [hour, minute] = time.split(':').map(Number);
  return hour * 60 + minute;
};

const formatArrivalText = (minute) => {
  if (minute === 0) return '곧 출발';
  return `${minute}분 후`;
};

// 전정대 고정 시간표 기준 다음 출발 버스 조회
router.get('/timetable/next', async (req, res) => {
  const stationName = req.query.stationName?.trim() || '전정대';

  if (!allowedStations.includes(stationName)) {
    return res.status(400).json({
      success: false,
      message: '지원하지 않는 정류장입니다.',
    });
  }
/*
  const now = new Date();
  const today = dayMap[now.getDay()];

  if (!['월', '화', '수', '목', '금'].includes(today)) {
    return res.json({
      success: true,
      stationName,
      dayOfWeek: today,
      arrivals: [],
      message: '주말 시간표는 아직 등록되어 있지 않습니다.',
    });
  }

  const currentMinute = now.getHours() * 60 + now.getMinutes();*/

  const now = new Date();

const requestedDayOfWeek = req.query.dayOfWeek?.trim();
const requestedTime = req.query.time?.trim();

const today = requestedDayOfWeek || dayMap[now.getDay()];

if (!['월', '화', '수', '목', '금'].includes(today)) {
  return res.json({
    success: true,
    stationName,
    dayOfWeek: today,
    arrivals: [],
    message: '주말 시간표는 아직 등록되어 있지 않습니다.',
  });
}

let currentMinute = now.getHours() * 60 + now.getMinutes();

if (requestedTime) {
  const [hour, minute] = requestedTime.split(':').map(Number);

  if (
    Number.isInteger(hour) &&
    Number.isInteger(minute) &&
    hour >= 0 &&
    hour <= 23 &&
    minute >= 0 &&
    minute <= 59
  ) {
    currentMinute = hour * 60 + minute;
  } else {
    return res.status(400).json({
      success: false,
      message: 'time 형식이 올바르지 않습니다. 예: 09:00',
    });
  }
}

  try {
    const [rows] = await db.query(
      `
      SELECT
        bus_number AS busNumber,
        departure_time AS departureTime
      FROM bus_timetables
      WHERE station_name = ?
        AND day_of_week = ?
        AND bus_number IN ('9', '1112', '5100', '7000')
      ORDER BY bus_number, departure_time
      `,
      [stationName, today]
    );

    const nextByBus = {};

    for (const row of rows) {
      const departureMinute = timeToMinute(row.departureTime);

      if (departureMinute < currentMinute) continue;

      if (!nextByBus[row.busNumber]) {
        const arrivalMinute = departureMinute - currentMinute;

        nextByBus[row.busNumber] = {
          busNumber: row.busNumber,
          departureTime: row.departureTime,
          arrival: formatArrivalText(arrivalMinute),
          arrivalMinute,
        };
      }
    }

    const arrivals = allowedBusNumbers
      .map((busNumber) => nextByBus[busNumber])
      .filter(Boolean)
      .sort((a, b) => a.arrivalMinute - b.arrivalMinute);

    return res.json({
      success: true,
      stationName,
      dayOfWeek: today,
      arrivals,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '버스 시간표 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

module.exports = router;