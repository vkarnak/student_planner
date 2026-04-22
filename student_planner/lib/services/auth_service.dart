import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl = "http://10.0.2.2:3000"; // или твой backend

  // 🔐 LOGIN
  static Future<String?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["token"];
    }

    return null;
  }

  // 📝 REGISTER
  static Future<bool> register(
      String email, String password, String name) async {

    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "name": name,
      }),
    );

    return res.statusCode == 200;
  }
}