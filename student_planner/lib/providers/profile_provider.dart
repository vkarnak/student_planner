import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {

  Map? user;
  bool isLoading = false;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    user = await ApiService.getProfile();

    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String email) async {

    // 🔥 d. validate input
    if (name.isEmpty || email.isEmpty) {
      return false;
    }

    await ApiService.updateProfile(name, email);

    // 🔥 i. refresh UI
    await loadProfile();

    return true;
  }
}