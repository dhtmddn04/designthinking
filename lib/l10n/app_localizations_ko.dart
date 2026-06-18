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
}
