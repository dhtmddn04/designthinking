import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

enum TransportMode { none, bus, walk }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedStation = '정문';

  String? activeStation;
  Timer? _congestionTimer;

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

  // 추후 실시간 버스 API 연결
  final Map<String, Map<String, dynamic>> stationData = {
    '정문': {
      'recommend': '버스',
      'bus': '1112번',
      'arrival': '3분 후',
      'arrivalMinute': 3,
      'classTime': '15분',
      'congestion': '보통',
      'waiting': 5,
    },
    '외대': {
      'recommend': '도보',
      'bus': '1112번',
      'arrival': '5분 후',
      'arrivalMinute': 5,
      'classTime': '12분',
      'congestion': '혼잡',
      'waiting': 18,
    },
    '전정대': {
      'recommend': '버스',
      'bus': '1112번',
      'arrival': '7분 후',
      'arrivalMinute': 7,
      'classTime': '18분',
      'congestion': '약간 혼잡',
      'waiting': 10,
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

    _congestionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadCongestionSummaries();
    });
  }

  @override
  void dispose() {
    _congestionTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> get currentData => stationData[selectedStation]!;

  TransportMode get transportMode =>
      transportModeByStation[selectedStation] ?? TransportMode.none;

  int get waitingCount =>
      waitingCountByStation[selectedStation] ??
      stationData[selectedStation]!['waiting'] as int;

  int? get myWaitingNumber => myWaitingNumberByStation[selectedStation];

  bool get canSelectTransportMode {
    return activeStation == null || activeStation == selectedStation;
  }

  // 지금은 GPS 시뮬레이션:
  // 정문을 선택했을 때만 정류장 50m 이내라고 가정
  bool get isNearStation => selectedStation == '정문';

  void _changeStation(String station) {
    setState(() {
      selectedStation = station;
    });

    _loadCongestionSummaries();
  }

  void _startBusWaiting() {
    if (!canSelectTransportMode) return;

    if (!isNearStation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('정류장 근처에 도착해야 버스를 선택할 수 있어요.'),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      final newNumber = waitingCount + 1;

      waitingCountByStation[selectedStation] = newNumber;
      myWaitingNumberByStation[selectedStation] = newNumber;
      transportModeByStation[selectedStation] = TransportMode.bus;
      activeStation = selectedStation;
    });
  }

  void _startWalking() {
    if (!canSelectTransportMode) return;

    setState(() {
      if (transportMode == TransportMode.bus && myWaitingNumber != null) {
        waitingCountByStation[selectedStation] = waitingCount > 0
            ? waitingCount - 1
            : 0;
        myWaitingNumberByStation[selectedStation] = null;
      }

      transportModeByStation[selectedStation] = TransportMode.walk;
      activeStation = selectedStation;
    });
  }

  void _cancelTransportMode() {
    setState(() {
      if (transportMode == TransportMode.bus && myWaitingNumber != null) {
        waitingCountByStation[selectedStation] = waitingCount > 0
            ? waitingCount - 1
            : 0;
      }

      transportModeByStation[selectedStation] = TransportMode.none;
      myWaitingNumberByStation[selectedStation] = null;
      activeStation = null;
    });
  }

  int get _estimatedArrivalAfterMinute {
    if (transportMode == TransportMode.walk) {
      return 15;
    }

    final arrivalMinute = currentData['arrivalMinute'] as int;

    if (myWaitingNumber == null) {
      return arrivalMinute + 9;
    }

    final busOrder = (myWaitingNumber! / busCapacity).ceil();

    if (busOrder <= 1) {
      return arrivalMinute + 9;
    }

    return arrivalMinute + 9 + ((busOrder - 1) * 10);
  }

  String get _boardingEstimateText {
    if (myWaitingNumber == null) return '다음 버스';

    final busOrder = (myWaitingNumber! / busCapacity).ceil();

    if (busOrder <= 1) {
      return '다음 버스';
    }

    return '$busOrder번째 버스';
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
            final String congestionLevel =
                summary['congestionLevel'] ?? '정보 없음';

            stationData[station]!['congestion'] =
                reportCount == 0 || congestionLevel == '정보 없음'
                ? '-'
                : congestionLevel;
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

  @override
  Widget build(BuildContext context) {
    final data = currentData;

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
                '정류장 선택',
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
                        onTap: () {
                          _changeStation(station);
                        },
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            station,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF374151),
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
                boardingEstimate: _boardingEstimateText,
                estimatedArrivalAfterMinute: _estimatedArrivalAfterMinute,
                myWaitingNumber: myWaitingNumber,
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
                      value: data['classTime'] as String,
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
                canSelectTransportMode: canSelectTransportMode,
                myWaitingNumber: myWaitingNumber,
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

  const _RecommendationCard({
    required this.transportMode,
    required this.recommend,
    required this.bus,
    required this.arrival,
    required this.boardingEstimate,
    required this.estimatedArrivalAfterMinute,
    required this.myWaitingNumber,
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isWalking
                  ? Icons.directions_walk_rounded
                  : Icons.directions_bus_filled_rounded,
              color: Colors.white,
              size: 23,
            ),
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
                  isWalking ? '도보 이동을 선택했습니다' : '$recommend 탑승을 권장합니다',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 12,
                  ),
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
                      : Text(
                          isWalking
                              ? '도보 예상 도착시간은 약 $estimatedArrivalAfterMinute분 후입니다'
                              : '$bus 버스가 $arrival 도착합니다',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
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
  final bool canSelectTransportMode;
  final int? myWaitingNumber;
  final VoidCallback onBusTap;
  final VoidCallback onWalkTap;
  final VoidCallback onCancel;

  const _TransportModeCard({
    required this.transportMode,
    required this.station,
    required this.isNearStation,
    required this.canSelectTransportMode,
    required this.myWaitingNumber,
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
                    onPressed: isNearStation && canSelectTransportMode
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
                          const Text(
                            '버스 줄서기',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isNearStation ? '정류장 근처 확인됨' : '정류장 근처에서만',
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
                            '도보',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 16),
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
                isNearStation
                    ? '📍 현재 위치: 정류장 근처 (50m 이내)'
                    : '📍 현재 위치: 정류장 도착 필요 (50m 이상)',
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
