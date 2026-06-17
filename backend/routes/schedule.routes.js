const express = require('express');
const db = require('../db');

const router = express.Router();

const allowedDays = ['월', '화', '수', '목', '금'];

const allowedBuildings = [
  '공학관',
  '외국어대학관',
  '체육대학관',
  '멀티미디어교육관',
  '생명과학대학관',
  '전자정보대학관',
  '예술디자인대학관',
  '국제학관',
];

const isValidTime = (time) => {
  if (typeof time !== 'string') return false;

  const parts = time.trim().split(':');
  if (parts.length !== 2) return false;

  const hour = Number(parts[0]);
  const minute = Number(parts[1]);

  if (!Number.isInteger(hour) || !Number.isInteger(minute)) return false;
  if (hour < 0 || hour > 23) return false;
  if (minute < 0 || minute > 59) return false;

  return true;
};

const timeToMinute = (time) => {
  const [hour, minute] = time.split(':').map(Number);
  return hour * 60 + minute;
};

// 사용자 시간표 전체 조회
router.get('/user/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const [schedules] = await db.query(
      `
      SELECT
        id,
        user_id AS userId,
        day_of_week AS dayOfWeek,
        start_time AS startTime,
        end_time AS endTime,
        building_name AS buildingName,
        room_number AS roomNumber,
        created_at AS createdAt
      FROM user_schedules
      WHERE user_id = ?
      ORDER BY
        FIELD(day_of_week, '월', '화', '수', '목', '금'),
        start_time
      `,
      [userId]
    );

    return res.json({
      success: true,
      schedules,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '시간표 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

// 시간표 추가
router.post('/', async (req, res) => {
  const {
    userId,
    dayOfWeek,
    startTime,
    endTime,
    buildingName,
    roomNumber,
  } = req.body;

  const normalizedDay = dayOfWeek?.trim();
  const normalizedStartTime = startTime?.trim();
  const normalizedEndTime = endTime?.trim();
  const normalizedBuildingName = buildingName?.trim();
  const normalizedRoomNumber = roomNumber?.trim();

  if (
    !userId ||
    !normalizedDay ||
    !normalizedStartTime ||
    !normalizedEndTime ||
    !normalizedBuildingName ||
    !normalizedRoomNumber
  ) {
    return res.status(400).json({
      success: false,
      message: '시간표 정보를 모두 입력해주세요.',
    });
  }

  if (!allowedDays.includes(normalizedDay)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 요일입니다.',
    });
  }

  if (!allowedBuildings.includes(normalizedBuildingName)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 강의 건물입니다.',
    });
  }

  if (!isValidTime(normalizedStartTime) || !isValidTime(normalizedEndTime)) {
    return res.status(400).json({
      success: false,
      message: '시간 형식이 올바르지 않습니다.',
    });
  }

  if (timeToMinute(normalizedStartTime) >= timeToMinute(normalizedEndTime)) {
    return res.status(400).json({
      success: false,
      message: '종료 시간은 시작 시간보다 늦어야 합니다.',
    });
  }

  try {
    const [users] = await db.query(
      `
      SELECT id
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

    const [overlappingSchedules] = await db.query(
      `
      SELECT id
      FROM user_schedules
      WHERE user_id = ?
        AND day_of_week = ?
        AND TIME_TO_SEC(start_time) < TIME_TO_SEC(?)
        AND TIME_TO_SEC(end_time) > TIME_TO_SEC(?)
      LIMIT 1
      `,
      [
        userId,
        normalizedDay,
        normalizedEndTime,
        normalizedStartTime,
      ]
    );

    if (overlappingSchedules.length > 0) {
      return res.status(409).json({
        success: false,
        message: '같은 시간대에 이미 등록된 수업이 있습니다.',
      });
    }

    await db.query(
      `
      INSERT INTO user_schedules
        (user_id, day_of_week, start_time, end_time, building_name, room_number)
      VALUES (?, ?, ?, ?, ?, ?)
      `,
      [
        userId,
        normalizedDay,
        normalizedStartTime,
        normalizedEndTime,
        normalizedBuildingName,
        normalizedRoomNumber,
      ]
    );

    return res.status(201).json({
      success: true,
      message: '시간표가 추가되었습니다.',
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '시간표 추가 중 서버 오류가 발생했습니다.',
    });
  }
});

// 시간표 수정
router.put('/:scheduleId', async (req, res) => {
  const { scheduleId } = req.params;

  const {
    userId,
    dayOfWeek,
    startTime,
    endTime,
    buildingName,
    roomNumber,
  } = req.body;

  const normalizedDay = dayOfWeek?.trim();
  const normalizedStartTime = startTime?.trim();
  const normalizedEndTime = endTime?.trim();
  const normalizedBuildingName = buildingName?.trim();
  const normalizedRoomNumber = roomNumber?.trim();

  if (
    !userId ||
    !normalizedDay ||
    !normalizedStartTime ||
    !normalizedEndTime ||
    !normalizedBuildingName ||
    !normalizedRoomNumber
  ) {
    return res.status(400).json({
      success: false,
      message: '시간표 정보를 모두 입력해주세요.',
    });
  }

  if (!allowedDays.includes(normalizedDay)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 요일입니다.',
    });
  }

  if (!allowedBuildings.includes(normalizedBuildingName)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 강의 건물입니다.',
    });
  }

  if (!isValidTime(normalizedStartTime) || !isValidTime(normalizedEndTime)) {
    return res.status(400).json({
      success: false,
      message: '시간 형식이 올바르지 않습니다.',
    });
  }

  if (timeToMinute(normalizedStartTime) >= timeToMinute(normalizedEndTime)) {
    return res.status(400).json({
      success: false,
      message: '종료 시간은 시작 시간보다 늦어야 합니다.',
    });
  }

  try {
    const [users] = await db.query(
      `
      SELECT id
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

    const [existingSchedules] = await db.query(
      `
      SELECT id
      FROM user_schedules
      WHERE id = ?
        AND user_id = ?
      LIMIT 1
      `,
      [scheduleId, userId]
    );

    if (existingSchedules.length === 0) {
      return res.status(404).json({
        success: false,
        message: '수정할 시간표를 찾을 수 없습니다.',
      });
    }

    const [overlappingSchedules] = await db.query(
      `
      SELECT id
      FROM user_schedules
      WHERE user_id = ?
        AND day_of_week = ?
        AND id != ?
        AND TIME_TO_SEC(start_time) < TIME_TO_SEC(?)
        AND TIME_TO_SEC(end_time) > TIME_TO_SEC(?)
      LIMIT 1
      `,
      [
        userId,
        normalizedDay,
        scheduleId,
        normalizedEndTime,
        normalizedStartTime,
      ]
    );

    if (overlappingSchedules.length > 0) {
      return res.status(409).json({
        success: false,
        message: '같은 시간대에 이미 등록된 수업이 있습니다.',
      });
    }

    await db.query(
      `
      UPDATE user_schedules
      SET
        day_of_week = ?,
        start_time = ?,
        end_time = ?,
        building_name = ?,
        room_number = ?
      WHERE id = ?
        AND user_id = ?
      `,
      [
        normalizedDay,
        normalizedStartTime,
        normalizedEndTime,
        normalizedBuildingName,
        normalizedRoomNumber,
        scheduleId,
        userId,
      ]
    );

    return res.json({
      success: true,
      message: '시간표가 수정되었습니다.',
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '시간표 수정 중 서버 오류가 발생했습니다.',
    });
  }
});

