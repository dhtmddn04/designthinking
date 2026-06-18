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
