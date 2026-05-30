const express = require('express');
const db = require('../db');

const router = express.Router();

const allowedStops = ['정문', '외대', '전정대'];
const allowedLevels = ['여유', '보통', '약간 혼잡', '혼잡'];

const createEmptyLevelCounts = () => ({
  '여유': 0,
  '보통': 0,
  '약간 혼잡': 0,
  '혼잡': 0,
});

// 프론트의 _highlightLevel과 동일하게 동률이면 먼저 누적된 값 유지.
// 즉 allowedLevels 순서상 여유 → 보통 → 약간 혼잡 → 혼잡 순서에서
// 먼저 max가 된 값을 유지한다.
const getMostReportedLevel = (levelCounts) => {
  let selectedLevel = null;
  let selectedCount = 0;

  for (const level of allowedLevels) {
    const count = levelCounts[level] ?? 0;

    if (count > selectedCount) {
      selectedLevel = level;
      selectedCount = count;
    }
  }

  return selectedLevel;
};

router.post('/', async (req, res) => {
  const { userId, stopName, congestionLevel, comment } = req.body;

  const normalizedStopName = stopName?.trim();
  const normalizedCongestionLevel = congestionLevel?.trim();
  const normalizedComment = comment?.trim();

  if (!normalizedStopName || !normalizedCongestionLevel) {
    return res.status(400).json({
      success: false,
      message: '정류장과 혼잡도 정보가 필요합니다.',
    });
  }

  if (!allowedStops.includes(normalizedStopName)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 정류장 값입니다.',
    });
  }

  if (!allowedLevels.includes(normalizedCongestionLevel)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 혼잡도 값입니다.',
    });
  }

  try {
    await db.query(
      `
      INSERT INTO crowd_reports
        (user_id, stop_name, congestion_level, comment)
      VALUES (?, ?, ?, ?)
      `,
      [
        userId || null,
        normalizedStopName,
        normalizedCongestionLevel,
        normalizedComment || null,
      ]
    );

    return res.status(201).json({
      success: true,
      message: '혼잡도 제보가 저장되었습니다.',
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '혼잡도 제보 저장 중 서버 오류가 발생했습니다.',
    });
  }
});

router.get('/recent', async (req, res) => {
  const { stopName } = req.query;
  const normalizedStopName = stopName?.trim();

  if (!normalizedStopName) {
    return res.status(400).json({
      success: false,
      message: '정류장 정보가 필요합니다.',
    });
  }

  if (!allowedStops.includes(normalizedStopName)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 정류장 값입니다.',
    });
  }

  try {
    const [reports] = await db.query(
      `
      SELECT id, user_id, stop_name, congestion_level, comment, created_at
      FROM crowd_reports
      WHERE stop_name = ?
        AND created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
      ORDER BY created_at DESC
      LIMIT 50
      `,
      [normalizedStopName]
    );

    return res.json({
      success: true,
      reports,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '최근 혼잡도 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

router.get('/summary', async (req, res) => {
  const { stopName } = req.query;
  const normalizedStopName = stopName?.trim();

  if (!normalizedStopName) {
    return res.status(400).json({
      success: false,
      message: '정류장 정보가 필요합니다.',
    });
  }

  if (!allowedStops.includes(normalizedStopName)) {
    return res.status(400).json({
      success: false,
      message: '올바르지 않은 정류장 값입니다.',
    });
  }

  try {
    const [reports] = await db.query(
      `
      SELECT congestion_level
      FROM crowd_reports
      WHERE stop_name = ?
        AND created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
      ORDER BY created_at DESC
      LIMIT 100
      `,
      [normalizedStopName]
    );

    const levelCounts = createEmptyLevelCounts();

    for (const report of reports) {
      if (levelCounts[report.congestion_level] !== undefined) {
        levelCounts[report.congestion_level] += 1;
      }
    }

    const congestionLevel = getMostReportedLevel(levelCounts);

    return res.json({
      success: true,
      summary: {
        stopName: normalizedStopName,
        congestionLevel: congestionLevel ?? '정보 없음',
        reportCount: reports.length,
        levelCounts,
      },
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '혼잡도 요약 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

router.get('/summary/all', async (req, res) => {
  try {
    const summaries = {};

    for (const stopName of allowedStops) {
      const [reports] = await db.query(
        `
        SELECT congestion_level
        FROM crowd_reports
        WHERE stop_name = ?
          AND created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
        ORDER BY created_at DESC
        LIMIT 100
        `,
        [stopName]
      );

      const levelCounts = createEmptyLevelCounts();

      for (const report of reports) {
        if (levelCounts[report.congestion_level] !== undefined) {
          levelCounts[report.congestion_level] += 1;
        }
      }

      const congestionLevel = getMostReportedLevel(levelCounts);

      summaries[stopName] = {
        stopName,
        congestionLevel: congestionLevel ?? '정보 없음',
        reportCount: reports.length,
        levelCounts,
      };
    }

    return res.json({
      success: true,
      summaries,
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: '전체 혼잡도 요약 조회 중 서버 오류가 발생했습니다.',
    });
  }
});

module.exports = router;