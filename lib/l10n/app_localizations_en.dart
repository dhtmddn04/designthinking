// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KHU BUS';

  @override
  String get language => 'Language';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';

  @override
  String get homeTab => 'Home';

  @override
  String get reservationTab => 'Reservation';

  @override
  String get reportTab => 'Report';

  @override
  String get profileTab => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Log in to your account';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get autoLogin => 'Auto login';

  @override
  String get signup => 'Sign up';

  @override
  String get signupSubtitle => 'Create a new account';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get reenterPassword => 'Re-enter your password';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get wheelchairUser => 'Wheelchair user';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get createAccount => 'Create account';

  @override
  String get backToLogin => 'Already have an account? Log in';

  @override
  String get enterUsernameAndPassword =>
      'Please enter your username and password.';

  @override
  String get loginSuccess => 'Logged in successfully.';

  @override
  String get loginFailed => 'Login failed.';

  @override
  String get serverConnectionFailed => 'Unable to connect to the server.';

  @override
  String get fillAllFields => 'Please fill in all fields.';

  @override
  String get phoneNumberFourDigits =>
      'Please enter 4 digits for each phone number field.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get signupSuccess => 'Account created successfully.';

  @override
  String get signupFailed => 'Sign-up failed.';

  @override
  String get profileInfo => 'Profile information';

  @override
  String get noRegisteredPhone => 'No phone number registered';

  @override
  String get timetable => 'Timetable';

  @override
  String get logout => 'Log out';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get enterFullPhoneNumber => 'Please enter your full phone number.';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully.';

  @override
  String get profileUpdateFailed => 'Failed to update profile.';

  @override
  String get saveInProgress => 'Saving...';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get homeTitle => 'Classroom Route Guide';

  @override
  String get homeSubtitle => 'We recommend the best way to get there';

  @override
  String get departureStation => 'Select departure stop';

  @override
  String get mainGateStation => 'Main Gate';

  @override
  String get oedaeStation => 'Foreign';

  @override
  String get jeonjeongdaeStation => 'Electronics';

  @override
  String get classUntil => 'Until class';

  @override
  String get congestion => 'Crowding';

  @override
  String get waitingPeople => 'Waiting';

  @override
  String get congestionLight => 'Light';

  @override
  String get congestionNormal => 'Normal';

  @override
  String get congestionBusy => 'Busy';

  @override
  String get congestionCrowded => 'Crowded';

  @override
  String get noInfo => 'No info';

  @override
  String peopleCount(int count) {
    return '$count people';
  }

  @override
  String get recommendedTransport => 'Recommended transport';

  @override
  String get busRecommended => 'Bus recommended';

  @override
  String get walkRecommended => 'Walking recommended';

  @override
  String get walkingSelected => 'Walking selected';

  @override
  String get boardingEstimate => 'Boarding estimate';

  @override
  String get busArrival => 'Bus arrival';

  @override
  String get estimatedArrivalTime => 'Estimated arrival';

  @override
  String afterMinutes(int minute) {
    return 'In about $minute min';
  }

  @override
  String busArrivesIn(String bus, String arrival) {
    return 'Bus $bus arrives $arrival';
  }

  @override
  String get noWalkingEstimate =>
      'No next class info.\nWalking time cannot be estimated.';

  @override
  String walkingEstimate(int minute) {
    return 'It takes about $minute min to walk to your next class.';
  }

  @override
  String busArrivingSoon(String bus) {
    return 'Bus $bus is arriving soon';
  }

  @override
  String get noBusServiceToday => 'No bus service information today';

  @override
  String get transportMethodTitle => 'Choose transport method';

  @override
  String get transportMethodSubtitle => 'How would you like to go?';

  @override
  String get busQueue => 'Join bus queue';

  @override
  String get noServiceInfo => 'No service info';

  @override
  String get currentlyUnavailable => 'Currently unavailable';

  @override
  String get checkBoardingEstimate => 'Check boarding estimate';

  @override
  String get nearStopOnly => 'Near stop only';

  @override
  String get walkMove => 'Walk';

  @override
  String get checkWalkingTime => 'Check walking time';

  @override
  String get locationPermissionNeeded => '📍 Location permission required';

  @override
  String get gettingLocation => '📍 Getting location...';

  @override
  String get noLocationInfo => '📍 No location information';

  @override
  String currentLocationNearStation(String distance) {
    return '📍 Current location: near the stop ($distance · within 50m)';
  }

  @override
  String currentLocationToStation(String distance) {
    return '📍 Current location: $distance from the stop\n(over 50m)';
  }

  @override
  String get busWaiting => 'Waiting for bus';

  @override
  String get walkingInProgress => 'Walking';

  @override
  String stationStop(String station) {
    return '📍 $station stop';
  }

  @override
  String get includedInWaitingList =>
      'You have been added to the waiting count';

  @override
  String get cancelWaiting => 'Cancel waiting';

  @override
  String get cancelMove => 'Cancel';

  @override
  String get reservationSubtitle => 'Support feature for wheelchair users.';

  @override
  String get pleaseSelectStop => 'Please select a stop';

  @override
  String get timeHeader => 'Time';

  @override
  String get reservationHeader => 'Reservation';

  @override
  String get ticket => 'Ticket';

  @override
  String get reserved => 'Reserved';

  @override
  String get reservationUnavailable => 'Unavailable';

  @override
  String get makeReservation => 'Reserve';

  @override
  String get reservationLoadFailed => 'Failed to load reservations.';

  @override
  String get reservationNotAvailableTitle => 'Reservation unavailable';

  @override
  String get invalidReservationTime =>
      'This time is not available for reservation.';

  @override
  String get alreadyReservedTime => 'This time slot is already reserved.';

  @override
  String get alreadyHasReservation => 'You already have a reservation.';

  @override
  String get alreadyHasSameTimeReservation =>
      'You already have a reservation at another stop at the same time.';

  @override
  String get notReservationTarget =>
      'You are not eligible to use this reservation feature.';

  @override
  String get weekendReservationUnavailable =>
      'Reservations are not available on weekends.';

  @override
  String get ok => 'OK';

  @override
  String get loginRequired => 'Login required.';

  @override
  String get reservationSuccess => 'Reservation completed.';

  @override
  String get reservationFailed => 'Failed to make reservation.';

  @override
  String get reservationCancelSuccess => 'Reservation canceled.';

  @override
  String get reservationCancelFailed => 'Failed to cancel reservation.';

  @override
  String get reservationResultUnknown => 'Unable to check reservation result.';

  @override
  String get reservationCancelResultUnknown =>
      'Unable to check cancellation result.';

  @override
  String get ticketTitle => 'Ticket';

  @override
  String get stopLabel => 'Stop';

  @override
  String get boardingBusLabel => 'Bus';

  @override
  String get classTimeLabel => 'Class time';

  @override
  String get arriveFiveMinutesEarly =>
      'Please arrive at the stop 5 minutes before boarding.';

  @override
  String get lowFloorBus9 => 'Low-floor bus 9';

  @override
  String lowFloorBus9Scheduled(String time) {
    return 'Low-floor bus 9 ($time scheduled)';
  }

  @override
  String get busArrivalInfoLoadFailed =>
      'Failed to load low-floor bus 9 arrival information.';

  @override
  String get busArrivalInfoNotReady =>
      'Low-floor bus 9 arrival information is not available yet.';

  @override
  String get reservationCompletedTitle => 'Reserved';

  @override
  String reservationCompletedMessage(String stop, String time) {
    return 'Your reservation for $stop stop at $time is complete.';
  }

  @override
  String get close => 'Close';

  @override
  String get cancelReservation => 'Cancel reservation';

  @override
  String get reportTitle => 'Real-time Crowding Report';

  @override
  String get reportSubtitle =>
      'Report how crowded the stop feels in real time.';

  @override
  String get reportLocation => 'Report location';

  @override
  String get selectLocation => 'Select location';

  @override
  String get feltCongestion => 'Felt crowding';

  @override
  String get selectCongestion => 'Select crowding';

  @override
  String get reportUnavailable => 'Report unavailable';

  @override
  String get reportNearStopOnly => 'Report near stop only';

  @override
  String get submitReport => 'Submit report';

  @override
  String get realtimeReportStatus => 'Real-time report status';

  @override
  String get reportStatusSubtitle =>
      'Check real-time crowding data reported by students.';

  @override
  String totalReports(int count) {
    return '$count reports';
  }

  @override
  String reportCount(int count) {
    return '$count';
  }

  @override
  String get recentReportNotice =>
      '* Data is based on student crowding reports from the last 5 minutes.';

  @override
  String get cctvSupplementNotice =>
      'Crowding reports supplement CCTV waiting counts for boarding estimates.';

  @override
  String get selectStopToCheckDistance =>
      'Select a stop to check your distance from it.';

  @override
  String testModeNearStop(String station) {
    return 'Test mode: treated as near $station stop.\nYou can report. (0m)';
  }

  @override
  String get cannotCheckLocation =>
      'Unable to check your current location. Please check location permission and GPS settings.';

  @override
  String get checkingLocation =>
      'Checking your current location. Please try again shortly.';

  @override
  String get cannotCheckStopLocation =>
      'Unable to check stop location information.';

  @override
  String nearSelectedStop(String station, String distance) {
    return 'You are near $station stop.\nYou can report. ($distance)';
  }

  @override
  String reportOnlyWithin50m(String distance) {
    return 'Reports are only available within 50m of the stop.\nCurrent distance: $distance';
  }

  @override
  String get weekendReportUnavailable =>
      'Crowding reports are not available on weekends.';

  @override
  String get selectReportLocationMessage => 'Please select a report location.';

  @override
  String get selectCongestionMessage => 'Please select felt crowding.';

  @override
  String reportSubmitSuccess(String location, String congestion) {
    return '[$location] $congestion report submitted!\nYou can report again in 5 minutes.';
  }

  @override
  String get reportSubmitFailed => 'Failed to save report.';

  @override
  String get cooldownTitle => 'Wait!';

  @override
  String cooldownMessage(String time) {
    return 'You can report once every 5 minutes near a stop.\n\n⏱ You can report again after $time';
  }

  @override
  String canReportAfter(String time) {
    return 'Available again after $time';
  }

  @override
  String cooldownMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String cooldownSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get editTimetable => 'Edit timetable';

  @override
  String get enterClassInfo => 'Enter class information';

  @override
  String get currentTimetable => 'Current timetable';

  @override
  String get addClass => 'Add class';

  @override
  String get editClass => 'Edit class';

  @override
  String get dayLabel => 'Day';

  @override
  String get startTimeLabel => 'Start time';

  @override
  String get endTimeLabel => 'End time';

  @override
  String get classroomLabel => 'Classroom';

  @override
  String get addingClass => 'Adding...';

  @override
  String get updatingClass => 'Updating...';

  @override
  String get updateClassDone => 'Save changes';

  @override
  String get cancelEdit => 'Cancel edit';

  @override
  String get classList => 'Class list';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get exampleTime => 'Ex: 09:15';

  @override
  String get exampleEndTime => 'Ex: 10:45';

  @override
  String get exampleRoom => 'Ex: 101';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String deleteClassMessage(String day, String time, String room) {
    return '$day $time\nDelete $room class?';
  }

  @override
  String get deleteClassTitle => 'Delete class';

  @override
  String get deleteButton => 'Delete';

  @override
  String get timetableDeleted => 'Timetable entry deleted.';

  @override
  String get timetableDeleteFailed => 'Failed to delete timetable entry.';

  @override
  String get boardingPredictionTitle => 'My boarding estimate';

  @override
  String get expectedBoardingBus => 'Expected bus';

  @override
  String get noBoardableBusFound =>
      'No boardable bus was found\namong currently available buses.';

  @override
  String arrivalScheduledText(String arrival, String time) {
    return 'Arrives $arrival · $time';
  }

  @override
  String get waitingCountAtStart => 'Waiting count when joined';

  @override
  String get expectedBoardingOrder => 'Expected boarding order';

  @override
  String arrivalOrderBus(int order) {
    return 'Arriving bus #$order';
  }

  @override
  String get boardingCompletedMessage => 'Marked as boarded.';

  @override
  String get expectedBusListTitle => 'Expected arriving buses';

  @override
  String get nextBoardingPredictionLoadFailed =>
      'Failed to load the next boarding estimate.';

  @override
  String get boardableExpected => 'Likely boardable';

  @override
  String get cannotJudge => 'Cannot determine';

  @override
  String get boardingDifficult => 'Difficult to board';

  @override
  String get afterRecommendedBus => 'After recommended';

  @override
  String get previousRecommendedBus => 'Previous recommended bus';

  @override
  String get notBoarded => 'Not boarded';

  @override
  String get noBoardingDecisionInfo => 'No boarding decision info';

  @override
  String get expectedBusArrivedTitle => 'Your expected bus has arrived';

  @override
  String get expectedBusArrivedSubtitle =>
      'Select whether you boarded to continue guidance.';

  @override
  String get boardedCompleteButton => 'I boarded';

  @override
  String get checkingNow => 'Checking...';

  @override
  String get stillWaiting => 'Still waiting';

  @override
  String busNumberLabel(String busNumber) {
    return 'Bus $busNumber';
  }

  @override
  String arrivalInMinutes(int minute) {
    return 'in $minute min';
  }

  @override
  String get timetableLoadFailed => 'Failed to load timetable.';

  @override
  String get timetableEditInfoMissing =>
      'Could not find timetable information to edit.';

  @override
  String get selectTimetableToEdit =>
      'Please select a timetable entry to edit.';

  @override
  String get selectOneDayToEdit => 'Please select only one day to edit.';

  @override
  String classTimeOverlap(String day) {
    return 'There is already a class at the same time on $day.';
  }

  @override
  String get timetableUpdated => 'Timetable updated.';

  @override
  String get timetableUpdateFailed => 'Failed to update timetable.';

  @override
  String get timetableAdded => 'Timetable entry added.';

  @override
  String get timetableAddFailed => 'Failed to add timetable entry.';

  @override
  String get timetableDeleteInfoMissing =>
      'Could not find timetable information to delete.';

  @override
  String get queueNoBusInfo =>
      'Bus queue is unavailable because there is no current bus service information.';

  @override
  String get queueNearStationRequired =>
      'You need to be near the stop to join the bus queue.';

  @override
  String get boardingPredictionLoadFailed =>
      'Failed to load boarding estimate.';

  @override
  String get nextBus => 'Next bus';

  @override
  String nthBus(int order) {
    return 'Bus #$order';
  }

  @override
  String quickReportTitle(String station) {
    return 'How crowded does $station stop feel right now?';
  }

  @override
  String get quickReportSubtitle => 'Submit a crowding report with one tap.';

  @override
  String get doLater => 'Maybe later';

  @override
  String quickReportCooldownAgain(String time) {
    return 'You can report again after $time.';
  }

  @override
  String quickReportSuccess(String station, String level) {
    return '[$station] $level report was reflected in the boarding estimate.';
  }

  @override
  String get recommendationReasonTitle => 'Recommendation criteria';

  @override
  String wheelchairReservationCount(int count) {
    return '$count wheelchair reservation(s)';
  }

  @override
  String get wheelchairReservationExists => 'Wheelchair reservation exists';

  @override
  String get reasonNoBusArrival =>
      'No current bus arrival information is available, so walking should also be considered.';

  @override
  String get reasonNoWalkInfo =>
      'Walking information is unavailable, so guidance is based on current bus arrival information.';

  @override
  String get reasonTooManyWaiting =>
      'Many people are waiting, so nearby buses may be hard to board. Walking is recommended.';

  @override
  String get reasonBusTimeFits =>
      'Bus is recommended based on the bus arrival time and the time left until your next class.';

  @override
  String get reasonWalkFaster =>
      'Walking is recommended because the estimated travel time is shorter.';

  @override
  String get reasonBusTooLate =>
      'Walking is recommended because the bus may not arrive in time for your next class.';

  @override
  String get reasonBusFaster =>
      'Bus is recommended because the estimated travel time is shorter.';

  @override
  String get reasonBusFasterThanWalk =>
      'Bus is recommended because it is expected to take less time than walking.';

  @override
  String get reasonNoNextClassBuilding =>
      'No next class building information is available, so guidance is based on bus arrival information for the selected stop.';

  @override
  String get reasonMainGateEngineeringNoBus =>
      'There is no bus route directly toward Engineering Hall from the Main Gate, so walking is recommended.';

  @override
  String get reasonNextClassNearStop =>
      'Your next class building is near the selected stop, so walking is recommended.';

  @override
  String get reasonNoBusRouteToNextClass =>
      'There is no available bus route from the selected stop toward your next class building, so walking is recommended.';

  @override
  String reasonBusRouteRecommended(String routeText, int minutes) {
    return 'Based on $routeText, $minutes min of travel time and bus waiting time are considered. Bus is recommended.';
  }

  @override
  String capacityLowFloorAtStation(int base, String station, int count) {
    return 'Capacity: $base\nCan board at $station: $count';
  }

  @override
  String capacitySeatsAtStation(int base, String station, int count) {
    return 'Seats left: $base\nCan board at $station: $count';
  }

  @override
  String get ruleMainGate80 =>
      'Boarding estimate based on 80% boarding at Main Gate';

  @override
  String capacityJeonjeongdae(int count) {
    return 'Seats left: 45\nCan board at Electronics: $count';
  }

  @override
  String get ruleJeonjeongdae =>
      'Boarding estimate based on expected boarders at the departure stop';

  @override
  String get noSeatInfo => 'Seat information is unavailable';

  @override
  String ruleMainGateBoardingReflected(int count) {
    return 'After $count boarded at Main Gate';
  }

  @override
  String get signupFailedTitle => 'Sign-up Failed';

  @override
  String get duplicateUsernameMessage => 'This ID is already in use.';

  @override
  String get signupCompletedMessage => 'Sign-up completed.';

  @override
  String get signupFailedMessage => 'Failed to sign up.';
}
