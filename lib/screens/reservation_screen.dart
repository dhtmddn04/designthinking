import 'package:flutter/material.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String? selectedStop;
  final Map<String, String> reservedTimesByStop = {};

  final List<String> stops = ['정문', '외대', '전정대'];

  final List<String> times = [
    '9:00',
    '10:30',
    '12:00',
    '13:30',
    '15:00',
    '16:30',
    '18:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 44, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예약',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '휠체어 사용자를 위한 지원 기능입니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              '정류장 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: stops.map((stop) {
                final bool isSelected = selectedStop == stop;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedStop = stop;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF2B7FFF)
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black,
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2B7FFF)
                              : const Color(0xFFD1D5DC),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        stop,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: selectedStop == null
                  ? const Center(
                      child: Text(
                        '정류장을 선택해주세요',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                    )
                  : _buildScheduleList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketBottomSheet(String time) {
    final stop = selectedStop ?? '정문';
    const busInfo = '9번 저상버스 (8:35 도착)';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                      size: 38,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '탑승권',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white24,
                    ),

                    const SizedBox(height: 20),

                    _ticketInfoBox(label: '정류장', value: stop),

                    const SizedBox(height: 12),

                    _ticketInfoBox(label: '이용 버스', value: busInfo),

                    const SizedBox(height: 12),

                    _ticketInfoBox(label: '강의 시간', value: time),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white24,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      '탑승 5분 전까지 정류장에 도착해주세요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ticketInfoBox({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                '시간',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            Expanded(
              child: Text(
                '예약',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            Expanded(
              child: Text(
                '탑승권',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Divider(height: 1, thickness: 1.5, color: Color(0xFFD1D5DC)),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: times.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final time = times[index];
              final bool isReserved = reservedTimesByStop[selectedStop] == time;

              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD1D5DC), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedStop == null) return;

                              setState(() {
                                reservedTimesByStop[selectedStop!] = time;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isReserved
                                  ? const Color(0xFF00C950)
                                  : const Color(0xFF2B7FFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              isReserved ? '예약됨' : '예약하기',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: isReserved
                                ? () {
                                    _showTicketBottomSheet(time);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isReserved
                                  ? const Color(0xFFAD46FF)
                                  : const Color(0xFFE5E7EB),
                              foregroundColor: isReserved
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                              disabledBackgroundColor: const Color(0xFFE5E7EB),
                              disabledForegroundColor: const Color(0xFF9CA3AF),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              '탑승권',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
