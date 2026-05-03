import 'package:flutter/material.dart';
import 'package:student_planner/models/suggestion.dart';
import 'package:student_planner/services/api_service.dart';

class AiProvider with ChangeNotifier {
  List<Suggestion> suggestions = [];

  Future<void> loadSuggestions() async {
    final data = await ApiService.getAiSuggestions();

    suggestions = data.map((e) => Suggestion.fromJson(e)).toList();
    notifyListeners();
  }

  void removeSuggestion(Suggestion s) {
    suggestions.remove(s);
    notifyListeners();
  }
}
