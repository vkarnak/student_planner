import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<TaskProvider>(context, listen: false).loadTasks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Today")),

      body: taskProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : taskProvider.tasks.isEmpty
          ? Center(child: Text("No tasks yet"))
          : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];

                return Dismissible(
                  key: Key(task.id.toString()),
                  direction: DismissDirection.endToStart,

                  confirmDismiss: (_) async {
                    return await showDialog(
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
                  },

                  onDismissed: (_) {
                    taskProvider.deleteTask(task.id!);

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Task deleted")));
                  },

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),

                  child: TaskTile(task),
                );
              },
            ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "event",
            onPressed: () {
              Navigator.pushNamed(context, "/add_event");
            },
            child: Icon(Icons.event),
          ),

          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "task",
            onPressed: () {
              Navigator.pushNamed(context, "/add");
            },
            child: Icon(Icons.add),
          ),

          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "suggestions",
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.pushNamed(context, "/suggestions");
            },
            child: Icon(Icons.lightbulb),
          ),

          // 🤖 AI кнопка
          FloatingActionButton(
            heroTag: "ai",
            backgroundColor: Colors.purple,
            onPressed: () {
              Navigator.pushNamed(context, "/schedule"); // 👉 отдельный экран
            },
            child: Icon(Icons.auto_awesome),
          ),
        ],
      ),
    );
  }
}
