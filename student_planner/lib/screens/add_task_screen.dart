import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final title = TextEditingController();
  final deadline = TextEditingController();

  int priority = 3;
  int duration = 60;

  String? error;
  bool isLoading = false;

  void createTask() async {
    // 🔥 validate
    if (title.text.isEmpty) {
      setState(() => error = "Title required");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final provider = Provider.of<TaskProvider>(context, listen: false);

    final task = Task(
      title: title.text,
      description: "",
      deadline: deadline.text,
      duration: duration,
      priority: priority,
      difficulty: 2,
      status: "pending",
    );

    // 🔥 send request
    await provider.addTask(task);

    setState(() => isLoading = false);

    // 🔥 success + back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Task")),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: deadline,
              decoration: InputDecoration(labelText: "Deadline"),
            ),

            DropdownButton<int>(
              value: priority,
              items: [
                DropdownMenuItem(value: 1, child: Text("Low")),
                DropdownMenuItem(value: 2, child: Text("Medium")),
                DropdownMenuItem(value: 3, child: Text("High")),
                DropdownMenuItem(value: 4, child: Text("Urgent")),
              ],
              onChanged: (v) => setState(() => priority = v!),
            ),

            SizedBox(height: 20),

            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),

            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createTask,
                    child: Text("Create Task"),
                  ),
          ],
        ),
      ),
    );
  }
}
