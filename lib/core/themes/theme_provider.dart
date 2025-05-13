import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deepseek/presentation/bloc/settings/settings_bloc.dart'; // For AppTheme enum

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppTheme _appTheme = AppTheme.system;

  ThemeMode get themeMode => _themeMode;
  AppTheme get appTheme => _appTheme;

  // Add getters for the themes
  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme') ?? 'system';
    _appTheme = AppTheme.values.firstWhere((e) => e.toString().split('.').last == themeName, orElse: () => AppTheme.system);
    _setThemeModeFromAppTheme(_appTheme);
    notifyListeners();
  }

  void setTheme(AppTheme theme) async {
    if (_appTheme == theme) return;

    _appTheme = theme;
    _setThemeModeFromAppTheme(theme);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.toString().split('.').last);
    notifyListeners();
  }

  void _setThemeModeFromAppTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        _themeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppTheme.system:
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }
}

// Define your ThemeData if not already defined elsewhere
final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF3D71ED),
  highlightColor: const Color(0xFFDBEAFE)
  
  // Add other light theme properties
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  // Add other dark theme properties
);
