import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile(this.task, {super.key});

  Color getColor() {
    switch (task.priority) {
      case 4:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(radius: 6, backgroundColor: getColor()),

      title: Text(task.title),

      subtitle: Text("Due: ${task.deadline}"),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✏️ EDIT
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, "/edit", arguments: task);
            },
          ),

          // ❌ DELETE
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Delete task"),
                  content: Text("Are you sure?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text("Delete"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).deleteTask(task.id!);
              }
            },
          ),

          // ✅ DONE / UNDONE
          IconButton(
            icon: Icon(
              task.status == "done"
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: task.status == "done" ? Colors.green : null,
            ),
            onPressed: () {
              // дальше добавим toggle
            },
          ),
        ],
      ),
    );
  }
}
