import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';

class SettingsProvider with ChangeNotifier {
  UserSettings _settings = const UserSettings();
  bool _isLoaded = false;

  UserSettings get settings => _settings;
  bool get isLoaded => _isLoaded;

  // ================= LOAD =================
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("settings");

    if (data != null) {
      _settings = UserSettings.fromJson(jsonDecode(data));
    }

    _isLoaded = true;
    notifyListeners();
  }

  // ================= SAVE =================
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("settings", jsonEncode(_settings.toJson()));
  }

  // ================= TOGGLES =================

  void toggleDailyPlan(bool value) {
    if (_settings.dailyPlan == value) return;

    _settings = _settings.copyWith(dailyPlan: value);
    _save();
    notifyListeners();
  }

  void toggleDeadlines(bool value) {
    if (_settings.deadlines == value) return;

    _settings = _settings.copyWith(deadlines: value);
    _save();
    notifyListeners();
  }

  void toggleAi(bool value) {
    if (_settings.aiSuggestions == value) return;

    _settings = _settings.copyWith(aiSuggestions: value);
    _save();
    notifyListeners();
  }
}
