import 'api_service.dart';

class ProfileService {

  // 👤 GET PROFILE
  static Future<Map<String, dynamic>?> getProfile() async {
    return await ApiService.getProfile();
  }

  // ✏️ UPDATE PROFILE
  static Future<bool> updateProfile(String name, String email) async {
    return await ApiService.updateProfile(name, email);
  }
}