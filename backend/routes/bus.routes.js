const express = require('express');
const db = require('../db');

const router = express.Router();

const GBIS_BASE_URL =
  'https://apis.data.go.kr/6410000/busarrivalservice/v2/getBusArrivalListv2';

const realtimeStationMap = {
  외대: '228000710',
  정문: '228000723',
  전정대_M5107: '203000125',
};

const targetBusNumbersByStation = {
  외대: ['9', '1112', '5100', '7000', 'M5107'],
  정문: ['9', '1112', '5100', '7000', 'M5107'],
};

const allowedStations = ['전정대'];
const allowedBusNumbers = ['9', '1112', '5100', '7000', 'M5107'];

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

const minuteToTime = (totalMinute) => {
  const hour = Math.floor(totalMinute / 60);
  const minute = totalMinute % 60;

  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
};

const fetchRealtimeArrivals = async ({
  stationId,
  targetBusNumbers,
  currentMinute,
  arrivalMinuteOffset = 0,
}) => {
  const serviceKey = process.env.GBIS_API_KEY;

  const params = new URLSearchParams({
    serviceKey,
    stationId,
    format: 'json',
  });

  const gbisUrl = `${GBIS_BASE_URL}?${params.toString()}`;

  const gbisResponse = await fetch(gbisUrl);

  if (!gbisResponse.ok) {
    const error = new Error('GBIS API 호출에 실패했습니다.');
    error.status = 502;
    error.body = {
      success: false,
      message: 'GBIS API 호출에 실패했습니다.',
      status: gbisResponse.status,
    };
    throw error;
  }

  const gbisData = await gbisResponse.json();

  const resultCode = gbisData?.response?.msgHeader?.resultCode;

  if (resultCode !== 0) {
    const error = new Error('GBIS API 응답이 정상적이지 않습니다.');
    error.status = 502;
    error.body = {
      success: false,
      message:
        gbisData?.response?.msgHeader?.resultMessage ||
        'GBIS API 응답이 정상적이지 않습니다.',
      resultCode,
    };
    throw error;
  }

  const rawList = gbisData?.response?.msgBody?.busArrivalList ?? [];

  const busArrivalList = Array.isArray(rawList) ? rawList : [rawList];

  return busArrivalList
    .map((item) => {
      const busNumber = normalizeRouteName(item.routeName);
      const rawArrivalMinute = parsePredictTime(item.predictTime1);

      if (!targetBusNumbers.includes(busNumber)) {
        return null;
      }

      if (rawArrivalMinute === null) {
        return null;
      }

      const arrivalMinute = rawArrivalMinute + arrivalMinuteOffset;

      if (arrivalMinute < 0) {
        return null;
      }

      const expectedArrivalTime = minuteToTime(currentMinute + arrivalMinute);

      return {
        busNumber,
        routeId: item.routeId,
        arrival: formatRealtimeArrivalText(arrivalMinute),
        arrivalMinute,
        expectedArrivalTime,
        departureTime: expectedArrivalTime,
        locationNo: parsePredictTime(item.locationNo1),
        plateNo: item.plateNo1 || null,
        remainSeatCnt: parsePredictTime(item.remainSeatCnt1),
        crowded: parsePredictTime(item.crowded1),
      };
    })
    .filter(Boolean);
};

const isValidTimeText = (time) => {
  if (typeof time !== 'string') return false;

  const [hourText, minuteText] = time.trim().split(':');
  const hour = Number(hourText);
  const minute = Number(minuteText);

  return (
    Number.isInteger(hour) &&
    Number.isInteger(minute) &&
    hour >= 0 &&
    hour <= 23 &&
    minute >= 0 &&
    minute <= 59
  );
};