// 시간표 삭제
router.delete('/:scheduleId', async (req, res) => {
  const { scheduleId } = req.params;
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: '사용자 정보가 필요합니다.',
    });
  }

  try {
    const [result] = await db.query(
      `
      DELETE FROM user_schedules
      WHERE id = ? AND user_id = ?
      `,
      [scheduleId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '삭제할 시간표를 찾을 수 없습니다.',
      });
    }

    return res.json({
      success: true,
      message: '시간표가 삭제되었습니다.',
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '시간표 삭제 중 서버 오류가 발생했습니다.',
    });
  }
});

// 오늘 현재 시각 이후 가장 가까운 수업 조회
router.get('/user/:userId/today/next', async (req, res) => {
  const { userId } = req.params;

  const dayMap = ['일', '월', '화', '수', '목', '금', '토'];
  const now = new Date();
  const today = dayMap[now.getDay()];

  if (!allowedDays.includes(today)) {
    return res.json({
      success: true,
      nextSchedule: null,
      message: '오늘은 등록 가능한 수업 요일이 아닙니다.',
    });
  }

  const currentMinute = now.getHours() * 60 + now.getMinutes();

  try {
    const [schedules] = await db.query(
      `
      SELECT
        id,
        user_id AS userId,
        day_of_week AS dayOfWeek,
        start_time AS startTime,
        end_time AS endTime,
        building_name AS buildingName,
        room_number AS roomNumber,
        created_at AS createdAt
      FROM user_schedules
      WHERE user_id = ?
        AND day_of_week = ?
      ORDER BY start_time
      `,
      [userId, today]
    );

    const nextSchedule =
      schedules.find((schedule) => {
        return timeToMinute(schedule.startTime) >= currentMinute;
      }) ?? null;

    return res.json({
      success: true,
      nextSchedule,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '다음 수업 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

module.exports = router;