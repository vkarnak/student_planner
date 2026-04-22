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

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isLoading = false;
  String? error;

  late Event original;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    original = ModalRoute.of(context)!.settings.arguments as Event;

    title = TextEditingController(text: original.title);

    final dt = DateTime.parse(original.date);
    selectedDate = dt;
    selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

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

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime!,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void save() async {
    if (title.text.isEmpty || selectedDate == null || selectedTime == null) {
      setState(() => error = "Fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final updated = Event(
      id: original.id,
      title: title.text,
      date: dateTime.toIso8601String(),
    );

    await Provider.of<EventProvider>(
      context,
      listen: false,
    ).updateEvent(updated);

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

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

            Row(
              children: [
                Text("${selectedDate!.toLocal()}".split(' ')[0]),
                Spacer(),
                TextButton(onPressed: pickDate, child: Text("Change date")),
              ],
            ),

            Row(
              children: [
                Text(selectedTime!.format(context)),
                Spacer(),
                TextButton(onPressed: pickTime, child: Text("Change time")),
              ],
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
