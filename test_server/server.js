const http = require('http');
const { URL } = require('url');

const PORT = 3000;

// 정류장별 현재 대기인원 저장
const waitingCounts = {
  '정문': 0,
  '외대': 0,
  '전정대': 0,
};

// JSON 응답 보내기
function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  });

  res.end(JSON.stringify(data));
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  // CORS 사전 요청 처리
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
    res.end();
    return;
  }

  // 서버 실행 확인용
  if (req.method === 'GET' && url.pathname === '/') {
    sendJson(res, 200, {
      message: 'IDLE waiting count server is running',
      waitingCounts,
    });
    return;
  }

  // Flutter 앱이 현재 대기인원을 조회할 때 사용
  // 예: GET /waiting-count?station=정문
  if (req.method === 'GET' && url.pathname === '/waiting-count') {
    const station = url.searchParams.get('station');

    if (!station || !(station in waitingCounts)) {
      sendJson(res, 400, {
        message: '올바른 정류장을 입력하세요.',
      });
      return;
    }

    sendJson(res, 200, {
      station,
      count: waitingCounts[station],
      updatedAt: new Date().toISOString(),
    });
    return;
  }

  // Python 객체검출 프로그램이 인원 수를 보낼 때 사용
  // 예: POST /waiting-count
  if (req.method === 'POST' && url.pathname === '/waiting-count') {
    let body = '';

    req.on('data', (chunk) => {
      body += chunk;
    });

    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const station = data.station;
        const count = data.count;

        if (!station || !(station in waitingCounts)) {
          sendJson(res, 400, {
            message: '올바른 정류장을 입력하세요.',
          });
          return;
        }

        if (!Number.isInteger(count) || count < 0) {
          sendJson(res, 400, {
            message: 'count는 0 이상의 정수여야 합니다.',
          });
          return;
        }

        waitingCounts[station] = count;

        console.log(`[업데이트] ${station} 현재 대기인원: ${count}명`);

        sendJson(res, 200, {
          message: '대기인원이 저장되었습니다.',
          station,
          count,
          updatedAt: new Date().toISOString(),
        });
      } catch (error) {
        sendJson(res, 400, {
          message: 'JSON 형식이 올바르지 않습니다.',
        });
      }
    });

    return;
  }

  sendJson(res, 404, {
    message: '요청한 주소를 찾을 수 없습니다.',
  });
});

server.listen(PORT, () => {
  console.log('==============================');
  console.log('IDLE 임시 서버 실행 완료');
  console.log(`주소: http://localhost:${PORT}`);
  console.log('종료: Ctrl + C');
  console.log('==============================');
});