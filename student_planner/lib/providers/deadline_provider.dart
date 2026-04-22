import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeadlineProvider extends ChangeNotifier {

  List items = [];
  bool isLoading = false;

  Future<void> loadDeadlines() async {
    isLoading = true;
    notifyListeners();

    items = await ApiService.getDeadlines();

    isLoading = false;
    notifyListeners();
  }
}