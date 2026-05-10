import 'api_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> getProfile() async {
    return await ApiService.getProfile();
  }

  static Future<bool> updateProfile(String name, String email) async {
    return await ApiService.updateProfile(name, email);
  }
}
