import 'dart:async';
import 'package:flutter/material.dart';

import '../models/suggestion.dart';
import '../models/task.dart';
import '../models/event.dart';
import '../services/ai_scheduler.dart';

import 'task_provider.dart';
import 'event_provider.dart';

class AiProvider with ChangeNotifier {
  List<Suggestion> suggestions = [];

  late TaskProvider _taskProvider;
  late EventProvider _eventProvider;

  Timer? _debounce;

  /// 🔗 ПОДКЛЮЧЕНИЕ
  void bind(TaskProvider taskProvider, EventProvider eventProvider) {
    _taskProvider = taskProvider;
    _eventProvider = eventProvider;

    /// слушаем задачи
    _taskProvider.addListener(_onDataChanged);

    /// слушаем события
    _eventProvider.addListener(_onDataChanged);

    /// первая генерация
    _regenerate();
  }

  /// 🔄 КОГДА ЧТО-ТО ИЗМЕНИЛОСЬ
  void _onDataChanged() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _regenerate();
    });
  }

  /// 🧠 ПЕРЕСЧЁТ
  void _regenerate() {
    suggestions = AiScheduler.generate(
      _taskProvider.tasks,
      _eventProvider.events,
    );

    notifyListeners();
  }

  /// ❌ УДАЛЕНИЕ
  void removeSuggestion(Suggestion s) {
    suggestions.remove(s);
    notifyListeners();
  }

  /// 🧹 ОЧИСТКА
  void clear() {
    suggestions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _taskProvider.removeListener(_onDataChanged);
    _eventProvider.removeListener(_onDataChanged);

    super.dispose();
  }
}
