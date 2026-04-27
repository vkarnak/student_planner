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
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? error;
  bool isLoading = false;

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

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void createEvent() async {
    // 🔥 validate
    if (title.text.isEmpty || selectedDate == null || selectedTime == null) {
      setState(() => error = "Fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final provider = Provider.of<EventProvider>(context, listen: false);

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final event = Event(title: title.text, date: dateTime.toIso8601String());

    final success = await provider.addEvent(event);

    setState(() => isLoading = false);

    if (!success) {
      setState(() => error = "Failed to create event");
      return;
    }

    Navigator.pop(context);
  }

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

            Row(
              children: [
                Text(
                  selectedDate == null
                      ? "No date"
                      : "${selectedDate!.toLocal()}".split(' ')[0],
                ),
                Spacer(),
                TextButton(onPressed: pickDate, child: Text("Pick date")),
              ],
            ),

            Row(
              children: [
                Text(
                  selectedTime == null
                      ? "No time"
                      : selectedTime!.format(context),
                ),
                Spacer(),
                TextButton(onPressed: pickTime, child: Text("Pick time")),
              ],
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