const getTodayKorean = () => {
  const now = new Date();
  return dayMap[now.getDay()];
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

    let arrivals = ['9', '1112', '5100', '7000']
      .map((busNumber) => nextByBus[busNumber])
      .filter(Boolean);

    try {
      const m5107Arrivals = await fetchRealtimeArrivals({
        stationId: realtimeStationMap['전정대_M5107'],
        targetBusNumbers: ['M5107'],
        currentMinute,
        arrivalMinuteOffset: -10,
      });

      arrivals = [...arrivals, ...m5107Arrivals];
    } catch (error) {
      console.error('전정대 M5107 실시간 조회 실패:', error);
    }

    arrivals.sort((a, b) => a.arrivalMinute - b.arrivalMinute);

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

  if (!['정문', '외대'].includes(stationName)) {
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

  try {
    const now = new Date();
    const currentMinute = now.getHours() * 60 + now.getMinutes();

    let arrivals = [];

    if (stationName === '정문') {
      arrivals = await fetchRealtimeArrivals({
        stationId: realtimeStationMap['정문'],
        targetBusNumbers: ['9', '1112', '5100', '7000', 'M5107'],
        currentMinute,
      });
    }

    if (stationName === '외대') {
      const normalArrivals = await fetchRealtimeArrivals({
        stationId: realtimeStationMap['외대'],
        targetBusNumbers: ['9', '1112', '5100', '7000'],
        currentMinute,
      });

      const m5107Arrivals = await fetchRealtimeArrivals({
        stationId: realtimeStationMap['정문'],
        targetBusNumbers: ['M5107'],
        currentMinute,
        arrivalMinuteOffset: 1,
      });

      arrivals = [...normalArrivals, ...m5107Arrivals];
    }

    arrivals.sort((a, b) => a.arrivalMinute - b.arrivalMinute);

    return res.json({
      success: true,
      stationName,
      stationId: realtimeStationMap[stationName],
      arrivals,
    });
  } catch (error) {
    console.error(error);

    if (error.status && error.body) {
      return res.status(error.status).json(error.body);
    }

    return res.status(500).json({
      success: false,
      message: '실시간 버스 도착정보 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

const saveBoardingTime = async (reservationId, boardingTime) => {
  await db.query(
    `
    UPDATE reservations
    SET
      boarding_bus_number = ?,
      boarding_time = ?,
      boarding_confirmed_at = NOW()
    WHERE id = ?
    `,
    ['9', boardingTime, reservationId]
  );
};

const resolveBoardingRecommendation = async ({
  userId,
  stationName,
  reservedTime,
  shouldSave = true,
}) => {
  const [reservationRows] = await db.query(
    `
    SELECT
      id,
      boarding_bus_number AS boardingBusNumber,
      boarding_time AS boardingTime,
      boarding_confirmed_at AS boardingConfirmedAt
    FROM reservations
    WHERE user_id = ?
      AND stop_name = ?
      AND reserved_time = ?
      AND status = 'active'
    LIMIT 1
    `,
    [userId, stationName, reservedTime]
  );

  if (reservationRows.length === 0) {
    return {
      httpStatus: 404,
      body: {
        success: false,
        available: false,
        message: '예약 정보를 찾을 수 없습니다.',
      },
    };
  }

  const reservation = reservationRows[0];

  if (reservation.boardingTime) {
    return {
      httpStatus: 200,
      body: {
        success: true,
        available: true,
        status: 'confirmed',
        stationName,
        busNumber: reservation.boardingBusNumber || '9',
        reservedTime,
        boardingTime: reservation.boardingTime,
        expectedArrivalTime: reservation.boardingTime,
        arrivalText: `${reservation.boardingTime} 예정`,
        message: '저장된 9번 저상버스 탑승정보입니다.',
      },
    };
  }

  const now = new Date();
  const currentMinute = now.getHours() * 60 + now.getMinutes();
  const reservedMinute = timeToMinute(reservedTime);
  const checkStartMinute = reservedMinute - 60;
  const cutoffMinute = reservedMinute - 15;

  if (currentMinute < checkStartMinute) {
    return {
      httpStatus: 200,
      body: {
        success: true,
        available: false,
        status: 'too_early',
        stationName,
        busNumber: '9',
        reservedTime,
        checkStartTime: minuteToTime(checkStartMinute),
        cutoffTime: minuteToTime(cutoffMinute),
        message: '예약 시간 1시간 전부터 \n9번 저상버스 도착정보가 표시됩니다.',
      },
    };
  }

  if (currentMinute > cutoffMinute) {
    return {
      httpStatus: 200,
      body: {
        success: true,
        available: false,
        status: 'too_late',
        stationName,
        busNumber: '9',
        reservedTime,
        checkStartTime: minuteToTime(checkStartMinute),
        cutoffTime: minuteToTime(cutoffMinute),
        message: '예약 시간에 맞는 9번 저상버스가 아직 확인되지 않았습니다.',
      },
    };
  }

  if (stationName === '정문' || stationName === '외대') {
    const stationId = realtimeStationMap[stationName];
    const serviceKey = process.env.GBIS_API_KEY;

    if (!serviceKey) {
      return {
        httpStatus: 500,
        body: {
          success: false,
          available: false,
          message: 'GBIS_API_KEY가 설정되어 있지 않습니다.',
        },
      };
    }

    const params = new URLSearchParams({
      serviceKey,
      stationId,
      format: 'json',
    });

    const gbisUrl = `${GBIS_BASE_URL}?${params.toString()}`;
    const gbisResponse = await fetch(gbisUrl);

    if (!gbisResponse.ok) {
      return {
        httpStatus: 502,
        body: {
          success: false,
          available: false,
          message: 'GBIS API 호출에 실패했습니다.',
          status: gbisResponse.status,
        },
      };
    }

    const gbisData = await gbisResponse.json();
    const resultCode = gbisData?.response?.msgHeader?.resultCode;

    if (resultCode !== 0) {
      return {
        httpStatus: 502,
        body: {
          success: false,
          available: false,
          message:
            gbisData?.response?.msgHeader?.resultMessage ||
            'GBIS API 응답이 정상적이지 않습니다.',
          resultCode,
        },
      };
    }

    const rawList = gbisData?.response?.msgBody?.busArrivalList ?? [];
    const busArrivalList = Array.isArray(rawList) ? rawList : [rawList];

    const nineBus = busArrivalList
      .map((item) => {
        const busNumber = normalizeRouteName(item.routeName);
        const arrivalMinute = parsePredictTime(item.predictTime1);

        if (busNumber !== '9') return null;
        if (arrivalMinute === null) return null;

        const expectedArrivalMinute = currentMinute + arrivalMinute;

        return {
          arrivalMinute,
          expectedArrivalMinute,
          expectedArrivalTime: minuteToTime(expectedArrivalMinute),
          plateNo: item.plateNo1 || null,
          locationNo: parsePredictTime(item.locationNo1),
        };
      })
      .filter(Boolean)
      .sort((a, b) => a.arrivalMinute - b.arrivalMinute)[0];

    if (!nineBus) {
      return {
        httpStatus: 200,
        body: {
          success: true,
          available: false,
          status: 'not_found',
          stationName,
          busNumber: '9',
          reservedTime,
          checkStartTime: minuteToTime(checkStartMinute),
          cutoffTime: minuteToTime(cutoffMinute),
          message: '예약 시간에 맞는 9번 저상버스가 아직 확인되지 않았습니다.',
        },
      };
    }

    if (nineBus.expectedArrivalMinute <= cutoffMinute) {
      if (shouldSave) {
        await saveBoardingTime(reservation.id, nineBus.expectedArrivalTime);
      }

      return {
        httpStatus: 200,
        body: {
          success: true,
          available: true,
          status: 'recommended',
          stationName,
          busNumber: '9',
          reservedTime,
          boardingTime: nineBus.expectedArrivalTime,
          expectedArrivalTime: nineBus.expectedArrivalTime,
          arrivalMinute: nineBus.arrivalMinute,
          arrivalText: `${nineBus.expectedArrivalTime} 예정`,
          plateNo: nineBus.plateNo,
          locationNo: nineBus.locationNo,
          message: '9번 저상버스가 추천되었습니다.',
        },
      };
    }

    return {
      httpStatus: 200,
      body: {
        success: true,
        available: false,
        status: 'not_suitable',
        stationName,
        busNumber: '9',
        reservedTime,
        checkStartTime: minuteToTime(checkStartMinute),
        cutoffTime: minuteToTime(cutoffMinute),
        arrivalMinute: nineBus.arrivalMinute,
        expectedArrivalTime: nineBus.expectedArrivalTime,
        message: '예약 시간에 맞는 9번 저상버스가 아직 확인되지 않았습니다.',
      },
    };
  }

  if (stationName === '전정대') {
    const today = getTodayKorean();

    if (!['월', '화', '수', '목', '금'].includes(today)) {
      return {
        httpStatus: 200,
        body: {
          success: true,
          available: false,
          status: 'weekend',
          stationName,
          busNumber: '9',
          reservedTime,
          checkStartTime: minuteToTime(checkStartMinute),
          cutoffTime: minuteToTime(cutoffMinute),
          message: '주말 시간표는 등록되어 있지 않습니다.',
        },
      };
    }

    const [rows] = await db.query(
      `
      SELECT departure_time AS departureTime
      FROM bus_timetables
      WHERE station_name = ?
        AND day_of_week = ?
        AND bus_number = '9'
      ORDER BY departure_time
      `,
      [stationName, today]
    );

    const recommendedBus = rows
      .map((row) => {
        const departureMinute = timeToMinute(row.departureTime);

        return {
          departureTime: row.departureTime,
          departureMinute,
        };
      })
      .filter((bus) => {
        return (
          bus.departureMinute >= currentMinute &&
          bus.departureMinute <= cutoffMinute
        );
      })[0];

    if (!recommendedBus) {
      return {
        httpStatus: 200,
        body: {
          success: true,
          available: false,
          status: 'not_found',
          stationName,
          busNumber: '9',
          reservedTime,
          checkStartTime: minuteToTime(checkStartMinute),
          cutoffTime: minuteToTime(cutoffMinute),
          message: '예약 시간에 맞는 9번 저상버스가 아직 확인되지 않았습니다.',
        },
      };
    }

    if (shouldSave) {
      await saveBoardingTime(reservation.id, recommendedBus.departureTime);
    }

    return {
      httpStatus: 200,
      body: {
        success: true,
        available: true,
        status: 'recommended',
        stationName,
        busNumber: '9',
        reservedTime,
        boardingTime: recommendedBus.departureTime,
        expectedArrivalTime: recommendedBus.departureTime,
        departureTime: recommendedBus.departureTime,
        arrivalText: `${recommendedBus.departureTime} 예정`,
        message: '9번 저상버스가 추천되었습니다.',
      },
    };
  }

  return {
    httpStatus: 400,
    body: {
      success: false,
      available: false,
      message: '지원하지 않는 정류장입니다.',
    },
  };
};

router.get('/boarding-recommendation', async (req, res) => {
  const userId = Number(req.query.userId);
  const stationName = req.query.stationName?.trim();
  const reservedTime = req.query.reservedTime?.trim();

  if (!userId || !stationName || !reservedTime) {
    return res.status(400).json({
      success: false,
      available: false,
      message: 'userId, stationName, reservedTime이 필요합니다.',
    });
  }

  if (!['정문', '외대', '전정대'].includes(stationName)) {
    return res.status(400).json({
      success: false,
      available: false,
      message: '지원하지 않는 정류장입니다.',
    });
  }

  if (!isValidTimeText(reservedTime)) {
    return res.status(400).json({
      success: false,
      available: false,
      message: 'reservedTime 형식이 올바르지 않습니다. 예: 09:00',
    });
  }

  try {
    const result = await resolveBoardingRecommendation({
      userId,
      stationName,
      reservedTime,
      shouldSave: true,
    });

    return res.status(result.httpStatus).json(result.body);
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      available: false,
      message: '9번 저상버스 추천 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

const processPendingBoardingRecommendations = async () => {
  try {
    const [reservations] = await db.query(
      `
      SELECT
        user_id AS userId,
        stop_name AS stationName,
        reserved_time AS reservedTime
      FROM reservations
      WHERE status = 'active'
        AND boarding_time IS NULL
      `
    );

    for (const reservation of reservations) {
      try {
        await resolveBoardingRecommendation({
          userId: reservation.userId,
          stationName: reservation.stationName,
          reservedTime: reservation.reservedTime,
          shouldSave: true,
        });
      } catch (error) {
        console.error('탑승권 자동 추천 처리 실패:', error);
      }
    }
  } catch (error) {
    console.error('탑승권 자동 추천 대상 조회 실패:', error);
  }
};

router.processPendingBoardingRecommendations =
  processPendingBoardingRecommendations;

module.exports = router;