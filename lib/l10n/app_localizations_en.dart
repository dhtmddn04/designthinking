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
}
