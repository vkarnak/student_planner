import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://10.0.2.2:3000";

  static String? token;

  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

  // 👤 PROFILE
  static Future<Map<String, dynamic>?> getProfile() async {
    final res = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return null;
  }

  static Future<bool> updateProfile(
      String name, String email) async {
    final res = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "email": email,
      }),
    );

    return res.statusCode == 200;
  }

  // 📋 TASKS
  static Future<List<dynamic>> getTasks() async {
    final res = await http.get(
      Uri.parse("$baseUrl/tasks"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<void> createTask(Map data) async {
    await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<void> updateTask(Map data) async {
    await http.put(
      Uri.parse("$baseUrl/tasks/${data['id']}"),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteTask(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: headers,
    );
  }

  // 📅 EVENTS
  static Future<List<dynamic>> getEvents() async {
    final res = await http.get(
      Uri.parse("$baseUrl/events"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<void> createEvent(Map data) async {
    await http.post(
      Uri.parse("$baseUrl/events"),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<void> updateEvent(Map data) async {
    await http.put(
      Uri.parse("$baseUrl/events/${data['id']}"),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteEvent(int id) async {
  await http.delete(
    Uri.parse("$baseUrl/events/$id"),
    headers: headers,
  );
}

  // 🧠 SUGGESTIONS
  static Future<List<dynamic>> getSuggestions() async {
    final res = await http.get(
      Uri.parse("$baseUrl/suggestions"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  // ⏰ DEADLINES
  static Future<List<dynamic>> getDeadlines() async {
    final res = await http.get(
      Uri.parse("$baseUrl/deadlines"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }
}