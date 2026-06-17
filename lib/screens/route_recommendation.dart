import 'dart:math';

/// 추천 이동 수단
enum RecommendedMode { bus, walk }

/// 최종 추천 결과
class RouteDecision {
  final RecommendedMode mode;

  final int? busTotalMinutes; // T_bus_total = T_wait + T_travel
  final int? walkMinutes; // T_walk
  final int? waitMinutes; // T_wait (추천 버스 도착까지)
  final int? travelMinutes; // T_travel (출발 정류장 -> 다음 수업 건물 방향 버스 이동)
  final int? limitMinutes; // T_limit (수업까지 남은 시간)

  final int waitingCount; // N_wait (보정된 대기 인원)
  final int failedBusCount; // K (만차로 보낸 버스 수)

  /// 추천 수단으로 가도 수업 시간 안에 못 들어가는 경우 true
  final bool willBeLate;

  final String reason; // UI에 보여줄 한 줄 설명

  const RouteDecision({
    required this.mode,
    required this.waitingCount,
    required this.failedBusCount,
    required this.willBeLate,
    required this.reason,
    this.busTotalMinutes,
    this.walkMinutes,
    this.waitMinutes,
    this.travelMinutes,
    this.limitMinutes,
  });

  bool get isBus => mode == RecommendedMode.bus;
  bool get isWalk => mode == RecommendedMode.walk;
}

class RouteRecommender {
  // ---------------------------------------------------------------------------
  // 튜닝 상수
  // ---------------------------------------------------------------------------

  /// 도보 속도 (m/분). 약 1.1m/s. 캠퍼스 경사를 감안한 보수적 값.
  /// 네이버/카카오 지도 기준(80m/분)을 쓰고 싶으면 80으로 바꾸면 됨.
  static const double walkingSpeedMetersPerMin = 67.0;

  /// 지구 반지름 (m) - Haversine 계산용
  static const double earthRadiusMeters = 6371000.0;

  // ---------------------------------------------------------------------------
  // 1) 의견 제보 혼잡도 -> 혼잡도 지수 p (1~4)
  // ---------------------------------------------------------------------------

