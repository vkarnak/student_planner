import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController title;
  late TextEditingController description;

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isLoading = false;
  String? error;

  late Event original;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      original = ModalRoute.of(context)!.settings.arguments as Event;

      title = TextEditingController(text: original.title);
      description = TextEditingController(text: original.description ?? "");

      selectedDate = original.start;

      startTime = TimeOfDay(
        hour: original.start.hour,
        minute: original.start.minute,
      );

      endTime = TimeOfDay(hour: original.end.hour, minute: original.end.minute);

      _isInit = true;
    }

    super.didChangeDependencies();
  }

  // 📅 DATE
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
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
      initialTime: startTime!,
    );

    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  // ⏰ END
  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime!,
    );

    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

  void save() async {
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

    final updated = Event(
      id: original.id,
      title: title.text,
      start: start,
      end: end,
      description: description.text,
    );

    await Provider.of<EventProvider>(
      context,
      listen: false,
    ).updateEvent(updated);

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Event")),

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
                : ElevatedButton(onPressed: save, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
