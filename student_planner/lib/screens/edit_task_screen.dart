import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController title;
  late TextEditingController deadline;

  int priority = 3;

  bool isLoading = false;
  String? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final task = ModalRoute.of(context)!.settings.arguments as Task;

    title = TextEditingController(text: task.title);
    deadline = TextEditingController(text: task.deadline);
    priority = task.priority;
  }

  void save(Task original) async {
    if (title.text.isEmpty) {
      setState(() => error = "Title required");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final updated = original.copyWith(
      title: title.text,
      deadline: deadline.text,
      priority: priority,
    );

    await Provider.of<TaskProvider>(context, listen: false).updateTask(updated);

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as Task;

    return Scaffold(
      appBar: AppBar(title: Text("Edit Task")),
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
                    onPressed: () => save(task),
                    child: Text("Save"),
                  ),
          ],
        ),
      ),
    );
  }
}
