import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'KHU BUS'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @korean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @homeTab.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get homeTab;

  /// No description provided for @reservationTab.
  ///
  /// In ko, this message translates to:
  /// **'예약'**
  String get reservationTab;

  /// No description provided for @reportTab.
  ///
  /// In ko, this message translates to:
  /// **'제보'**
  String get reportTab;

  /// No description provided for @profileTab.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profileTab;

  /// No description provided for @login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'계정에 로그인하세요'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In ko, this message translates to:
  /// **'아이디'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In ko, this message translates to:
  /// **'아이디를 입력하세요'**
  String get enterUsername;

  /// No description provided for @password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력하세요'**
  String get enterPassword;

  /// No description provided for @autoLogin.
  ///
  /// In ko, this message translates to:
  /// **'자동 로그인'**
  String get autoLogin;

  /// No description provided for @signup.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get signup;

  /// No description provided for @signupSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'새 계정을 만들어보세요'**
  String get signupSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 재확인'**
  String get confirmPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 다시 입력하세요'**
  String get reenterPassword;

  /// No description provided for @phoneNumber.
  ///
  /// In ko, this message translates to:
  /// **'휴대전화'**
  String get phoneNumber;

  /// No description provided for @wheelchairUser.
  ///
  /// In ko, this message translates to:
  /// **'휠체어 탑승 여부'**
  String get wheelchairUser;

  /// No description provided for @yes.
  ///
  /// In ko, this message translates to:
  /// **'예'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ko, this message translates to:
  /// **'아니오'**
  String get no;

  /// No description provided for @createAccount.
  ///
  /// In ko, this message translates to:
  /// **'가입하기'**
  String get createAccount;

  /// No description provided for @backToLogin.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요? 로그인'**
  String get backToLogin;

  /// No description provided for @enterUsernameAndPassword.
  ///
  /// In ko, this message translates to:
  /// **'아이디와 비밀번호를 입력해주세요.'**
  String get enterUsernameAndPassword;

  /// No description provided for @loginSuccess.
  ///
  /// In ko, this message translates to:
  /// **'로그인되었습니다.'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다.'**
  String get loginFailed;

  /// No description provided for @serverConnectionFailed.
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없습니다.'**
  String get serverConnectionFailed;

  /// No description provided for @fillAllFields.
  ///
  /// In ko, this message translates to:
  /// **'모든 정보를 입력해주세요.'**
  String get fillAllFields;

  /// No description provided for @phoneNumberFourDigits.
  ///
  /// In ko, this message translates to:
  /// **'휴대전화 번호는 4자리씩 입력해주세요.'**
  String get phoneNumberFourDigits;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 일치하지 않습니다.'**
  String get passwordsDoNotMatch;

  /// No description provided for @signupSuccess.
  ///
  /// In ko, this message translates to:
  /// **'회원가입이 완료되었습니다.'**
  String get signupSuccess;

  /// No description provided for @signupFailed.
  ///
  /// In ko, this message translates to:
  /// **'회원가입에 실패했습니다.'**
  String get signupFailed;

  /// No description provided for @profileInfo.
  ///
  /// In ko, this message translates to:
  /// **'프로필 정보'**
  String get profileInfo;

  /// No description provided for @noRegisteredPhone.
  ///
  /// In ko, this message translates to:
  /// **'등록된 번호 없음'**
  String get noRegisteredPhone;

  /// No description provided for @timetable.
  ///
  /// In ko, this message translates to:
  /// **'시간표'**
  String get timetable;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 수정'**
  String get editProfile;

  /// No description provided for @enterFullPhoneNumber.
  ///
  /// In ko, this message translates to:
  /// **'휴대전화 번호를 모두 입력해주세요.'**
  String get enterFullPhoneNumber;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In ko, this message translates to:
  /// **'프로필이 수정되었습니다.'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In ko, this message translates to:
  /// **'프로필 수정에 실패했습니다.'**
  String get profileUpdateFailed;

  /// No description provided for @saveInProgress.
  ///
  /// In ko, this message translates to:
  /// **'저장 중...'**
  String get saveInProgress;

  /// No description provided for @saveChanges.
  ///
  /// In ko, this message translates to:
  /// **'수정 완료'**
  String get saveChanges;

  /// No description provided for @homeTitle.
  ///
  /// In ko, this message translates to:
  /// **'강의실 이동 안내'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'최적의 이동 수단을 추천합니다'**
  String get homeSubtitle;

  /// No description provided for @departureStation.
  ///
  /// In ko, this message translates to:
  /// **'출발 정류장 선택'**
  String get departureStation;

  /// No description provided for @mainGateStation.
  ///
  /// In ko, this message translates to:
  /// **'정문'**
  String get mainGateStation;

  /// No description provided for @oedaeStation.
  ///
  /// In ko, this message translates to:
  /// **'외대'**
  String get oedaeStation;

  /// No description provided for @jeonjeongdaeStation.
  ///
  /// In ko, this message translates to:
  /// **'전정대'**
  String get jeonjeongdaeStation;

  /// No description provided for @classUntil.
  ///
  /// In ko, this message translates to:
  /// **'수업까지'**
  String get classUntil;

  /// No description provided for @congestion.
  ///
  /// In ko, this message translates to:
  /// **'혼잡도'**
  String get congestion;

  /// No description provided for @waitingPeople.
  ///
  /// In ko, this message translates to:
  /// **'대기인원'**
  String get waitingPeople;

  /// No description provided for @congestionLight.
  ///
  /// In ko, this message translates to:
  /// **'여유'**
  String get congestionLight;

  /// No description provided for @congestionNormal.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get congestionNormal;

  /// No description provided for @congestionBusy.
  ///
  /// In ko, this message translates to:
  /// **'약간 혼잡'**
  String get congestionBusy;

  /// No description provided for @congestionCrowded.
  ///
  /// In ko, this message translates to:
  /// **'혼잡'**
  String get congestionCrowded;

  /// No description provided for @noInfo.
  ///
  /// In ko, this message translates to:
  /// **'정보 없음'**
  String get noInfo;

  /// No description provided for @peopleCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String peopleCount(int count);

  /// No description provided for @recommendedTransport.
  ///
  /// In ko, this message translates to:
  /// **'추천 이동 수단'**
  String get recommendedTransport;

  /// No description provided for @busRecommended.
  ///
  /// In ko, this message translates to:
  /// **'버스 탑승을 권장합니다'**
  String get busRecommended;

  /// No description provided for @walkRecommended.
  ///
  /// In ko, this message translates to:
  /// **'도보 이동을 권장합니다'**
  String get walkRecommended;

  /// No description provided for @walkingSelected.
  ///
  /// In ko, this message translates to:
  /// **'도보 이동을 선택했습니다'**
  String get walkingSelected;

  /// No description provided for @boardingEstimate.
  ///
  /// In ko, this message translates to:
  /// **'탑승 예상'**
  String get boardingEstimate;

  /// No description provided for @busArrival.
  ///
  /// In ko, this message translates to:
  /// **'버스 도착'**
  String get busArrival;

  /// No description provided for @estimatedArrivalTime.
  ///
  /// In ko, this message translates to:
  /// **'예상 도착시간'**
  String get estimatedArrivalTime;

  /// No description provided for @afterMinutes.
  ///
  /// In ko, this message translates to:
  /// **'약 {minute}분 후'**
  String afterMinutes(int minute);

  /// No description provided for @busArrivesIn.
  ///
  /// In ko, this message translates to:
  /// **'{bus} 버스가 {arrival} 도착합니다'**
  String busArrivesIn(String bus, String arrival);

  /// No description provided for @noWalkingEstimate.
  ///
  /// In ko, this message translates to:
  /// **'다음 수업 정보가 없어\n예상 도보 시간을 계산할 수 없어요.'**
  String get noWalkingEstimate;

  /// No description provided for @walkingEstimate.
  ///
  /// In ko, this message translates to:
  /// **'다음 수업 건물까지 걸어서 약 {minute}분 걸려요.'**
  String walkingEstimate(int minute);

  /// No description provided for @busArrivingSoon.
  ///
  /// In ko, this message translates to:
  /// **'{bus} 버스가 곧 도착합니다'**
  String busArrivingSoon(String bus);

  /// No description provided for @noBusServiceToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘 운행 정보가 없습니다'**
  String get noBusServiceToday;

  /// No description provided for @transportMethodTitle.
  ///
  /// In ko, this message translates to:
  /// **'이동 방법 선택'**
  String get transportMethodTitle;

  /// No description provided for @transportMethodSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'어떻게 이동하시겠어요?'**
  String get transportMethodSubtitle;

  /// No description provided for @busQueue.
  ///
  /// In ko, this message translates to:
  /// **'버스 줄서기'**
  String get busQueue;

  /// No description provided for @noServiceInfo.
  ///
  /// In ko, this message translates to:
  /// **'운행 정보 없음'**
  String get noServiceInfo;

  /// No description provided for @currentlyUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'현재 이용 불가'**
  String get currentlyUnavailable;

  /// No description provided for @checkBoardingEstimate.
  ///
  /// In ko, this message translates to:
  /// **'내 탑승 예상 확인'**
  String get checkBoardingEstimate;

  /// No description provided for @nearStopOnly.
  ///
  /// In ko, this message translates to:
  /// **'정류장 근처에서만'**
  String get nearStopOnly;

  /// No description provided for @walkMove.
  ///
  /// In ko, this message translates to:
  /// **'도보 이동'**
  String get walkMove;

  /// No description provided for @checkWalkingTime.
  ///
  /// In ko, this message translates to:
  /// **'예상 도보 시간 확인'**
  String get checkWalkingTime;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In ko, this message translates to:
  /// **'📍 위치 권한이 필요합니다'**
  String get locationPermissionNeeded;

  /// No description provided for @gettingLocation.
  ///
  /// In ko, this message translates to:
  /// **'📍 위치 정보를 가져오는 중...'**
  String get gettingLocation;

  /// No description provided for @noLocationInfo.
  ///
  /// In ko, this message translates to:
  /// **'📍 위치 정보 없음'**
  String get noLocationInfo;

  /// No description provided for @currentLocationNearStation.
  ///
  /// In ko, this message translates to:
  /// **'📍 현재 위치: 정류장 근처 ({distance} · 50m 이내)'**
  String currentLocationNearStation(String distance);

  /// No description provided for @currentLocationToStation.
  ///
  /// In ko, this message translates to:
  /// **'📍 현재 위치: 정류장까지 {distance} (50m 이상)'**
  String currentLocationToStation(String distance);

  /// No description provided for @busWaiting.
  ///
  /// In ko, this message translates to:
  /// **'버스 대기 중'**
  String get busWaiting;

  /// No description provided for @walkingInProgress.
  ///
  /// In ko, this message translates to:
  /// **'도보 이동 중'**
  String get walkingInProgress;

  /// No description provided for @stationStop.
  ///
  /// In ko, this message translates to:
  /// **'📍 {station} 정류장'**
  String stationStop(String station);

  /// No description provided for @includedInWaitingList.
  ///
  /// In ko, this message translates to:
  /// **'대기인원에 포함되었습니다'**
  String get includedInWaitingList;

  /// No description provided for @cancelWaiting.
  ///
  /// In ko, this message translates to:
  /// **'대기 취소'**
  String get cancelWaiting;

  /// No description provided for @cancelMove.
  ///
  /// In ko, this message translates to:
  /// **'이동 취소'**
  String get cancelMove;

  /// No description provided for @reservationSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'휠체어 사용자를 위한 지원 기능입니다.'**
  String get reservationSubtitle;

  /// No description provided for @pleaseSelectStop.
  ///
  /// In ko, this message translates to:
  /// **'정류장을 선택해주세요'**
  String get pleaseSelectStop;

  /// No description provided for @timeHeader.
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get timeHeader;

  /// No description provided for @reservationHeader.
  ///
  /// In ko, this message translates to:
  /// **'예약'**
  String get reservationHeader;

  /// No description provided for @ticket.
  ///
  /// In ko, this message translates to:
  /// **'탑승권'**
  String get ticket;

  /// No description provided for @reserved.
  ///
  /// In ko, this message translates to:
  /// **'예약완료'**
  String get reserved;

  /// No description provided for @reservationUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'예약불가'**
  String get reservationUnavailable;

  /// No description provided for @makeReservation.
  ///
  /// In ko, this message translates to:
  /// **'예약하기'**
  String get makeReservation;

  /// No description provided for @reservationLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'예약 내역을 불러올 수 없습니다.'**
  String get reservationLoadFailed;

  /// No description provided for @reservationNotAvailableTitle.
  ///
  /// In ko, this message translates to:
  /// **'예약 불가'**
  String get reservationNotAvailableTitle;

  /// No description provided for @invalidReservationTime.
  ///
  /// In ko, this message translates to:
  /// **'예약 가능한 시간이 아닙니다.'**
  String get invalidReservationTime;

  /// No description provided for @alreadyReservedTime.
  ///
  /// In ko, this message translates to:
  /// **'이미 예약된 시간대입니다.'**
  String get alreadyReservedTime;

  /// No description provided for @alreadyHasReservation.
  ///
  /// In ko, this message translates to:
  /// **'이미 예약한 시간이 있습니다.'**
  String get alreadyHasReservation;

  /// No description provided for @alreadyHasSameTimeReservation.
  ///
  /// In ko, this message translates to:
  /// **'이미 같은 시간에 다른 정류장 예약이 있습니다.'**
  String get alreadyHasSameTimeReservation;

  /// No description provided for @notReservationTarget.
  ///
  /// In ko, this message translates to:
  /// **'예약 기능 이용 대상자가 아닙니다.'**
  String get notReservationTarget;

  /// No description provided for @weekendReservationUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'주말에는 예약 기능을 이용할 수 없습니다.'**
  String get weekendReservationUnavailable;

  /// No description provided for @ok.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;

  /// No description provided for @loginRequired.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다.'**
  String get loginRequired;

  /// No description provided for @reservationSuccess.
  ///
  /// In ko, this message translates to:
  /// **'예약이 완료되었습니다.'**
  String get reservationSuccess;

  /// No description provided for @reservationFailed.
  ///
  /// In ko, this message translates to:
  /// **'예약에 실패했습니다.'**
  String get reservationFailed;

  /// No description provided for @reservationCancelSuccess.
  ///
  /// In ko, this message translates to:
  /// **'예약이 취소되었습니다.'**
  String get reservationCancelSuccess;

  /// No description provided for @reservationCancelFailed.
  ///
  /// In ko, this message translates to:
  /// **'예약 취소에 실패했습니다.'**
  String get reservationCancelFailed;

  /// No description provided for @reservationResultUnknown.
  ///
  /// In ko, this message translates to:
  /// **'예약 결과를 확인할 수 없습니다.'**
  String get reservationResultUnknown;

  /// No description provided for @reservationCancelResultUnknown.
  ///
  /// In ko, this message translates to:
  /// **'예약 취소 결과를 확인할 수 없습니다.'**
  String get reservationCancelResultUnknown;

  /// No description provided for @ticketTitle.
  ///
  /// In ko, this message translates to:
  /// **'탑승권'**
  String get ticketTitle;

  /// No description provided for @stopLabel.
  ///
  /// In ko, this message translates to:
  /// **'정류장'**
  String get stopLabel;

  /// No description provided for @boardingBusLabel.
  ///
  /// In ko, this message translates to:
  /// **'이용 버스'**
  String get boardingBusLabel;

  /// No description provided for @classTimeLabel.
  ///
  /// In ko, this message translates to:
  /// **'강의 시간'**
  String get classTimeLabel;

  /// No description provided for @arriveFiveMinutesEarly.
  ///
  /// In ko, this message translates to:
  /// **'탑승 5분 전까지 정류장에 도착해주세요'**
  String get arriveFiveMinutesEarly;

  /// No description provided for @lowFloorBus9.
  ///
  /// In ko, this message translates to:
  /// **'9번 저상버스'**
  String get lowFloorBus9;

  /// No description provided for @lowFloorBus9Scheduled.
  ///
  /// In ko, this message translates to:
  /// **'9번 저상버스 ({time} 예정)'**
  String lowFloorBus9Scheduled(String time);

  /// No description provided for @busArrivalInfoLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'9번 저상버스 도착정보를 불러올 수 없습니다.'**
  String get busArrivalInfoLoadFailed;

  /// No description provided for @busArrivalInfoNotReady.
  ///
  /// In ko, this message translates to:
  /// **'9번 저상버스 도착정보가 아직 없습니다.'**
  String get busArrivalInfoNotReady;

  /// No description provided for @reservationCompletedTitle.
  ///
  /// In ko, this message translates to:
  /// **'예약되었습니다'**
  String get reservationCompletedTitle;

  /// No description provided for @reservationCompletedMessage.
  ///
  /// In ko, this message translates to:
  /// **'{stop} 정류장 {time} 예약이 완료되었습니다.'**
  String reservationCompletedMessage(String stop, String time);

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @cancelReservation.
  ///
  /// In ko, this message translates to:
  /// **'예약 취소'**
  String get cancelReservation;

  /// No description provided for @reportTitle.
  ///
  /// In ko, this message translates to:
  /// **'실시간 체감 혼잡도 제보'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'실제 정류장에서 느낀 혼잡도를 제보해 주세요.'**
  String get reportSubtitle;

  /// No description provided for @reportLocation.
  ///
  /// In ko, this message translates to:
  /// **'제보 위치'**
  String get reportLocation;

  /// No description provided for @selectLocation.
  ///
  /// In ko, this message translates to:
  /// **'위치 선택'**
  String get selectLocation;

  /// No description provided for @feltCongestion.
  ///
  /// In ko, this message translates to:
  /// **'체감 혼잡도'**
  String get feltCongestion;

  /// No description provided for @selectCongestion.
  ///
  /// In ko, this message translates to:
  /// **'혼잡도 선택'**
  String get selectCongestion;

  /// No description provided for @reportUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'제보 불가'**
  String get reportUnavailable;

  /// No description provided for @reportNearStopOnly.
  ///
  /// In ko, this message translates to:
  /// **'정류장 근처에서 제보 가능'**
  String get reportNearStopOnly;

  /// No description provided for @submitReport.
  ///
  /// In ko, this message translates to:
  /// **'제보하기'**
  String get submitReport;

  /// No description provided for @realtimeReportStatus.
  ///
  /// In ko, this message translates to:
  /// **'실시간 제보 현황'**
  String get realtimeReportStatus;

  /// No description provided for @reportStatusSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'학생들이 제보한 실시간 혼잡 데이터를 확인하세요.'**
  String get reportStatusSubtitle;

  /// No description provided for @totalReports.
  ///
  /// In ko, this message translates to:
  /// **'전체 {count}건'**
  String totalReports(int count);

  /// No description provided for @reportCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}건'**
  String reportCount(int count);

  /// No description provided for @recentReportNotice.
  ///
  /// In ko, this message translates to:
  /// **'* 데이터는 최근 5분 이내 학생들의 체감 혼잡도 제보를 기반으로 합니다.'**
  String get recentReportNotice;

  /// No description provided for @cctvSupplementNotice.
  ///
  /// In ko, this message translates to:
  /// **'체감 혼잡도 제보는 CCTV 대기 인원을 보완해 탑승 예상 계산에 사용됩니다.'**
  String get cctvSupplementNotice;

  /// No description provided for @selectStopToCheckDistance.
  ///
  /// In ko, this message translates to:
  /// **'제보할 정류장을 선택하면 현재 위치와의 거리를 확인할 수 있어요.'**
  String get selectStopToCheckDistance;

  /// No description provided for @testModeNearStop.
  ///
  /// In ko, this message translates to:
  /// **'테스트 모드: 현재 {station} 정류장 근처로 처리 중입니다.\n제보할 수 있어요. (0m)'**
  String testModeNearStop(String station);

  /// No description provided for @cannotCheckLocation.
  ///
  /// In ko, this message translates to:
  /// **'현재 위치를 확인할 수 없어요. 위치 권한과 GPS 설정을 확인해 주세요.'**
  String get cannotCheckLocation;

  /// No description provided for @checkingLocation.
  ///
  /// In ko, this message translates to:
  /// **'현재 위치를 확인하는 중입니다. 잠시 후 다시 시도해 주세요.'**
  String get checkingLocation;

  /// No description provided for @cannotCheckStopLocation.
  ///
  /// In ko, this message translates to:
  /// **'정류장 위치 정보를 확인할 수 없어요.'**
  String get cannotCheckStopLocation;

  /// No description provided for @nearSelectedStop.
  ///
  /// In ko, this message translates to:
  /// **'현재 {station} 정류장 근처입니다. 제보할 수 있어요. ({distance})'**
  String nearSelectedStop(String station, String distance);

  /// No description provided for @reportOnlyWithin50m.
  ///
  /// In ko, this message translates to:
  /// **'정류장 50m 이내에서만 제보할 수 있어요.\n현재 거리: {distance}'**
  String reportOnlyWithin50m(String distance);

  /// No description provided for @weekendReportUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'주말에는 혼잡도 제보를 이용할 수 없습니다.'**
  String get weekendReportUnavailable;

  /// No description provided for @selectReportLocationMessage.
  ///
  /// In ko, this message translates to:
  /// **'제보 위치를 선택해 주세요.'**
  String get selectReportLocationMessage;

  /// No description provided for @selectCongestionMessage.
  ///
  /// In ko, this message translates to:
  /// **'체감 혼잡도를 선택해 주세요.'**
  String get selectCongestionMessage;

  /// No description provided for @reportSubmitSuccess.
  ///
  /// In ko, this message translates to:
  /// **'[{location}] {congestion} 제보 완료!\n5분 후 다시 제보할 수 있어요.'**
  String reportSubmitSuccess(String location, String congestion);

  /// No description provided for @reportSubmitFailed.
  ///
  /// In ko, this message translates to:
  /// **'제보 저장에 실패했습니다.'**
  String get reportSubmitFailed;

  /// No description provided for @cooldownTitle.
  ///
  /// In ko, this message translates to:
  /// **'잠깐!'**
  String get cooldownTitle;

  /// No description provided for @cooldownMessage.
  ///
  /// In ko, this message translates to:
  /// **'제보는 정류장 근처에서 5분에 한 번만 가능해요.\n\n⏱ {time} 후 제보 가능합니다'**
  String cooldownMessage(String time);

  /// No description provided for @canReportAfter.
  ///
  /// In ko, this message translates to:
  /// **'{time} 후 제보 가능합니다'**
  String canReportAfter(String time);

  /// No description provided for @cooldownMinutesSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 {seconds}초'**
  String cooldownMinutesSeconds(int minutes, int seconds);

  /// No description provided for @cooldownSeconds.
  ///
  /// In ko, this message translates to:
  /// **'{seconds}초'**
  String cooldownSeconds(int seconds);

  /// No description provided for @editTimetable.
  ///
  /// In ko, this message translates to:
  /// **'시간표 편집'**
  String get editTimetable;

  /// No description provided for @enterClassInfo.
  ///
  /// In ko, this message translates to:
  /// **'수업 정보를 입력하세요'**
  String get enterClassInfo;

  /// No description provided for @currentTimetable.
  ///
  /// In ko, this message translates to:
  /// **'현재 시간표'**
  String get currentTimetable;

  /// No description provided for @addClass.
  ///
  /// In ko, this message translates to:
  /// **'수업 추가'**
  String get addClass;

  /// No description provided for @editClass.
  ///
  /// In ko, this message translates to:
  /// **'수업 수정'**
  String get editClass;

  /// No description provided for @dayLabel.
  ///
  /// In ko, this message translates to:
  /// **'요일'**
  String get dayLabel;

  /// No description provided for @startTimeLabel.
  ///
  /// In ko, this message translates to:
  /// **'시작 시간'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In ko, this message translates to:
  /// **'종료 시간'**
  String get endTimeLabel;

  /// No description provided for @classroomLabel.
  ///
  /// In ko, this message translates to:
  /// **'강의실'**
  String get classroomLabel;

  /// No description provided for @addingClass.
  ///
  /// In ko, this message translates to:
  /// **'추가 중...'**
  String get addingClass;

  /// No description provided for @updatingClass.
  ///
  /// In ko, this message translates to:
  /// **'수정 중...'**
  String get updatingClass;

  /// No description provided for @updateClassDone.
  ///
  /// In ko, this message translates to:
  /// **'수정 완료'**
  String get updateClassDone;

  /// No description provided for @cancelEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정 취소'**
  String get cancelEdit;

  /// No description provided for @classList.
  ///
  /// In ko, this message translates to:
  /// **'수업 목록'**
  String get classList;

  /// No description provided for @done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @exampleTime.
  ///
  /// In ko, this message translates to:
  /// **'예: 09:15'**
  String get exampleTime;

  /// No description provided for @exampleEndTime.
  ///
  /// In ko, this message translates to:
  /// **'예: 10:45'**
  String get exampleEndTime;

  /// No description provided for @exampleRoom.
  ///
  /// In ko, this message translates to:
  /// **'예: 101'**
  String get exampleRoom;

  /// No description provided for @mondayShort.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get fridayShort;

  /// No description provided for @deleteClassMessage.
  ///
  /// In ko, this message translates to:
  /// **'{day} {time}\n{room} 수업을 삭제할까요?'**
  String deleteClassMessage(String day, String time, String room);

  /// No description provided for @deleteClassTitle.
  ///
  /// In ko, this message translates to:
  /// **'수업 삭제'**
  String get deleteClassTitle;

  /// No description provided for @deleteButton.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get deleteButton;

  /// No description provided for @timetableDeleted.
  ///
  /// In ko, this message translates to:
  /// **'시간표가 삭제되었습니다.'**
  String get timetableDeleted;

  /// No description provided for @timetableDeleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'시간표 삭제에 실패했습니다.'**
  String get timetableDeleteFailed;

  /// No description provided for @boardingPredictionTitle.
  ///
  /// In ko, this message translates to:
  /// **'내 탑승 예상'**
  String get boardingPredictionTitle;

  /// No description provided for @expectedBoardingBus.
  ///
  /// In ko, this message translates to:
  /// **'예상 탑승 버스'**
  String get expectedBoardingBus;

  /// No description provided for @noBoardableBusFound.
  ///
  /// In ko, this message translates to:
  /// **'현재 확인 가능한 버스 중\n탑승 가능한 버스를 찾지 못했어요'**
  String get noBoardableBusFound;

  /// No description provided for @arrivalScheduledText.
  ///
  /// In ko, this message translates to:
  /// **'{arrival} 도착 예정 · {time}'**
  String arrivalScheduledText(String arrival, String time);

  /// No description provided for @waitingCountAtStart.
  ///
  /// In ko, this message translates to:
  /// **'줄서기 시작 당시 대기인원'**
  String get waitingCountAtStart;

  /// No description provided for @expectedBoardingOrder.
  ///
  /// In ko, this message translates to:
  /// **'예상 탑승 순서'**
  String get expectedBoardingOrder;

  /// No description provided for @arrivalOrderBus.
  ///
  /// In ko, this message translates to:
  /// **'{order}번째 도착 버스'**
  String arrivalOrderBus(int order);

  /// No description provided for @boardingCompletedMessage.
  ///
  /// In ko, this message translates to:
  /// **'탑승 완료로 처리되었습니다.'**
  String get boardingCompletedMessage;

  /// No description provided for @expectedBusListTitle.
  ///
  /// In ko, this message translates to:
  /// **'도착 예정 버스 확인'**
  String get expectedBusListTitle;

  /// No description provided for @nextBoardingPredictionLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'다음 탑승 예상 정보를 불러올 수 없습니다.'**
  String get nextBoardingPredictionLoadFailed;

  /// No description provided for @boardableExpected.
  ///
  /// In ko, this message translates to:
  /// **'탑승 가능 예상'**
  String get boardableExpected;

  /// No description provided for @cannotJudge.
  ///
  /// In ko, this message translates to:
  /// **'판단 불가'**
  String get cannotJudge;

  /// No description provided for @boardingDifficult.
  ///
  /// In ko, this message translates to:
  /// **'탑승 어려움'**
  String get boardingDifficult;

  /// No description provided for @afterRecommendedBus.
  ///
  /// In ko, this message translates to:
  /// **'추천 버스 이후 도착'**
  String get afterRecommendedBus;

  /// No description provided for @previousRecommendedBus.
  ///
  /// In ko, this message translates to:
  /// **'이전 예상 버스'**
  String get previousRecommendedBus;

  /// No description provided for @notBoarded.
  ///
  /// In ko, this message translates to:
  /// **'탑승하지 않음'**
  String get notBoarded;

  /// No description provided for @noBoardingDecisionInfo.
  ///
  /// In ko, this message translates to:
  /// **'탑승 판단 정보 없음'**
  String get noBoardingDecisionInfo;

  /// No description provided for @expectedBusArrivedTitle.
  ///
  /// In ko, this message translates to:
  /// **'예상 버스가 도착했어요'**
  String get expectedBusArrivedTitle;

  /// No description provided for @expectedBusArrivedSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'탑승 여부를 선택하면 안내를 이어갈 수 있어요.'**
  String get expectedBusArrivedSubtitle;

  /// No description provided for @boardedCompleteButton.
  ///
  /// In ko, this message translates to:
  /// **'탑승 완료'**
  String get boardedCompleteButton;

  /// No description provided for @checkingNow.
  ///
  /// In ko, this message translates to:
  /// **'확인 중...'**
  String get checkingNow;

  /// No description provided for @stillWaiting.
  ///
  /// In ko, this message translates to:
  /// **'아직 대기 중'**
  String get stillWaiting;

  /// No description provided for @busNumberLabel.
  ///
  /// In ko, this message translates to:
  /// **'{busNumber}번'**
  String busNumberLabel(String busNumber);

  /// No description provided for @arrivalInMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minute}분 후'**
  String arrivalInMinutes(int minute);

  /// No description provided for @timetableLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'시간표를 불러올 수 없습니다.'**
  String get timetableLoadFailed;

  /// No description provided for @timetableEditInfoMissing.
  ///
  /// In ko, this message translates to:
  /// **'수정할 시간표 정보를 찾을 수 없습니다.'**
  String get timetableEditInfoMissing;

  /// No description provided for @selectTimetableToEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정할 시간표를 선택해주세요.'**
  String get selectTimetableToEdit;

  /// No description provided for @selectOneDayToEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정할 요일은 하나만 선택해주세요.'**
  String get selectOneDayToEdit;

  /// No description provided for @classTimeOverlap.
  ///
  /// In ko, this message translates to:
  /// **'{day} 같은 시간대에 이미 수업이 있습니다.'**
  String classTimeOverlap(String day);

  /// No description provided for @timetableUpdated.
  ///
  /// In ko, this message translates to:
  /// **'시간표가 수정되었습니다.'**
  String get timetableUpdated;

  /// No description provided for @timetableUpdateFailed.
  ///
  /// In ko, this message translates to:
  /// **'시간표 수정에 실패했습니다.'**
  String get timetableUpdateFailed;

  /// No description provided for @timetableAdded.
  ///
  /// In ko, this message translates to:
  /// **'시간표가 추가되었습니다.'**
  String get timetableAdded;

  /// No description provided for @timetableAddFailed.
  ///
  /// In ko, this message translates to:
  /// **'시간표 추가에 실패했습니다.'**
  String get timetableAddFailed;

  /// No description provided for @timetableDeleteInfoMissing.
  ///
  /// In ko, this message translates to:
  /// **'삭제할 시간표 정보를 찾을 수 없습니다.'**
  String get timetableDeleteInfoMissing;

  /// No description provided for @queueNoBusInfo.
  ///
  /// In ko, this message translates to:
  /// **'현재 버스 운행 정보가 없어 줄서기를 이용할 수 없어요.'**
  String get queueNoBusInfo;

  /// No description provided for @queueNearStationRequired.
  ///
  /// In ko, this message translates to:
  /// **'정류장 근처에 도착해야 버스 줄서기를 이용할 수 있어요.'**
  String get queueNearStationRequired;

  /// No description provided for @boardingPredictionLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'탑승 예상 정보를 불러올 수 없습니다.'**
  String get boardingPredictionLoadFailed;

  /// No description provided for @nextBus.
  ///
  /// In ko, this message translates to:
  /// **'다음 버스'**
  String get nextBus;

  /// No description provided for @nthBus.
  ///
  /// In ko, this message translates to:
  /// **'{order}번째 버스'**
  String nthBus(int order);

  /// No description provided for @quickReportTitle.
  ///
  /// In ko, this message translates to:
  /// **'지금 {station} 정류장의\n체감 혼잡도는 어떤가요?'**
  String quickReportTitle(String station);

  /// No description provided for @quickReportSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'한 번의 터치로 혼잡도 제보에 참여할 수 있어요'**
  String get quickReportSubtitle;

  /// No description provided for @doLater.
  ///
  /// In ko, this message translates to:
  /// **'나중에 할게요'**
  String get doLater;

  /// No description provided for @quickReportCooldownAgain.
  ///
  /// In ko, this message translates to:
  /// **'{time} 후 다시 제보할 수 있어요.'**
  String quickReportCooldownAgain(String time);

  /// No description provided for @quickReportSuccess.
  ///
  /// In ko, this message translates to:
  /// **'[{station}] {level} 제보가 탑승 예상에 반영되었어요.'**
  String quickReportSuccess(String station, String level);

  /// No description provided for @recommendationReasonTitle.
  ///
  /// In ko, this message translates to:
  /// **'이동 수단 추천 기준'**
  String get recommendationReasonTitle;

  /// No description provided for @wheelchairReservationCount.
  ///
  /// In ko, this message translates to:
  /// **'휠체어 예약자 {count}명'**
  String wheelchairReservationCount(int count);

  /// No description provided for @wheelchairReservationExists.
  ///
  /// In ko, this message translates to:
  /// **'휠체어 예약자 있음'**
  String get wheelchairReservationExists;

  /// No description provided for @reasonNoBusArrival.
  ///
  /// In ko, this message translates to:
  /// **'현재 확인 가능한 버스 도착 정보가 없어, 도보 이동을 함께 고려해 주세요.'**
  String get reasonNoBusArrival;

  /// No description provided for @reasonNoWalkInfo.
  ///
  /// In ko, this message translates to:
  /// **'도보 이동 정보를 확인할 수 없어, 현재 버스 도착 정보를 기준으로 안내합니다.'**
  String get reasonNoWalkInfo;

  /// No description provided for @reasonTooManyWaiting.
  ///
  /// In ko, this message translates to:
  /// **'대기 인원이 많아 가까운 버스 탑승이 어려울 수 있어, 도보 이동을 추천합니다.'**
  String get reasonTooManyWaiting;

  /// No description provided for @reasonBusTimeFits.
  ///
  /// In ko, this message translates to:
  /// **'버스 도착 시간과 다음 수업까지 남은 시간을 기준으로, 버스 이동을 추천합니다.'**
  String get reasonBusTimeFits;

  /// No description provided for @reasonWalkFaster.
  ///
  /// In ko, this message translates to:
  /// **'예상 이동 시간이 더 짧아, 도보 이동을 추천합니다.'**
  String get reasonWalkFaster;

  /// No description provided for @reasonBusTooLate.
  ///
  /// In ko, this message translates to:
  /// **'버스 이동으로는 다음 수업 시간에 맞추기 어려워, 도보 이동을 추천합니다.'**
  String get reasonBusTooLate;

  /// No description provided for @reasonBusFaster.
  ///
  /// In ko, this message translates to:
  /// **'예상 이동 시간이 더 짧아, 버스 이동을 추천합니다.'**
  String get reasonBusFaster;

  /// No description provided for @reasonBusFasterThanWalk.
  ///
  /// In ko, this message translates to:
  /// **'도보 이동보다 버스 이동의 예상 소요 시간이 더 짧아, 버스 이동을 추천합니다.'**
  String get reasonBusFasterThanWalk;

  /// No description provided for @reasonNoNextClassBuilding.
  ///
  /// In ko, this message translates to:
  /// **'다음 수업 건물 정보가 없어, 현재 선택한 정류장의 버스 도착 정보를 기준으로 안내합니다.'**
  String get reasonNoNextClassBuilding;

  /// No description provided for @reasonMainGateEngineeringNoBus.
  ///
  /// In ko, this message translates to:
  /// **'정문에서는 공학관 방향으로 바로 이동할 수 있는 버스 경로가 없어 도보 이동을 추천합니다.'**
  String get reasonMainGateEngineeringNoBus;

  /// No description provided for @reasonNextClassNearStop.
  ///
  /// In ko, this message translates to:
  /// **'다음 수업 건물이 현재 선택한 정류장 근처에 있어 도보 이동을 추천합니다.'**
  String get reasonNextClassNearStop;

  /// No description provided for @reasonNoBusRouteToNextClass.
  ///
  /// In ko, this message translates to:
  /// **'현재 선택한 정류장에서는 다음 수업 건물 방향으로 이용할 수 있는 버스 경로가 없어 도보 이동을 추천합니다.'**
  String get reasonNoBusRouteToNextClass;

  /// No description provided for @reasonBusRouteRecommended.
  ///
  /// In ko, this message translates to:
  /// **'{routeText} 기준의 이동 시간 {minutes}분과 버스 대기 시간을 함께 계산해, 버스 이동을 추천합니다.'**
  String reasonBusRouteRecommended(String routeText, int minutes);

  /// No description provided for @capacityLowFloorAtStation.
  ///
  /// In ko, this message translates to:
  /// **'저상버스 기준 {base}명\n{station} 예상 탑승 가능 {count}명'**
  String capacityLowFloorAtStation(int base, String station, int count);

  /// No description provided for @capacitySeatsAtStation.
  ///
  /// In ko, this message translates to:
  /// **'남은 좌석 {base}석\n{station} 예상 탑승 가능 {count}명'**
  String capacitySeatsAtStation(int base, String station, int count);

  /// No description provided for @ruleMainGate80.
  ///
  /// In ko, this message translates to:
  /// **'정문 80% 탑승 가정 기준 탑승 가능 예상'**
  String get ruleMainGate80;

  /// No description provided for @capacityJeonjeongdae.
  ///
  /// In ko, this message translates to:
  /// **'남은 좌석 45석\n전정대 예상 탑승 인원 {count}명'**
  String capacityJeonjeongdae(int count);

  /// No description provided for @ruleJeonjeongdae.
  ///
  /// In ko, this message translates to:
  /// **'출발 정류장 예상 탑승 인원 기준 탑승 가능 예상'**
  String get ruleJeonjeongdae;

  /// No description provided for @noSeatInfo.
  ///
  /// In ko, this message translates to:
  /// **'좌석 정보를 확인할 수 없습니다'**
  String get noSeatInfo;

  /// No description provided for @ruleMainGateBoardingReflected.
  ///
  /// In ko, this message translates to:
  /// **'정문 예상 탑승 {count}명 반영 후 탑승 가능 예상'**
  String ruleMainGateBoardingReflected(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
