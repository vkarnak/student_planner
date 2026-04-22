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

  Future<void> addEvent(Event event) async {
    await EventService.addEvent(event);
    await loadEvents();
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