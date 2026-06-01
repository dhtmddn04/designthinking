const express = require('express');
const db = require('../db');

const router = express.Router();

function getTodayString() {
  const now = new Date();

  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

function isPastTime(reservedTime) {
  /*const realNow = new Date();

  // 테스트용: 오늘 14시로 가정
  const now = new Date(
    realNow.getFullYear(),
    realNow.getMonth(),
    realNow.getDate(),
    14,
    0
  );*/

  const now = new Date();

  const [hour, minute] = reservedTime.split(':').map(Number);

  const reservationDate = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate(),
    hour,
    minute
  );

  return reservationDate < now;
}

async function resetReservationsIfNewDay() {
  const today = getTodayString();

  const [rows] = await db.query(
    `
    SELECT meta_value
    FROM app_meta
    WHERE meta_key = ?
    `,
    ['reservation_reset_date']
  );

  if (rows.length === 0) {
    await db.query(
      `
      INSERT INTO app_meta (meta_key, meta_value)
      VALUES (?, ?)
      `,
      ['reservation_reset_date', today]
    );
    return;
  }

  const lastResetDate = rows[0].meta_value;

  if (lastResetDate !== today) {
    await db.query(
      `
      DELETE FROM reservations
      WHERE id > 0
      `
    );

    await db.query(
      `
      UPDATE app_meta
      SET meta_value = ?
      WHERE meta_key = ?
      `,
      [today, 'reservation_reset_date']
    );
  }
}

async function deleteExpiredReservations() {
  const [reservations] = await db.query(
    `
    SELECT id, reserved_time
    FROM reservations
    WHERE status = 'active'
    `
  );

  const expiredIds = reservations
    .filter((reservation) => isPastTime(reservation.reserved_time))
    .map((reservation) => reservation.id);

  if (expiredIds.length > 0) {
    await db.query(
      `
      DELETE FROM reservations
      WHERE id IN (?)
      `,
      [expiredIds]
    );
  }
}

async function syncReservationState() {
  await resetReservationsIfNewDay();
  await deleteExpiredReservations();
}

router.post('/', async (req, res) => {
  const { userId, stopName, busNumber, reservedTime } = req.body;

  if (!userId || !stopName || !busNumber || !reservedTime) {
    return res.status(400).json({
      success: false,
      message: '예약 정보가 부족합니다.',
    });
  }

try {
  await syncReservationState();

  if (isPastTime(reservedTime)) {
    return res.status(400).json({
      success: false,
      message: '이미 지난 시간은 예약할 수 없습니다.',
    });
  }

  const [users] = await db.query(
      'SELECT id, needs_wheelchair FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.',
      });
    }

    const user = users[0];

    if (user.needs_wheelchair !== 1) {
      return res.status(403).json({
        success: false,
        message: '예약 기능 이용 대상자가 아닙니다.',
      });
    }

    const [sameTimeReservations] = await db.query(
      `
      SELECT id, stop_name
      FROM reservations
      WHERE user_id = ?
        AND reserved_time = ?
        AND status = 'active'
      LIMIT 1
      `,
      [userId, reservedTime]
    );

    if (sameTimeReservations.length > 0) {
      return res.status(409).json({
        success: false,
        message: '이미 같은 시간대에 다른 정류장 예약이 있습니다.',
      });
    }

    await db.query(
      `
      INSERT INTO reservations (user_id, stop_name, bus_number, reserved_time)
      VALUES (?, ?, ?, ?)
      `,
      [userId, stopName, busNumber, reservedTime]
    );

    return res.status(201).json({
      success: true,
      message: '예약이 완료되었습니다.',
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: '이미 예약된 시간입니다.',
      });
    }

    console.error(error);

    return res.status(500).json({
      success: false,
      message: '예약 중 서버 오류가 발생했습니다.',
    });
  }
});

router.get('/', async (req, res) => {
  try {
    await syncReservationState();

    const [reservations] = await db.query(
      `
      SELECT
        id,
        user_id,
        stop_name,
        bus_number,
        reserved_time,
        status,
        boarding_bus_number,
        boarding_time,
        boarding_confirmed_at,
        created_at
      FROM reservations
      WHERE status = 'active'
      ORDER BY created_at DESC
      `
    );

    return res.json({
      success: true,
      reservations,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '전체 예약 내역 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

router.get('/boarding-status', async (req, res) => {
  const stationName = req.query.stationName?.trim();
  const busNumber = req.query.busNumber?.trim();
  const boardingTime = req.query.boardingTime?.trim();

  if (!stationName || !busNumber || !boardingTime) {
    return res.status(400).json({
      success: false,
      message: 'stationName, busNumber, boardingTime이 필요합니다.',
    });
  }

  try {
    const [rows] = await db.query(
      `
      SELECT COUNT(*) AS reservationCount
      FROM reservations r
      JOIN users u ON r.user_id = u.id
      WHERE r.status = 'active'
        AND r.stop_name = ?
        AND r.boarding_bus_number = ?
        AND r.boarding_time = ?
        AND u.needs_wheelchair = 1
      `,
      [stationName, busNumber, boardingTime]
    );

    const reservationCount = rows[0].reservationCount ?? 0;

    return res.json({
      success: true,
      hasWheelchairReservation: reservationCount > 0,
      reservationCount,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '휠체어 예약자 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

router.get('/user/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const [reservations] = await db.query(
      `
      SELECT
        id,
        user_id,
        stop_name,
        bus_number,
        reserved_time,
        status,
        boarding_bus_number,
        boarding_time,
        boarding_confirmed_at,
        created_at
      FROM reservations
      WHERE user_id = ? AND status = 'active'
      ORDER BY created_at DESC
      `,
      [userId]
    );

    return res.json({
      success: true,
      reservations,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '예약 내역 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

router.delete('/', async (req, res) => {
  const { userId, stopName, reservedTime } = req.body;

  if (!userId || !stopName || !reservedTime) {
    return res.status(400).json({
      success: false,
      message: '취소 정보가 부족합니다.',
    });
  }

try {
  await syncReservationState();

  const [result] = await db.query(
      `
      DELETE FROM reservations
      WHERE user_id = ?
        AND stop_name = ?
        AND reserved_time = ?
      `,
      [userId, stopName, reservedTime]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '취소할 예약을 찾을 수 없습니다.',
      });
    }

    return res.json({
      success: true,
      message: '예약이 취소되었습니다.',
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '예약 취소 중 서버 오류가 발생했습니다.',
    });
  }
});

module.exports = router;