import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuggestionProvider extends ChangeNotifier {
  List<dynamic> suggestions = [];
  bool isLoading = false;

  Future<void> loadSuggestions() async {
    isLoading = true;
    notifyListeners();

    try {
      suggestions = await ApiService.getSuggestions();
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }
}