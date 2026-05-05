import 'dart:async';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../models/suggestion.dart';
import '../services/ai_scheduler.dart';

import 'task_provider.dart';
import 'event_provider.dart';
import 'settings_provider.dart'; // 👈 добавили

class AiProvider with ChangeNotifier {
  List<Suggestion> _suggestions = [];
  List<Suggestion> get suggestions => List.unmodifiable(_suggestions);

  late TaskProvider _taskProvider;
  late EventProvider _eventProvider;
  late SettingsProvider _settingsProvider; // 👈 добавили

  Timer? _debounce;
  bool _isBound = false;
  bool _isGenerating = false;

  /// 🔗 ПОДКЛЮЧЕНИЕ
  void bind(
    TaskProvider taskProvider,
    EventProvider eventProvider,
    SettingsProvider settingsProvider, // 👈 добавили
  ) {
    if (_isBound) return;

    _taskProvider = taskProvider;
    _eventProvider = eventProvider;
    _settingsProvider = settingsProvider;

    _taskProvider.addListener(_onDataChanged);
    _eventProvider.addListener(_onDataChanged);
    _settingsProvider.addListener(_onDataChanged); // 👈 важно!

    _isBound = true;

    _regenerate();
  }

  /// 🔄 КОГДА ЧТО-ТО ИЗМЕНИЛОСЬ
  void _onDataChanged() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _regenerate();
    });
  }

  /// ❌ УДАЛЕНИЕ
  void removeSuggestion(Suggestion s) {
    _suggestions.remove(s);
    notifyListeners();
  }

  /// 🧹 ОЧИСТКА
  void clear() {
    _suggestions = [];
    notifyListeners();
  }

  /// 🧠 ПЕРЕСЧЁТ
  Future<void> _regenerate() async {
    if (_isGenerating) return;

    _isGenerating = true;

    try {
      final newSuggestions = AiScheduler.generate(
        _taskProvider.tasks,
        _eventProvider.events,
      );

      _suggestions = newSuggestions;

      await NotificationService.cancelAll();

      final settings = _settingsProvider.settings;

      List<Future> futures = [];

      if (settings.dailyPlan) {
        futures.add(
          NotificationService.scheduleDailyPlan(
            _eventProvider.events,
            _suggestions,
          ),
        );
      }

      if (settings.deadlines) {
        futures.add(NotificationService.scheduleDeadlines(_taskProvider.tasks));
      }

      if (settings.aiSuggestions) {
        futures.add(NotificationService.scheduleAISuggestions(_suggestions));
      }

      await Future.wait(futures);

      notifyListeners();
    } finally {
      _isGenerating = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();

    if (_isBound) {
      _taskProvider.removeListener(_onDataChanged);
      _eventProvider.removeListener(_onDataChanged);
      _settingsProvider.removeListener(_onDataChanged); // 👈 важно
    }

    super.dispose();
  }
}
