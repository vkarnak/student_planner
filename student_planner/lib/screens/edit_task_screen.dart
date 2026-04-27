import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final title = TextEditingController();
  final description = TextEditingController();

  DateTime? selectedDeadline;
  Duration selectedDuration = Duration(hours: 1);

  int priority = 3;
  int difficulty = 2;

  bool isLoading = false;
  String? error;

  late Task originalTask;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    originalTask = ModalRoute.of(context)!.settings.arguments as Task;

    title.text = originalTask.title;
    description.text = originalTask.description ?? "";

    if (originalTask.deadline != null) {
      selectedDeadline = DateTime.parse(originalTask.deadline!);
    }

    selectedDuration = Duration(minutes: originalTask.duration ?? 60);
    priority = originalTask.priority;
    difficulty = originalTask.difficulty ?? 2;
  }

  // 📅 дата
  Future<void> pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDeadline = picked);
    }
  }

  // ⏱ время
  Future<void> pickDuration() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: selectedDuration.inHours,
        minute: selectedDuration.inMinutes % 60,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDuration = Duration(hours: picked.hour, minutes: picked.minute);
      });
    }
  }

  // 💾 сохранить
  void save() async {
    if (title.text.isEmpty || selectedDeadline == null) {
      setState(() => error = "Fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final updated = originalTask.copyWith(
      title: title.text,
      description: description.text,
      deadline: selectedDeadline!.toIso8601String(),
      duration: selectedDuration.inMinutes,
      priority: priority,
      difficulty: difficulty,
    );

    await Provider.of<TaskProvider>(context, listen: false).updateTask(updated);

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Not selected";
    return DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // TITLE + DESCRIPTION
          Card(
            child: Padding(
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
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // DEADLINE
          Card(
            child: ListTile(
              title: Text("Deadline"),
              subtitle: Text(formatDate(selectedDeadline)),
              trailing: TextButton(
                onPressed: pickDeadline,
                child: Text("Pick"),
              ),
            ),
          ),

          // DURATION
          Card(
            child: ListTile(
              title: Text("Duration"),
              subtitle: Text(
                "${selectedDuration.inHours}h ${(selectedDuration.inMinutes % 60)}m",
              ),
              trailing: TextButton(
                onPressed: pickDuration,
                child: Text("Pick"),
              ),
            ),
          ),

          // PRIORITY
          Card(
            child: ListTile(
              title: Text("Priority"),
              trailing: DropdownButton<int>(
                value: priority,
                items: [
                  DropdownMenuItem(value: 1, child: Text("Low")),
                  DropdownMenuItem(value: 2, child: Text("Medium")),
                  DropdownMenuItem(value: 3, child: Text("High")),
                  DropdownMenuItem(value: 4, child: Text("Urgent")),
                ],
                onChanged: (v) => setState(() => priority = v!),
              ),
            ),
          ),

          // DIFFICULTY
          Card(
            child: ListTile(
              title: Text("Difficulty"),
              trailing: DropdownButton<int>(
                value: difficulty,
                items: [
                  DropdownMenuItem(value: 1, child: Text("Easy")),
                  DropdownMenuItem(value: 2, child: Text("Medium")),
                  DropdownMenuItem(value: 3, child: Text("Hard")),
                  DropdownMenuItem(value: 4, child: Text("Very Hard")),
                ],
                onChanged: (v) => setState(() => difficulty = v!),
              ),
            ),
          ),

          SizedBox(height: 20),

          if (error != null) Text(error!, style: TextStyle(color: Colors.red)),

          isLoading
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(onPressed: save, child: Text("Save")),
        ],
      ),
    );
  }
}
