import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode;
  Color _seedColor;

  ThemeProvider(this._isDarkMode, this._seedColor);

  bool get isDarkMode => _isDarkMode;
  Color get seedColor => _seedColor;

  static Future<ThemeProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('darkMode') ?? false;
    final seedColorValue = prefs.getInt('seedColor') ?? Colors.indigo.value;
    return ThemeProvider(isDarkMode, Color(seedColorValue));
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleSeedColor(Color color) async {
    _seedColor = color;
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setInt('seedColor', color.value);
    notifyListeners();
  }
}
