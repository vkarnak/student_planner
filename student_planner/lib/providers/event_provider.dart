import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  List<Event> events = [];
  bool isLoading = false;

  Future<void> loadEvents() async {
    isLoading = true;
    notifyListeners();

    try {
      events = await EventService.getEvents();
    } catch (e) {
      events = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addEvent(Event event) async {
    final success = await EventService.addEvent(event);

    if (success) {
      await loadEvents();
      return true;
    }

    return false;
  }

  Future<void> updateEvent(Event event) async {
    await EventService.updateEvent(event);
    await loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    await EventService.deleteEvent(id);
    await loadEvents();
  }
}
