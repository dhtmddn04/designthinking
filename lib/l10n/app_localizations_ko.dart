// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'KHU BUS';

  @override
  String get language => '언어';

  @override
  String get korean => '한국어';

  @override
  String get english => 'English';

  @override
  String get homeTab => '홈';

  @override
  String get reservationTab => '예약';

  @override
  String get reportTab => '제보';

  @override
  String get profileTab => '프로필';

  @override
  String get login => '로그인';

  @override
  String get loginSubtitle => '계정에 로그인하세요';

  @override
  String get username => '아이디';

  @override
  String get enterUsername => '아이디를 입력하세요';

  @override
  String get password => '비밀번호';

  @override
  String get enterPassword => '비밀번호를 입력하세요';

  @override
  String get autoLogin => '자동 로그인';

  @override
  String get signup => '회원가입';

  @override
  String get signupSubtitle => '새 계정을 만들어보세요';

  @override
  String get confirmPassword => '비밀번호 재확인';

  @override
  String get reenterPassword => '비밀번호를 다시 입력하세요';

  @override
  String get phoneNumber => '휴대전화';

  @override
  String get wheelchairUser => '휠체어 탑승 여부';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get createAccount => '가입하기';

  @override
  String get backToLogin => '이미 계정이 있으신가요? 로그인';

  @override
  String get enterUsernameAndPassword => '아이디와 비밀번호를 입력해주세요.';

  @override
  String get loginSuccess => '로그인되었습니다.';

  @override
  String get loginFailed => '로그인에 실패했습니다.';

  @override
  String get serverConnectionFailed => '서버에 연결할 수 없습니다.';

  @override
  String get fillAllFields => '모든 정보를 입력해주세요.';

  @override
  String get phoneNumberFourDigits => '휴대전화 번호는 4자리씩 입력해주세요.';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get signupSuccess => '회원가입이 완료되었습니다.';

  @override
  String get signupFailed => '회원가입에 실패했습니다.';

  @override
  String get profileInfo => '프로필 정보';

  @override
  String get noRegisteredPhone => '등록된 번호 없음';

  @override
  String get timetable => '시간표';

  @override
  String get logout => '로그아웃';

  @override
  String get editProfile => '프로필 수정';

  @override
  String get enterFullPhoneNumber => '휴대전화 번호를 모두 입력해주세요.';

  @override
  String get profileUpdateSuccess => '프로필이 수정되었습니다.';

  @override
  String get profileUpdateFailed => '프로필 수정에 실패했습니다.';

  @override
  String get saveInProgress => '저장 중...';

  @override
  String get saveChanges => '수정 완료';

  @override
  String get homeTitle => '강의실 이동 안내';

  @override
  String get homeSubtitle => '최적의 이동 수단을 추천합니다';

  @override
  String get departureStation => '출발 정류장 선택';

  @override
  String get mainGateStation => '정문';

  @override
  String get oedaeStation => '외대';

  @override
  String get jeonjeongdaeStation => '전정대';

  @override
  String get classUntil => '수업까지';

  @override
  String get congestion => '혼잡도';

  @override
  String get waitingPeople => '대기인원';

  @override
  String get congestionLight => '여유';

  @override
  String get congestionNormal => '보통';

  @override
  String get congestionBusy => '약간 혼잡';

  @override
  String get congestionCrowded => '혼잡';

  @override
  String get noInfo => '정보 없음';

  @override
  String peopleCount(int count) {
    return '$count명';
  }

  @override
  String get recommendedTransport => '추천 이동 수단';

  @override
  String get busRecommended => '버스 탑승을 권장합니다';

  @override
  String get walkRecommended => '도보 이동을 권장합니다';

  @override
  String get walkingSelected => '도보 이동을 선택했습니다';

  @override
  String get boardingEstimate => '탑승 예상';

  @override
  String get busArrival => '버스 도착';

  @override
  String get estimatedArrivalTime => '예상 도착시간';

  @override
  String afterMinutes(int minute) {
    return '약 $minute분 후';
  }

  @override
  String busArrivesIn(String bus, String arrival) {
    return '$bus 버스가 $arrival 도착합니다';
  }

  @override
  String get noWalkingEstimate => '다음 수업 정보가 없어\n예상 도보 시간을 계산할 수 없어요.';

  @override
  String walkingEstimate(int minute) {
    return '다음 수업 건물까지 걸어서 약 $minute분 걸려요.';
  }

  @override
  String busArrivingSoon(String bus) {
    return '$bus 버스가 곧 도착합니다';
  }

  @override
  String get noBusServiceToday => '오늘 운행 정보가 없습니다';

  @override
  String get transportMethodTitle => '이동 방법 선택';

  @override
  String get transportMethodSubtitle => '어떻게 이동하시겠어요?';

  @override
  String get busQueue => '버스 줄서기';

  @override
  String get noServiceInfo => '운행 정보 없음';

  @override
  String get currentlyUnavailable => '현재 이용 불가';

  @override
  String get checkBoardingEstimate => '내 탑승 예상 확인';

  @override
  String get nearStopOnly => '정류장 근처에서만';

  @override
  String get walkMove => '도보 이동';

  @override
  String get checkWalkingTime => '예상 도보 시간 확인';

  @override
  String get locationPermissionNeeded => '📍 위치 권한이 필요합니다';

  @override
  String get gettingLocation => '📍 위치 정보를 가져오는 중...';

  @override
  String get noLocationInfo => '📍 위치 정보 없음';

  @override
  String currentLocationNearStation(String distance) {
    return '📍 현재 위치: 정류장 근처 ($distance · 50m 이내)';
  }

  @override
  String currentLocationToStation(String distance) {
    return '📍 현재 위치: 정류장까지 $distance (50m 이상)';
  }

  @override
  String get busWaiting => '버스 대기 중';

  @override
  String get walkingInProgress => '도보 이동 중';

  @override
  String stationStop(String station) {
    return '📍 $station 정류장';
  }

  @override
  String get includedInWaitingList => '대기인원에 포함되었습니다';

  @override
  String get cancelWaiting => '대기 취소';

  @override
  String get cancelMove => '이동 취소';

  @override
  String get reservationSubtitle => '휠체어 사용자를 위한 지원 기능입니다.';

  @override
  String get pleaseSelectStop => '정류장을 선택해주세요';

  @override
  String get timeHeader => '시간';

  @override
  String get reservationHeader => '예약';

  @override
  String get ticket => '탑승권';

  @override
  String get reserved => '예약완료';

  @override
  String get reservationUnavailable => '예약불가';

  @override
  String get makeReservation => '예약하기';

  @override
  String get reservationLoadFailed => '예약 내역을 불러올 수 없습니다.';

  @override
  String get reservationNotAvailableTitle => '예약 불가';

  @override
  String get invalidReservationTime => '예약 가능한 시간이 아닙니다.';

  @override
  String get alreadyReservedTime => '이미 예약된 시간대입니다.';

  @override
  String get alreadyHasReservation => '이미 예약한 시간이 있습니다.';

  @override
  String get alreadyHasSameTimeReservation => '이미 같은 시간에 다른 정류장 예약이 있습니다.';

  @override
  String get notReservationTarget => '예약 기능 이용 대상자가 아닙니다.';

  @override
  String get weekendReservationUnavailable => '주말에는 예약 기능을 이용할 수 없습니다.';

  @override
  String get ok => '확인';

  @override
  String get loginRequired => '로그인이 필요합니다.';

  @override
  String get reservationSuccess => '예약이 완료되었습니다.';

  @override
  String get reservationFailed => '예약에 실패했습니다.';

  @override
  String get reservationCancelSuccess => '예약이 취소되었습니다.';

  @override
  String get reservationCancelFailed => '예약 취소에 실패했습니다.';

  @override
  String get reservationResultUnknown => '예약 결과를 확인할 수 없습니다.';

  @override
  String get reservationCancelResultUnknown => '예약 취소 결과를 확인할 수 없습니다.';

  @override
  String get ticketTitle => '탑승권';

  @override
  String get stopLabel => '정류장';

  @override
  String get boardingBusLabel => '이용 버스';

  @override
  String get classTimeLabel => '강의 시간';

  @override
  String get arriveFiveMinutesEarly => '탑승 5분 전까지 정류장에 도착해주세요';

  @override
  String get lowFloorBus9 => '9번 저상버스';

  @override
  String lowFloorBus9Scheduled(String time) {
    return '9번 저상버스 ($time 예정)';
  }

  @override
  String get busArrivalInfoLoadFailed => '9번 저상버스 도착정보를 불러올 수 없습니다.';

  @override
  String get busArrivalInfoNotReady => '9번 저상버스 도착정보가 아직 없습니다.';

  @override
  String get reservationCompletedTitle => '예약되었습니다';

  @override
  String reservationCompletedMessage(String stop, String time) {
    return '$stop 정류장 $time 예약이 완료되었습니다.';
  }

  @override
  String get close => '닫기';

  @override
  String get cancelReservation => '예약 취소';

  @override
  String get reportTitle => '실시간 체감 혼잡도 제보';

  @override
  String get reportSubtitle => '실제 정류장에서 느낀 혼잡도를 제보해 주세요.';

  @override
  String get reportLocation => '제보 위치';

  @override
  String get selectLocation => '위치 선택';

  @override
  String get feltCongestion => '체감 혼잡도';

  @override
  String get selectCongestion => '혼잡도 선택';

  @override
  String get reportUnavailable => '제보 불가';

  @override
  String get reportNearStopOnly => '정류장 근처에서 제보 가능';

  @override
  String get submitReport => '제보하기';

  @override
  String get realtimeReportStatus => '실시간 제보 현황';

  @override
  String get reportStatusSubtitle => '학생들이 제보한 실시간 혼잡 데이터를 확인하세요.';

  @override
  String totalReports(int count) {
    return '전체 $count건';
  }

  @override
  String reportCount(int count) {
    return '$count건';
  }

  @override
  String get recentReportNotice => '* 데이터는 최근 5분 이내 학생들의 체감 혼잡도 제보를 기반으로 합니다.';

  @override
  String get cctvSupplementNotice =>
      '체감 혼잡도 제보는 CCTV 대기 인원을 보완해 탑승 예상 계산에 사용됩니다.';

  @override
  String get selectStopToCheckDistance =>
      '제보할 정류장을 선택하면 현재 위치와의 거리를 확인할 수 있어요.';

  @override
  String testModeNearStop(String station) {
    return '테스트 모드: 현재 $station 정류장 근처로 처리 중입니다.\n제보할 수 있어요. (0m)';
  }

  @override
  String get cannotCheckLocation => '현재 위치를 확인할 수 없어요. 위치 권한과 GPS 설정을 확인해 주세요.';

  @override
  String get checkingLocation => '현재 위치를 확인하는 중입니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get cannotCheckStopLocation => '정류장 위치 정보를 확인할 수 없어요.';

  @override
  String nearSelectedStop(String station, String distance) {
    return '현재 $station 정류장 근처입니다. 제보할 수 있어요. ($distance)';
  }

  @override
  String reportOnlyWithin50m(String distance) {
    return '정류장 50m 이내에서만 제보할 수 있어요.\n현재 거리: $distance';
  }

  @override
  String get weekendReportUnavailable => '주말에는 혼잡도 제보를 이용할 수 없습니다.';

  @override
  String get selectReportLocationMessage => '제보 위치를 선택해 주세요.';

  @override
  String get selectCongestionMessage => '체감 혼잡도를 선택해 주세요.';

  @override
  String reportSubmitSuccess(String location, String congestion) {
    return '[$location] $congestion 제보 완료!\n5분 후 다시 제보할 수 있어요.';
  }

  @override
  String get reportSubmitFailed => '제보 저장에 실패했습니다.';

  @override
  String get cooldownTitle => '잠깐!';

  @override
  String cooldownMessage(String time) {
    return '제보는 정류장 근처에서 5분에 한 번만 가능해요.\n\n⏱ $time 후 제보 가능합니다';
  }

  @override
  String canReportAfter(String time) {
    return '$time 후 제보 가능합니다';
  }

  @override
  String cooldownMinutesSeconds(int minutes, int seconds) {
    return '$minutes분 $seconds초';
  }

  @override
  String cooldownSeconds(int seconds) {
    return '$seconds초';
  }

  @override
  String get editTimetable => '시간표 편집';

  @override
  String get enterClassInfo => '수업 정보를 입력하세요';

  @override
  String get currentTimetable => '현재 시간표';

  @override
  String get addClass => '수업 추가';

  @override
  String get editClass => '수업 수정';

  @override
  String get dayLabel => '요일';

  @override
  String get startTimeLabel => '시작 시간';

  @override
  String get endTimeLabel => '종료 시간';

  @override
  String get classroomLabel => '강의실';

  @override
  String get addingClass => '추가 중...';

  @override
  String get updatingClass => '수정 중...';

  @override
  String get updateClassDone => '수정 완료';

  @override
  String get cancelEdit => '수정 취소';

  @override
  String get classList => '수업 목록';

  @override
  String get done => '완료';

  @override
  String get cancel => '취소';

  @override
  String get exampleTime => '예: 09:15';

  @override
  String get exampleEndTime => '예: 10:45';

  @override
  String get exampleRoom => '예: 101';

  @override
  String get mondayShort => '월';

  @override
  String get tuesdayShort => '화';

  @override
  String get wednesdayShort => '수';

  @override
  String get thursdayShort => '목';

  @override
  String get fridayShort => '금';

  @override
  String deleteClassMessage(String day, String time, String room) {
    return '$day $time\n$room 수업을 삭제할까요?';
  }

  @override
  String get deleteClassTitle => '수업 삭제';

  @override
  String get deleteButton => '삭제';

  @override
  String get timetableDeleted => '시간표가 삭제되었습니다.';

  @override
  String get timetableDeleteFailed => '시간표 삭제에 실패했습니다.';

  @override
  String get boardingPredictionTitle => '내 탑승 예상';

  @override
  String get expectedBoardingBus => '예상 탑승 버스';

  @override
  String get noBoardableBusFound => '현재 확인 가능한 버스 중\n탑승 가능한 버스를 찾지 못했어요';

  @override
  String arrivalScheduledText(String arrival, String time) {
    return '$arrival 도착 예정 · $time';
  }

  @override
  String get waitingCountAtStart => '줄서기 시작 당시 대기인원';

  @override
  String get expectedBoardingOrder => '예상 탑승 순서';

  @override
  String arrivalOrderBus(int order) {
    return '$order번째 도착 버스';
  }

  @override
  String get boardingCompletedMessage => '탑승 완료로 처리되었습니다.';

  @override
  String get expectedBusListTitle => '도착 예정 버스 확인';

  @override
  String get nextBoardingPredictionLoadFailed => '다음 탑승 예상 정보를 불러올 수 없습니다.';

  @override
  String get boardableExpected => '탑승 가능 예상';

  @override
  String get cannotJudge => '판단 불가';

  @override
  String get boardingDifficult => '탑승 어려움';

  @override
  String get afterRecommendedBus => '추천 버스 이후 도착';

  @override
  String get previousRecommendedBus => '이전 예상 버스';

  @override
  String get notBoarded => '탑승하지 않음';

  @override
  String get noBoardingDecisionInfo => '탑승 판단 정보 없음';

  @override
  String get expectedBusArrivedTitle => '예상 버스가 도착했어요';

  @override
  String get expectedBusArrivedSubtitle => '탑승 여부를 선택하면 안내를 이어갈 수 있어요.';

  @override
  String get boardedCompleteButton => '탑승 완료';

  @override
  String get checkingNow => '확인 중...';

  @override
  String get stillWaiting => '아직 대기 중';

  @override
  String busNumberLabel(String busNumber) {
    return '$busNumber번';
  }

  @override
  String arrivalInMinutes(int minute) {
    return '$minute분 후';
  }

  @override
  String get timetableLoadFailed => '시간표를 불러올 수 없습니다.';

  @override
  String get timetableEditInfoMissing => '수정할 시간표 정보를 찾을 수 없습니다.';

  @override
  String get selectTimetableToEdit => '수정할 시간표를 선택해주세요.';

  @override
  String get selectOneDayToEdit => '수정할 요일은 하나만 선택해주세요.';

  @override
  String classTimeOverlap(String day) {
    return '$day 같은 시간대에 이미 수업이 있습니다.';
  }

  @override
  String get timetableUpdated => '시간표가 수정되었습니다.';

  @override
  String get timetableUpdateFailed => '시간표 수정에 실패했습니다.';

  @override
  String get timetableAdded => '시간표가 추가되었습니다.';

  @override
  String get timetableAddFailed => '시간표 추가에 실패했습니다.';

  @override
  String get timetableDeleteInfoMissing => '삭제할 시간표 정보를 찾을 수 없습니다.';

  @override
  String get queueNoBusInfo => '현재 버스 운행 정보가 없어 줄서기를 이용할 수 없어요.';

  @override
  String get queueNearStationRequired => '정류장 근처에 도착해야 버스 줄서기를 이용할 수 있어요.';

  @override
  String get boardingPredictionLoadFailed => '탑승 예상 정보를 불러올 수 없습니다.';

  @override
  String get nextBus => '다음 버스';

  @override
  String nthBus(int order) {
    return '$order번째 버스';
  }

  @override
  String quickReportTitle(String station) {
    return '지금 $station 정류장의\n체감 혼잡도는 어떤가요?';
  }

  @override
  String get quickReportSubtitle => '한 번의 터치로 혼잡도 제보에 참여할 수 있어요';

  @override
  String get doLater => '나중에 할게요';

  @override
  String quickReportCooldownAgain(String time) {
    return '$time 후 다시 제보할 수 있어요.';
  }

  @override
  String quickReportSuccess(String station, String level) {
    return '[$station] $level 제보가 탑승 예상에 반영되었어요.';
  }

  @override
  String get recommendationReasonTitle => '이동 수단 추천 기준';

  @override
  String wheelchairReservationCount(int count) {
    return '휠체어 예약자 $count명';
  }

  @override
  String get wheelchairReservationExists => '휠체어 예약자 있음';

  @override
  String get reasonNoBusArrival => '현재 확인 가능한 버스 도착 정보가 없어, 도보 이동을 함께 고려해 주세요.';

  @override
  String get reasonNoWalkInfo => '도보 이동 정보를 확인할 수 없어, 현재 버스 도착 정보를 기준으로 안내합니다.';

  @override
  String get reasonTooManyWaiting =>
      '대기 인원이 많아 가까운 버스 탑승이 어려울 수 있어, 도보 이동을 추천합니다.';

  @override
  String get reasonBusTimeFits =>
      '버스 도착 시간과 다음 수업까지 남은 시간을 기준으로, 버스 이동을 추천합니다.';

  @override
  String get reasonWalkFaster => '예상 이동 시간이 더 짧아, 도보 이동을 추천합니다.';

  @override
  String get reasonBusTooLate => '버스 이동으로는 다음 수업 시간에 맞추기 어려워, 도보 이동을 추천합니다.';

  @override
  String get reasonBusFaster => '예상 이동 시간이 더 짧아, 버스 이동을 추천합니다.';

  @override
  String get reasonBusFasterThanWalk =>
      '도보 이동보다 버스 이동의 예상 소요 시간이 더 짧아, 버스 이동을 추천합니다.';

  @override
  String get reasonNoNextClassBuilding =>
      '다음 수업 건물 정보가 없어, 현재 선택한 정류장의 버스 도착 정보를 기준으로 안내합니다.';

  @override
  String get reasonMainGateEngineeringNoBus =>
      '정문에서는 공학관 방향으로 바로 이동할 수 있는 버스 경로가 없어 도보 이동을 추천합니다.';

  @override
  String get reasonNextClassNearStop =>
      '다음 수업 건물이 현재 선택한 정류장 근처에 있어 도보 이동을 추천합니다.';

  @override
  String get reasonNoBusRouteToNextClass =>
      '현재 선택한 정류장에서는 다음 수업 건물 방향으로 이용할 수 있는 버스 경로가 없어 도보 이동을 추천합니다.';

  @override
  String reasonBusRouteRecommended(String routeText, int minutes) {
    return '$routeText 기준의 이동 시간 $minutes분과 버스 대기 시간을 함께 계산해, 버스 이동을 추천합니다.';
  }

  @override
  String capacityLowFloorAtStation(int base, String station, int count) {
    return '저상버스 기준 $base명\n$station 예상 탑승 가능 $count명';
  }

  @override
  String capacitySeatsAtStation(int base, String station, int count) {
    return '남은 좌석 $base석\n$station 예상 탑승 가능 $count명';
  }

  @override
  String get ruleMainGate80 => '정문 80% 탑승 가정 기준 탑승 가능 예상';

  @override
  String capacityJeonjeongdae(int count) {
    return '남은 좌석 45석\n전정대 예상 탑승 인원 $count명';
  }

  @override
  String get ruleJeonjeongdae => '출발 정류장 예상 탑승 인원 기준 탑승 가능 예상';

  @override
  String get noSeatInfo => '좌석 정보를 확인할 수 없습니다';

  @override
  String ruleMainGateBoardingReflected(int count) {
    return '정문 예상 탑승 $count명 반영 후 탑승 가능 예상';
  }

  @override
  String get signupFailedTitle => '회원가입 실패';

  @override
  String get duplicateUsernameMessage => '이미 사용 중인 아이디입니다.';

  @override
  String get signupCompletedMessage => '회원가입이 완료되었습니다.';

  @override
  String get signupFailedMessage => '회원가입에 실패했습니다.';
}
