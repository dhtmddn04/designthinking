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

module.exports = router;