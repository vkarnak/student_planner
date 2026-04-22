import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/task.dart';

class ScheduleService {

  static Future<List<Task>> getSchedule() async {
    final res = await http.get(
      Uri.parse("${ApiService.baseUrl}/schedule"),
      headers: ApiService.headers,
    );

    final data = jsonDecode(res.body) as List;

    return data.map((e) => Task.fromJson(e)).toList();
  }
}