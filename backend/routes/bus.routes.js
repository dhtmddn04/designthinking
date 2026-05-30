const express = require('express');
const db = require('../db');

const router = express.Router();

const GBIS_BASE_URL =
  'https://apis.data.go.kr/6410000/busarrivalservice/v2/getBusArrivalListv2';

const realtimeStationMap = {
  외대: '228000710',
  정문: '228000723',
};

const targetBusNumbersByStation = {
  외대: ['9', '1112', '5100', '7000'],
  정문: ['9', '1112', '5100', '7000'],
  // 나중에 M5107 추가하려면 이렇게만 바꾸면 됨:
  // 정문: ['9', '1112', '5100', '7000', 'M5107'],
};

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

const normalizeRouteName = (routeName) => String(routeName).trim();

const parsePredictTime = (value) => {
  if (value === '' || value === null || value === undefined) {
    return null;
  }

  const numberValue = Number(value);

  if (!Number.isFinite(numberValue)) {
    return null;
  }

  return numberValue;
};

const formatRealtimeArrivalText = (minute) => {
  if (minute <= 0) return '곧 도착';
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

// 정문/외대 실시간 버스 도착정보 조회
router.get('/realtime/next', async (req, res) => {
  const stationName = req.query.stationName?.trim();

  if (!stationName) {
    return res.status(400).json({
      success: false,
      message: 'stationName이 필요합니다.',
    });
  }

  const stationId = realtimeStationMap[stationName];

  if (!stationId) {
    return res.status(400).json({
      success: false,
      message: '실시간 도착정보를 지원하지 않는 정류장입니다.',
    });
  }

  const serviceKey = process.env.GBIS_API_KEY;

  if (!serviceKey) {
    return res.status(500).json({
      success: false,
      message: 'GBIS_API_KEY가 설정되어 있지 않습니다.',
    });
  }

  const targetBusNumbers = targetBusNumbersByStation[stationName] ?? [];

  try {
    const params = new URLSearchParams({
      serviceKey,
      stationId,
      format: 'json',
    });

    const gbisUrl = `${GBIS_BASE_URL}?${params.toString()}`;

    const gbisResponse = await fetch(gbisUrl);

    if (!gbisResponse.ok) {
      return res.status(502).json({
        success: false,
        message: 'GBIS API 호출에 실패했습니다.',
        status: gbisResponse.status,
      });
    }

    const gbisData = await gbisResponse.json();

    const resultCode = gbisData?.response?.msgHeader?.resultCode;

    if (resultCode !== 0) {
      return res.status(502).json({
        success: false,
        message:
          gbisData?.response?.msgHeader?.resultMessage ||
          'GBIS API 응답이 정상적이지 않습니다.',
        resultCode,
      });
    }

    const rawList =
      gbisData?.response?.msgBody?.busArrivalList ?? [];

    const busArrivalList = Array.isArray(rawList)
      ? rawList
      : [rawList];

    const arrivals = busArrivalList
      .map((item) => {
        const busNumber = normalizeRouteName(item.routeName);
        const arrivalMinute = parsePredictTime(item.predictTime1);

        if (!targetBusNumbers.includes(busNumber)) {
          return null;
        }

        if (arrivalMinute === null) {
          return null;
        }

        return {
          busNumber,
          routeId: item.routeId,
          arrival: formatRealtimeArrivalText(arrivalMinute),
          arrivalMinute,
          locationNo: parsePredictTime(item.locationNo1),
          plateNo: item.plateNo1 || null,
          remainSeatCnt: parsePredictTime(item.remainSeatCnt1),
          crowded: parsePredictTime(item.crowded1),
        };
      })
      .filter(Boolean)
      .sort((a, b) => a.arrivalMinute - b.arrivalMinute);

    return res.json({
      success: true,
      stationName,
      stationId,
      arrivals,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '실시간 버스 도착정보 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

module.exports = router;