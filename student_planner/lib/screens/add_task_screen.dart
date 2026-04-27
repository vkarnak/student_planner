import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:flutter/cupertino.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final title = TextEditingController();
  final description = TextEditingController();

  DateTime? selectedDeadline;
  Duration selectedDuration = Duration(hours: 1);

  int priority = 3;
  int difficulty = 2;

  String? error;
  bool isLoading = false;

  // 📅 PICK DEADLINE
  Future<void> pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDeadline = picked);
    }
  }

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

  // 🚀 CREATE TASK
  void createTask() async {
    if (title.text.isEmpty || selectedDeadline == null) {
      setState(() => error = "Fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final provider = Provider.of<TaskProvider>(context, listen: false);

    final task = Task(
      title: title.text,
      description: description.text,
      deadline: selectedDeadline!.toIso8601String(),
      duration: selectedDuration.inMinutes,
      priority: priority,
      difficulty: difficulty,
      status: "pending",
    );

    await provider.addTask(task);

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Task")),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 📌 TITLE + DESCRIPTION
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
                    decoration: InputDecoration(labelText: "Description"),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // 📅 DEADLINE
          Card(
            child: ListTile(
              title: Text("Deadline"),
              subtitle: Text(
                selectedDeadline == null
                    ? "Not selected"
                    : selectedDeadline!.toLocal().toString().split(' ')[0],
              ),
              trailing: TextButton(
                onPressed: pickDeadline,
                child: Text("Pick"),
              ),
            ),
          ),

          // ⏱ DURATION
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

          // ⚡ PRIORITY
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

          // 🧠 DIFFICULTY
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

          ElevatedButton(onPressed: createTask, child: Text("Create Task")),
        ],
      ),
    );
  }
}
