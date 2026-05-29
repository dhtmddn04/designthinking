const express = require('express');
const db = require('../db');

const router = express.Router();

router.post('/', async (req, res) => {
  const { userId, stopName, busNumber, reservedTime } = req.body;

  if (!userId || !stopName || !busNumber || !reservedTime) {
    return res.status(400).json({
      success: false,
      message: '예약 정보가 부족합니다.',
    });
  }

  try {
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

module.exports = router;