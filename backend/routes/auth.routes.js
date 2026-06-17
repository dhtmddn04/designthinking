const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../db');

const router = express.Router();

router.post('/signup', async (req, res) => {
  const { username, password, phone, needsWheelchair } = req.body;

  const normalizedPhone = phone?.trim();

  if (!username || !password || !normalizedPhone) {
    return res.status(400).json({
      success: false,
      message: '아이디, 비밀번호, 휴대전화를 모두 입력해주세요.',
    });
  }

  const phoneRegex = /^010-\d{4}-\d{4}$/;

  if (!phoneRegex.test(normalizedPhone)) {
    return res.status(400).json({
      success: false,
      message: '휴대전화 번호는 010-0000-0000 형식으로 입력해주세요.',
    });
  }

  try {
    const [existingUsers] = await db.query(
      'SELECT id FROM users WHERE username = ?',
      [username]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: '이미 사용 중인 아이디입니다.',
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    await db.query(
      `
      INSERT INTO users (username, password_hash, phone, needs_wheelchair)
      VALUES (?, ?, ?, ?)
      `,
      [username, passwordHash, normalizedPhone, needsWheelchair ? 1 : 0]
    );

    return res.status(201).json({
      success: true,
      message: '회원가입이 완료되었습니다.',
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '회원가입 중 서버 오류가 발생했습니다.',
    });
  }
});

router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: '아이디와 비밀번호를 입력해주세요.',
    });
  }

  try {
    const [users] = await db.query(
      `
      SELECT id, username, password_hash, phone, needs_wheelchair
      FROM users
      WHERE username = ?
      `,
      [username]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: '아이디 또는 비밀번호가 올바르지 않습니다.',
      });
    }

    const user = users[0];

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: '아이디 또는 비밀번호가 올바르지 않습니다.',
      });
    }

    return res.json({
      success: true,
      message: '로그인 성공',
      user: {
        id: user.id,
        username: user.username,
        phone: user.phone,
        needsWheelchair: user.needs_wheelchair === 1,
      },
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '로그인 중 서버 오류가 발생했습니다.',
    });
  }
});

// 현재 로그인한 사용자 프로필 조회
router.get('/profile/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const [users] = await db.query(
      `
      SELECT id, username, phone, needs_wheelchair
      FROM users
      WHERE id = ?
      `,
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.',
      });
    }

    const user = users[0];

    return res.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        phone: user.phone,
        needsWheelchair: user.needs_wheelchair === 1,
      },
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '프로필 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

// 휴대전화, 휠체어 탑승 여부 수정
router.put('/profile/:userId', async (req, res) => {
  const { userId } = req.params;
  const { phone, needsWheelchair } = req.body;

  const normalizedPhone = phone?.trim();

  if (!normalizedPhone || typeof needsWheelchair !== 'boolean') {
    return res.status(400).json({
      success: false,
      message: '휴대전화와 휠체어 탑승 여부를 모두 입력해주세요.',
    });
  }

  const phoneRegex = /^010-\d{4}-\d{4}$/;

  if (!phoneRegex.test(normalizedPhone)) {
    return res.status(400).json({
      success: false,
      message: '휴대전화 번호는 010-0000-0000 형식으로 입력해주세요.',
    });
  }

  try {
    const [users] = await db.query(
      `
      SELECT id, username, phone, needs_wheelchair
      FROM users
      WHERE id = ?
      `,
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.',
      });
    }

    const user = users[0];

    // 휠체어 사용자에서 일반 사용자로 바꾸려는 경우,
    // 활성 예약이 있으면 먼저 예약을 취소하게 막는다.
    if (user.needs_wheelchair === 1 && needsWheelchair === false) {
      const [activeReservations] = await db.query(
        `
        SELECT id
        FROM reservations
        WHERE user_id = ?
          AND status = 'active'
        LIMIT 1
        `,
        [userId]
      );

      if (activeReservations.length > 0) {
        return res.status(409).json({
          success: false,
          message: '활성 예약이 있어 휠체어 탑승 여부를 변경할 수 없습니다. 예약을 취소한 뒤 다시 시도해주세요.',
        });
      }
    }

    await db.query(
      `
      UPDATE users
      SET phone = ?, needs_wheelchair = ?
      WHERE id = ?
      `,
      [normalizedPhone, needsWheelchair ? 1 : 0, userId]
    );

    return res.json({
      success: true,
      message: '프로필이 수정되었습니다.',
      user: {
        id: user.id,
        username: user.username,
        phone: normalizedPhone,
        needsWheelchair,
      },
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '프로필 수정 중 서버 오류가 발생했습니다.',
    });
  }
});

module.exports = router;