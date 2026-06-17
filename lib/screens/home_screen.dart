import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'boarding_prediction_screen.dart';
import 'route_recommendation.dart';

enum TransportMode { none, bus, walk }

class BusRouteOption {
  final int travelMinutes;
  final String routeText;

  const BusRouteOption({
    required this.travelMinutes,
    required this.routeText,
  });
}

class HomeScreen extends StatefulWidget {
  final int? userId;
  final int refreshVersion;
  final bool isActive;

  const HomeScreen({
    super.key,
    required this.userId,
    this.refreshVersion = 0,
    this.isActive = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedStation = '정문';

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  bool _locationPermissionGranted = false;

  static const Map<String, Map<String, double>> stationCoordinates = {
    '정문': {'lat': 37.2475167, 'lng': 127.0779039},
    '외대': {'lat': 37.24512, 'lng': 127.078460},
    '전정대': {'lat': 37.24051, 'lng': 127.0825},
  };

  static const Map<String, Map<String, double>> destinationCoordinates = {
    '공학관': {'lat': 37.2464962, 'lng': 127.0808592},
    '외국어대학관': {'lat': 37.245336, 'lng': 127.077709},
    '체육대학관': {'lat': 37.244540, 'lng': 127.080433},
    '멀티미디어교육관': {'lat': 37.244515, 'lng': 127.076807},
    '생명과학대학관': {'lat': 37.242943, 'lng': 127.081077},
    '전자정보대학관': {'lat': 37.239821, 'lng': 127.083287},
    '예술디자인대학관': {'lat': 37.241641, 'lng': 127.084424},
    '국제학관': {'lat': 37.239856, 'lng': 127.081200},
  };

  static const Map<String, List<String>> walkingOnlyBuildingsByStation = {
    '정문': [
      '공학관',
    ],
    '외대': [
      '외국어대학관',
      '멀티미디어교육관',
    ],
    '전정대': [
      '전자정보대학관',
      '예술디자인대학관',
      '국제학관',
    ],
  };

  static const Map<String, Map<String, BusRouteOption>>
  busRouteOptionsByStationAndBuilding = {
    // 교내 진입 방향: 정문 → 외대 → 생대1 → 사색의 광장
    '정문': {
      '외국어대학관': BusRouteOption(
        travelMinutes: 1,
        routeText: '외대 정류장 하차',
      ),

      // 정문 → 외대 정류장 1분 + 외대 정류장 → 멀관 도보 3분
      '멀티미디어교육관': BusRouteOption(
        travelMinutes: 4,
        routeText: '외대 정류장 하차 후 도보 3분',
      ),

      '생명과학대학관': BusRouteOption(
        travelMinutes: 3,
        routeText: '생대1 정류장 하차',
      ),

      // 정문 → 사색의 광장 5분 + 사색의 광장 → 전정대 도보 3분
      '전자정보대학관': BusRouteOption(
        travelMinutes: 8,
        routeText: '사색의 광장 하차 후 도보 3분',
      ),

      // 정문 → 사색의 광장 5분 + 사색의 광장 → 예대 도보 4분
      '예술디자인대학관': BusRouteOption(
        travelMinutes: 9,
        routeText: '사색의 광장 하차 후 도보 4분',
      ),

      // 정문 → 사색의 광장 5분 + 사색의 광장 → 국제대 도보 3분
      '국제학관': BusRouteOption(
        travelMinutes: 8,
        routeText: '사색의 광장 하차 후 도보 3분',
      ),

      // 정문 → 체대는 외대에서 내려 걸어가는 우회 경로
      // 정확한 도보 시간이 정해지면 8을 수정하면 됨
      '체육대학관': BusRouteOption(
        travelMinutes: 8,
        routeText: '외대 정류장 하차 후 도보',
      ),

      // 정문 → 공학관은 넣지 않음
      // walkingOnlyBuildingsByStation에서 무조건 도보 처리
    },

    // 외대 출발: 외대/멀관은 walkingOnly에서 도보 처리
    '외대': {
      '생명과학대학관': BusRouteOption(
        travelMinutes: 2,
        routeText: '생대1 정류장 하차',
      ),

      // 외대 → 사색의 광장 4분 + 사색의 광장 → 전정대 도보 3분
      '전자정보대학관': BusRouteOption(
        travelMinutes: 7,
        routeText: '사색의 광장 하차 후 도보 3분',
      ),

      // 외대 → 사색의 광장 4분 + 사색의 광장 → 예대 도보 4분
      '예술디자인대학관': BusRouteOption(
        travelMinutes: 8,
        routeText: '사색의 광장 하차 후 도보 4분',
      ),

      // 외대 → 사색의 광장 4분 + 사색의 광장 → 국제대 도보 3분
      '국제학관': BusRouteOption(
        travelMinutes: 7,
        routeText: '사색의 광장 하차 후 도보 3분',
      ),
    },

    // 교내 나가는 방향: 전정대 → 생대2 → 체대
    '전정대': {
      '생명과학대학관': BusRouteOption(
        travelMinutes: 2,
        routeText: '생대2 정류장 하차',
      ),

      '체육대학관': BusRouteOption(
        travelMinutes: 4,
        routeText: '체대 정류장 하차',
      ),

      // 전정대 → 체대 4분 + 체대 → 공학관 도보 5분
      '공학관': BusRouteOption(
        travelMinutes: 9,
        routeText: '체대 정류장 하차 후 도보 5분',
      ),

      // 전정대 → 외대/멀관은 체대에서 내려 걸어가는 우회 경로
      // 아직 정확한 도보 시간이 없으면 기존 추정값 유지
      '외국어대학관': BusRouteOption(
        travelMinutes: 9,
        routeText: '체대 정류장 하차 후 도보',
      ),

      '멀티미디어교육관': BusRouteOption(
        travelMinutes: 8,
        routeText: '체대 정류장 하차 후 도보',
      ),
    },
  };

  bool _isWalkingOnlyBuilding({
    required String station,
    required String building,
  }) {
    return walkingOnlyBuildingsByStation[station]?.contains(building) == true;
  }

  BusRouteOption? _busRouteOptionToBuilding({
    required String station,
    required String building,
  }) {
    return busRouteOptionsByStationAndBuilding[station]?[building];
  }

  static const double nearStationThresholdMeters = 50.0;

  String? activeStation;
  Timer? _congestionTimer;
  Timer? _scheduleTimer;
  Timer? _busTimetableTimer;
  Timer? _waitingCountTimer;
  bool _isOpeningPrediction = false;

  // ──────────────────────────────────────────────
  // 원터치 혼잡도 제보
  // ──────────────────────────────────────────────
  static const List<_QuickCongestionOption> _quickReportOptions = [
    _QuickCongestionOption(
      level: '여유',
      label: '여유',
      icon: Icons.sentiment_very_satisfied_rounded,
      bgColor: Color(0xFFECFDF5),
      borderColor: Color(0xFFA7F3D0),
      iconBgColor: Color(0xFFD1FAE5),
      iconColor: Color(0xFF10B981),
      textColor: Color(0xFF047857),
      dotColor: Color(0xFF34D399),
    ),
    _QuickCongestionOption(
      level: '보통',
      label: '보통',
      icon: Icons.sentiment_satisfied_alt_rounded,
      bgColor: Color(0xFFEFF6FF),
      borderColor: Color(0xFFBFDBFE),
      iconBgColor: Color(0xFFDBEAFE),
      iconColor: Color(0xFF2563EB),
      textColor: Color(0xFF1D4ED8),
      dotColor: Color(0xFF60A5FA),
    ),
    _QuickCongestionOption(
      level: '약간 혼잡',
      label: '약간\n혼잡',
      icon: Icons.sentiment_neutral_rounded,
      bgColor: Color(0xFFFFFBEB),
      borderColor: Color(0xFFFDE68A),
      iconBgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFF59E0B),
      textColor: Color(0xFFB45309),
      dotColor: Color(0xFFFBBF24),
    ),
    _QuickCongestionOption(
      level: '혼잡',
      label: '혼잡',
      icon: Icons.sentiment_very_dissatisfied_rounded,
      bgColor: Color(0xFFFEF2F2),
      borderColor: Color(0xFFFECACA),
      iconBgColor: Color(0xFFFEE2E2),
      iconColor: Color(0xFFEF4444),
      textColor: Color(0xFFB91C1C),
      dotColor: Color(0xFFF87171),
    ),
  ];

  static const Duration _quickReportCooldown = Duration(minutes: 5);

// 사용자별 마지막 원터치 제보 시간
  static final Map<int, DateTime> _lastQuickReportedAtByUser = {};

  // 정류장별로 "다음에 다시 팝업을 띄울 수 있는 시간" 저장
  final Map<String, DateTime> _quickReportSnoozedUntilByStation = {};

  Timer? _quickReportPromptTimer;

  bool _isQuickReportSheetOpen = false;
  bool _isSubmittingQuickReport = false;

  List<Map<String, dynamic>> _schedules = [];
  String _classTimeText = '-';
  String _nextClassText = '-';
  int? _nextClassRemainMinute;
  String? _nextClassBuilding;

  final Map<String, TransportMode> transportModeByStation = {
    '정문': TransportMode.none,
    '외대': TransportMode.none,
    '전정대': TransportMode.none,
  };

  final Map<String, int?> myWaitingNumberByStation = {
    '정문': null,
    '외대': null,
    '전정대': null,
  };

  Map<String, int> waitingCountByStation = {};
  static const int busCapacity = 40;
  final List<String> stations = ['정문', '외대', '전정대'];

  final Map<String, Map<String, dynamic>> stationData = {
    '정문': {
      'recommend': '버스',
      'reason': '',
      'bus': '1112번',
      'arrival': '3분 후',
      'arrivalMinute': 3,
      'remainSeatCnt': null,
      'crowded': null,
      'hasWheelchairReservation': false,
      'wheelchairReservationCount': 0,
      'hasBusInfo': true,
      'classTime': '15분',
      'congestion': '보통',
      'waiting': 5,
    },
    '외대': {
      'recommend': '도보',
      'reason': '',
      'bus': '1112번',
      'arrival': '5분 후',
      'arrivalMinute': 5,
      'remainSeatCnt': null,
      'crowded': null,
      'hasWheelchairReservation': false,
      'wheelchairReservationCount': 0,
      'hasBusInfo': true,
      'classTime': '12분',
      'congestion': '혼잡',
      'waiting': 20,
    },
    '전정대': {
      'recommend': '버스',
      'reason': '',
      'bus': '1112번',
      'arrival': '7분 후',
      'arrivalMinute': 7,
      'remainSeatCnt': null,
      'crowded': null,
      'hasWheelchairReservation': false,
      'wheelchairReservationCount': 0,
      'hasBusInfo': true,
      'classTime': '18분',
      'congestion': '약간 혼잡',
      'waiting': 40,
    },
  };

  @override
  void initState() {
    super.initState();

    waitingCountByStation = {
      for (final station in stations)
        station: stationData[station]!['waiting'] as int,
    };

    _loadCongestionSummaries();
    _loadSchedules();
    _loadWaitingCount();
    _initLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isWeekend) {
        _applyWeekendNoBusInfo(selectedStation);
        return;
      }
      if (selectedStation == '전정대') {
        _loadJeonjeongdaeBusTimetable();
      } else if (selectedStation == '정문' || selectedStation == '외대') {
        _loadRealtimeBusTimetable(selectedStation);
      }
    });

    _congestionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadCongestionSummaries();
    });
    _waitingCountTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadWaitingCount();
    });
    _quickReportPromptTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _maybeShowQuickReportSheet();
    });
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateNextClassText();
    });
    _busTimetableTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_isWeekend) {
        _applyWeekendNoBusInfo(selectedStation);
        return;
      }
      if (selectedStation == '전정대') {
        _loadJeonjeongdaeBusTimetable();
      } else if (selectedStation == '정문' || selectedStation == '외대') {
        _loadRealtimeBusTimetable(selectedStation);
      }
    });
  }

  int? _parseTimeToMinute(String? text) {
    if (text == null) return null;
    final parts = text.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  String _formatRemainTime(int minute) {
    if (minute < 60) return '$minute분';
    final hour = minute ~/ 60;
    final remainingMinute = minute % 60;
    if (remainingMinute == 0) return '$hour시간';
    return '$hour시간 $remainingMinute분';
  }

  String _getTodayKorean(DateTime now) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return days[now.weekday % 7];
  }

  void _updateNextClassText() {
    if (_schedules.isEmpty) {
      setState(() {
        _classTimeText = '-';
        _nextClassText = '-';
        _nextClassRemainMinute = null;
        _nextClassBuilding = null;
      });
      return;
    }

    final now = DateTime.now();
    final today = _getTodayKorean(now);
    final currentMinute = now.hour * 60 + now.minute;

    Map<String, dynamic>? todayNextSchedule;
    int? todayRemainMinute;

    for (final schedule in _schedules) {
      if (schedule['dayOfWeek'] != today) continue;
      final startMinute = _parseTimeToMinute(schedule['startTime']);
      if (startMinute == null) continue;
      if (startMinute >= currentMinute) {
        final remain = startMinute - currentMinute;
        if (todayRemainMinute == null || remain < todayRemainMinute) {
          todayRemainMinute = remain;
          todayNextSchedule = schedule;
        }
      }
    }

    if (todayNextSchedule != null && todayRemainMinute != null) {
      final buildingName = todayNextSchedule['buildingName'] ?? '';
      final roomNumber = todayNextSchedule['roomNumber'] ?? '';
      final startTime = todayNextSchedule['startTime'] ?? '';
      setState(() {
        _classTimeText = _formatRemainTime(todayRemainMinute!);
        _nextClassText = '$buildingName $roomNumber · $startTime';
        _nextClassRemainMinute = todayRemainMinute;
        _nextClassBuilding = buildingName.toString();
      });
      return;
    }

    setState(() {
      _classTimeText = '-';
      _nextClassText = '-';
      _nextClassRemainMinute = null;
      _nextClassBuilding = null;
    });
  }

  Future<void> _loadSchedules() async {
    final userId = widget.userId;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _schedules = [];
        _classTimeText = '-';
        _nextClassText = '-';
      });
      return;
    }
    try {
      final result = await ApiService.getSchedules(userId: userId);
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _schedules = List<Map<String, dynamic>>.from(result['schedules']);
        });
        _updateNextClassText();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _schedules = [];
        _classTimeText = '-';
        _nextClassText = '-';
      });
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.refreshVersion != widget.refreshVersion) {
      _loadSchedules();
    }

    final bool becameActive = !oldWidget.isActive && widget.isActive;
    final bool loginChangedWhileHomeActive =
        oldWidget.userId != widget.userId && widget.isActive;

    if (becameActive || loginChangedWhileHomeActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _maybeShowQuickReportSheet();
      });
    }
  }

  @override
  void dispose() {
    _congestionTimer?.cancel();
    _scheduleTimer?.cancel();
    _busTimetableTimer?.cancel();
    _waitingCountTimer?.cancel();
    _quickReportPromptTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Map<String, dynamic> get currentData => stationData[selectedStation]!;
  bool get hasCurrentBusInfo => currentData['hasBusInfo'] == true;

  bool get _isWeekend {
    final now = DateTime.now();
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  TransportMode get transportMode =>
      transportModeByStation[selectedStation] ?? TransportMode.none;

  int get waitingCount =>
      waitingCountByStation[selectedStation] ??
          stationData[selectedStation]!['waiting'] as int;

  int? get myWaitingNumber => myWaitingNumberByStation[selectedStation];

  bool get canSelectTransportMode =>
      activeStation == null || activeStation == selectedStation;

  DateTime? get _lastQuickReportedAt {
    final userId = widget.userId;
    if (userId == null) return null;

    return _lastQuickReportedAtByUser[userId];
  }

  Duration get _remainingQuickReportCooldown {
    final lastReportedAt = _lastQuickReportedAt;

    if (lastReportedAt == null) return Duration.zero;

    final elapsed = DateTime.now().difference(lastReportedAt);

    if (elapsed >= _quickReportCooldown) {
      return Duration.zero;
    }

    return _quickReportCooldown - elapsed;
  }

  bool get _canQuickReport => _remainingQuickReportCooldown == Duration.zero;

  String get _quickReportCooldownText {
    final remaining = _remainingQuickReportCooldown;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes분 $seconds초';
    }

    return '$seconds초';
  }

  bool _isQuickReportSnoozed(String stationName) {
    final snoozedUntil = _quickReportSnoozedUntilByStation[stationName];

    if (snoozedUntil == null) return false;

    return DateTime.now().isBefore(snoozedUntil);
  }

  bool get _shouldShowQuickReportPrompt {
    if (!widget.isActive) return false; // 홈 탭이 실제로 보일 때만 표시
    if (widget.userId == null) return false;
    if (_isWeekend) return false;
    if (!isNearStation) return false;
    if (!_canQuickReport) return false;
    if (_isQuickReportSheetOpen) return false;
    if (_isQuickReportSnoozed(selectedStation)) return false;

    return true;
  }

  String get _locationStatusText {
    if (!_locationPermissionGranted) return '📍 위치 권한이 필요합니다';
    if (_currentPosition == null) return '📍 위치 정보를 가져오는 중...';
    final coords = stationCoordinates[selectedStation];
    if (coords == null) return '📍 위치 정보 없음';
    final distance = _calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords['lat']!,
      coords['lng']!,
    );
    final distanceText = distance < 1000
        ? '${distance.toStringAsFixed(0)}m'
        : '${(distance / 1000).toStringAsFixed(1)}km';
    return isNearStation
        ? '📍 현재 위치: 정류장 근처 ($distanceText · 50m 이내)'
        : '📍 현재 위치: 정류장까지 $distanceText (50m 이상)';
  }

  bool get isNearStation {
    return true; // 테스트용
  }
