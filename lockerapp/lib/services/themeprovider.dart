import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  final String _themeKey = 'theme';
  late Box _box;
  late ThemeData _themeData;

  ThemeProvider() {
    _box = Hive.box('settings');
    _themeData = _box.get(_themeKey, defaultValue: lightTheme) == 'dark'
        ? darkTheme
        : lightTheme;
  }

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData theme) {
    _themeData = theme;
    _box.put(_themeKey, theme == darkTheme ? 'dark' : 'light');
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  appBarTheme: AppBarTheme(
    color: Colors.blue,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // Background color
      foregroundColor: Colors.white, // Text color
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[850],
  appBarTheme: AppBarTheme(
    color: Colors.grey[850],
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[850], // Background color
      foregroundColor: Colors.white, // Text color
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.grey[850],
    foregroundColor: Colors.white,
  ),
);
