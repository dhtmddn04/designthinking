const express = require('express');

const router = express.Router();

const allowedStations = ['정문', '외대', '전정대'];

// 실시간 CCTV 대기인원 저장용
// 지금은 정문 웹캠만 사용하므로 정문 값이 실제로 갱신됨
const waitingCounts = {
  정문: {
    count: 0,
    updatedAt: null,
  },
  외대: {
    count: 0,
    updatedAt: null,
  },
  전정대: {
    count: 0,
    updatedAt: null,
  },
};

// Python CCTV 프로그램이 현재 인원 수를 보내는 API
router.post('/', (req, res) => {
  const { station, count } = req.body;

  if (!allowedStations.includes(station)) {
    return res.status(400).json({
      success: false,
      message: '지원하지 않는 정류장입니다.',
    });
  }

  const numericCount = Number(count);

  if (!Number.isInteger(numericCount) || numericCount < 0) {
    return res.status(400).json({
      success: false,
      message: '대기인원 값이 올바르지 않습니다.',
    });
  }

  waitingCounts[station] = {
    count: numericCount,
    updatedAt: new Date().toISOString(),
  };

  console.log(`[CCTV] ${station} 현재 대기인원: ${numericCount}명`);

  return res.json({
    success: true,
    station,
    count: numericCount,
    updatedAt: waitingCounts[station].updatedAt,
  });
});

// Flutter 앱이 현재 대기인원을 조회하는 API
router.get('/', (req, res) => {
  const station = req.query.station?.trim();

  if (!allowedStations.includes(station)) {
    return res.status(400).json({
      success: false,
      message: '지원하지 않는 정류장입니다.',
    });
  }

  return res.json({
    success: true,
    station,
    count: waitingCounts[station].count,
    updatedAt: waitingCounts[station].updatedAt,
  });
});

module.exports = router;