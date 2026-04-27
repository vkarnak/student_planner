import 'api_service.dart';
import '../models/event.dart';

class EventService {
  // 📅 GET EVENTS
  static Future<List<Event>> getEvents() async {
    final data = await ApiService.getEvents();

    return data.map((e) => Event.fromJson(e)).toList();
  }

  // ➕ ADD EVENT
  static Future<bool> addEvent(Event event) async {
    return await ApiService.createEvent(event.toJson());
  }

  // ✏️ UPDATE EVENT
  static Future<void> updateEvent(Event event) async {
    await ApiService.updateEvent(event.toJson());
  }

  // ❌ DELETE EVENT
  static Future<void> deleteEvent(int id) async {
    await ApiService.deleteEvent(id);
  }
}
