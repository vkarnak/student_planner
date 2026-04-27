import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final title = TextEditingController();
  final description = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String? error;
  bool isLoading = false;

  // 📅 DATE
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ⏰ START
  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  // ⏰ END
  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

  void createEvent() async {
    if (title.text.isEmpty ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      setState(() => error = "Fill all fields");
      return;
    }

    final start = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final end = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (end.isBefore(start)) {
      setState(() => error = "End time must be after start time");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final provider = Provider.of<EventProvider>(context, listen: false);

    final event = Event(
      title: title.text,
      start: start,
      end: end,
      description: description.text,
    );
    final success = await provider.addEvent(event);

    setState(() => isLoading = false);

    if (!success) {
      setState(() => error = "Failed to create event");
      return;
    }

    Navigator.pop(context);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Event")),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 10),

            TextField(
              controller: description,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 2,
            ),

            // 📅 DATE
            ListTile(
              title: Text("Date"),
              subtitle: Text(
                selectedDate == null
                    ? "Not selected"
                    : "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
              ),
              trailing: TextButton(onPressed: pickDate, child: Text("Pick")),
            ),

            // ⏰ START
            ListTile(
              title: Text("Start"),
              subtitle: Text(
                startTime == null ? "Not selected" : startTime!.format(context),
              ),
              trailing: TextButton(
                onPressed: pickStartTime,
                child: Text("Pick"),
              ),
            ),

            // ⏰ END
            ListTile(
              title: Text("End"),
              subtitle: Text(
                endTime == null ? "Not selected" : endTime!.format(context),
              ),
              trailing: TextButton(onPressed: pickEndTime, child: Text("Pick")),
            ),

            SizedBox(height: 20),

            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createEvent,
                    child: Text("Create Event"),
                  ),
          ],
        ),
      ),
    );
  }
}
