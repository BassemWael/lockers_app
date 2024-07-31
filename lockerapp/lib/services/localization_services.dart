import 'package:flutter/material.dart';
import 'package:lockerapp/services/deskstorage.dart';

class LocalizationServices extends ChangeNotifier {
  Locale _locale = Locale('en', 'US'); // Default locale

  Locale get locale => _locale;

  // Initialize localization settings
  Future<void> initLocalization() async {
    String localeCode = await Deskstorage().getLanguage();
    _locale = Locale(localeCode == 'ar' ? 'ar' : 'en', localeCode == 'ar' ? 'EG' : 'US');
    notifyListeners();
  }

  // Change locale and save preference
  void changeLocale(String languageCode) async {
    if (languageCode == 'ar') {
      _locale = Locale('ar', 'EG');
    } else {
      _locale = Locale('en', 'US');
    }
    await Deskstorage().setLanguage(languageCode);
    notifyListeners();
  }
}
