import 'api_service.dart';
import '../models/event.dart';

class EventService {
  static Future<List<Event>> getEvents() async {
    final data = await ApiService.getEvents();
    return data.map((e) => Event.fromJson(e)).toList();
  }

  static Future<bool> addEvent(Event event) async {
    return await ApiService.createEvent(event.toJson());
  }

  static Future<bool> updateEvent(Event event) async {
    try {
      await ApiService.updateEvent(event.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteEvent(int id) async {
    await ApiService.deleteEvent(id);
  }
}