/*
  bool get isNearStation {
    if (!_locationPermissionGranted || _currentPosition == null) return false;
    final coords = stationCoordinates[selectedStation];
    if (coords == null) return false;
    final distance = _calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords['lat']!,
      coords['lng']!,
    );
    return distance <= nearStationThresholdMeters;
  } */

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  int? _walkMinutesToDestination() {
    if (_currentPosition == null) return null;
    final building = _nextClassBuilding;
    final dest = (building != null) ? destinationCoordinates[building] : null;
    if (dest == null) return null;
    return RouteRecommender.walkMinutesBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      dest['lat']!,
      dest['lng']!,
    );
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() { _locationPermissionGranted = false; });
      return;
    }

    if (!mounted) return;
    setState(() { _locationPermissionGranted = true; });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() { _currentPosition = position; });
      _maybeShowQuickReportSheet();
    } catch (_) {}

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((position) {
      if (!mounted) return;
      if (position.accuracy > 50) return;
      setState(() { _currentPosition = position; });
      _maybeShowQuickReportSheet();
    });
  }

  void _changeStation(String station) {
    setState(() { selectedStation = station; });

    _loadCongestionSummaries();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowQuickReportSheet();
    });

    if (_isWeekend) {
      _applyWeekendNoBusInfo(station);
      return;
    }

    if (station == '전정대') {
      _loadJeonjeongdaeBusTimetable();
    } else if (station == '정문' || station == '외대') {
      _loadRealtimeBusTimetable(station);
    }
  }

  static const int predictionCapacity = 30;
  static const bool useTestMainGateWaitingCount = true;
  static const int testMainGateWaitingCount = 20;
  static const double mainGateBoardingRatio = 0.8;

  String _predictionBusKey(Map<String, dynamic> bus) {
    final plateNo = bus['plateNo']?.toString();
    if (plateNo != null && plateNo.isNotEmpty) return plateNo;
    final busNumber = bus['busNumber']?.toString() ?? '';
    final time = bus['expectedArrivalTime']?.toString() ??
        bus['departureTime']?.toString() ?? '';
    return '$busNumber|$time';
  }

  int? _getBaseBoardingCapacity(Map<String, dynamic> bus) {
    final String busNumber = bus['busNumber']?.toString() ?? '';
    if (busNumber == '9') return predictionCapacity;
    final dynamic remainSeat = bus['remainSeatCnt'];
    if (remainSeat is int) return remainSeat;
    if (remainSeat is num) return remainSeat.toInt();
    return int.tryParse(remainSeat?.toString() ?? '');
  }

  int _getMainGateBoardingLimit(int baseCapacity) {
    if (baseCapacity <= 0) return 0;
    return max(1, (baseCapacity * mainGateBoardingRatio).floor()).toInt();
  }

  Map<String, dynamic>? _findMatchingMainGateBus(
      Map<String, dynamic> oedaeBus,
      List<Map<String, dynamic>> mainGateArrivals) {
    final String? oedaePlateNo = oedaeBus['plateNo']?.toString();
    if (oedaePlateNo != null && oedaePlateNo.isNotEmpty) {
      for (final bus in mainGateArrivals) {
        if (bus['plateNo']?.toString() == oedaePlateNo) return bus;
      }
    }
    final String oedaeBusNumber = oedaeBus['busNumber']?.toString() ?? '';
    final sameNumberBuses = mainGateArrivals
        .where((bus) => bus['busNumber']?.toString() == oedaeBusNumber)
        .toList();
    if (sameNumberBuses.length == 1) return sameNumberBuses.first;
    return null;
  }

  Map<String, dynamic> _getBoardingRuleForBus(
      String stationName,
      Map<String, dynamic> bus, {
        required int? mainGateWaitingCount,
        required List<Map<String, dynamic>> mainGateArrivals,
      }) {
    final String busNumber = bus['busNumber']?.toString() ?? '';

    if (stationName == '전정대') {
      return {
        'capacity': predictionCapacity,
        'capacityText': '남은 좌석 45석\n전정대 예상 탑승 인원 $predictionCapacity명',
        'ruleText': '출발 정류장 예상 탑승 인원 기준 탑승 가능 예상',
      };
    }

    if (stationName == '정문') {
      final int? baseCapacity = _getBaseBoardingCapacity(bus);
      if (baseCapacity == null) {
        return {
          'capacity': null,
          'capacityText': '탑승 판단 정보 없음',
          'ruleText': '좌석 정보를 확인할 수 없습니다',
        };
      }
      final int mainGateCapacity = _getMainGateBoardingLimit(baseCapacity);
      return {
        'capacity': mainGateCapacity,
        'capacityText': busNumber == '9'
            ? '저상버스 기준 $baseCapacity명\n정문 예상 탑승 가능 $mainGateCapacity명'
            : '남은 좌석 $baseCapacity석\n정문 예상 탑승 가능 $mainGateCapacity명',
        'ruleText': '정문 80% 탑승 가정 기준 탑승 가능 예상',
      };
    }

    if (stationName == '외대') {
      final matchingMainGateBus = _findMatchingMainGateBus(bus, mainGateArrivals);
      final int? mainGateBaseCapacity = matchingMainGateBus == null
          ? null
          : _getBaseBoardingCapacity(matchingMainGateBus);

      if (matchingMainGateBus != null &&
          mainGateBaseCapacity != null &&
          mainGateWaitingCount != null) {
        final int mainGateLimit = _getMainGateBoardingLimit(mainGateBaseCapacity);
        final int predictedBoardingAtMainGate =
            min(mainGateWaitingCount, mainGateLimit).toInt();
        final int availableAtOedae =
            max(0, mainGateBaseCapacity - predictedBoardingAtMainGate).toInt();
        return {
          'capacity': availableAtOedae,
          'capacityText': busNumber == '9'
              ? '저상버스 기준 $mainGateBaseCapacity명\n외대 예상 탑승 가능 $availableAtOedae명'
              : '남은 좌석 $mainGateBaseCapacity석\n외대 예상 탑승 가능 $availableAtOedae명',
          'ruleText': '정문 예상 탑승 $predictedBoardingAtMainGate명 반영 후 탑승 가능 예상',
        };
      }

      final int? fallbackCapacity = _getBaseBoardingCapacity(bus);
      return {
        'capacity': fallbackCapacity,
        'capacityText': fallbackCapacity == null
            ? '탑승 판단 정보 없음'
            : busNumber == '9'
            ? '저상버스 기준 $fallbackCapacity명'
            : '남은 좌석 $fallbackCapacity석\n외대 직접 조회 기준',
        'ruleText': '정문 차량 연결 불가로 외대 실시간 좌석 기준 예측',
      };
    }

    return {
      'capacity': null,
      'capacityText': '탑승 판단 정보 없음',
      'ruleText': '탑승 기준을 확인할 수 없습니다',
    };
  }

  Future<Map<String, dynamic>?> _calculateBoardingPrediction(
      String stationName, {
        String? excludedBusKey,
        int? waitingPeopleForCalculation,
      }) async {
    int waitingCountAtStart;

    final String congestionText =
        stationData[stationName]?['congestion']?.toString() ?? '-';
    final int p = RouteRecommender.congestionLevelToIndex(congestionText);

    if (stationName == '정문') {
      int nApp;
      if (useTestMainGateWaitingCount) {
        nApp = testMainGateWaitingCount;
      } else {
        final waitingResult =
            await ApiService.getWaitingCount(stationName: '정문');
        if (waitingResult['success'] != true) return null;
        nApp = waitingResult['count'] as int? ?? 0;
      }
      waitingCountAtStart =
          RouteRecommender.estimateWaitingCount(nApp: nApp, p: p);
    } else {
      // 외대·전정대: 제보 없을 때 기본값 사용
      const Map<String, int> defaultWaiting = {
        '외대': 20,
        '전정대': 40,
      };
      waitingCountAtStart = p == 0
          ? (defaultWaiting[stationName] ?? 0)
          : RouteRecommender.estimateWaitingCount(nApp: 0, p: p);
    }

    Map<String, dynamic> busResult;
    if (stationName == '전정대') {
      busResult =
          await ApiService.getNextBusTimetable(stationName: stationName);
    } else {
      busResult = await ApiService.getRealtimeNextBus(stationName: stationName);
    }

    if (busResult['success'] != true) return null;

    final List<dynamic> rawArrivals =
        busResult['arrivals'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> arrivals =
        rawArrivals.map((bus) => Map<String, dynamic>.from(bus as Map)).toList();

    int? mainGateWaitingCount;
    List<Map<String, dynamic>> mainGateArrivals = [];

    if (stationName == '외대') {
      try {
        if (useTestMainGateWaitingCount) {
          mainGateWaitingCount = testMainGateWaitingCount;
        } else {
          final waitingResult =
              await ApiService.getWaitingCount(stationName: '정문');
          if (waitingResult['success'] == true) {
            mainGateWaitingCount = waitingResult['count'] as int? ?? 0;
          }
        }
        final mainGateBusResult =
            await ApiService.getRealtimeNextBus(stationName: '정문');
        if (mainGateBusResult['success'] == true) {
          final List<dynamic> rawMainGateArrivals =
              mainGateBusResult['arrivals'] as List<dynamic>? ?? [];
          mainGateArrivals = rawMainGateArrivals
              .map((bus) => Map<String, dynamic>.from(bus as Map))
              .toList();
        }
      } catch (_) {}
    }

    Map<String, dynamic>? recommendedBus;
    final List<Map<String, dynamic>> analyzedArrivals = [];
    int remainingPeople = waitingPeopleForCalculation ?? waitingCountAtStart;
    bool foundRecommendation = false;

    for (int i = 0; i < arrivals.length; i++) {
      final Map<String, dynamic> bus = arrivals[i];

      if (excludedBusKey != null && _predictionBusKey(bus) == excludedBusKey) {
        analyzedArrivals.add({
          ...bus,
          'capacityText': '이전 예상 버스',
          'statusText': '탑승하지 않음',
          'isRecommended': false,
        });
        continue;
      }

      final Map<String, dynamic> rule = _getBoardingRuleForBus(
        stationName, bus,
        mainGateWaitingCount: mainGateWaitingCount,
        mainGateArrivals: mainGateArrivals,
      );

      final int? capacity = rule['capacity'] as int?;
      final String capacityText = rule['capacityText'] as String;
      final String ruleText = rule['ruleText'] as String;

      if (foundRecommendation) {
        analyzedArrivals.add({
          ...bus,
          'capacityText': capacityText,
          'statusText': '추천 버스 이후 도착',
          'isRecommended': false,
        });
        continue;
      }

      if (capacity == null) {
        analyzedArrivals.add({
          ...bus,
          'capacityText': capacityText,
          'statusText': '판단 불가',
          'isRecommended': false,
        });
        continue;
      }

      if (capacity <= 0) {
        analyzedArrivals.add({
          ...bus,
          'capacityText': capacityText,
          'statusText': '탑승 어려움',
          'isRecommended': false,
        });
        continue;
      }

      if (remainingPeople <= capacity) {
        recommendedBus = {
          ...bus,
          'arrivalOrder': i + 1,
          'capacityText': capacityText,
          'ruleText': ruleText,
          'statusText': '탑승 가능 예상',
          'isRecommended': true,
        };
        analyzedArrivals.add(recommendedBus);
        foundRecommendation = true;
      } else {
        analyzedArrivals.add({
          ...bus,
          'capacityText': capacityText,
          'statusText': '탑승 어려움',
          'isRecommended': false,
        });
        remainingPeople -= capacity;
      }
    }

    return {
      'stationName': stationName,
      'waitingCountAtStart': waitingCountAtStart,
      'recommendedBus': recommendedBus,
      'arrivals': analyzedArrivals,
      'usesRealtimeWaitingCount': stationName == '정문',
    };
  }

  Future<void> _updateRecommendation(String station) async {
    final building = _nextClassBuilding;

    // 다음 수업 건물 정보가 없으면 버스 추천
    if (building == null) {
      if (!mounted) return;

      setState(() {
        stationData[station]?['recommend'] = '버스';
        stationData[station]?['reason'] =
        '다음 수업 건물 정보가 없어, 현재 선택한 정류장의 버스 도착 정보를 기준으로 안내합니다.';
      });

      return;
    }

    // 1. 무조건 도보 처리하는 경우
    // 예: 정문 → 공학관, 외대 → 외대/멀관, 전정대 → 전정대/예대/국제대
    if (_isWalkingOnlyBuilding(station: station, building: building)) {
      if (!mounted) return;

      setState(() {
        stationData[station]?['recommend'] = '도보';

        if (station == '정문' && building == '공학관') {
          stationData[station]?['reason'] =
          '정문에서는 공학관 방향으로 바로 이동할 수 있는 버스 경로가 없어 도보 이동을 추천합니다.';
        } else {
          stationData[station]?['reason'] =
          '다음 수업 건물이 현재 선택한 정류장 근처에 있어 도보 이동을 추천합니다.';
        }
      });

      return;
    }

    // 2. 출발 정류장에서 다음 수업 건물까지 이용 가능한 버스 경로 확인
    final routeOption = _busRouteOptionToBuilding(
      station: station,
      building: building,
    );

    // 3. 버스 경로가 없으면 도보 추천
    if (routeOption == null) {
      if (!mounted) return;

      setState(() {
        stationData[station]?['recommend'] = '도보';
        stationData[station]?['reason'] =
        '현재 선택한 정류장에서는 다음 수업 건물 방향으로 이용할 수 있는 버스 경로가 없어 도보 이동을 추천합니다.';
      });

      return;
    }

    // 4. 버스 경로가 있으면 탑승 예측 계산
    int? wait;
    int failedBus = 0;
    int waitingCount = 0;

    final prediction = await _calculateBoardingPrediction(station);

    if (prediction != null) {
      waitingCount = prediction['waitingCountAtStart'] as int? ?? 0;

      final rec = prediction['recommendedBus'] as Map<String, dynamic>?;

      if (rec != null) {
        wait = (rec['arrivalMinute'] as num?)?.toInt();
        failedBus = ((rec['arrivalOrder'] as int?) ?? 1) - 1;
      }
    }

    final decision = RouteRecommender.decide(
      waitingCount: waitingCount,
      failedBusCount: failedBus,
      waitMinutes: wait,
      travelMinutes: routeOption.travelMinutes,
      walkMinutes: _walkMinutesToDestination(),
      limitMinutes: _nextClassRemainMinute,
    );

    if (!mounted) return;

    setState(() {
      stationData[station]?['recommend'] = decision.isBus ? '버스' : '도보';

      if (decision.isBus) {
        stationData[station]?['reason'] =
        '${routeOption.routeText} 기준의 이동 시간 ${routeOption.travelMinutes}분과 버스 대기 시간을 함께 계산해, 버스 이동을 추천합니다.';
      } else {
        stationData[station]?['reason'] = decision.reason;
      }
    });
  }

  Future<void> _startBusWaiting() async {
    if (!canSelectTransportMode) return;
    if (!hasCurrentBusInfo) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('현재 버스 운행 정보가 없어 줄서기를 이용할 수 없어요.'),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    if (!isNearStation) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('정류장 근처에 도착해야 버스 줄서기를 이용할 수 있어요.'),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    if (_isOpeningPrediction) return;
    setState(() { _isOpeningPrediction = true; });

    try {
      final String stationAtStart = selectedStation;
      final prediction = await _calculateBoardingPrediction(stationAtStart);
      if (!mounted) return;
      if (prediction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('탑승 예상 정보를 불러올 수 없습니다.')),
        );
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BoardingPredictionScreen(
            stationName: stationAtStart,
            waitingCountAtStart: prediction['waitingCountAtStart'] as int,
            recommendedBus: prediction['recommendedBus'] as Map<String, dynamic>?,
            arrivals: List<Map<String, dynamic>>.from(prediction['arrivals']),
            usesRealtimeWaitingCount:
                prediction['usesRealtimeWaitingCount'] == true,
            onStillWaiting: (previousBus) async {
              return _calculateBoardingPrediction(
                stationAtStart,
                excludedBusKey: _predictionBusKey(previousBus),
                waitingPeopleForCalculation:
                    stationAtStart == '정문' ? null : 1,
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버에 연결할 수 없습니다.')),
      );
    } finally {
      if (mounted) setState(() { _isOpeningPrediction = false; });
    }
  }

  void _startWalking() {
    if (!canSelectTransportMode) return;
    setState(() {
      if (transportMode == TransportMode.bus && myWaitingNumber != null) {
        myWaitingNumberByStation[selectedStation] = null;
      }
      transportModeByStation[selectedStation] = TransportMode.walk;
      activeStation = selectedStation;
    });
  }

  void _cancelTransportMode() {
    setState(() {
      transportModeByStation[selectedStation] = TransportMode.none;
      myWaitingNumberByStation[selectedStation] = null;
      activeStation = null;
    });
  }

  int get _estimatedArrivalAfterMinute {
    if (transportMode == TransportMode.walk) {
      return _walkMinutesToDestination() ?? 0;
    }
    final arrivalMinute = currentData['arrivalMinute'] as int? ?? 0;
    if (myWaitingNumber == null) return arrivalMinute + 9;
    final busOrder = (myWaitingNumber! / busCapacity).ceil();
    if (busOrder <= 1) return arrivalMinute + 9;
    return arrivalMinute + 9 + ((busOrder - 1) * 10);
  }

  String get _boardingEstimateText {
    if (myWaitingNumber == null) return '다음 버스';
    final busOrder = (myWaitingNumber! / busCapacity).ceil();
    if (busOrder <= 1) return '다음 버스';
    return '$busOrder번째 버스';
  }

  void _maybeShowQuickReportSheet() {
    if (!_shouldShowQuickReportPrompt) return;

    final stationName = selectedStation;

    unawaited(_showQuickReportSheet(stationName));
  }

  Widget _buildQuickReportFaceIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 1.2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 13,
            left: 12,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 13,
            right: 12,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            child: Container(
              width: 16,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReportOptionCard({
    required _QuickCongestionOption option,
    required String stationName,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: _isSubmittingQuickReport
            ? null
            : () {
          _submitQuickReport(
            stationName: stationName,
            congestionLevel: option.level,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: option.bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: option.borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: option.iconColor.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: option.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  color: option.iconColor,
                  size: 27,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                option.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: option.textColor,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: option.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickReportSheet(String stationName) async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    if (_isWeekend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주말에는 혼잡도 제보를 이용할 수 없습니다.')),
      );
      return;
    }

    if (!isNearStation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정류장 50m 이내에서만 제보할 수 있어요.')),
      );
      return;
    }

    if (!_canQuickReport) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_quickReportCooldownText 후 다시 제보할 수 있어요.')),
      );
      return;
    }

    if (_isQuickReportSheetOpen) return;

    setState(() {
      _isQuickReportSheetOpen = true;
    });

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 18,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildQuickReportFaceIcon(),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '지금 $stationName의 상태는 어떤가요?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '실시간 혼잡도 제보에 도움이 됩니다',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _quickReportSnoozedUntilByStation[stationName] =
                                DateTime.now().add(_quickReportCooldown);
                          });

                          Navigator.pop(bottomSheetContext);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      for (int i = 0; i < _quickReportOptions.length; i++) ...[
                        _buildQuickReportOptionCard(
                          option: _quickReportOptions[i],
                          stationName: stationName,
                        ),
                        if (i != _quickReportOptions.length - 1)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _quickReportSnoozedUntilByStation[stationName] =
                              DateTime.now().add(_quickReportCooldown);
                        });

                        Navigator.pop(bottomSheetContext);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF6B7280),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '나중에 할게요',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    setState(() {
      _isQuickReportSheetOpen = false;
    });
  }

  Future<void> _submitQuickReport({
    required String stationName,
    required String congestionLevel,
  }) async {
    final userId = widget.userId;

    if (userId == null) return;
    if (_isSubmittingQuickReport) return;

    setState(() {
      _isSubmittingQuickReport = true;
    });

    try {
      final result = await ApiService.submitOpinion(
        userId: userId,
        stopName: stationName,
        congestionLevel: congestionLevel,
        comment: null,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pop(context);

        setState(() {
          _lastQuickReportedAtByUser[userId] = DateTime.now();
        });

        await _loadCongestionSummaries();

        if (mounted) {
          await _updateRecommendation(stationName);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '[$stationName] $congestionLevel 제보가 탑승 예상에 반영되었어요.',
            ),
            backgroundColor: const Color(0xFF2563EB),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '제보 저장에 실패했습니다.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('서버에 연결할 수 없습니다.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingQuickReport = false;
        });
      }
    }
  }

  Future<void> _loadCongestionSummaries() async {
    try {
      final result = await ApiService.getOpinionSummaries();
      if (!mounted) return;
      if (result['success'] == true) {
        final summaries = result['summaries'] as Map<String, dynamic>;
        setState(() {
          for (final station in stationData.keys) {
            final summary = summaries[station];
            if (summary == null) {
              stationData[station]!['congestion'] = '-';
              continue;
            }
            final int reportCount = summary['reportCount'] ?? 0;
            final String congestionLevel = summary['congestionLevel'] ?? '정보 없음';
            stationData[station]!['congestion'] =
                reportCount == 0 || congestionLevel == '정보 없음'
                    ? '-'
                    : congestionLevel;

            if (station != '정문') {
              final int p = RouteRecommender.congestionLevelToIndex(
                stationData[station]!['congestion'] as String?,
              );
              const Map<String, int> defaultWaiting = {
                '외대': 20,
                '전정대': 40,
              };
              final int estimated = p == 0
                  ? (defaultWaiting[station] ?? 0)
                  : RouteRecommender.estimateWaitingCount(nApp: 0, p: p);
              waitingCountByStation[station] = estimated;
              stationData[station]!['waiting'] = estimated;
            }
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        for (final station in stationData.keys) {
          stationData[station]!['congestion'] = '-';
        }
      });
    }
  }

  Future<void> _loadWaitingCount() async {
    if (useTestMainGateWaitingCount) {
      if (!mounted) return;
      setState(() {
        waitingCountByStation['정문'] = testMainGateWaitingCount;
        stationData['정문']!['waiting'] = testMainGateWaitingCount;
      });
      return;
    }
    try {
      final result = await ApiService.getWaitingCount(stationName: '정문');
      if (!mounted) return;
      if (result['success'] == true) {
        final int count = result['count'] ?? 0;
        final int currentCount = waitingCountByStation['정문'] ?? 0;
        if (count == currentCount) return;
        setState(() {
          waitingCountByStation['정문'] = count;
          stationData['정문']!['waiting'] = count;
        });
      }
    } catch (e) {}
  }

  void _applyWeekendNoBusInfo(String stationName) {
    setState(() {
      stationData[stationName]!['recommend'] = '도보';
      stationData[stationName]!['reason'] = '주말에는 버스 운행 정보가 없습니다.';
      stationData[stationName]!['bus'] = '-';
      stationData[stationName]!['arrival'] = '오늘 운행 정보가 없습니다';
      stationData[stationName]!['arrivalMinute'] = 0;
      stationData[stationName]!['remainSeatCnt'] = null;
      stationData[stationName]!['crowded'] = null;
      stationData[stationName]!['hasWheelchairReservation'] = false;
      stationData[stationName]!['wheelchairReservationCount'] = 0;
      stationData[stationName]!['hasBusInfo'] = false;
      transportModeByStation[stationName] = TransportMode.none;
      myWaitingNumberByStation[stationName] = null;
      if (activeStation == stationName) activeStation = null;
    });
  }

  Future<void> _loadJeonjeongdaeBusTimetable() async {
    try {
      final result = await ApiService.getNextBusTimetable(stationName: '전정대');
      if (!mounted) return;
      if (result['success'] != true) return;

      final arrivals = result['arrivals'] as List<dynamic>? ?? [];
      if (arrivals.isEmpty) {
        setState(() {
          stationData['전정대']!['recommend'] = '도보';
          stationData['전정대']!['reason'] = '';
          stationData['전정대']!['bus'] = '-';
          stationData['전정대']!['arrival'] = '오늘 운행 정보가 없습니다';
          stationData['전정대']!['arrivalMinute'] = 0;
          stationData['전정대']!['remainSeatCnt'] = null;
          stationData['전정대']!['crowded'] = null;
          stationData['전정대']!['hasWheelchairReservation'] = false;
          stationData['전정대']!['wheelchairReservationCount'] = 0;
          stationData['전정대']!['hasBusInfo'] = false;
          transportModeByStation['전정대'] = TransportMode.none;
          myWaitingNumberByStation['전정대'] = null;
          if (activeStation == '전정대') activeStation = null;
        });
        return;
      }

      final firstBus = Map<String, dynamic>.from(arrivals.first as Map);
      bool hasWheelchairReservation = false;
      int wheelchairReservationCount = 0;
      final firstBusNumber = firstBus['busNumber']?.toString();
      final departureTime = firstBus['departureTime']?.toString();

      if (firstBusNumber == '9' && departureTime != null) {
        try {
          final reservationResult = await ApiService.getBoardingStatus(
            stationName: '전정대',
            busNumber: '9',
            boardingTime: departureTime,
          );
          if (reservationResult['success'] == true) {
            hasWheelchairReservation =
                reservationResult['hasWheelchairReservation'] == true;
            wheelchairReservationCount =
                reservationResult['reservationCount'] as int? ?? 0;
          }
        } catch (e) {}
      }

      setState(() {
        stationData['전정대']!['recommend'] = '버스';
        stationData['전정대']!['bus'] = '${firstBus['busNumber']}번';
        stationData['전정대']!['arrival'] = firstBus['arrival'] ?? '-';
        stationData['전정대']!['arrivalMinute'] = firstBus['arrivalMinute'] ?? 0;
        stationData['전정대']!['remainSeatCnt'] = null;
        stationData['전정대']!['crowded'] = null;
        stationData['전정대']!['hasWheelchairReservation'] = hasWheelchairReservation;
        stationData['전정대']!['wheelchairReservationCount'] = wheelchairReservationCount;
        stationData['전정대']!['hasBusInfo'] = true;
      });
      _updateRecommendation('전정대');
    } catch (e) {}
  }

  Future<void> _loadRealtimeBusTimetable(String stationName) async {
    try {
      final result = await ApiService.getRealtimeNextBus(stationName: stationName);
      if (!mounted) return;
      if (result['success'] != true) return;

      final arrivals = result['arrivals'] as List<dynamic>? ?? [];
      if (arrivals.isEmpty) {
        setState(() {
          stationData[stationName]!['recommend'] = '도보';
          stationData[stationName]!['reason'] = '';
          stationData[stationName]!['bus'] = '-';
          stationData[stationName]!['arrival'] = '현재 도착 정보가 없습니다';
          stationData[stationName]!['arrivalMinute'] = 0;
          stationData[stationName]!['remainSeatCnt'] = null;
          stationData[stationName]!['crowded'] = null;
          stationData[stationName]!['hasWheelchairReservation'] = false;
          stationData[stationName]!['wheelchairReservationCount'] = 0;
          stationData[stationName]!['hasBusInfo'] = false;
          transportModeByStation[stationName] = TransportMode.none;
          myWaitingNumberByStation[stationName] = null;
          if (activeStation == stationName) activeStation = null;
        });
        return;
      }

      final firstBus = Map<String, dynamic>.from(arrivals.first as Map);
      bool hasWheelchairReservation = false;
      int wheelchairReservationCount = 0;
      final firstBusNumber = firstBus['busNumber']?.toString();
      final expectedArrivalTime = firstBus['expectedArrivalTime']?.toString();

      if (firstBusNumber == '9' && expectedArrivalTime != null) {
        try {
          final reservationResult = await ApiService.getBoardingStatus(
            stationName: stationName,
            busNumber: '9',
            boardingTime: expectedArrivalTime,
          );
          if (reservationResult['success'] == true) {
            hasWheelchairReservation =
                reservationResult['hasWheelchairReservation'] == true;
            wheelchairReservationCount =
                reservationResult['reservationCount'] as int? ?? 0;
          }
        } catch (e) {}
      }

      setState(() {
        stationData[stationName]!['recommend'] = '버스';
        stationData[stationName]!['bus'] = '${firstBus['busNumber']}번';
        stationData[stationName]!['arrival'] = firstBus['arrival'] ?? '-';
        stationData[stationName]!['arrivalMinute'] = firstBus['arrivalMinute'] ?? 0;
        stationData[stationName]!['remainSeatCnt'] = firstBus['remainSeatCnt'];
        stationData[stationName]!['crowded'] = firstBus['crowded'];
        stationData[stationName]!['hasWheelchairReservation'] = hasWheelchairReservation;
        stationData[stationName]!['wheelchairReservationCount'] = wheelchairReservationCount;
        stationData[stationName]!['hasBusInfo'] = true;
      });
      _updateRecommendation(stationName);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final data = currentData;
    final bool hasWheelchairReservation = data['hasWheelchairReservation'] == true;
    final int wheelchairReservationCount =
        data['wheelchairReservationCount'] as int? ?? 0;

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '강의실 이동 안내',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '최적의 이동 수단을 추천합니다',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 22),
              const Text(
                '출발 정류장 선택',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: stations.map((station) {
                  final bool isSelected = selectedStation == station;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _changeStation(station),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFD1D5DC),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            station,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _RecommendationCard(
                transportMode: transportMode,
                recommend: data['recommend'] as String,
                bus: data['bus'] as String,
                arrival: data['arrival'] as String,
                hasBusInfo: hasCurrentBusInfo,
                boardingEstimate: _boardingEstimateText,
                estimatedArrivalAfterMinute: _estimatedArrivalAfterMinute,
                myWaitingNumber: myWaitingNumber,
                hasWheelchairReservation: hasWheelchairReservation,
                wheelchairReservationCount: wheelchairReservationCount,
                reason: data['reason'] as String? ?? '', // ← reason 전달
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SmallInfoCard(
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFFFF8A00),
                      iconBgColor: const Color(0xFFFFF4E5),
                      label: '수업까지',
                      value: _classTimeText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallInfoCard(
                      icon: Icons.groups_rounded,
                      iconColor: const Color(0xFF22C55E),
                      iconBgColor: const Color(0xFFEFFDF4),
                      label: '혼잡도',
                      value: data['congestion'] as String,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallInfoCard(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      iconBgColor: const Color(0xFFEFF6FF),
                      label: '대기인원',
                      value: '$waitingCount명',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _TransportModeCard(
                transportMode: transportMode,
                station: selectedStation,
                isNearStation: isNearStation,
                hasBusInfo: hasCurrentBusInfo,
                canSelectTransportMode: canSelectTransportMode,
                myWaitingNumber: myWaitingNumber,
                locationStatusText: _locationStatusText,
                onBusTap: _startBusWaiting,
                onWalkTap: _startWalking,
                onCancel: _cancelTransportMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final TransportMode transportMode;
  final String recommend;
  final String bus;
  final String arrival;
  final String boardingEstimate;
  final int estimatedArrivalAfterMinute;
  final int? myWaitingNumber;
  final bool hasBusInfo;
  final bool hasWheelchairReservation;
  final int wheelchairReservationCount;
  final String reason; // ← 추가

  const _RecommendationCard({
    required this.transportMode,
    required this.recommend,
    required this.bus,
    required this.arrival,
    required this.hasBusInfo,
    required this.boardingEstimate,
    required this.estimatedArrivalAfterMinute,
    required this.myWaitingNumber,
    required this.hasWheelchairReservation,
    required this.wheelchairReservationCount,
    required this.reason, // ← 추가
  });

  @override
  Widget build(BuildContext context) {
    final bool isWalking = transportMode == TransportMode.walk;
    final bool isBusWaiting = transportMode == TransportMode.bus;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isWalking || recommend == '도보'
                      ? Icons.directions_walk_rounded
                      : Icons.directions_bus_filled_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              if (!isWalking && reason.isNotEmpty) ...[
                const SizedBox(height: 14),
                _ReasonBadge(reason: reason),
              ],
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '추천 이동 수단',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWalking
                      ? '도보 이동을 선택했습니다'
                      : hasBusInfo
                      ? recommend == '버스'
                          ? '버스 탑승을 권장합니다'
                          : '도보 이동을 권장합니다'
                      : '도보 이동을 권장합니다',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isBusWaiting
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoLine(label: '탑승 예상', value: boardingEstimate),
                      const SizedBox(height: 5),
                      _InfoLine(
                        label: '버스 도착',
                        value: arrival,
                        valueColor: Color(0xFFFFF176),
                      ),
                      const SizedBox(height: 5),
                      _InfoLine(
                        label: '예상 도착시간',
                        value: '약 $estimatedArrivalAfterMinute분 후',
                      ),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWalking
                            ? (estimatedArrivalAfterMinute == 0
                            ? '다음 수업 정보가 없어\n예상 도보 시간을 계산할 수 없어요.'
                            : '다음 수업 건물까지 걸어서 약 $estimatedArrivalAfterMinute분 걸려요.')
                            : hasBusInfo
                            ? arrival == '곧 출발'
                            ? '$bus 버스가 곧 도착합니다'
                            : '$bus 버스가 $arrival 도착합니다'
                            : '오늘 운행 정보가 없습니다',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isWalking && hasBusInfo && hasWheelchairReservation) ...[
                        const SizedBox(height: 5),
                        Text(
                          wheelchairReservationCount > 1
                              ? '휠체어 예약자 ${wheelchairReservationCount}명'
                              : '휠체어 예약자 있음',
                          style: const TextStyle(
                            color: Color(0xFFFFF176),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoLine({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;

  const _SmallInfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: iconColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportModeCard extends StatelessWidget {
  final TransportMode transportMode;
  final String station;
  final bool isNearStation;
  final bool hasBusInfo;
  final bool canSelectTransportMode;
  final int? myWaitingNumber;
  final String locationStatusText;
  final VoidCallback onBusTap;
  final VoidCallback onWalkTap;
  final VoidCallback onCancel;

  const _TransportModeCard({
    required this.transportMode,
    required this.station,
    required this.isNearStation,
    required this.hasBusInfo,
    required this.canSelectTransportMode,
    required this.myWaitingNumber,
    required this.locationStatusText,
    required this.onBusTap,
    required this.onWalkTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (transportMode == TransportMode.none) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              '이동 방법 선택',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              '어떻게 이동하시겠어요?',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasBusInfo && isNearStation && canSelectTransportMode
                        ? onBusTap
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF9CA3AF),
                      elevation: isNearStation ? 4 : 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: SizedBox(
                      height: 78,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_bus_filled_rounded),
                          const SizedBox(height: 5),
                          Text(
                            hasBusInfo ? '버스 줄서기' : '운행 정보 없음',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            !hasBusInfo
                                ? '현재 이용 불가'
                                : isNearStation
                                ? '내 탑승 예상 확인'
                                : '정류장 근처에서만',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canSelectTransportMode ? onWalkTap : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const SizedBox(
                      height: 78,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_walk_rounded),
                          SizedBox(height: 5),
                          Text(
                            '도보 이동',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '예상 도보 시간 확인',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                locationStatusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isNearStation
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isBus = transportMode == TransportMode.bus;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isBus ? const Color(0xFFEFF6FF) : const Color(0xFFEFFDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBus ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isBus ? const Color(0xFFDBEAFE) : const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBus
                  ? Icons.directions_bus_filled_rounded
                  : Icons.directions_walk_rounded,
              color: isBus ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isBus ? '버스 대기 중' : '도보 이동 중',
            style: TextStyle(
              color: isBus ? const Color(0xFF1E3A8A) : const Color(0xFF166534),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '📍 $station 정류장',
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isBus) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '대기인원에 포함되었습니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF374151),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isBus ? '대기 취소' : '이동 취소',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ReasonBadge extends StatefulWidget {
  final String reason;
  const _ReasonBadge({required this.reason});

  @override
  State<_ReasonBadge> createState() => _ReasonBadgeState();
}

class _ReasonBadgeState extends State<_ReasonBadge> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '이동 수단 추천 기준',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.reason,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
class _QuickCongestionOption {
  final String level;
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color textColor;
  final Color dotColor;

  const _QuickCongestionOption({
    required this.level,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.textColor,
    required this.dotColor,
  });
}