import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('de')); // German default

  void setLocale(Locale locale) {
    if (['de', 'en', 'ar'].contains(locale.languageCode)) {
      state = locale;
    }
  }

  void setLanguageCode(String code) {
    setLocale(Locale(code));
  }

  bool get isRTL => state.languageCode == 'ar';
}
