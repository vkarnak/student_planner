import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  // 🔐 LOGIN
  static Future<String?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["token"];
    }

    return null;
  }

  // 📝 REGISTER
  static Future<bool> register(
    String email,
    String password,
    String name,
  ) async {
    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password, "name": name}),
    );

    return res.statusCode == 200;
  }
}