  /// 여유=1, 보통=2, 약간 혼잡=3, 혼잡=4, 그 외(정보 없음/-)=0
  static int congestionLevelToIndex(String? level) {
    switch (level?.trim()) {
      case '여유':
        return 1;
      case '보통':
        return 2;
      case '약간 혼잡':
        return 3;
      case '혼잡':
        return 4;
      default:
        return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // 2) 보정 대기 인원 N_wait = MAX(N_app, 10p + 5)
  // ---------------------------------------------------------------------------

  /// [nApp]   : 앱/CCTV로 확인된 명시적 대기 인원 (없으면 0)
  /// [p]      : 의견 제보 혼잡도 지수 (0~4)
  ///
  /// p == 0 (제보 없음)일 때는 근거 없이 +5를 더하지 않고 nApp 그대로 사용.
  /// p >= 1 일 때만 10p+5(=15/25/35/45)를 비사용자 포함 추정치로 적용.
  static int estimateWaitingCount({required int nApp, required int p}) {
    final reportEstimate = (p <= 0) ? 0 : (10 * p) + 5;
    return max(nApp, reportEstimate);
  }

  // ---------------------------------------------------------------------------
  // 3) 도보 시간 T_walk
  // ---------------------------------------------------------------------------

  /// 두 좌표 사이 직선 거리(m) - Haversine
  static double haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    double toRad(double deg) => deg * pi / 180;

    final dLat = toRad(lat2 - lat1);
    final dLng = toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRad(lat1)) * cos(toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// 거리(m)로부터 도보 소요 시간(분)을 올림 계산.
  static int walkMinutesFromDistance(double distanceMeters) {
    if (distanceMeters <= 0) return 0;
    return (distanceMeters / walkingSpeedMetersPerMin).ceil();
  }

  /// 현재 좌표 -> 목적지 좌표 도보 시간(분).
  static int walkMinutesBetween(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    final distance = haversineMeters(fromLat, fromLng, toLat, toLng);
    return walkMinutesFromDistance(distance);
  }

  // ---------------------------------------------------------------------------
  // 4) 최종 판단 규칙 (Decision Rule)
  //
  //    T_bus_total = T_wait + T_travel
  //    if (T_bus_total <= T_limit)  -> 버스
  //    else                         -> min(T_bus_total, T_walk) 가장 빠른 수단
  //
  //    + 예외 처리:
  //      - 버스 정보 없음(busTotal == null) -> 도보
  //      - 도보 정보 없음(walk == null)     -> 버스
  //      - 둘 다 없음                        -> 버스(기본값)로 두고 reason 안내
  // ---------------------------------------------------------------------------

  static RouteDecision decide({
    required int waitingCount, // N_wait
    required int failedBusCount, // K
    int? waitMinutes, // T_wait (추천 버스 없으면 null)
    int? travelMinutes, // T_travel, home_screen.dart에서 계산한 버스 이동 시간
    int? walkMinutes, // T_walk (GPS 없으면 null)
    int? limitMinutes, // T_limit (수업 없으면 null)
  }) {
    // T_bus_total: 추천 버스가 있고 이동시간도 알 때만 계산 가능
    final int? busTotal = (waitMinutes != null && travelMinutes != null)
        ? waitMinutes + travelMinutes
        : null;

    RecommendedMode mode;
    String reason;
    bool willBeLate = false;

    if (busTotal == null && walkMinutes == null) {
      mode = RecommendedMode.bus;
      reason = waitMinutes == null
          ? '현재 확인 가능한 버스 도착 정보가 없어, 도보 이동을 함께 고려해 주세요.'
          : '도보 이동 정보를 확인할 수 없어, 현재 버스 도착 정보를 기준으로 안내합니다.';

    } else if (busTotal == null) {
      // 탈 수 있는 버스가 없음 -> 도보
      mode = RecommendedMode.walk;
      reason = '대기 인원이 많아 가까운 버스 탑승이 어려울 수 있어, 도보 이동을 추천합니다.';
      willBeLate = (limitMinutes != null && walkMinutes! > limitMinutes);

    } else if (walkMinutes == null) {
      // 위치 정보 없음 -> 버스
      mode = RecommendedMode.bus;
      reason = '도보 이동 정보를 확인할 수 없어, 현재 버스 도착 정보를 기준으로 안내합니다.';
      willBeLate = (limitMinutes != null && busTotal > limitMinutes);

    } else if (limitMinutes != null && busTotal <= limitMinutes) {
      // 버스로 수업 시간 안에 도착 가능 -> 버스 우선
      mode = RecommendedMode.bus;
      reason = '버스 도착 시간과 다음 수업까지 남은 시간을 기준으로, 버스 이동을 추천합니다.';
      willBeLate = false;

    } else {
      // 버스가 수업 시간을 못 맞추거나 수업 일정이 없음 -> 더 빠른 수단
      if (walkMinutes < busTotal) {
        mode = RecommendedMode.walk;
        reason = limitMinutes == null
            ? '예상 이동 시간이 더 짧아, 도보 이동을 추천합니다.'
            : '버스 이동으로는 다음 수업 시간에 맞추기 어려워, 도보 이동을 추천합니다.';
      } else {
        mode = RecommendedMode.bus;
        reason = limitMinutes == null
            ? '예상 이동 시간이 더 짧아, 버스 이동을 추천합니다.'
            : '도보 이동보다 버스 이동의 예상 소요 시간이 더 짧아, 버스 이동을 추천합니다.';
      }

      final chosen = (mode == RecommendedMode.walk) ? walkMinutes : busTotal;
      willBeLate = (limitMinutes != null && chosen > limitMinutes);
    }

    return RouteDecision(
      mode: mode,
      waitingCount: waitingCount,
      failedBusCount: failedBusCount,
      willBeLate: willBeLate,
      reason: reason,
      busTotalMinutes: busTotal,
      walkMinutes: walkMinutes,
      waitMinutes: waitMinutes,
      travelMinutes: travelMinutes,
      limitMinutes: limitMinutes,
    );
  }
}