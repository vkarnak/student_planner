import 'api_service.dart';

class AiService {

  static Future<List> optimize() async {
    return await ApiService.get("/optimize");
  }

  static Future<List> suggestions() async {
    return await ApiService.get("/suggestions");
  }

  static Future<List> autoDistribute() async {
    return await ApiService.post("/auto-distribute", {});
  }
}