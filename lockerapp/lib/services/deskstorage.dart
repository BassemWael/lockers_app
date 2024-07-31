import 'package:hive/hive.dart';

class Deskstorage {
  // Save language preference
  Future<void> setLanguage(String language) async {
    var hivebox = await Hive.openBox('localization');
    await hivebox.put('language', language);
  }

  // Retrieve language preference
  Future<String> getLanguage() async {
    var hivebox = await Hive.openBox('localization');
    return hivebox.get('language', defaultValue: 'en');
  }
}
