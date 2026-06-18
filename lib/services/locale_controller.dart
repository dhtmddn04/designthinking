import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static const String _languageCodeKey = 'languageCode';

  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(
    const Locale('ko'),
  );

  static Future<void> loadSavedLocale() async {
    final prefs = SharedPreferencesAsync();
    final code = await prefs.getString(_languageCodeKey) ?? 'ko';

    if (code == 'en') {
      localeNotifier.value = const Locale('en');
    } else {
      localeNotifier.value = const Locale('ko');
    }
  }

  static Future<void> setLocale(String code) async {
    if (code != 'ko' && code != 'en') return;

    final prefs = SharedPreferencesAsync();
    await prefs.setString(_languageCodeKey, code);

    localeNotifier.value = Locale(code);
  }

  static String get currentLanguageCode => localeNotifier.value.languageCode;
}
