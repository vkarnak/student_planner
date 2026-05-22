import 'dart:async';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../models/suggestion.dart';
import '../services/ai_scheduler.dart';

import 'task_provider.dart';
import 'event_provider.dart';
import 'settings_provider.dart';

class AiProvider with ChangeNotifier {
  List<Suggestion> _suggestions = [];
  List<Suggestion> get suggestions => List.unmodifiable(_suggestions);

  late TaskProvider _taskProvider;
  late EventProvider _eventProvider;
  late SettingsProvider _settingsProvider;

  Timer? _debounce;
  bool _isBound = false;
  bool _isGenerating = false;

  final Map<String, DateTime> _manualSuggestions = {};

  void bind(
    TaskProvider taskProvider,
    EventProvider eventProvider,
    SettingsProvider settingsProvider,
  ) {
    if (_isBound) return;

    _taskProvider = taskProvider;
    _eventProvider = eventProvider;
    _settingsProvider = settingsProvider;

    _taskProvider.addListener(_onDataChanged);
    _eventProvider.addListener(_onDataChanged);
    _settingsProvider.addListener(_onDataChanged);

    _isBound = true;

    _regenerate();
  }

  void _onDataChanged() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _regenerate();
    });
  }

  void removeSuggestion(Suggestion s) {
    _suggestions.remove(s);
    notifyListeners();
  }

  Future<void> updateSuggestion(
    Suggestion oldSuggestion,
    DateTime newStart,
  ) async {
    _manualSuggestions[oldSuggestion.id] = newStart;

    await _regenerate();
  }

  void clear() {
    _suggestions = [];
    notifyListeners();
  }

  Future<void> _regenerate() async {
    if (_isGenerating) return;

    _isGenerating = true;

    try {
      final newSuggestions = AiScheduler.generate(
        _taskProvider.tasks,
        _eventProvider.events,
      );

      for (int i = 0; i < newSuggestions.length; i++) {
        final s = newSuggestions[i];

        if (_manualSuggestions.containsKey(s.id)) {
          final newStart = _manualSuggestions[s.id]!;

          final duration = s.end.difference(s.start);

          newSuggestions[i] = Suggestion(
            id: s.id,
            taskId: s.taskId,
            title: s.title,
            start: newStart,
            end: newStart.add(duration),
          );
        }
      }

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
      _settingsProvider.removeListener(_onDataChanged);
    }

    super.dispose();
  }
}
